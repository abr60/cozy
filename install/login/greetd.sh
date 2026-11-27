#!/usr/bin/env bash
# Safely source helpers; terminal size detection may fail in headless/container envs.
# "set -euo pipefail" is omitted here to avoid failure from /dev/tty/stty in such envs.
# Individual helpers (msg/ok/warn) work fine without it.
# =============================================================================
# install/login/greetd.sh — Install and enable Greetd + tuigreet
# =============================================================================
# Configures Greetd as the display manager with tuigreet TUI greeter,
# auto-launches Hyprland via uwsm after successful password login, and
# replaces SDDM if previously enabled.
#
# On non-T14 machines the script still runs but SDDM may be preferred;
# it only gates on whether greetd-tuigreet is available.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Greetd + tuigreet Display Manager"

# ── 1. Install packages ──────────────────────────────────────────────────────
msg "Installing greetd and tuigreet..."
ensure_installed greetd
ensure_installed greetd-tuigreet
ok "greetd + tuigreet installed"

# ── 2. Ensure greeter user ───────────────────────────────────────────────────
# The greeter user already exists in the Arch ISO, but guarantee groups.
if id -nG greeter | grep -qw video; then
    ok "greeter already in video group"
else
    sudo usermod -a -G video greeter && ok "Added greeter to video group" || \
        warn "Could not add greeter to video group"
fi

# Create cache directory for tuigreet remember feature
if [[ ! -d /var/cache/tuigreet ]]; then
    sudo mkdir -p /var/cache/tuigreet
    sudo chown greeter:greeter /var/cache/tuigreet
    sudo chmod 0755 /var/cache/tuigreet
    ok "Created /var/cache/tuigreet for tuigreet remember"
else
    ok "/var/cache/tuigreet already present"
fi

# ── 3. Write /etc/greetd/config.toml ────────────────────────────────────────
mkdir -p /etc/greetd

sudo tee /etc/greetd/config.toml >/dev/null << 'TOML_EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --cmd 'uwsm start -e -D Hyprland hyprland.desktop'"
user = "greeter"
TOML_EOF
ok "Wrote /etc/greetd/config.toml"

# ── 4. Deploy greetd PAM ────────────────────────────────────────────────────
# Mirrors the SDDM PAM so howdy (face) + fprintd (fingerprint) + pam_unix
# all work at the TUI greeter. Uses config/pam.sh backing.
msg "Deploying PAM configuration for greetd..."
source "$(dirname "${BASH_SOURCE[0]}")/../config/pam.sh" && ok "PAM configured" || \
    warn "PAM configuration had issues"

# ── 5. Disable SDDM (if enabled) and enable Greetd ─────────────────────────
msg "Managing display-manager services..."

# Disable sddm gracefully
if systemctl is-enabled sddm.service 2>/dev/null | grep -q 'enabled'; then
    sudo systemctl disable --now sddm.service 2>/dev/null && \
        ok "Disabled sddm.service" || \
        warn "Could not disable sddm.service (may already be disabled)"
else
    ok "sddm.service was not enabled"
fi

# Enable greetd (it aliases display-manager.service)
if ! systemctl is-enabled greetd.service 2>/dev/null | grep -q 'enabled'; then
    sudo systemctl enable greetd.service 2>/dev/null && \
        ok "Enabled greetd.service" || \
        warn "Could not enable greetd.service (may already be enabled)"
else
    ok "greetd.service was already enabled"
fi

# ── 6. Verify tuigreet can start a session ──────────────────────────────────
msg "Testing tuigreet session launch..."
# Run tuigreet in mock mode to verify it's functional; we don't actually
# authenticate since there's no greeter TTY available in this context.
if tuigreet --mock &>/dev/null; then
    ok "tuigreet mock mode passed"
else
    warn "tuigreet mock mode exited non-zero — may be expected in chroot/container"
fi

# ── 7. Summary ─────────────────────────────────────────────────────────────
echo ""
echo "Greetd + tuigreet setup complete."
echo ""
echo "What happens next:"
echo "  1. On reboot, tty1 will show the tuigreet TUI login prompt."
echo "  2. Enter your password (or use face/finger if set up)."
echo "  3. Successful auth auto-starts Hyprland via uwsm."
echo "  4. To revert to SDDM later: run 'sudo systemctl enable sddm.service && sudo systemctl disable greetd.service && sudo reboot'."
echo ""
echo "Manual controls:"
echo "  - F2: Edit session command"
echo "  - F3: List available sessions"
echo "  - F4: Change background animation"
echo "  - F12: Power menu (shutdown/reboot/suspend/hibernate)"
echo "  - --remember: pre-fills last username"
echo "  - /var/cache/tuigreet: stores remember state (owned by greeter user)"