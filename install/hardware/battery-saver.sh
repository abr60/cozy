#!/usr/bin/env bash
# =============================================================================
# hardware/battery-saver.sh — Apply battery-saver dimming/brightness on AC/battery
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Battery Saver"

if ! has_battery; then
    warn "No battery detected — skipping battery saver"
    exit 0
fi

INSTALL_DIR="${INSTALL_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)}"
COZY_PATH="${COZY_PATH:-$HOME/.local/share/Cozy}"

# Ensure the persistent-nag hook is installed
HOOK_SRC="$INSTALL_DIR/hooks/battery-low/persistent-nag"
if [[ ! -f "$HOOK_SRC" ]]; then
    warn "Persistent-nag hook not found — installing it now"
    bash "$INSTALL_DIR/hardware/battery-low-hook.sh"
fi

# ── Helper: set absolute brightness ──────────────────────────────────────────
set_abs_brightness() {
    local target="$1"
    command -v brightnessctl &>/dev/null || return 0
    # Clamp to valid range
    if (( target < 1 )); then target=1; fi
    if (( target > 100 )); then target=100; fi
    brightnessctl set "${target}%" 2>/dev/null || true
}

# ── Check if we are on AC or battery ─────────────────────────────────────────
if bash "$COZY_PATH/bin/libexec/cozy/hardware/ac-present" &>/dev/null; then
    # Plugged in: performance profile, 45% brightness
    powerprofilesctl set performance 2>/dev/null || true
    set_abs_brightness 45
    ok "On AC — performance profile, 45% brightness"
    exit 0
fi

# On battery — determine which tier
capacity=""
capacity=$(upower -i $(upower -e | grep 'BAT' | head -n 1) 2>/dev/null | awk '/percentage/ {print $2}' | tr -d '%') || true

if [[ -z "$capacity" || ! "$capacity" =~ ^[0-9]+$ ]]; then
    warn "Could not read battery capacity — using balanced profile"
    powerprofilesctl set balanced 2>/dev/null || true
    exit 0
fi

if (( capacity >= 30 )); then
    # Unplugged ≥30%: balanced, 35% brightness
    powerprofilesctl set balanced 2>/dev/null || true
    set_abs_brightness 35
    ok "On battery (≥30%) — balanced profile, 35% brightness"
else
    # Unplugged <30%: power-saver, 25% brightness (or 10% if <10%)
    if (( capacity < 10 )); then
        powerprofilesctl set power-saver 2>/dev/null || true
        set_abs_brightness 10
    else
        powerprofilesctl set power-saver 2>/dev/null || true
        set_abs_brightness 25
    fi
    ok "On battery (<30%) — power-saver profile, ${capacity}<10?10:25% brightness"
fi

# Keyboard backlight left untouched — stays off by default
# (keyboard-idle daemon handles 10-min auto-off when active)
