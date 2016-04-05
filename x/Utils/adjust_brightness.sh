# Sets brightness to something sane.
h=$(date "+%k")

echo "Current hour: $h (0..23)"

if ((h >= 23)); then
    br=25
elif ((h >= 20)); then
    br=50
elif ((h >= 18 )); then
    br=75
elif ((h >= 10 )); then
    br=100
elif ((h >= 7 )); then
    br=50
elif ((h >= 0 )); then
    br=10
fi

xbacklight -set "$br" -time 0

notify-send -u low "Adjusting Brightness" -- "$br/100%"
