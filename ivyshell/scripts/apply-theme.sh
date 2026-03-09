#!/bin/sh
SLUG=$1

NIRI_THEMES="$HOME/.config/niri/themes"
NIRI_COLORS="$HOME/.config/niri/colors.kdl"

if [ ! -f "$NIRI_THEMES/$SLUG.kdl" ]; then
    echo "ivyshell: niri theme '$SLUG' not found, skipping" >&2
    notify-send -u low "IvyShell" "niri: no variant for '$SLUG', skipped"
else
    echo "include \"themes/$SLUG.kdl\"" > "$NIRI_COLORS"
    notify-send -u low "IvyShell" "Theme applied: $SLUG"
fi
