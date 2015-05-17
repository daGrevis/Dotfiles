#!/bin/bash

if [ "$#" -eq 1 ]; then
   user=$(whoami)
   from=$1
   to="/home/$user/Pictures/wallpaper"

   rm -f $to
   ln -s $from $to

   echo "$from -> $to"
fi

if [[ "$(hostname)" == $WORK_HOSTNAME ]]; then
    feh --bg-fill ~/Pictures/wallpaper --no-xinerama &
    echo "feh --bg-fill ~/Pictures/wallpaper --no-xinerama &"
else
    feh --bg-center ~/Pictures/wallpaper &
    echo "feh --bg-center ~/Pictures/wallpaper &"
fi
