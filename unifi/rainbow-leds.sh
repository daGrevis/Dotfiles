#!/bin/bash

# Trap Ctrl+C to exit gracefully
trap "echo -e '\nExiting...'; exit" INT

echo "Starting color rotation. Press Ctrl+C to exit."

# Main loop
while true; do
    # Red to Yellow
    for i in $(seq 0 5 255); do
        printf -v color "ff%02x00" $i
        uled-ctrl color $color
    done

    # Yellow to Green
    for i in $(seq 255 -5 0); do
        printf -v color "%02xff00" $i
        uled-ctrl color $color
    done

    # Green to Cyan
    for i in $(seq 0 5 255); do
        printf -v color "00ff%02x" $i
        uled-ctrl color $color
    done

    # Cyan to Blue
    for i in $(seq 255 -5 0); do
        printf -v color "00%02xff" $i
        uled-ctrl color $color
    done

    # Blue to Magenta
    for i in $(seq 0 5 255); do
        printf -v color "%02x00ff" $i
        uled-ctrl color $color
    done

    # Magenta to Red
    for i in $(seq 255 -5 0); do
        printf -v color "ff00%02x" $i
        uled-ctrl color $color
    done
done
