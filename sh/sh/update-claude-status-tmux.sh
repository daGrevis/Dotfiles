#!/bin/sh

# Puts which model Claude runs, how much it reasons, how full its context
# window is and when its prompt cache runs out into the @claude_model,
# @claude_effort, @claude_context and @claude_cache_expiry tmux options, which
# .tmux.conf renders in the status bar, and redraws them. Meant for Claude's
# statusLine: Claude sends all of them on every redraw, so they follow the
# conversation.
#
# Also puts the limits into @claude_usage_5h and @claude_usage_7d, as soon as
# Claude has them. See limits.
#
# Also meant for Claude's SessionStart hook, which sends a different input and
# gets the context bar up before the conversation starts. See below.
#
# Model, effort, context and cache belong to one conversation, so the options
# are set on the pane claude runs in and several claudes each report their own.
#
# Claude's hooks cannot do this. They get no token counts, and the transcript
# does not say how large the window is, which is 200k for one model and 1M for
# another.
#
# Unsets an option when there is nothing to report, so that the status bar
# leaves that part out instead of drawing an empty one.
#
# The values are bare ("opus-5", not "(model opus-5)"), because .tmux.conf says
# which one is which by layout and by label.

status=$(cat)

# Which pane to put the options on. Without a target tmux takes the pane that
# is active in the session, which is another one when this claude runs in a
# window that nobody looks at, so the pane comes from TMUX_PANE, which claude
# passes on to what it starts. The variable holds both words and is on purpose
# not quoted, because an empty one must add no argument at all.
pane_target=${TMUX_PANE:+-t $TMUX_PANE}

# Claude runs a statusLine command for the first time with the first answer, so
# a session that only opened shows no bar at all. The SessionStart hook runs
# this script with its own input, which puts the bar up at 0 until the first
# answer replaces it. A resumed or a compacted session keeps the bar it has,
# because its context is not 0.
#
# A new conversation has no cache before its first request either, so the hook
# also takes down a cache bar that an earlier claude in this pane left.
if [ "$(printf '%s' "$status" | jq -r '.hook_event_name // empty' 2> /dev/null)" = "SessionStart" ]; then
    case $(printf '%s' "$status" | jq -r '.source // empty' 2> /dev/null) in
        startup | clear)
            # shellcheck disable=SC2086 # See pane_target.
            tmux set-option -p $pane_target @claude_context "$("$HOME/sh/bar.sh" --tmux 0)" 2> /dev/null
            # shellcheck disable=SC2086 # See pane_target.
            tmux set-option -pu $pane_target @claude_cache_expiry 2> /dev/null
            # shellcheck disable=SC2086 # See pane_target.
            tmux set-option -pu $pane_target @claude_cache 2> /dev/null
            tmux refresh-client -S 2> /dev/null
            ;;
    esac
    exit 0
fi

# The id, not the display name, because it says which exact model answers, e.g.
# "opus-5[1m]" over "Opus 5 (1M context)". Every id starts with "claude-", which
# says nothing here and is dropped.
model=$(printf '%s' "$status" | jq -r '.model.id // empty | sub("^claude-";"")' 2> /dev/null)

# Only models that take an effort setting report one, so this is often absent.
effort=$(printf '%s' "$status" | jq -r '.effort.level // empty' 2> /dev/null)

# A bar, like the limit usage has, so that how full the window is reads at a
# glance. The bar carries the "%" of the value, because .tmux.conf cannot write
# one itself. See the comment on status-right.
#
# A conversation that has no answer yet reports no count, and that one reads as
# 0, so that the bar is there from the moment claude starts instead of turning
# up with the first answer.
percentage=$(printf '%s' "$status" | jq -r '.context_window.used_percentage // 0 | round' 2> /dev/null)
[ -n "$percentage" ] || percentage=0
context=$("$HOME/sh/bar.sh" --tmux "$percentage")

# When the prompt cache runs out, as epoch seconds, and its TTL in seconds, for
# the cache bar. update-claude-cache-tmux.sh draws the bar from them, because
# the bar has to move while claude waits for a prompt, and this only runs when
# Claude has news. See there.
#
# Claude starts the TTL when it sends a request, and reports which TTL the last
# request wrote and when it runs out. The TTL is 1h, or 5m once the account is
# in overage.
#
# Claude reports nothing before the first request of a conversation, and says
# so when the provider reports no cache at all, so the bar is left out then. A
# last request that reported no cache has no expiry, which goes in as 0, so
# that the bar reads 100: the next request starts from scratch too.
#
# Both in one option, e.g. "1759600000 3600", because .tmux.conf only hands
# them on.
cache_expiry=$(printf '%s' "$status" |
    jq -r '
        .prompt_cache // empty
        | select(.caching_observed == true)
        | "\(.expires_at // 0) \(if .ttl == "1h" then 3600 else 300 end)"' 2> /dev/null)

# The limits, which update-claude-usage-tmux.sh also sets. Its hook only asks
# the endpoint when a session opens, so a request that fails then leaves the
# status bar without limits, and a session limit that only starts with the
# first question has no reset time. Claude reads the limits off every response,
# so they are here from the first one on. Before that Claude leaves them out, and the options keep what
# the hook put there.
#
# One value per line, like claude-usage.sh: the session percentage, when it
# resets, then the same two for the week. The reset times are epoch seconds.
limits=$(printf '%s' "$status" |
    jq -r '
        def clock: strflocaltime("%H:%M");

        .rate_limits
        | if (.five_hour.used_percentage != null and .five_hour.resets_at != null
            and .seven_day.used_percentage != null and .seven_day.resets_at != null)
        then "\(.five_hour.used_percentage | round)",
             (.five_hour.resets_at | clock),
             "\(.seven_day.used_percentage | round)",
             (.seven_day.resets_at as $reset
                 | "\($reset | strflocaltime("%b %d") | sub(" 0";" ")), \($reset | clock)")
        else empty end' 2> /dev/null)

# The status line redraws many times per answer, so tmux only hears about a
# value that changed. Returns 0 when it did.
# shellcheck disable=SC2086 # See pane_target.
update() {
    [ "$2" = "$(tmux show-options -pqv $pane_target "$1" 2> /dev/null)" ] && return 1
    if [ -n "$2" ]; then
        tmux set-option -p $pane_target "$1" "$2" 2> /dev/null
    else
        tmux set-option -pu $pane_target "$1" 2> /dev/null
    fi
}

# The same for the limits, which are the account's and so global, like
# update-claude-usage-tmux.sh sets them. Never unsets, see limits.
update_limit() {
    [ "$2" = "$(tmux show-options -gqv "$1" 2> /dev/null)" ] && return 1
    tmux set-option -g "$1" "$2" 2> /dev/null
}

changed=""
update @claude_model "$model" && changed=1
update @claude_effort "$effort" && changed=1
update @claude_context "$context" && changed=1
update @claude_cache_expiry "$cache_expiry" && changed=1
if [ -n "$limits" ]; then
    {
        read -r five_hour_percentage
        read -r five_hour_reset
        read -r seven_day_percentage
        read -r seven_day_reset
    } << EOF
$limits
EOF
    # The same text that claude-usage.sh prints, so that the hooks and this do
    # not draw the limits in two ways.
    update_limit @claude_usage_5h "5h $("$HOME/sh/bar.sh" --tmux "$five_hour_percentage") $five_hour_reset" && changed=1
    update_limit @claude_usage_7d "7d $("$HOME/sh/bar.sh" --tmux "$seven_day_percentage") $seven_day_reset" && changed=1
fi
[ -n "$changed" ] && tmux refresh-client -S 2> /dev/null

# Claude draws its own status line from what a statusLine command prints, so
# this one prints nothing and never fails.
exit 0
