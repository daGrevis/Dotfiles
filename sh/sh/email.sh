#!/usr/bin/env bash

# Send an email with Gmail SMTP.
#
#   email.sh recipients subject text [html]
#
# Recipients is a comma-separated list. The credentials come from
# $GMAIL_ADDRESS and $GMAIL_APP_PASSWORD. The app password comes from
# https://myaccount.google.com/apppasswords and needs 2-Step Verification.
#
#   email.sh me@example.com 'Test' 'Hello'
#   email.sh 'me@example.com, you@example.com' 'Test' 'Hello to both'
#   email.sh me@example.com 'Test' $'Line 1\nLine 2'
#   email.sh me@example.com 'Test' 'Hello' '<p><b>Hello</b></p>'
#
# The sender address is $GMAIL_ADDRESS, because Gmail replaces any other
# address with it, and the sender name is the hostname, so the email shows
# which machine sent it.
#
# The email has a text part and an HTML part. If html is not given, the text
# also goes as escaped HTML, with <br> for each newline. If html is given, the
# text stays too, because some email clients show only the text part.
#
# The subject and both parts are UTF-8 in base64, so quotes, newlines and
# non-ASCII characters in all arguments stay correct. The credentials go to
# curl through a file descriptor and not as an argument, so they do not show
# in the process list.

if [ -z "$GMAIL_ADDRESS" ] || [ -z "$GMAIL_APP_PASSWORD" ]; then
  echo 'Error: GMAIL_ADDRESS or GMAIL_APP_PASSWORD is not set' >&2
  exit 1
fi

if [ $# -ne 3 ] && [ $# -ne 4 ]; then
  echo 'Usage: email.sh recipients subject text [html]' >&2
  exit 1
fi

IFS=, read -ra recipients <<< "${1//[[:space:]]/}"
rcpt_args=()
for recipient in "${recipients[@]}"; do
  rcpt_args+=(--mail-rcpt "$recipient")
done
html=${4:-$(jq -rn --arg body "$3" '$body | @html | gsub("\n"; "<br>")')}
boundary='=_email.sh'

curl -sS smtps://smtp.gmail.com:465 \
  -K <(printf 'user = "%s:%s"\n' "$GMAIL_ADDRESS" "${GMAIL_APP_PASSWORD// /}") \
  --mail-from "$GMAIL_ADDRESS" \
  "${rcpt_args[@]}" \
  --crlf -T - <<EOF
From: "$(uname -n)" <$GMAIL_ADDRESS>
To: $(IFS=,; echo "${recipients[*]}")
Subject: =?UTF-8?B?$(printf %s "$2" | base64 | tr -d '\n')?=
Date: $(LC_ALL=C date '+%a, %d %b %Y %H:%M:%S %z')
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="$boundary"

--$boundary
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64

$(printf %s "$3" | base64)
--$boundary
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

$(printf %s "$html" | base64)
--$boundary--
EOF
