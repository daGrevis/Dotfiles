# Sets cursor.
xsetroot -cursor_name left_ptr

# Keyboard layout.
setxkbmap -layout lv

ESCAPE_KEYCODE=9
CAPS_KEYCODE=66
LCONTROL_KEYCODE=37

# Make caps as control and escape at the same time. Based on super-caps by cmatheson.
xmodmap -e "clear Lock"
xmodmap -e "keycode $CAPS_KEYCODE = Control_L"
xmodmap -e "add Control = Control_L"
xmodmap -e "keysym Escape = Caps_Lock"
xmodmap -e "add Lock = Caps_Lock"
xmodmap -e "keycode 999 = Escape"
xcape -e "Control_L=Escape"
# Maps escape and left control to no-op.
xmodmap -e "keycode $ESCAPE_KEYCODE ="
xmodmap -e "keycode $LCONTROL_KEYCODE ="
