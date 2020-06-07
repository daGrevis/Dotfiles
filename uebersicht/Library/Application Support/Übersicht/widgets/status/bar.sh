#!/bin/sh

PATH=/usr/local/bin/:$PATH

displays=$(yabai -m query --displays)
spaces=$(yabai -m query --spaces)
windows=$(yabai -m query --windows)

output="
{
  \"displays\": $displays,
  \"spaces\": $spaces,
  \"windows\": $windows
}
"

echo "$output"
