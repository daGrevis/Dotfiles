#!/bin/bash
#
# floodlight-keepalive.sh
#
# Keeps a UniFi Protect floodlight ON while a camera is detecting activity,
# and turns it OFF once there have been no events for a hold window.
#
# HOW IT WORKS (short version):
#   - READ side  : polls the Protect Postgres DB directly (no API key needed)
#                  for recent rows in the `events` table.
#   - WRITE side : toggles the floodlight over Protect's INTERNAL REST API using
#                  the localhost-trust `x-userid` header (no API key needed).
#                  A raw DB write can NOT toggle the light -- the device command
#                  is only emitted from the in-process save path, so we must go
#                  through HTTP.
#
# See floodlight-keepalive.md for the full explanation.
#
# Requires: bash, psql, curl. Run on the Protect host, inside the container
# network namespace (e.g. after `unifi-os shell`) so 127.0.0.1:7080 and the
# postgres socket are reachable.

set -u

# ---------------------------------------------------------------------------
# Defaults (override via flags)
# ---------------------------------------------------------------------------
MAC=""                                   # -m  floodlight MAC (required)
POLL_INTERVAL=30                         # -i  seconds between DB polls while idle/off
HOLD_WINDOW=300                          # -w  seconds of silence before OFF (5 min)
MAX_LEVEL=6                              # -b  brightness right after an event (1-6)
MIN_LEVEL=1                              # -B  brightness just before OFF (1-6)
BASE_URL="http://127.0.0.1:7080"         # -u  Protect API base (script appends /api/...)
USER_ID=""                               # -U  x-userid identity id (auto if empty)
CAMERA_MACS=""                           # -c  comma-separated camera MACs that may trigger (empty = all)
SMART_CLASSES="person,animal"            # -s  smartDetect classes to react to (motion is always included)
PSQL_BIN="psql"                          # -P  psql command (e.g. "sudo -u unifi-protect psql")
PG_CONN="postgresql://unifi-protect@/unifi-protect?host=/var/run/postgresql&port=5433"  # -C
DRY_RUN=0                                # -n  log decisions, never PATCH

usage() {
  cat <<'EOF'
Usage: floodlight-keepalive.sh -m <floodlight-mac> [options]

Required:
  -m MAC        Floodlight MAC address (e.g. 74ACB9XXXXXX or 74:ac:b9:xx:xx:xx)

Options:
  -i SECONDS    Idle poll interval, used only while the light is off/idle
                (default 30). While the light is on, the script sleeps until
                the next brightness-ramp boundary instead.
  -w SECONDS    Hold window / off delay (default 300 = 5 min)
  -b LEVEL      Max brightness after an event, 1-6 (default 6)
  -B LEVEL      Min brightness before OFF, 1-6   (default 1)
  -u URL        API base URL           (default http://127.0.0.1:7080)
                Must be the internal port; the /proxy/protect path ignores
                x-userid and returns 401.
  -U ID         x-userid identity id   (default: console owner's identity)
                Must map to a user with device write permission (owner/admin),
                or the light PATCH returns 403. Find one with:
                  psql ... -Atc 'SELECT ui.id FROM "ucoreIdentities" ui
                    JOIN users u ON u.id=ui."userId" WHERE u."isOwner";'
  -c MACS       Comma-separated camera MACs that may trigger the light
                (default: all cameras). Strongly recommended -- it also lets the
                activity query use the (cameraId,start,end) index.
  -s CLASSES    Comma-separated smartDetect classes to react to
                (default: person,animal). "motion" events always count too.
                Pass -s "" to react to motion only.
  -P CMD        psql command           (default "psql"; e.g. "sudo -u unifi-protect psql")
  -C CONNSTR    Postgres connection string
  -n            Dry run (decide + log, but never toggle the light)
  -h            Show this help

Example:
  ./floodlight-keepalive.sh -m 74ACB9AABBCC -w 300 -c AABBCC001122,AABBCC334455 -s person,animal
EOF
}

while getopts ":m:i:w:b:B:u:U:c:s:P:C:nh" opt; do
  case "$opt" in
    m) MAC="$OPTARG" ;;
    i) POLL_INTERVAL="$OPTARG" ;;
    w) HOLD_WINDOW="$OPTARG" ;;
    b) MAX_LEVEL="$OPTARG" ;;
    B) MIN_LEVEL="$OPTARG" ;;
    u) BASE_URL="$OPTARG" ;;
    U) USER_ID="$OPTARG" ;;
    c) CAMERA_MACS="$OPTARG" ;;
    s) SMART_CLASSES="$OPTARG" ;;
    P) PSQL_BIN="$OPTARG" ;;
    C) PG_CONN="$OPTARG" ;;
    n) DRY_RUN=1 ;;
    h) usage; exit 0 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "Option -$OPTARG needs an argument" >&2; exit 2 ;;
  esac
done

if [ -z "$MAC" ]; then
  echo "ERROR: floodlight MAC (-m) is required" >&2
  usage
  exit 2
fi

# ledLevel is an integer 1-6 (validated by Protect); MIN must not exceed MAX.
case "$MAX_LEVEL" in [1-6]) ;; *) echo "ERROR: -b must be an integer 1-6" >&2; exit 2 ;; esac
case "$MIN_LEVEL" in [1-6]) ;; *) echo "ERROR: -B must be an integer 1-6" >&2; exit 2 ;; esac
if [ "$MIN_LEVEL" -gt "$MAX_LEVEL" ]; then
  echo "ERROR: -B (min ${MIN_LEVEL}) cannot exceed -b (max ${MAX_LEVEL})" >&2
  exit 2
fi

# Normalize MAC: strip separators, uppercase (DB stores bare uppercase hex).
norm_mac() { echo "$1" | tr -d ':-' | tr '[:lower:]' '[:upper:]'; }

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }

# Run a single-value SQL query, print the trimmed scalar result.
pg() { $PSQL_BIN "$PG_CONN" -Atq -c "$1"; }

MAC_NORM="$(norm_mac "$MAC")"

# ---------------------------------------------------------------------------
# Resolve identifiers up-front; fail fast on bad config.
# ---------------------------------------------------------------------------
LIGHT_ID="$(pg "SELECT id FROM lights WHERE upper(replace(replace(mac,':',''),'-','')) = '${MAC_NORM}' LIMIT 1;")"
if [ -z "$LIGHT_ID" ]; then
  log "ERROR: no light found for MAC ${MAC} (looked up ${MAC_NORM}). Check -m / DB access."
  exit 1
fi

if [ -z "$USER_ID" ]; then
  # The PATCH route needs DEVICE_SETTINGS_EDIT / WRITE. Prefer the console
  # owner's identity, which always has it. Fall back to the first identity
  # only if no owner exists (and warn -- it may 403).
  USER_ID="$(pg 'SELECT ui.id FROM "ucoreIdentities" ui JOIN users u ON u.id = ui."userId" WHERE u."isOwner" = true ORDER BY ui."createdAt" LIMIT 1;')"
  if [ -n "$USER_ID" ]; then
    log "using owner identity ${USER_ID} (auto)"
  else
    USER_ID="$(pg 'SELECT id FROM "ucoreIdentities" ORDER BY "createdAt" LIMIT 1;')"
    log "WARN: no owner identity found; using first identity ${USER_ID}. It may lack DEVICE_SETTINGS_EDIT and cause a 403. Pass an admin identity with -U."
  fi
fi
if [ -z "$USER_ID" ]; then
  log "ERROR: could not resolve an x-userid identity. Pass one with -U."
  exit 1
fi

# Optional camera filter: resolve MACs -> ids, build a pg array literal.
CAM_CLAUSE=""
if [ -n "$CAMERA_MACS" ]; then
  cam_norm="$(echo "$CAMERA_MACS" | tr ',' '\n' | while read -r m; do norm_mac "$m"; done | paste -sd, -)"
  # Turn the comma list into a quoted SQL IN-list of MACs, resolve to ids.
  mac_in="$(echo "$cam_norm" | sed "s/[^,]*/'&'/g")"
  cam_ids="$(pg "SELECT string_agg(id, ',') FROM cameras WHERE upper(replace(replace(mac,':',''),'-','')) IN (${mac_in});")"
  if [ -z "$cam_ids" ]; then
    log "ERROR: none of the camera MACs (${CAMERA_MACS}) matched a camera."
    exit 1
  fi
  CAM_CLAUSE="AND \"cameraId\" = ANY('{${cam_ids}}')"
fi

# Trigger filter: a 'motion' event, OR a smartDetect event carrying one of the
# requested classes (person/animal/...). smartDetectTypes is JSON, so cast to
# jsonb for jsonb_exists_any.
if [ -n "$SMART_CLASSES" ]; then
  classes_sql="'$(echo "$SMART_CLASSES" | sed "s/,/','/g")'"
  TRIGGER_CLAUSE="AND (type = 'motion' OR jsonb_exists_any(\"smartDetectTypes\"::jsonb, ARRAY[${classes_sql}]))"
else
  TRIGGER_CLAUSE="AND type = 'motion'"
fi

# curl base opts: -k is harmless on http, needed for the self-signed proxy on https.
CURL="curl -sk --max-time 10"

# PATCH the floodlight. $1 = json body.
patch_light() {
  local body="$1"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY-RUN: would PATCH ${body}"
    return 0
  fi
  local code
  code="$($CURL -o /dev/null -w '%{http_code}' -X PATCH \
    "${BASE_URL}/api/lights/${LIGHT_ID}" \
    -H "x-userid: ${USER_ID}" \
    -H 'Content-Type: application/json' \
    -d "$body")"
  if [ "$code" = "200" ] || [ "$code" = "204" ]; then
    return 0
  fi
  log "WARN: light PATCH returned HTTP ${code} (state not applied)"
  return 1
}

# The device drops the force-on override by itself after ~30-60s (observed; the
# ledDuration field does not persist via this API, it reads back 0). So while the
# light is on we never sleep longer than this many seconds without re-asserting
# it -- keep it safely under the observed auto-off.
REFRESH_MAX=20

# Turn on at brightness $1 (1-6). Sets ledLevel and forces the light on. Called
# on every active poll (not just on change) so it also refreshes the force-on
# before the device's auto-off can fire.
light_on() {
  patch_light "{\"lightDeviceSettings\":{\"ledLevel\":$1},\"lightOnSettings\":{\"isLedForceOn\":true}}"
}

# Release the force-on override (light returns to its configured/off mode).
light_off() {
  patch_light '{"lightOnSettings":{"isLedForceOn":false}}'
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
LAST_STATE=""    # "on" | "off" | "" (unknown -> force first apply)
LAST_LEVEL=""    # last brightness pushed while on

cleanup() { log "stopping (light left in '${LAST_STATE:-unknown}' state)"; exit 0; }
trap cleanup INT TERM

log "watching light=${LIGHT_ID} mac=${MAC_NORM} idlePoll=${POLL_INTERVAL}s hold=${HOLD_WINDOW}s bright=${MAX_LEVEL}->${MIN_LEVEL} cameras=${CAMERA_MACS:-ALL} classes=${SMART_CLASSES:-motion-only} dry=${DRY_RUN}"

hold_ms=$(( HOLD_WINDOW * 1000 ))
range=$(( MAX_LEVEL - MIN_LEVEL ))

while true; do
  now_ms=$(( $(date +%s) * 1000 ))
  cutoff_ms=$(( now_ms - hold_ms ))

  # Start time of the most recent qualifying event inside the hold window.
  # ORDER BY "start" DESC LIMIT 1 rides the (cameraId,start,end) index; the outer
  # COALESCE guarantees a single row (0 = no recent event) so empty output
  # unambiguously means the query itself failed.
  last_ms="$(pg "SELECT COALESCE((
      SELECT \"start\" FROM events
      WHERE \"start\" > ${cutoff_ms}
        AND \"deletedAt\" IS NULL
        ${CAM_CLAUSE}
        ${TRIGGER_CLAUSE}
      ORDER BY \"start\" DESC
      LIMIT 1), 0);")"

  if [ -z "$last_ms" ]; then
    log "WARN: DB query failed, skipping this poll"
    sleep "$POLL_INTERVAL"
    continue
  fi

  if [ "$last_ms" -eq 0 ]; then
    # No activity in the window -> off. There is no next state to predict (an
    # event can arrive at any time), so poll at the idle interval.
    if [ "$LAST_STATE" != "off" ]; then
      if light_off; then log "idle -> light off"; LAST_STATE="off"; LAST_LEVEL=""; fi
    else
      log "idle -> light off (unchanged)"
    fi
    sleep_s="$POLL_INTERVAL"
  else
    # Linear ramp: elapsed 0 -> MAX_LEVEL, elapsed hold_ms -> MIN_LEVEL.
    elapsed=$(( now_ms - last_ms ))
    [ "$elapsed" -lt 0 ] && elapsed=0
    drop=$(( (range * elapsed + hold_ms / 2) / hold_ms ))   # rounded
    level=$(( MAX_LEVEL - drop ))
    [ "$level" -lt "$MIN_LEVEL" ] && level="$MIN_LEVEL"
    [ "$level" -gt "$MAX_LEVEL" ] && level="$MAX_LEVEL"

    # Always re-assert the light (refreshes the force-on so the device can't
    # auto-off between polls); log whether the level actually changed.
    if light_on "$level"; then
      if [ "$LAST_STATE" != "on" ] || [ "$level" != "$LAST_LEVEL" ]; then
        log "active ${elapsed}ms ago -> light on level ${level}"
      else
        log "active ${elapsed}ms ago -> refresh level ${level}"
      fi
      LAST_STATE="on"; LAST_LEVEL="$level"
    fi

    # The level only changes at discrete ramp boundaries, so we would like to
    # sleep until the next one. drop increments once elapsed reaches
    # (2*drop+1)*hold/(2*range); at MIN_LEVEL the next change is the light turning
    # off when the last event ages past the hold window. But we must also
    # re-assert before the device auto-offs, so cap the sleep at REFRESH_MAX.
    # Trade-off: a new event while dimmed won't re-brighten until this wakes.
    if [ "$range" -le 0 ] || [ "$level" -le "$MIN_LEVEL" ]; then
      next_ms="$hold_ms"
    else
      next_ms=$(( (2 * drop + 1) * hold_ms / (2 * range) ))   # elapsed at next step
    fi
    sleep_ms=$(( next_ms - elapsed ))
    [ "$sleep_ms" -lt 1000 ] && sleep_ms=1000
    sleep_s=$(( (sleep_ms + 999) / 1000 ))                    # ceil to whole seconds
    [ "$sleep_s" -gt "$REFRESH_MAX" ] && sleep_s="$REFRESH_MAX"
  fi

  sleep "$sleep_s"
done
