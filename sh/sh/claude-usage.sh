#!/bin/sh

# Claude limit usage, e.g. "5h [||         18%] 19:10  7d [|           9%] Jul
# 27, 13:00": how much of the current session limit is used and when it resets,
# then the same for the week. bar.sh draws the bars.
#
# Exits 1 without output when there is nothing to report: claude is not
# installed, nobody is logged in, or the account is an API key, Bedrock or
# Vertex one, which has no such limits.
#
# Exits 2 when the request did not go through, which says nothing about the
# account: the endpoint rate limits after a handful of calls and several claudes
# ask on every answer, so 429 is ordinary. Callers keep what they had.
#
# Fetching is not an inference request, so this costs no tokens.
#
# With --tmux, the bars come out in tmux style sequences, for the status bar.
# See bar.sh.

tmux_styles=false
[ "$1" = "--tmux" ] && tmux_styles=true

bar() {
    if $tmux_styles; then
        "$HOME/sh/bar.sh" --tmux "$1"
    else
        "$HOME/sh/bar.sh" "$1"
    fi
}

command -v curl > /dev/null || exit 1
command -v jq > /dev/null || exit 1

credentials="$HOME/.claude/.credentials.json"
[ -f "$credentials" ] || exit 1
token=$(jq -r '.claudeAiOauth.accessToken // empty' "$credentials")
[ -n "$token" ] || exit 1

response=$(curl -sf --max-time 5 -H "Authorization: Bearer $token" https://api.anthropic.com/api/oauth/usage) || exit 2

# One value per line: the session percentage, when it resets, then the same two
# for the week. The shell puts them together, because bar.sh draws the bars.
#
# Reset times are local and on the 24 hour clock, so an hour reads the same
# here as everywhere else the machine prints one. An empty body leaves jq with
# nothing to print.
usage=$(printf '%s' "$response" |
    jq -r '
        def epoch: sub("\\.[0-9]+";"") | sub("\\+00:00$";"Z") | fromdateiso8601;
        def clock: strflocaltime("%H:%M");

        if (.five_hour.utilization != null and .five_hour.resets_at != null
            and .seven_day.utilization != null and .seven_day.resets_at != null)
        then "\(.five_hour.utilization | round)",
             (.five_hour.resets_at | epoch | clock),
             "\(.seven_day.utilization | round)",
             ((.seven_day.resets_at | epoch) as $reset
                 | "\($reset | strflocaltime("%b %d") | sub(" 0";" ")), \($reset | clock)")
        else empty end')

[ -n "$usage" ] || exit 1

{
    read -r five_hour_percentage
    read -r five_hour_reset
    read -r seven_day_percentage
    read -r seven_day_reset
} << EOF
$usage
EOF

# "5h" and "7d" are how long each window is, which is what tells the two apart,
# and they are short like the "ctx" that the tmux status bar puts on the context
# bar. Two spaces between the two limits, because one reset time ends where the
# other's name begins and a single space runs them together.
printf '5h %s %s  7d %s %s\n' \
    "$(bar "$five_hour_percentage")" "$five_hour_reset" \
    "$(bar "$seven_day_percentage")" "$seven_day_reset"
