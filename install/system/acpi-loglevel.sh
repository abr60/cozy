#!/usr/bin/env bash
# =============================================================================
# system/acpi-loglevel.sh — Keep harmless ACPI firmware errors off the TTY
# Cozy/Omarchy Limine mechanism: /etc/default/limine is authoritative.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "ACPI Console Log Level"

DEFAULT_LIMINE="/etc/default/limine"
LEGACY_DROPIN="/etc/limine-entry-tool.d/cozy-defaults.conf"
CMDLINE_FILE="/etc/kernel/cmdline"

set_loglevel_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if sudo grep -q 'loglevel=' "$file"; then
    sudo sed -i -E 's/loglevel=[0-9]+/loglevel=3/g' "$file"
  else
    # Append loglevel=3 to kernel cmdline line where appropriate.
    if grep -q 'KERNEL_CMDLINE' "$file"; then
      sudo sed -i -E 's/(KERNEL_CMDLINE\[default\]\+="[^"]*)"/\1 loglevel=3"/' "$file" || true
    else
      printf ' %s\n' "loglevel=3" | sudo tee -a "$file" >/dev/null
    fi
  fi
  ok "Normalized loglevel=3 in $file"
}

# Primary: /etc/default/limine
if [[ -f "$DEFAULT_LIMINE" ]]; then
  set_loglevel_file "$DEFAULT_LIMINE"
else
  warn "$DEFAULT_LIMINE not found; run refresh-limine to create it"
fi

# Legacy compatibility
set_loglevel_file "$LEGACY_DROPIN"
set_loglevel_file "$CMDLINE_FILE"

if command -v limine-mkinitcpio &>/dev/null; then
  msg "Rebuilding UKIs via limine-mkinitcpio..."
  sudo limine-mkinitcpio >/dev/null 2>&1 || warn "limine-mkinitcpio failed"
elif command -v mkinitcpio &>/dev/null; then
  msg "Rebuilding initramfs via mkinitcpio -P..."
  sudo mkinitcpio -P >/dev/null 2>&1 || warn "mkinitcpio -P failed"
fi

# Apply to current session only; boot-time value comes from rebuilt UKI/entries.
sudo dmesg -n 3 >/dev/null 2>&1 || true
ok "TTY loglevel normalized; messages remain in journalctl/dmesg"
