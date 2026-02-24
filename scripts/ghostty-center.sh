#!/bin/bash
# Open Ghostty and center it on screen

# Launch Ghostty in background
ghostty --gtk-single-instance=false &
sleep 0.5

# Find the newest Ghostty window
WID=$(xdotool search --class ghostty 2>/dev/null | tail -1)

if [ -n "$WID" ]; then
    # Get screen dimensions
    read SCREEN_W SCREEN_H <<< $(xdotool getdisplaygeometry)

    # Get window dimensions
    eval $(xdotool getwindowgeometry --shell "$WID" 2>/dev/null)

    # Calculate center position
    X=$(( (SCREEN_W - WIDTH) / 2 ))
    Y=$(( (SCREEN_H - HEIGHT) / 2 ))

    # Move and focus window
    xdotool windowmove "$WID" "$X" "$Y"
    xdotool windowactivate "$WID"
fi
