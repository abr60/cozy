#!/bin/sh
# Executed by Ly before it takes control of the TTY.
# Catppuccin Mocha palette for the Linux console (OSC ]P0..P15).

if [ "$TERM" = "linux" ]; then
    COLORS="11111b f38ba8 a6e3a1 f9e2af 89b4fa cba6f7 94e2d5 cdd6f4"
    BRIGHT="45475a eba0ac a6e3a1 fab387 b4befe f5c2e7 89dceb f5e0dc"

    i=0
    for color in $COLORS $BRIGHT; do
        printf '\033]P%x%s\007' "$i" "$color"
        i=$(( i + 1 ))
    done

    clear # avoid background artifacting after changing the palette
fi

# Ensure the console loglevel is forced to 3 so ACPI errors stay out of the TTY
# (they may re-appear after early boot, especially after resume from suspend).
if [ -x /usr/bin/dmesg ]; then
    dmesg -n 3 2>/dev/null || true
fi

# Regenerate the rain animation for the actual console resolution so it always
# fills the screen (a .dur file is a fixed-size frame, unlike built-in animations).
RAIN_GEN=/home/abr/.local/share/Cozy/default/ly/generate-rain.py
if [ -x "$RAIN_GEN" ]; then
    size=$(stty size 2>/dev/null </dev/tty)
    [ -n "$size" ] || size=$(stty size 2>/dev/null </dev/tty2)
    set -- $size
    if [ -n "$1" ] && [ -n "$2" ]; then
        python3 "$RAIN_GEN" /etc/ly/rain.dur "$2" "$1" >/dev/null 2>&1 || true
    fi
fi