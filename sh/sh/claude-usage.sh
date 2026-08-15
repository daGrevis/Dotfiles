#!/bin/sh

# Claude limit usage, e.g. "(18%; 7:10pm) (9%; Jul 27, 1pm)": how much of the
# current session limit is used and when it resets, then the same for the week.
#
# Fails without output when there is nothing to report: claude is not installed,
# nobody is logged in, the account is an API key, Bedrock or Vertex one, which
# has no such limits, or the request did not go through.
#
# Fetching is not an inference request, so this costs no tokens.

command -v curl > /dev/null || exit 1
command -v jq > /dev/null || exit 1

credentials="$HOME/.claude/.credentials.json"
[ -f "$credentials" ] || exit 1
token=$(jq -r '.claudeAiOauth.accessToken // empty' "$credentials")
[ -n "$token" ] || exit 1

# Reset times are local and always land on a whole minute, so ":00" is dropped
# as noise. An empty body leaves jq with nothing to print.
usage=$(curl -sf --max-time 5 -H "Authorization: Bearer $token" https://api.anthropic.com/api/oauth/usage |
    jq -r '
        def epoch: sub("\\.[0-9]+";"") | sub("\\+00:00$";"Z") | fromdateiso8601;
        def clock: strflocaltime("%I:%M%p") | sub("^0";"") | ascii_downcase | sub(":00(?<m>[ap]m)$";"\(.m)");

        if (.five_hour.utilization != null and .five_hour.resets_at != null
            and .seven_day.utilization != null and .seven_day.resets_at != null)
        then "(\(.five_hour.utilization | round)%; \(.five_hour.resets_at | epoch | clock)) " +
             ((.seven_day.resets_at | epoch) as $reset
                 | "(\(.seven_day.utilization | round)%; \($reset | strflocaltime("%b %d") | sub(" 0";" ")), \($reset | clock))")
        else empty end')

[ -n "$usage" ] || exit 1

echo "$usage"
