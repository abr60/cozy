#!/usr/bin/env bash
# =============================================================================
# hardware/monitor-autodetect.sh — Auto-configure monitors.local.lua
# Detects connected monitors via hyprctl and writes the best refresh rate
# for each. Only runs if Hyprland is active.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Monitor Auto-Detection"

MONITORS_CONF="$HOME/.config/hypr/monitors.local.lua"

if ! command -v hyprctl &>/dev/null; then
    warn "hyprctl not found — skipping monitor detection"
    exit 0
fi

if ! hyprctl monitors &>/dev/null 2>&1; then
    warn "Hyprland not running — skipping monitor detection"
    exit 0
fi

TEMP_CONF=$(mktemp)

# Parse hyprctl output — pick highest refresh rate per monitor
hyprctl monitors | awk '
    /^Monitor / {
        if (monitor && mode) printf "hl.monitor({ output = \"%s\", mode = \"%s\", position = \"auto\", scale = 1 })\n", monitor, mode
        monitor = $2
        gsub(/[()]/, "", monitor)
        mode = ""
        max_refresh = 0
    }
    /availableModes:/ {
        modes_line = $0
        sub(/.*availableModes: /, "", modes_line)
        split(modes_line, modes, " ")
        for (i in modes) {
            if (modes[i] ~ /@/) {
                split(modes[i], parts, "@")
                refresh = parts[2]
                sub(/Hz$/, "", refresh)
                if (refresh + 0 > max_refresh) {
                    max_refresh = refresh + 0
                    mode = modes[i]
                    sub(/Hz$/, "", mode)
                }
            }
        }
    }
    END {
        if (monitor && mode) printf "hl.monitor({ output = \"%s\", mode = \"%s\", position = \"auto\", scale = 1 })\n", monitor, mode
    }
' > "$TEMP_CONF"

if grep -q "^hl\.monitor" "$TEMP_CONF"; then
    # Backup existing config
    if [[ -f "$MONITORS_CONF" ]]; then
        cp "$MONITORS_CONF" "${MONITORS_CONF}.bak"
        ok "Backed up existing monitors.local.lua"
    fi
    mv "$TEMP_CONF" "$MONITORS_CONF"
    ok "monitors.local.lua written:"
    grep "^hl\.monitor" "$MONITORS_CONF" | while read -r line; do
        echo "  $line"
    done
    hyprctl reload 2>/dev/null && ok "Hyprland reloaded" || true
else
    rm -f "$TEMP_CONF"
    warn "Could not detect monitor configuration — keeping existing"
fi
