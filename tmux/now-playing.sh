#!/bin/sh
if [ "$(uname)" = "Darwin" ]; then
    osascript -e 'tell application "Music" to if player state is playing then "♫ " & artist of current track & " - " & name of current track' 2>/dev/null
else
    playerctl metadata --format '♫ {{ artist }} - {{ title }}' 2>/dev/null
fi
