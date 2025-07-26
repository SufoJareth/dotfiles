#!/bin/bash

# Adds "StartupWMClass=steam_app_<id>" to a .desktop file (usually located in ~/.local/share/applications) to
# resolve missing missing game icons on Steam games in GNOME applications overview
# and task switcher.

if [[ -z "$1" ]]; then
    echo "Usage: $0 <path_to_desktop_file>"
    exit 1
fi

DESKTOP_FILE="$1"

if [[ ! -f "$DESKTOP_FILE" ]]; then
    echo "File not found: $DESKTOP_FILE"
    exit 1
fi

GAME_ID=$(grep '^Exec=' "$DESKTOP_FILE" | grep -oP 'steam://rungameid/\K[0-9]+')

if [[ -z "$GAME_ID" ]]; then
    echo "Game ID not found in $DESKTOP_FILE"
    exit 1
fi

if grep -q '^StartupWMClass=' "$DESKTOP_FILE"; then
    sed -i "s|^StartupWMClass=.*|StartupWMClass=steam_app_$GAME_ID|" "$DESKTOP_FILE"
    exit 0
fi

echo "StartupWMClass=steam_app_$GAME_ID" >> "$DESKTOP_FILE"
