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
# Ly runs this as root without a user HOME, so accept several candidate roots;
# the systemd drop-in installed by login/ly.sh normally provides COZY_PATH.
RAIN_GEN=""
for cozy_base in "${COZY_PATH:-}" "${HOME:-}/.local/share/Cozy" /home/abr/.local/share/Cozy /usr/share/Cozy; do
    [ -n "$cozy_base" ] || continue
    if [ -x "$cozy_base/default/ly/generate-rain.py" ]; then
        RAIN_GEN="$cozy_base/default/ly/generate-rain.py"
        break
    fi
done

log_rain() {
    if command -v logger >/dev/null 2>&1; then
        logger -t cozy-ly "$*"
    fi
}

if [ -z "$RAIN_GEN" ]; then
    log_rain "generate-rain.py not found; keeping existing rain.dur"
else
    size=$(stty size 2>/dev/null </dev/tty)
    [ -n "$size" ] || size=$(stty size 2>/dev/null </dev/tty2)
    set -- $size
    if [ -z "$1" ] || [ -z "$2" ]; then
        log_rain "could not read console size; keeping existing rain.dur"
    elif python3 "$RAIN_GEN" /etc/ly/rain.dur "$2" "$1" >/dev/null 2>&1; then
        :
    else
        log_rain "rain regeneration failed; keeping existing rain.dur"
    fi
fi