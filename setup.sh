#!/usr/bin/env bash
# =============================================================================
# Cozy - Setup Entry Point
# Usage: bash /path/to/COZY/setup.sh
# =============================================================================

set -euo pipefail

DOTS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
export COZY_PATH="${COZY_PATH:-$HOME/.local/share/Cozy}"
export COZY_PATH="$COZY_PATH"
export COZY_DIR="$COZY_PATH"
LEGACY_COZY_DIR="$HOME/.local/share/Cozy"
export INSTALL_DIR="$DOTS_DIR/install"

source "$INSTALL_DIR/lib/helpers.sh"

# ==========================================
# 1. DEPENDENCY CHECK
# ==========================================
ensure_installed gum

# ==========================================
# 2. SPLASH — colored, centered logo
# ==========================================
# Set TTY background to deep forest shadow
printf "\e]P0$C_TTY_BG"

print_logo

# ==========================================
# 3. WARNING & CONFIRMATION
# ==========================================
gum style \
    --foreground "$C_ERROR" --border-foreground "$C_ERROR" --border double \
    --align center --width "$TERM_WIDTH" --padding "0 1" \
    "WARNING: SYSTEM MODIFICATION" \
    "This script will make changes to your system."

echo ""
gum style \
    --foreground "$C_ACCENT" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  • Symlink dotfiles into ~/.config via Stow" \
    "  • Install core packages via pacman and yay" \
    "  • Set up fonts, binaries, and desktop apps" \
    "  • Configure system settings and services" \
    "  • Set up Ly, Plymouth, and Limine" \
    "  • Change your default shell to Zsh"

echo ""
gum style \
    --foreground "$C_MUTED" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  Optional steps (GPU drivers, plugins, wallpapers," \
    "  Git identity, Howdy, Spicetify etc.) run on first login."

echo ""
gum confirm "Proceed?" || { msg "Aborted."; exit 0; }

# ==========================================
# 4. LINK COZY AND KEEP THE COZY COMPATIBILITY PATH
# ==========================================
msg "Linking Cozy to $COZY_PATH..."
mkdir -p "$(dirname "$COZY_PATH")"
if [[ -d "$COZY_PATH" && ! -L "$COZY_PATH" ]]; then
    die "$COZY_PATH exists as a directory; move it before linking Cozy"
fi
if [[ "$COZY_PATH" != "$DOTS_DIR" ]]; then
    # Relative target keeps the link valid if the home directory moves.
    ln -sfnT --relative "$DOTS_DIR" "$COZY_PATH"
fi
if [[ "$LEGACY_COZY_DIR" != "$COZY_PATH" ]]; then
    if [[ -d "$LEGACY_COZY_DIR" && ! -L "$LEGACY_COZY_DIR" ]]; then
        warn "Leaving existing Cozy directory untouched: $LEGACY_COZY_DIR"
    else
        ln -sfnT --relative "$DOTS_DIR" "$LEGACY_COZY_DIR"
    fi
fi
mkdir -p "$HOME/.local/state/Cozy/toggles/hypr"
ok "Cozy linked; legacy Cozy alias retained when safe"

# ==========================================
# 5. MAKE ALL SCRIPTS EXECUTABLE
# ==========================================
msg "Setting permissions..."
find "$DOTS_DIR" -type f \( \
    -name "*.sh" \
    -o -name "*.bash" \
    -o -path "*/bin/*" \
    -o -path "*/scripts/*" \
\) -exec chmod +x {} +
chmod +x "$DOTS_DIR/setup.sh" "$DOTS_DIR/update.sh" "$DOTS_DIR/post-install.sh"
ok "Permissions set"

# ==========================================
# 6. RUN INSTALL STEPS
# ==========================================
START_TIME=$SECONDS

# ── Packages ──────────────────────────────────────────────────────────────────
run_step "packaging/packages"             "Installing core packages"        true

# ── Shell ─────────────────────────────────────────────────────────────────────
run_step "config/zsh.sh"                  "Setting up Zsh"                  false

# ── Configs & dotfiles ────────────────────────────────────────────────────────
run_step "config/dotfiles.sh"             "Symlinking config files"         true

echo ""
section "Cleaning plugin configs"
if [[ -f "$INSTALL_DIR/extras/plugins.sh" ]]; then
    bash "$INSTALL_DIR/extras/plugins.sh" --clean
else
    warn "plugins.sh not found — skipping"
fi

run_step "config/applications.sh"         "Setting up applications"         false

# ── System tweaks ─────────────────────────────────────────────────────────────
run_step "system/fd-limit.sh"             "File descriptor limits"          false
run_step "system/file-watchers.sh"        "File watchers"                   false
run_step "system/sudo-tries.sh"           "Sudo tries"                      false
run_step "system/input-group.sh"          "Input group"                     false
run_step "system/ssh-flakiness.sh"        "SSH flakiness fix"               false
run_step "system/network.sh"              "Network config"                  false
run_step "system/user-dirs.sh"            "User directories"                false
run_step "system/firewall.sh"             "Firewall"                        false
run_step "system/mimetypes.sh"            "Default apps"                    false

# ── Hardware ──────────────────────────────────────────────────────────────────
run_step "hardware/bluetooth.sh"          "Bluetooth"                       false
run_step "hardware/wifi-powersave.sh"     "WiFi powersave"                  false
run_step "system/battery-timer.sh"        "Battery / screen-time timer"     false
run_step "hardware/fast-shutdown.sh"      "Fast shutdown"                   false
run_step "hardware/unmount-fuse.sh"       "FUSE unmount hook"               false
run_step "hardware/swayosd.sh"            "SwayOSD"                         false
run_step "hardware/recover-monitor.sh"    "Monitor recovery"                false

# ── Services ──────────────────────────────────────────────────────────────────
run_step "services/all.sh"    "services"                 false
run_step "hardware/battery-low-hook.sh" "Low-battery hook" false
run_step "hardware/battery-saver.sh"    "Battery saver" false
run_step "hardware/keyboard-idle.sh"    "Keyboard idle" false

# ── Login / Boot Stack ────────────────────────────────────────────────────────
run_step "login/ly.sh"                    "Ly display manager"              false
run_step "login/limine.sh"                "Limine bootloader"               true
run_step "login/plymouth.sh"              "Plymouth"                        true
run_step "system/acpi-loglevel.sh"        "ACPI console log level"          false
run_step "login/agents.sh"                "Agent skills"                    false

# ==========================================
# 7. DONE
# ==========================================
DURATION=$(( SECONDS - START_TIME ))
echo ""
gum style \
    --foreground "$C_SUCCESS" --border-foreground "$C_SUCCESS" --border rounded \
    --align center --width "$TERM_WIDTH" --padding "1 2" \
    "✓ BASE INSTALL DONE!" \
    "Finished in ${DURATION}s"

echo ""
gum style \
    --foreground "$C_TEAL" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  Post-install wizard runs on first login." \
    "  Git, timezone, plugins, wallpapers, GPU drivers," \
    "  Howdy, Spicetify and more."

echo ""
gum confirm "Reboot now?" && sudo reboot || msg "Reboot skipped — reboot manually when ready."