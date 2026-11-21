#!/usr/bin/env bash
# =============================================================================
# login/ly.sh — Install Ly TUI display manager with manual Hyprland login
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Ly Display Manager"

# ─── Remove old display managers ─────────────────────────────────────────────
for pkg in sddm greetd greetd-agreety greetd-tuigreet; do
    if is_installed "$pkg"; then
        msg "Removing $pkg..."
        sudo pacman -Rns --noconfirm "$pkg" || warn "Could not remove $pkg"
    fi
done

for unit in sddm.service greetd.service; do
    if unit_exists_system "$unit"; then
        sudo systemctl disable "$unit" 2>/dev/null || true
    fi
done
sudo rm -rf /etc/sddm.conf.d /etc/sddm.conf /etc/greetd
ok "SDDM / greetd removed"

# ─── Install Ly ───────────────────────────────────────────────────────────────
ensure_installed ly

# ─── Use the boot-active VT so Ly paints without a switch ────────────────────
TTY_NUM=1
[[ "$TTY_NUM" =~ ^[0-9]+$ ]] || TTY_NUM=2
LY_UNIT="ly@tty${TTY_NUM}.service"
GETTY_UNIT="getty@tty${TTY_NUM}.service"

# ─── Enable Ly, retire getty on that TTY ─────────────────────────────────────
sudo systemctl disable "$GETTY_UNIT" 2>/dev/null || true
sudo systemctl mask "$GETTY_UNIT" 2>/dev/null || true
sudo systemctl enable "$LY_UNIT"
ok "Ly enabled on tty${TTY_NUM} — starts on next boot"

# ─── Deploy Catppuccin Mocha theme ───────────────────────────────────────────
LY_THEME_DIR="$COZY_DIR/default/ly"
if [[ -f $LY_THEME_DIR/config.ini && -f $LY_THEME_DIR/startup.sh && -f $LY_THEME_DIR/rain.dur ]]; then
    for theme_file in config.ini startup.sh rain.dur; do
        target="/etc/ly/$theme_file"
        if [[ -f $target ]] && ! cmp -s "$LY_THEME_DIR/$theme_file" "$target"; then
            sudo cp -a "$target" "${target}.bak"
        fi
        mode=644
        [[ $theme_file == startup.sh ]] && mode=755
        sudo install -m "$mode" "$LY_THEME_DIR/$theme_file" "$target"
    done
    ok "Ly themed with Catppuccin Mocha (config, console palette, light rain)"
else
    warn "Ly theme assets missing in $LY_THEME_DIR — keeping existing config"
fi
