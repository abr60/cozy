#!/usr/bin/env bash
# =============================================================================
# system/battery-timer.sh — Install the bat-screentime power/idle tracker
#
# Installs:
#   /usr/local/bin/bat-screentime-hook          root-owned udev/hypridle hook
#   /etc/udev/rules.d/99-battery-timer.rules    aggregate power-source rule
#   group "powerread" + ACLs on /var/lib/upower read-only history fallback
#
# The user-facing CLI stays in the Cozy repo:
#   bin/bat-screentime -> libexec/cozy/system/bat-screentime
#
# Idempotent: safe to re-run from setup.sh or update.sh.
# =============================================================================

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"
set -e

section "Battery / Screen-Time Timer"

if ! has_battery; then
    warn "No battery detected — skipping battery timer"
    exit 0
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd -P)"
COZY_DIR="$REPO_DIR"

HOOK_SRC="$COZY_DIR/bin/libexec/cozy/system/bat-screentime-hook"
RULE_SRC="$COZY_DIR/system/udev/99-battery-timer.rules"
HOOK_DST="/usr/local/bin/bat-screentime-hook"
RULE_DST="/etc/udev/rules.d/99-battery-timer.rules"
ACL_GROUP="powerread"
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    TARGET_USER="$SUDO_USER"
elif [[ -n "${PKEXEC_UID:-}" ]]; then
    TARGET_USER="$(getent passwd "$PKEXEC_UID" | cut -d: -f1)"
else
    TARGET_USER="${USER:-$(id -un)}"
fi
[[ -f "$HOOK_SRC" ]] || die "Hook not found: $HOOK_SRC"
[[ -f "$RULE_SRC" ]] || die "udev rule not found: $RULE_SRC"
[[ -n "$TARGET_USER" && "$TARGET_USER" != "root" ]] || \
    die "Run this as your user, or via pkexec from your desktop session"

# ─── Root-owned hook + udev rule ──────────────────────────────────────────────
msg "Installing root-owned hook and udev rule..."
sudo install -o root -g root -m 0755 "$HOOK_SRC" "$HOOK_DST"
sudo install -o root -g root -m 0644 "$RULE_SRC" "$RULE_DST"
ok "Hook    : $HOOK_DST"
ok "Rule    : $RULE_DST"

# ─── Persistent read access to UPower history (fallback only) ─────────────────
msg "Granting read-only access to UPower history via group '$ACL_GROUP'..."
ensure_installed acl

if ! getent group "$ACL_GROUP" >/dev/null 2>&1; then
    sudo groupadd --system "$ACL_GROUP"
    ok "Created group $ACL_GROUP"
fi

if ! id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx "$ACL_GROUP"; then
    sudo usermod -aG "$ACL_GROUP" "$TARGET_USER"
    ok "Added $TARGET_USER to $ACL_GROUP"
fi

if [[ -d /var/lib/upower ]]; then
    # Traverse/read the directory and make future UPower files inherit the grant.
    # The explicit user ACL means this works immediately, before re-login.
    sudo setfacl -m  "g:${ACL_GROUP}:r-x" /var/lib/upower
    sudo setfacl -d -m "g:${ACL_GROUP}:r-x" /var/lib/upower
    sudo setfacl -m  "u:${TARGET_USER}:r-x" /var/lib/upower
    sudo setfacl -d -m "u:${TARGET_USER}:r-x" /var/lib/upower

    HISTORY_FILES=()
    while IFS= read -r -d '' file; do
        HISTORY_FILES+=("$file")
    done < <(find /var/lib/upower -maxdepth 1 -type f -name 'history-charge-*.dat' -print0)

    if [[ ${#HISTORY_FILES[@]} -gt 0 ]]; then
        sudo setfacl -m "g:${ACL_GROUP}:r" "${HISTORY_FILES[@]}"
        sudo setfacl -m "u:${TARGET_USER}:r" "${HISTORY_FILES[@]}"
        ok "Granted ${#HISTORY_FILES[@]} existing history file(s)"
    else
        warn "No history-charge-*.dat files yet — default ACL will apply to new ones"
    fi
else
    warn "/var/lib/upower does not exist yet — skipping history ACL"
fi

# ─── Activate ─────────────────────────────────────────────────────────────────
msg "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=power_supply --action=change

# Seed the aggregate state immediately so the first unplug is not missed.
sudo "$HOOK_DST" reevaluate
ok "Aggregate power state initialised"

# ─── Restart hypridle so the new listeners load ───────────────────────────────
if command -v restart-hypridle >/dev/null 2>&1; then
    if restart-hypridle >/dev/null 2>&1; then
        ok "hypridle restarted"
    else
        warn "Could not restart hypridle now — it will pick up the config next login"
    fi
else
    warn "restart-hypridle not found — restart hypridle after login"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
ok "Run 'bat-screentime' to see the current session"
if [[ ! -d /var/log/journal ]]; then
    warn "Persistent journal missing — suspend history before a reboot will be incomplete"
fi
