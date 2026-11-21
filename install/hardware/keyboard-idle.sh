#!/usr/bin/env bash
# =============================================================================
# hardware/keyboard-idle.sh — Install the keyboard-idle systemd user service
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Keyboard Idle"

if ! has_battery; then
    warn "No battery detected — skipping keyboard idle"
    exit 0
fi

INSTALL_DIR="${INSTALL_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)}"
SERVICE_SRC="$INSTALL_DIR/config/systemd/user/keyboard-idle.service"
SERVICE_DEST="$HOME/.config/systemd/user/keyboard-idle.service"

if [[ ! -f "$SERVICE_SRC" ]]; then
    die "Keyboard-idle service source not found: $SERVICE_SRC"
fi

# Copy the service file to the user systemd directory
mkdir -p "$HOME/.config/systemd/user"
cp "$SERVICE_SRC" "$SERVICE_DEST"
ok "Installed service : $SERVICE_DEST"

# Enable the user service
if enable_user_service keyboard-idle.service; then
    ok "Enabled user service : keyboard-idle.service"
else
    warn "Failed to enable keyboard-idle.service (may already be enabled)"
fi

# Start it if not running
if systemctl --user is-active keyboard-idle.service &>/dev/null; then
    ok "keyboard-idle.service already running"
else
    systemctl --user start keyboard-idle.service \
        && ok "Started keyboard-idle.service" \
        || warn "Could not start keyboard-idle.service"
fi