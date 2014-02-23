pgrep hexchat
if [ $? -eq 0 ]; then
    hexchat -ec 'gui show'
else
    hexchat
fi
