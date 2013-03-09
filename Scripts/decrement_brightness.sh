BRIGHT_INCREMENT=1
MIN_BRIGHT=1

read MAX_BRIGHT < /sys/class/backlight/dell_backlight/max_brightness
read CURRENT_BRIGHT < /sys/class/backlight/dell_backlight/brightness

CURRENT_BRIGHT=`expr $CURRENT_BRIGHT - $BRIGHT_INCREMENT`

if [ $CURRENT_BRIGHT -ge $MIN_BRIGHT ]
then
    echo $CURRENT_BRIGHT | sudo tee /sys/class/backlight/dell_backlight/brightness
fi
