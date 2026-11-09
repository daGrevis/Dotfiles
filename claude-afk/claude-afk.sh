#!/bin/sh

# Spends free Claude subscription usage on tasks while you are away. README.md
# next to this script tells how to use it.
#
#     claude-afk status        shows each task and the gate, and runs nothing
#     claude-afk tick          runs the due task that comes first, if the gate
#                              is open. The timer starts this every 15 minutes.
#     claude-afk run <task>    runs one task now, with no gate, but with the
#                              watchdog
#
# The claude-afk command of claude-afk.nix starts this script. It sets
# CLAUDE_AFK_IMAGE to the image and PATH to the tools that the script needs.
# CLAUDE_AFK_DIR gives a different root directory, for tests.

root=${CLAUDE_AFK_DIR:-$HOME/claude-afk}
credentials=$HOME/.claude/.credentials.json
usage_script=$(dirname "$0")/../sh/sh/claude-usage.sh
brief_template=$(dirname "$0")/brief.md
tab=$(printf '\t')
now=$(date +%s)

# The time zone of the host, for the container, for example Europe/Riga.
timezone=$(readlink -f /etc/localtime | sed 's|.*/zoneinfo/||')

usage() {
    sed -n '6,11s/^# \{0,1\}//p' "$0" >&2
    exit 1
}

# {{{ Settings

# Prints the frontmatter of a prompt.md, without the --- lines.
frontmatter() {
    awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit } { print }' "$1"
}

# Prints a prompt.md after its frontmatter.
body() {
    awk 'NR == 1 && $0 == "---" { skip = 1; next } skip && $0 == "---" { skip = 0; next } !skip { print }' "$1"
}

# Prints a setting of a task: the value in the frontmatter, else the value in
# $root/config, else the default.
setting() {
    _value=$(frontmatter "$1/prompt.md" | sed -n "s/^$2:[[:space:]]*//p" | head -n 1)
    if [ -z "$_value" ] && [ -f "$root/config" ]; then
        _value=$(sed -n "s/^$2:[[:space:]]*//p" "$root/config" | head -n 1)
    fi
    printf '%s\n' "${_value:-$3}" | sed 's/[[:space:]]*$//'
}

# Prints the seconds of a duration such as 20m, 1h or 90s. A plain number is
# minutes.
seconds() {
    case $1 in
        *h) echo $(( ${1%h} * 3600 )) ;;
        *m) echo $(( ${1%m} * 60 )) ;;
        *s) echo "${1%s}" ;;
        *) echo $(( $1 * 60 )) ;;
    esac
}

enabled() {
    [ "$(setting "$1" enabled true)" != false ]
}

# }}}

# {{{ Time

# Prints an epoch as a local time, for the log and the brief.
clock() {
    date -d "@$1" '+%Y-%m-%d %H:%M'
}

# Prints the epoch of the first time of a schedule after an epoch. Prints
# nothing when the expression is not valid or has no more times. systemd-analyze
# calculates the time, so the script needs no cron parser.
#
# systemd-analyze has no JSON for calendar. It prints the time in UTC on a line
# of its own, except when the local time is UTC.
next_time() {
    _next=$(systemd-analyze calendar --iterations=1 --base-time="@$2" "$1" 2> /dev/null | awk '
        $1 == "Next" && $2 == "elapse:" && $4 ~ /^[0-9]/ { time = $4 " " $5 }
        $1 == "(in" && $2 == "UTC):" && $4 ~ /^[0-9]/ { utc = $4 " " $5 }
        END { print (utc != "" ? utc : time) }')
    [ -n "$_next" ] && date -d "$_next UTC" +%s
}

# Prints the epoch when a task became due, and fails when it is not due. A
# task with no last run is due now. If the gate stays closed through several
# times of the schedule, the task runs only once when the gate opens.
due_since() {
    _schedule=$(setting "$1" schedule "")
    [ -n "$_schedule" ] || return 1
    _last=$(cat "$1/.afk/last-run" 2> /dev/null)
    if [ -z "$_last" ]; then
        echo "$now"
        return 0
    fi
    _next=$(next_time "$_schedule" "$_last")
    [ -n "$_next" ] && [ "$_next" -le "$now" ] && echo "$_next"
}

# }}}

# {{{ Log and git

# Writes a line to the log of a task and to the journal.
#
# A skip or wait line with the same reason as the last line of the log stays
# out of the log, so that a task that waits for hours does not fill it. The
# reason is the text before the first colon.
log() {
    mkdir -p "$1/.afk"
    _line=$(printf '%s %-5s %s' "$(clock "$(date +%s)")" "$2" "$3")
    echo "$(basename "$1"): $2 $3"
    case $2 in
        skip | wait)
            _key="$2 ${3%%:*}"
            _last_key=$(tail -n 1 "$1/.afk/log" 2> /dev/null | awk '{ word = $3; $1 = $2 = $3 = ""; sub(/^ +/, ""); split($0, part, ":"); print word " " part[1] }')
            [ "$_key" = "$_last_key" ] && return
            ;;
    esac
    printf '%s\n' "$_line" >> "$1/.afk/log"
}

# Commits all changes of a task. The commit is not signed and runs no hooks,
# because it is the tool and not you. The runner never amends, resets, rebases
# or pushes. Each run adds one commit for the edits of the user before it, for
# example an answer under "## Response", and one commit for the run.
commit() {
    git -C "$1" add -A > /dev/null 2>&1
    git -C "$1" -c user.name=claude-afk -c user.email=claude-afk@localhost -c commit.gpgsign=false \
        commit -q --no-verify -m "$2" > /dev/null 2>&1
}

# A VM shutdown can cut off a run before it writes its end line. Then the next
# tick writes it and commits what the run left behind. Call only with the lock.
recover() {
    for _dir in "$root"/*/; do
        _dir=${_dir%/}
        [ -f "$_dir/.afk/log" ] || continue
        _last=$(tail -n 1 "$_dir/.afk/log")
        [ "$(echo "$_last" | awk '{ print $3 }')" = run ] || continue
        log "$_dir" end interrupted
        commit "$_dir" "Run $(echo "$_last" | awk '{ print $1 " " $2 }'): interrupted"
    done
}

# }}}

# {{{ Usage

# Prints the seconds until the access token in the credentials file expires.
token_left() {
    _expires=$(jq -r '.claudeAiOauth.expiresAt // 0' "$credentials" 2> /dev/null)
    echo $(( ${_expires:-0} / 1000 - $(date +%s) ))
}

# Succeeds when the access token in the credentials file expired, or expires in
# the next minute.
token_expired() {
    [ "$(token_left)" -le 60 ]
}

# Succeeds when the access token stays valid for a full run of a task, with 5
# minutes to spare, because the container cannot refresh it. A new access token
# lives 8 hours. Else prints the reason, for log.
token_lasts() {
    _left=$(token_left)
    _needs=$(( $(seconds "$(setting "$1" timeout 20m)") + 300 ))
    [ "$_left" -ge "$_needs" ] && return 0
    echo "token expiry: $(( _left / 60 )) min left, the run needs $(( _needs / 60 ))"
    return 1
}

# Claude Code refreshes the access token only when it runs, so after a long
# time with no claude the token in the file is expired. A small Haiku run on
# the host makes it refresh. The run costs few tokens, but it can start a 5h
# window.
#
# The script does not refresh the token itself with the refresh token, because
# Claude Code also refreshes it. Each refresh can make the other refresh token
# invalid, and then the user must log in again.
#
# claude auth status does not refresh the token, because its JSON output reads
# only the local state. A token of claude setup-token does not help either: it
# has only the user:inference scope, and the usage endpoint needs user:profile.
#
# claude -p runs the hooks of the user, which write to tmux and send desktop
# notifications. --bare also skips them, but it refuses OAuth.
refresh_token() {
    token_expired || return 0
    (
        cd "$root" &&
            env -u CLAUDE_CODE_EFFORT_LEVEL claude -p --model haiku --no-session-persistence \
                --settings '{"disableAllHooks": true}' 'Reply with OK.'
    ) > /dev/null 2>&1
    if ! token_expired; then
        echo "a Haiku run refreshed the token"
        return 0
    fi
    echo "the token is expired, and a Haiku run did not refresh it" >&2
    return 1
}

# Reads the usage into free_5h, free_week and week_elapsed, which are shares
# from 0 to 1, and into reset_5h, the epoch when the 5h window resets. With no
# active window, a run starts one, so reset_5h is 5 hours from now. Fails when
# the usage is unknown.
read_usage() {
    _json=$("$usage_script" --raw) || return 1
    _numbers=$(printf '%s' "$_json" | jq -r --argjson now "$(date +%s)" '
        def epoch: sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601;
        if .seven_day.utilization == null or .seven_day.resets_at == null then empty
        else (.five_hour.resets_at | if . == null then 0 else epoch end) as $reset |
            "\(1 - (.five_hour.utilization // 0) / 100) \(1 - .seven_day.utilization / 100) \(1 - ((.seven_day.resets_at | epoch) - $now) / 604800) \(if $reset > $now then $reset else $now + 18000 end)"
        end')
    [ -n "$_numbers" ] || return 1
    # shellcheck disable=SC2086
    set -- $_numbers
    free_5h=$1
    free_week=$2
    week_elapsed=$3
    reset_5h=$4
}

# Prints the reserve of a task: the highest value of its reserve curve from now
# until the 5h window resets. A curve with no valid entry gives 1, so that no
# task runs. Call after read_usage.
#
# The highest value until the reset, because the user can come at any time
# before the reset, and after the reset the user gets a full window.
#
# The default curve comes from the prompts in ~/.claude/history.jsonl from
# 2026-02-28 to 2026-10-30. The chance of a prompt in the next 5 hours was at
# most 5% from 01:00 to 04:00, 24% to 27% from 08:00 to 14:00, and 32% to 44%
# from 15:00 to 21:00. On weekends, it was 50% from 08:00 to 13:00.
reserve() {
    awk -v curve="$(setting "$1" reserve "01:00=0 09:00=0.5 15:00=0.8 23:00=0.5")" \
        -v now="$(date +%s)" -v reset="${reset_5h:-0}" '
        BEGIN {
            n = split(curve, entry, " ")
            for (i = 1; i <= n; i++) {
                if (entry[i] !~ /^[0-9][0-9]?:[0-9][0-9]=[0-9.]+$/) continue
                split(entry[i], part, /[:=]/)
                count++
                minute[count] = part[1] * 60 + part[2]
                value[count] = part[3] + 0
            }
            if (!count) { print 1; exit }
            # The value now is the value of the last entry at or before the time
            # of day, else of the last entry of the day before.
            today = strftime("%H", now) * 60 + strftime("%M", now)
            at = -1
            latest = -1
            for (i = 1; i <= count; i++) {
                if (minute[i] <= today && minute[i] > at) { at = minute[i]; result = value[i] }
                if (minute[i] > latest) { latest = minute[i]; last = value[i] }
            }
            if (at < 0) result = last
            # Each entry that starts after now and before the reset.
            for (i = 1; i <= count; i++) {
                start = now - now % 60 + (minute[i] - today + 1440) % 1440 * 60
                if (start > now && start < reset && value[i] > result) result = value[i]
            }
            print result
        }'
}

# Applies the gate to a task: the checks before a run. Prints the text for the
# log, and fails when the gate is closed. The text of a closed gate starts with
# the reason and a colon, for log.
#
# The gate does not check if the user works in claude now. The reserve, the
# week floor and the watchdog protect the share of the user.
#
# The free part of a 5h window goes away when the window resets, but each run
# also uses the week. The pace keeps the used share of the week at or under a
# straight line from 0% at the start of the week to 100% at the reset. Thus the
# tasks spread their usage over the week, and a night cannot take the week.
gate() {
    token_lasts "$1" || return 1
    # The gate needs 10% more than the reserve, so that the watchdog does not
    # stop a new run at its first check.
    awk -v free_5h="$free_5h" -v free_week="$free_week" -v elapsed="$week_elapsed" \
        -v reserve="$(reserve "$1")" \
        -v pace="$(setting "$1" max_week_pace 1.0)" \
        -v min_week="$(setting "$1" min_free_week 0.3)" '
        function percent(share) { return sprintf("%.0f%%", share * 100) }
        BEGIN {
            used = 1 - free_week
            if (free_5h < reserve + 0.1) { print "5h limit: " percent(free_5h) " free, needs " percent(reserve + 0.1) ", reserve " percent(reserve); exit 1 }
            if (free_week < min_week) { print "week floor: " percent(free_week) " free, needs " percent(min_week); exit 1 }
            if (used > pace * elapsed) { print "week pace: " percent(used) " used, pace " percent(pace * elapsed); exit 1 }
            print "5h " percent(free_5h) " free, reserve " percent(reserve) ", week " percent(free_week) " free, week used " percent(used) " of pace " percent(pace * elapsed)
        }'
}

# Applies the checks during a run: the free share of the 5h window must stay
# at or above the reserve, which changes with the time, and the week must stay
# at or above its floor. Prints the reason, and succeeds when the watchdog must
# stop the run. With a reserve of 0, a run can reach the hard limit of the 5h
# window, and its result is then limit.
watchdog() {
    awk -v free_5h="$free_5h" -v free_week="$free_week" \
        -v reserve="$(reserve "$1")" \
        -v min_week="$(setting "$1" min_free_week 0.3)" '
        function percent(share) { return sprintf("%.0f%%", share * 100) }
        BEGIN {
            if (free_5h < reserve) { print "watchdog: 5h " percent(free_5h) " free, reserve " percent(reserve); exit 0 }
            if (free_week < min_week) { print "watchdog: week " percent(free_week) " free"; exit 0 }
            exit 1
        }'
}

# }}}

# {{{ Run

# Holds the lock until the script ends, so that two runs never overlap. Fails
# when another run holds it. systemd does not start the oneshot service again
# while it is active, but claude-afk run starts outside systemd.
lock() {
    mkdir -p "$root"
    exec 9> "$root/.lock"
    flock -n 9
}

# Loads the image into Docker when Docker does not have this build of it, then
# removes the older builds and their Nix volumes. Sets tag and volume. The load
# takes approximately 1 minute, at the first run after a rebuild.
#
# The tag is the hash of the store path of the image, so that each build has
# its own tag. Each build also has its own Nix volume, because Docker fills a
# volume from the image only when the volume is empty.
load_image() {
    tag=$(basename "$CLAUDE_AFK_IMAGE" | cut -d - -f 1)
    volume=claude-afk-nix-$tag
    docker image inspect "claude-afk:$tag" > /dev/null 2>&1 && return 0
    echo "loading the image claude-afk:$tag"
    _loaded=$("$CLAUDE_AFK_IMAGE" | docker load | sed -n 's/^Loaded image: //p')
    [ -n "$_loaded" ] && docker tag "$_loaded" "claude-afk:$tag" || return 1
    docker images claude-afk --format '{{.Tag}}' | grep -v -x -e "$tag" -e latest |
        sed 's/^/claude-afk:/' | xargs -r docker rmi > /dev/null 2>&1
    docker volume ls -q --filter name=claude-afk-nix- | grep -v -x "$volume" |
        xargs -r docker volume rm > /dev/null 2>&1
    return 0
}

# Prints the brief for a run of a task, for --append-system-prompt: brief.md
# next to this script, with each {{name}} in it replaced by the value of name.
brief() {
    _last=$(awk '$3 == "end" { line = $0 } END { print line }' "$1/.afk/log" 2> /dev/null)
    if [ -n "$_last" ]; then
        _last="The last run ended at $(echo "$_last" | awk '{ print $1 " " $2 }') with the result: $(echo "$_last" | cut -c 24-)."
    else
        _last="This is the first run of the task."
    fi
    _next=$(next_time "$(setting "$1" schedule "")" "$(date +%s)")
    _next=${_next:+$(clock "$_next")}
    if [ -n "$free_5h" ]; then
        _usage=$(awk -v a="$free_5h" -v b="$free_week" 'BEGIN { printf "At the start, %.0f%% of the 5h window and %.0f%% of the week are free.", a * 100, b * 100 }')
    else
        _usage="The usage at the start is not known."
    fi
    _reserve=$(awk -v a="$(reserve "$1")" 'BEGIN { printf "%.0f%%", a * 100 }')
    _min_week=$(awk -v a="$(setting "$1" min_free_week 0.3)" 'BEGIN { printf "%.0f%%", a * 100 }')
    _mounts=$(setting "$1" mounts "")
    # Each run reads all of notes.md, so it must not grow with each run. The
    # git history keeps the old text.
    _limit=1500
    _words=$(cat "$1/notes.md" 2> /dev/null | wc -w)
    _notes="notes.md has $_words words, and the limit is $_limit."
    [ "$_words" -gt "$_limit" ] && _notes="$_notes Make it shorter before other work, as rules 4 and 5 say."
    if [ -n "$edits" ]; then
        _edits="Since the last run, the user changed these files: $edits."
    else
        _edits="Since the last run, the user changed no files."
    fi
    # The values go to awk in the environment, because awk -v changes each
    # backslash in a value.
    task=$(basename "$1") \
        now=$(date '+%A %Y-%m-%d %H:%M') \
        timezone=$timezone \
        last=$_last \
        next="${_next:-an unknown time}" \
        usage=$_usage \
        reserve=$_reserve \
        min_week=$_min_week \
        timeout=$(( $(seconds "$(setting "$1" timeout 20m)") / 60 )) \
        edits=$_edits \
        notes=$_notes \
        dir=$1 \
        mounts=${_mounts:-none} \
        limit=$_limit \
        awk '{
            line = $0
            out = ""
            while (match(line, /\{\{[a-z_]+\}\}/)) {
                out = out substr(line, 1, RSTART - 1) ENVIRON[substr(line, RSTART + 2, RLENGTH - 4)]
                line = substr(line, RSTART + RLENGTH)
            }
            print out line
        }' "$brief_template"
}

# Runs one task in its container with the watchdog, then logs and commits the
# result. The arguments are the task directory and the text for the run line of
# the log. Call only with the lock, and after read_usage.
run_task() {
    dir=$1
    name=$(basename "$dir")
    # Only the access token, and never the refresh token.
    # Not a token of claude setup-token, because it lasts one year, so a leak
    # of it costs more.
    token=$(jq -r '.claudeAiOauth.accessToken // empty' "$credentials" 2> /dev/null)
    if [ -z "$token" ]; then
        echo "no access token in $credentials: run claude, and log in" >&2
        return 1
    fi
    if ! load_image; then
        echo "cannot load the image $CLAUDE_AFK_IMAGE" >&2
        return 1
    fi

    mkdir -p "$dir/.afk/runs"
    [ -d "$dir/.git" ] || git -C "$dir" init -q
    start=$(date +%s)
    # The run removes the answers in notes.md after it reads them, so the
    # history must have them first. The brief names the files of this commit,
    # so that the run finds the new answers. The ticks between the runs write
    # .afk/log, which is not an edit of the user.
    edits=
    commit "$dir" "Edits before run $(clock "$start")" &&
        edits=$(git -C "$dir" -c core.quotePath=false show --name-only --format= HEAD -- . ':(exclude).afk' |
            awk 'NF { printf "%s%s", sep, $0; sep = ", " }')
    out=$dir/.afk/runs/$(date -d "@$start" +%Y-%m-%dT%H-%M)
    # The last run is the start of this run, so that a failed or interrupted
    # run also counts, and a failure does not try again on each tick.
    previous=$(cat "$dir/.afk/last-run" 2> /dev/null)
    echo "$start" > "$dir/.afk/last-run"
    log "$dir" run "$2"

    timeout=$(seconds "$(setting "$dir" timeout 20m)")
    # With no model setting, the model of the host, because the container has
    # no Claude Code settings.
    model=$(setting "$dir" model "$(jq -r '.model // empty' "$HOME/.claude/settings.json" 2> /dev/null)")
    container=claude-afk-$name

    # CLAUDE_CODE_EFFORT_LEVEL and not --effort, because the variable is the
    # only control that Opus 5.5 follows. See the Claude part of home.nix.
    # Claude Code ignores MAX_THINKING_TOKENS on current models, so the effort
    # is the only control for thinking.
    #
    # CLAUDE_CODE_TMPDIR, because Claude Code refuses /tmp/claude-<uid> when
    # it belongs to root. Docker makes that directory as root when a task
    # directory is under it.
    #
    # No auto memory, because it goes away with the container. notes.md is
    # the memory of the task.
    #
    # The container is in place of the Bash sandbox of Claude Code. It gets
    # only the task directory, the mounts and the access token. It never gets
    # the Docker socket, which gives root on the host. It also never gets the
    # home directory, the SSH agent or the Claude Code settings of the user.
    # Thus the hooks, CLAUDE.md and output style of the user do not apply.
    #
    # The task directory is the working directory, so Claude Code loads the
    # .claude/settings.json and CLAUDE.md of the task.
    #
    # A web page can inject instructions, and they can stay in notes.md or in
    # a script for the next runs. The network is open, so an injected
    # instruction can send to any host the access token, the task files, the
    # mounts, and requests to services on the host or the LAN with no login.
    # Auto mode stops risky actions, and git shows each change after it.
    #
    # All tasks share the Nix volume, as a cache for nix-shell.
    set -- docker run --rm --interactive --name "$container" \
        --hostname "$container" \
        --user "$(id -u):$(id -g)" \
        --tmpfs /tmp \
        --env HOME=/tmp \
        --env TZ="$timezone" \
        --env CLAUDE_CODE_TMPDIR=/tmp/claude-afk \
        --env CLAUDE_CODE_OAUTH_TOKEN \
        --env ENABLE_CLAUDEAI_MCP_SERVERS=false \
        --env CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 \
        --env CLAUDE_CODE_EFFORT_LEVEL="$(setting "$dir" effort high)" \
        --volume "$volume:/nix" \
        --volume "$dir:$dir" \
        --workdir "$dir"
    _add_dirs=
    for _mount in $(setting "$dir" mounts ""); do
        _path=${_mount%:*}
        _mode=${_mount##*:}
        if [ "$_path" = "$_mount" ] || { [ "$_mode" != ro ] && [ "$_mode" != rw ]; }; then
            _path=$_mount
            _mode=ro
        fi
        case $_path in "~"*) _path=$HOME${_path#"~"} ;; esac
        set -- "$@" --volume "$_path:$_path:$_mode"
        [ "$_mode" = rw ] && _add_dirs="$_add_dirs $_path"
    done
    # The values come from ~/.env, because systemd does not load it. --env with
    # no value takes the value from the environment of docker, so that the
    # value does not show in the process list.
    for _name in $(setting "$dir" env ""); do
        export "$_name=$(set -a && . "$HOME/.env" > /dev/null 2>&1; printenv "$_name")"
        set -- "$@" --env "$_name"
    done
    # ANTHROPIC_MODEL too, because an org default model can beat --model. See
    # the Claude part of home.nix.
    [ -n "$model" ] && set -- "$@" --env ANTHROPIC_MODEL="$model"
    set -- "$@" "claude-afk:$tag" claude -p --permission-mode auto --output-format json \
        --append-system-prompt "$(brief "$dir")"
    [ -n "$model" ] && set -- "$@" --model "$model"
    for _add_dir in $_add_dirs; do
        set -- "$@" --add-dir "$_add_dir"
    done

    # The token goes only to docker, and not to the claude of the host, which
    # must keep using the credentials file.
    body "$dir/prompt.md" | CLAUDE_CODE_OAUTH_TOKEN=$token "$@" > "$out.json" 2> "$out.err" &
    pid=$!

    # systemd sends SIGTERM only to this script, see KillMode in home.nix. The
    # trap runs after the current sleep, and the loop then stops the container.
    stopped=false
    trap 'stopped=true' TERM INT
    result=
    checked=$start
    while kill -0 "$pid" 2> /dev/null; do
        sleep 5
        kill -0 "$pid" 2> /dev/null || break
        if $stopped; then
            result=interrupted
        elif [ $(( $(date +%s) - start )) -ge "$timeout" ]; then
            result=timeout
        elif [ $(( $(date +%s) - checked )) -ge 300 ]; then
            # The rate_limit_event of claude has no utilization while its
            # status is allowed, so the watchdog reads the usage endpoint.
            checked=$(date +%s)
            read_usage && result=$(watchdog "$dir")
        fi
        if [ -n "$result" ]; then
            # claude exits at once on SIGTERM, but it writes no JSON output.
            docker stop --time 10 "$container" > /dev/null 2>&1
            break
        fi
    done
    wait "$pid"
    status=$?
    trap - TERM INT

    [ -s "$out.err" ] || rm -f "$out.err"
    if [ -z "$result" ]; then
        if [ "$status" = 0 ] && [ "$(jq -r '.is_error' "$out.json" 2> /dev/null)" = false ]; then
            result=ok
        elif jq -r '.result // empty' "$out.json" 2> /dev/null | grep -q -i 'limit'; then
            result=limit
        else
            result=failed
        fi
    fi

    # A run that ended on a usage limit does not count as a run, so that the
    # task runs again after the reset.
    if [ "$result" = limit ]; then
        if [ -n "$previous" ]; then
            echo "$previous" > "$dir/.afk/last-run"
        else
            rm -f "$dir/.afk/last-run"
        fi
    fi

    _summary="$result, $(( ($(date +%s) - start + 30) / 60 )) min"
    _turns=$(jq -r '.num_turns // empty' "$out.json" 2> /dev/null)
    case $_turns in
        "") ;;
        1) _summary="$_summary, 1 turn" ;;
        *) _summary="$_summary, $_turns turns" ;;
    esac
    # Auto mode refuses each model with haiku in its name. Then claude uses the
    # default mode, which denies each tool call that needs a permission, and
    # the run still ends ok.
    _denied=$(jq -r '.permission_denials | length' "$out.json" 2> /dev/null)
    [ "${_denied:-0}" -gt 0 ] && _summary="$_summary, $_denied denied"
    log "$dir" end "$_summary"
    commit "$dir" "Run $(clock "$start"): $_summary"
}

# }}}

# {{{ Commands

status_command() {
    if token_expired; then
        echo "Usage: unknown, because the token in $credentials is expired. The next tick refreshes it."
    elif read_usage; then
        awk -v a="$free_5h" -v b="$free_week" -v c="$week_elapsed" \
            'BEGIN { printf "Usage: 5h %.0f%% free, week %.0f%% free, %.0f%% of the week elapsed\n", a * 100, b * 100, c * 100 }'
    else
        echo "Usage: unknown, because the usage endpoint did not answer."
    fi
    if [ -f "$root/.lock" ] && ! flock -n "$root/.lock" true; then
        echo "A run is active."
    fi

    for dir in "$root"/*/; do
        dir=${dir%/}
        [ -f "$dir/prompt.md" ] || continue
        echo
        if ! enabled "$dir"; then
            echo "$(basename "$dir"): disabled"
            continue
        fi
        schedule=$(setting "$dir" schedule "")
        last=$(cat "$dir/.afk/last-run" 2> /dev/null)
        if since=$(due_since "$dir"); then
            echo "$(basename "$dir"): due since $(clock "$since"), priority $(setting "$dir" priority 0)"
        else
            echo "$(basename "$dir"): not due, priority $(setting "$dir" priority 0)"
        fi
        next=$(next_time "$schedule" "${last:-$now}")
        last_text=none
        [ -n "$last" ] && last_text=$(clock "$last")
        next_text=none
        [ -n "$next" ] && next_text=$(clock "$next")
        echo "    schedule ${schedule:-none}, last run $last_text, next $next_text"
        if [ -n "$free_5h" ]; then
            if text=$(gate "$dir"); then
                echo "    gate open: $text"
            else
                echo "    gate closed: $text"
            fi
        fi
        if [ -f "$dir/output/INDEX.md" ]; then
            echo "    findings: $(grep -c -w open "$dir/output/INDEX.md") open, $(grep -c -w updated "$dir/output/INDEX.md") updated"
        fi
    done
}

tick_command() {
    [ -d "$root" ] || exit 0
    lock || exit 0
    recover

    due=
    for dir in "$root"/*/; do
        dir=${dir%/}
        [ -f "$dir/prompt.md" ] && enabled "$dir" && due_since "$dir" > /dev/null || continue
        due="$due$(setting "$dir" priority 0)$tab$(cat "$dir/.afk/last-run" 2> /dev/null || echo 0)$tab$dir
"
    done
    [ -n "$due" ] || exit 0

    # The usage endpoint answers 429 after a few calls in a short time, so a
    # tick reads it only once, and only when a task is due.
    if ! refresh_token || ! read_usage; then
        printf '%s' "$due" | while IFS=$tab read -r _ _ dir; do
            log "$dir" skip "usage unknown: no answer from the usage endpoint"
        done
        exit 0
    fi

    # The due tasks in order: the highest priority first, then the oldest last
    # run. The first task with an open gate runs. Only one task runs per tick,
    # so that the next tick reads fresh usage numbers. Thus a long run cannot
    # start a chain of runs on old numbers.
    selected=
    while IFS=$tab read -r _ _ dir; do
        if [ -n "$selected" ]; then
            log "$dir" wait "$(basename "$selected") runs first: priority $(setting "$selected" priority 0)"
        elif text=$(gate "$dir"); then
            selected=$dir
            selected_text=$text
        else
            log "$dir" skip "$text"
        fi
    done << EOF
$(printf '%s' "$due" | sort -t "$tab" -k 1,1nr -k 2,2n)
EOF
    [ -z "$selected" ] || run_task "$selected" "$selected_text"
}

run_command() {
    dir=$root/$1
    if [ ! -f "$dir/prompt.md" ]; then
        echo "no task $1: $dir/prompt.md does not exist" >&2
        exit 1
    fi
    if ! lock; then
        echo "another run is active" >&2
        exit 1
    fi
    recover
    refresh_token
    if ! reason=$(token_lasts "$dir"); then
        echo "$reason: run the task again after the token in $credentials expires" >&2
        exit 1
    fi
    if read_usage; then
        run_task "$dir" "$(awk -v a="$free_5h" -v b="$free_week" 'BEGIN { printf "no gate: 5h %.0f%% free, week %.0f%% free", a * 100, b * 100 }')"
    else
        echo "the usage is not known, so the watchdog cannot stop this run" >&2
        run_task "$dir" "no gate: usage unknown"
    fi
}

# }}}

case $1 in
    status) status_command ;;
    tick) tick_command ;;
    run) [ -n "$2" ] || usage; run_command "$2" ;;
    *) usage ;;
esac
