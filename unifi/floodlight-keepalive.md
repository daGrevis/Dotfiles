# floodlight-keepalive.sh — design & operation notes (for an LLM)

This document explains `floodlight-keepalive.sh` in enough detail that an LLM
can operate, debug, or extend it without re-deriving the UniFi Protect internals.

## Goal

Keep a UniFi Protect **floodlight** (standalone UP-FloodLight) ON while a camera
is producing detection events, and turn it OFF once no events have occurred for
a configurable "hold window" (default 300s = 5 minutes). Runs as a polling loop
on the Protect host, no cloud, no official API key.

**Brightness ramp:** immediately after an event the light is at max brightness;
with no further events it dims **linearly** toward min brightness over the hold
window; when the window fully elapses the light turns OFF. Any new event resets
brightness back to max. Brightness (`ledLevel`) is an integer **1–6** enforced by
Protect, so the ramp has at most 6 discrete steps (not smooth).

## The key architectural fact

Protect exposes two independent capabilities that this script bridges:

1. **Reading events is keyless** — events are persisted synchronously to a local
   PostgreSQL table the moment they are detected. We can `SELECT` from it.
2. **Toggling the light is NOT possible via the DB** — writing to the `lights`
   table does nothing to the hardware. The physical device command
   (`changeLightSettings`) is emitted only from the **in-process** Decal save
   listener (`onLightSave` → handoff `devices.lights.lightOn` → device
   websocket). A raw SQL `UPDATE` never fires that listener. There is no DB
   trigger, poller, or external IPC that would pick it up. Therefore the light
   MUST be toggled over HTTP.

So: **read from Postgres, write over the REST API.**

## Read side — Postgres

- Connection (from `config/default.json`): unix socket `/var/run/postgresql`,
  port `5433`, database `unifi-protect`, user `unifi-protect`, **no password**
  (peer authentication). Because it is peer auth, the OS user running `psql`
  must map to the `unifi-protect` role. If you run as `root`, use
  `-P "sudo -u unifi-protect psql"`.
- Table: **`events`**. Relevant columns:
  - `id` (text pk), `type` (`motion`, `smartDetectZone`, `smartDetectLine`,
    `smartAudioDetect`, `ring`, ...)
  - `start`, `end` — unix epoch **milliseconds** (both are SQL reserved words,
    so they are always double-quoted in queries: `"start"`, `"end"`).
    `"end"` is NULL while an event is still ongoing.
  - `cameraId` (FK → `cameras.id`), `smartDetectTypes` (json), `score`,
    `metadata` (json), `deletedAt` (soft delete; filter `IS NULL`).
- Events are written in real time, synchronously, at detection start (and
  updated with `"end"` at stop). Polling new/recent rows is reliable.

### Activity query

Each poll computes `cutoff_ms = now_ms - HOLD_WINDOW*1000`, then asks for the
**`start` of the most recent qualifying event** inside the window:

```sql
SELECT COALESCE((
    SELECT "start" FROM events
    WHERE "start" > <cutoff_ms>
      AND "deletedAt" IS NULL
      [AND "cameraId" = ANY('{<camera-ids>}')]
      AND (type = 'motion'
           OR jsonb_exists_any("smartDetectTypes"::jsonb, ARRAY[<classes>]))
    ORDER BY "start" DESC
    LIMIT 1), 0);
```

Design points:

- **`start`, not `COALESCE(end, now)`.** We track *when the last qualifying event
  began*. That is exactly the "new event resets to max" trigger the ramp wants,
  and `start` is index-friendly. Trade-off: a single *continuous* event longer
  than the hold window is not treated as "still active" — its `start` ages out and
  the light ramps down. In practice motion/smart activity produces a stream of
  fresh events, so this is rarely visible; if it matters, shorten nothing —
  people moving generate new rows.
- **Index usage.** `ORDER BY "start" DESC LIMIT 1` with `"cameraId" = ANY(...)`
  and `"start" > cutoff` rides the `event_camera_start_end (cameraId, start, end)`
  index — a few index seeks, not a table scan. This is what makes 1–2s polling
  cheap. **Without `-c`** there is no `cameraId` predicate and the plan degrades
  to a scan, so `-c` is strongly recommended.
- **Trigger filter.** `type = 'motion'` OR a smartDetect event whose
  `smartDetectTypes` array contains one of the requested classes (default
  `person,animal`). `smartDetectTypes` is a JSON column, cast to `jsonb` for
  `jsonb_exists_any` (the function behind the `?|` operator). Motion events have
  an empty/absent `smartDetectTypes`, so the `type='motion'` branch covers them.
- **`COALESCE(subquery, 0)`** guarantees exactly one row: `0` means "no recent
  qualifying event" (⇒ OFF). Empty output therefore unambiguously means the query
  itself failed (skip the poll), which a bare `LIMIT 1` could not distinguish from
  "no rows".

The camera filter is optional but recommended (`-c`, comma-separated MACs,
resolved to `cameras.id` at startup). Same for the floodlight: `-m` is a MAC,
resolved to `lights.id`.

## Write side — internal REST API + `x-userid`

- Endpoint: `PATCH /api/lights/:id` (internal API, `src/middleware/api/rest/routes/lights.ts`).
- Auth without an API key: the `x-userid` header. `authenticateWithUid`
  (`src/core/lib/auth.ts`) trusts requests from a loopback / trusted local
  address that carry `x-userid: <ucoreIdentity id>`. This is the internal-trust
  mechanism UniFi OS components use. The value is **not a secret** — it is just a
  valid row id from the `ucoreIdentities` table.
- **Permission matters.** The PATCH handler (`routes/lights.ts`) calls
  `checkGranularUserPermissions` requiring `GranularAccess.DEVICE_SETTINGS_EDIT`
  / `AccessMode.WRITE`. The identity behind `x-userid` must map to a user that
  has it, or the request **403s** (silent no-op for the light). Not every
  identity qualifies — a view-only user will fail.
- **Identity selection.** `ucoreIdentities.userId` → `users.id`, and `users` has
  an `isOwner` boolean. The console owner always has write permission, so the
  script auto-picks the owner's identity:
  ```sql
  SELECT ui.id FROM "ucoreIdentities" ui
  JOIN users u ON u.id = ui."userId"
  WHERE u."isOwner" = true ORDER BY ui."createdAt" LIMIT 1;
  ```
  If no owner row exists it falls back to the first identity and logs a warning
  (that one may 403). Override explicitly with `-U <identityId>`.
- Bodies used:
  ```json
  // turn on at a given brightness (ledLevel is 1-6, 6 = brightest)
  {"lightDeviceSettings":{"ledLevel":4},"lightOnSettings":{"isLedForceOn":true}}
  // release the override (light returns to its configured/off mode)
  {"lightOnSettings":{"isLedForceOn":false}}
  ```
  `isLedForceOn` maps to the "force on" override. `false` releases the override
  and the light returns to its configured mode. **Prerequisite:** set the light's
  mode to *Manual / Off* in the Protect UI so that "release" actually means dark.
  If the light's base mode is "always on", `false` will not turn it off.
  `ledLevel` is validated 1–6 by Protect (`LightDeviceSettings.ts`); values
  outside that range are rejected by the API.
  **The force-on self-offs after ~30–60s.** The device drops `isLedForceOn` on
  its own after a short internal timer (`lightOnSettings.ledDuration` reads `0`
  and setting it via this API does *not* persist — it stays `0`). So the light
  must be **re-asserted** (`light_on` PATCHed again) well within that window or it
  goes dark mid-sleep. This is why the loop caps its on-state sleep — see
  `REFRESH_MAX` under Control logic.

### Reaching the API

- **Use the internal HTTP port directly** — `-u http://127.0.0.1:7080` (the
  default). The script appends `/api/lights/:id`. This is the path that honors
  the `x-userid` loopback trust. On setups where Protect runs in its own netns,
  enter it first (e.g. `unifi-os shell`); on setups where `unifi-protect` and
  postgres (port 5433) listen directly on `127.0.0.1` of the host, just run the
  script on the host as-is.
- **Do not go through the UniFi OS reverse proxy** for this. A PATCH via
  `https://127.0.0.1/proxy/protect/api/lights/:id` returns **HTTP 401** — the
  proxy ignores `x-userid` and requires real session / API-key auth. Always use
  the internal port above.

## Control logic

State is remembered in `LAST_STATE` (`on`/`off`/unknown) plus `LAST_LEVEL` (the
brightness last pushed while on):

1. Poll DB → `last_ms` (start of most recent qualifying event, or `0`).
2. If `last_ms == 0` → desired **off**.
3. Else compute the linear ramp:
   ```
   elapsed = now_ms - last_ms                       # >= 0
   drop    = round(range * elapsed / hold_ms)       # range = MAX_LEVEL - MIN_LEVEL
   level   = clamp(MAX_LEVEL - drop, MIN_LEVEL, MAX_LEVEL)
   ```
   `elapsed = 0` (fresh event) ⇒ `level = MAX_LEVEL`. As `elapsed` approaches
   `hold_ms`, `level` approaches `MIN_LEVEL`. Once `elapsed >= hold_ms` the row
   falls outside the window, `last_ms` becomes `0`, and step 2 turns it off.
   Integer math throughout (bash), matching `ledLevel`'s 1–6 granularity.
4. Apply only on change:
   - desired off and not already off → `light_off`.
   - desired on and (was not on **or** `level != LAST_LEVEL`) → `light_on level`.
   Otherwise do nothing (avoids re-PATCHing the device every poll).
5. Sleep before the next poll (see below).

First iteration has empty state, so the correct command is always issued once at
startup. A manual toggle elsewhere is not corrected until the next state/level
change (acceptable; the script is intended to be the sole controller).

### Adaptive sleep — poll only when something can change

The brightness level is a step function of `elapsed`, so between two ramp
boundaries nothing can change and polling is wasted. The loop therefore sleeps
only as long as the current state can safely last:

- **On (ramping):** sleep until the next boundary. With the rounded ramp, `drop`
  increments once `elapsed` reaches `(2*drop+1)*hold_ms/(2*range)`, so
  `sleep_ms = that - elapsed`. At `MIN_LEVEL` the next event is the light turning
  off when the last event ages past the hold window, i.e. at `elapsed = hold_ms`.
  A `sleep_ms` floor of 1s and a ceil-to-whole-seconds keep it safe on `busybox`
  `sleep`. **Capped at `REFRESH_MAX` (20s):** the force-on self-offs after
  ~30–60s (see write side), so on every active poll the loop re-asserts
  `light_on` and never sleeps past `REFRESH_MAX`. So while on it polls at most
  every ~20s (not once per step); still far below the idle/old cadence, and the
  light stays lit.
- **Off / idle:** a new event can arrive at any moment and there is nothing to
  predict, so fall back to a fixed `sleep POLL_INTERVAL` (`-i`) waiting for the
  next trigger. `-i` therefore only governs the idle cadence / first-event
  latency, not the on-ramp.

**Trade-off:** while the light is dimmed (below max), a *new* event won't
re-brighten it to `MAX_LEVEL` until the current sleep wakes — up to one step
(~one `hold_ms/range`) of latency. This is accepted deliberately: without a push
channel from Protect, avoiding it would mean polling continuously again. At
`MAX_LEVEL` there is no such cost (a new event keeps it at max, no change).

## CLI arguments

| Flag | Meaning | Default |
|------|---------|---------|
| `-m` | Floodlight MAC (required) | — |
| `-i` | Idle poll interval (s) — used only while off/idle | `30` |
| `-w` | Hold window before OFF (s) | `300` |
| `-b` | Max brightness after an event (1-6) | `6` |
| `-B` | Min brightness before OFF (1-6) | `1` |
| `-u` | API base URL | `http://127.0.0.1:7080` |
| `-U` | `x-userid` identity id (needs device write perm) | console owner's identity |
| `-c` | Camera MACs that may trigger (comma-sep) — recommended | all cameras |
| `-s` | smartDetect classes (comma-sep); motion always counts; `""` = motion only | `person,animal` |
| `-P` | psql command | `psql` |
| `-C` | Postgres connection string | socket conn (see above) |
| `-n` | Dry run (log decisions, never PATCH) | off |
| `-h` | Help | — |

Example:

```bash
./floodlight-keepalive.sh -m 74ACB9AABBCC -w 300 -c AABBCC001122,DDEEFF334455 -s person,animal
```

Test safely first with `-n` (dry run): it prints the on/off decision each poll
without touching the light.

## Failure handling

- Missing light for MAC, or no resolvable identity → hard exit at startup.
- A failed DB query mid-loop → logs a warning and skips that poll (keeps last
  state). A failed PATCH → logs the HTTP code and retries on the next transition.
- `SIGINT`/`SIGTERM` → clean exit; the light is left in its current state (it is
  not force-turned-off on quit).

## Caveats / stability

- The `x-userid` path is **internal and undocumented**. A firmware update could
  rename the header, tighten the trust check, or change the light body shape.
  The official, stable alternative is an API key against
  `/proxy/protect/integration/v1/lights/:id` with header `X-API-KEY` — swap
  `set_light` to use that if the `x-userid` path ever breaks.
- The `events`/`lights` table shapes are internal too, but have been stable
  across many releases.
- On UniFi OS, filesystem changes outside persistent storage can be wiped by
  firmware updates. Put the script somewhere persistent (or redeploy after
  updates), and consider a process manager if you want it to survive reboots.
- Peer auth: run as the `unifi-protect` OS user, or use `-P "sudo -u unifi-protect psql"`.

## How to extend

- **Only react to specific cameras**: pass `-c mac1,mac2,mac3`.
- **React to specific detections**: pass `-s <classes>` (e.g. `-s person` for
  people only, `-s person,animal,vehicle` to add vehicles). Motion always counts;
  use `-s ""` to react to motion only. Classes map to values in the event's
  `smartDetectTypes` array (person, animal, vehicle, package, face, licensePlate).
- **Push instead of poll**: replace the read side with the integration websocket
  `/proxy/protect/integration/v1/subscribe/events` for zero-latency reaction
  (requires an API key and a WS client, not pure curl).
