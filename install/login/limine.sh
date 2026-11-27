#!/usr/bin/env bash
# =============================================================================
# install/login/limine.sh — Deploy Limine bootloader + snapper (Cozy)
# Adopts Omarchy's limine-snapper-sync mechanism, Cozy-branded.
# Idempotent; intended for setup/update/refresh flows. Do not run blindly on a
# live machine without understanding boot risk.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Limine Bootloader Config"

COZY_DIR="${COZY_DIR:-$HOME/.local/share/Cozy}"
DEFAULT_CONF="$COZY_DIR/default/limine/default.conf"
LIMINE_HEADER="$COZY_DIR/default/limine/limine.conf"
SNAPPER_ROOT="$COZY_DIR/default/snapper/root"
LIMINE_CONF="/boot/limine.conf"

# ─── Helpers ─────────────────────────────────────────────────────────────────
is_btrfs_root() {
  [[ "$(findmnt -n -o FSTYPE / 2>/dev/null)" == "btrfs" ]]
}

extract_cmdline() {
  local cfg cmdline=""
  for cfg in /boot/EFI/arch-limine/limine.conf /boot/EFI/BOOT/limine.conf \
             /boot/EFI/limine/limine.conf /boot/limine/limine.conf /boot/limine.conf; do
    if [[ -f "$cfg" ]]; then
      cmdline=$(grep "^[[:space:]]*cmdline:" "$cfg" | head -1 | sed 's/^[[:space:]]*cmdline:[[:space:]]*//')
      [[ -n "$cmdline" ]] && { echo "$cmdline"; return 0; }
    fi
  done
  if [[ -f /etc/kernel/cmdline ]]; then
    tr '\n' ' ' < /etc/kernel/cmdline | sed 's/[[:space:]]*$//'
    return 0
  fi
  tr '\n' ' ' < /proc/cmdline | sed 's/[[:space:]]*$//'
}

# ─── Ensure packages ─────────────────────────────────────────────────────────
ensure_installed limine
ensure_installed efibootmgr

if ! is_installed limine-mkinitcpio-hook 2>/dev/null; then
  msg "Installing limine-mkinitcpio-hook..."
  if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm limine-mkinitcpio-hook 2>&1 | tail -5 || warn "Install limine-mkinitcpio-hook manually: yay -S limine-mkinitcpio-hook"
  else
    warn "yay not found — install limine-mkinitcpio-hook manually"
  fi
else
  ok "limine-mkinitcpio-hook already installed"
fi

if is_btrfs_root; then
  ensure_installed snapper
  if ! pacman -Q limine-snapper-sync &>/dev/null; then
    msg "Installing limine-snapper-sync..."
    if command -v yay &>/dev/null; then
      yay -S --needed --noconfirm limine-snapper-sync 2>&1 | tail -5 || warn "Install limine-snapper-sync manually: yay -S limine-snapper-sync"
    else
      warn "yay not found — install limine-snapper-sync manually"
    fi
  else
    ok "limine-snapper-sync already installed"
  fi
fi

# ─── Validate templates ──────────────────────────────────────────────────────
[[ -f "$DEFAULT_CONF" ]] || { err "Missing $DEFAULT_CONF"; exit 1; }
[[ -f "$LIMINE_HEADER" ]] || { err "Missing $LIMINE_HEADER"; exit 1; }

# ─── Build /etc/default/limine (Omarchy mechanism, Cozy-branded) ─────────────
CMDLINE=$(extract_cmdline)
[[ -n "$CMDLINE" ]] || { err "Could not determine kernel cmdline"; exit 1; }

sudo mkdir -p /etc/default
tmp_default=$(mktemp)
trap 'rm -f "$tmp_default"' EXIT
cp "$DEFAULT_CONF" "$tmp_default"
# Replace placeholder with captured cmdline; keep it literal.
python3 - "$tmp_default" "$CMDLINE" <<'PY'
import sys, pathlib
path, cmdline = sys.argv[1], sys.argv[2]
p = pathlib.Path(path)
text = p.read_text()
p.write_text(text.replace('@@CMDLINE@@', cmdline))
PY

sudo cp "$tmp_default" /etc/default/limine
sudo chmod 644 /etc/default/limine
ok "Wrote /etc/default/limine"

# Drop-ins in /etc/limine-entry-tool.d are loaded natively by limine-entry-tool.
# We intentionally do not append them into /etc/default/limine to avoid duplicate
# KERNEL_CMDLINE entries.

# ─── Deploy limine.conf header ───────────────────────────────────────────────
# Keep a backup of existing config before overwriting.
if [[ -f "$LIMINE_CONF" ]]; then
  sudo cp -a "$LIMINE_CONF" "${LIMINE_CONF}.bak.cozy"
fi
sudo cp "$LIMINE_HEADER" "$LIMINE_CONF"
sudo chmod 644 "$LIMINE_CONF"
ok "Deployed Limine header to $LIMINE_CONF"

# ─── Optional background ─────────────────────────────────────────────────────
if [[ -f "$COZY_DIR/default/limine/limine.png" ]]; then
  sudo cp "$COZY_DIR/default/limine/limine.png" /boot/limine.png
  ok "Deployed /boot/limine.png"
fi

# ─── Snapper root config (btrfs) ─────────────────────────────────────────────
if is_btrfs_root && command -v snapper &>/dev/null; then
  if ! sudo snapper list-configs 2>/dev/null | awk -F'|' 'NR>2{gsub(/ /,"",$1); print $1}' | grep -qx root; then
    sudo snapper -c root create-config /
    ok "Created snapper root config"
  fi
  if [[ -f "$SNAPPER_ROOT" ]]; then
    sudo cp "$SNAPPER_ROOT" /etc/snapper/configs/root
    ok "Applied Cozy snapper root config"
  fi
  sudo btrfs quota disable / 2>/dev/null || true
  if command -v limine-snapper-sync &>/dev/null && command -v systemctl &>/dev/null; then
    sudo systemctl enable limine-snapper-sync.service 2>/dev/null || true
    ok "Enabled limine-snapper-sync.service"
  fi
fi

# ─── Re-enable mkinitcpio pacman hooks if disabled by previous flows ─────────
for hook in /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled \
            /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled; do
  if [[ -f "$hook" ]]; then
    sudo mv "$hook" "${hook%.disabled}"
    ok "Re-enabled $(basename "${hook%.disabled}")"
  fi
done

# ─── Build UKI / boot entries ────────────────────────────────────────────────
if command -v limine-update &>/dev/null; then
  sudo limine-update
  ok "limine-update completed"
elif command -v limine-mkinitcpio &>/dev/null; then
  sudo limine-mkinitcpio
  ok "limine-mkinitcpio completed"
else
  warn "Neither limine-update nor limine-mkinitcpio found; skipping UKI rebuild"
fi

if ! grep -q "^/+" "$LIMINE_CONF" 2>/dev/null; then
  warn "No boot entries detected in $LIMINE_CONF after rebuild"
fi

# ─── Snapper sync refresh ────────────────────────────────────────────────────
if command -v limine-snapper-sync &>/dev/null; then
  sudo limine-snapper-sync || warn "limine-snapper-sync failed"
fi

# ─── EFI registration / cleanup (guarded) ────────────────────────────────────
if [[ -d /sys/firmware/efi ]] && command -v limine-install &>/dev/null; then
  sudo limine-install || warn "limine-install failed"
  if command -v efibootmgr &>/dev/null; then
    # Remove stale archinstall Limine entry only when we have a Limine/Cozy entry present.
    if efibootmgr | grep -Eq 'Limine|Cozy'; then
      while IFS= read -r bootnum; do
        sudo efibootmgr -b "$bootnum" -B >/dev/null 2>&1 || true
      done < <(efibootmgr | grep -E "^Boot[0-9]{4}\*? Arch Linux Limine" | sed 's/^Boot\([0-9]\{4\}\).*/\1/')
    fi
  fi
fi

ok "Limine setup complete"
