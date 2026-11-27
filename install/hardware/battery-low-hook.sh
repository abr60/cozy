#!/usr/bin/env bash
# =============================================================================
# hardware/battery-low-hook.sh — Install the persistent low-battery hook
# Ported from Omarchy's config/omarchy/hooks/battery-low.d/persistent-nag.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Low-Battery Hook"

if ! has_battery; then
    warn "No battery detected — skipping low-battery hook"
    exit 0
fi

INSTALL_DIR="${INSTALL_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)}"
HOOK_SRC="$INSTALL_DIR/hooks/battery-low/persistent-nag"
HOOK_DEST="$HOME/.config/Cozy/hooks/battery-low.d/persistent-nag"

if [[ ! -f "$HOOK_SRC" ]]; then
    die "Hook source not found: $HOOK_SRC"
fi

install -Dm755 "$HOOK_SRC" "$HOOK_DEST"
ok "Installed hook : $HOOK_DEST"

# The timer calls the hook through the `hook` dispatcher every 30 seconds.
if unit_exists_user battery-monitor.timer; then
    systemctl --user enable --now battery-monitor.timer \
        && ok "Enabled timer  : battery-monitor.timer" \
        || warn "Could not enable battery-monitor.timer"
else
    warn "battery-monitor.timer not found — the hook will not run automatically"
fi

if ! command -v brightnessctl &>/dev/null; then
    warn "brightnessctl missing — critical dimming will be skipped"
fi
