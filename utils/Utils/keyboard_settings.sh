#!/bin/bash

# Sets cursor.
xsetroot -cursor_name left_ptr

# Keyboard layout.
setxkbmap -layout lv

CAPS_KEYCODE=66

# Make caps as control and escape at the same time. Based on super-caps by cmatheson.
xmodmap -e "clear Lock"
xmodmap -e "keycode $CAPS_KEYCODE = Control_L"
xmodmap -e "add Control = Control_L"
xmodmap -e "add Lock = Caps_Lock"
xmodmap -e "keycode 999 = Escape"
xcape -e "Control_L=Escape"
