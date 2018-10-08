#!/usr/bin/env bash

CAPS_KEYCODE=66

# Make CapsLock act as Escape and Control.
# Based on https://github.com/cmatheson/super-caps
xmodmap -e "clear Lock"
xmodmap -e "keycode $CAPS_KEYCODE = Control_L"
xmodmap -e "add Control = Control_L"
xmodmap -e "add Lock = Caps_Lock"
xmodmap -e "keycode 999 = Escape"
xcape -e "Control_L=Escape"


# cat ~/.xprofile
# ./sh/super-caps.sh || true
