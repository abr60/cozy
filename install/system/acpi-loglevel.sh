#!/usr/bin/env bash
# =============================================================================
# system/acpi-loglevel.sh — Keep harmless ACPI firmware errors off the TTY
#
# Sets console loglevel=3 in every boot path that Cozy uses:
#   - /etc/kernel/cmdline      → embedded in the UKI (systemd-boot / firmware)
#   - cozy-defaults.conf       → KERNEL_CMDLINE used by limine-entry-tool
#
# Nothing is disabled. ACPI, sleep, battery, fans and CPU scaling stay intact;
# messages are still recorded in dmesg/journalctl, just not printed on the TTY.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "ACPI Console Log Level"

CMDLINE_FILE="/etc/kernel/cmdline"
LIMINE_DROPIN="/etc/limine-entry-tool.d/cozy-defaults.conf"
STAMP="$(date +%Y%m%d%H%M%S)"

ensure_loglevel_three() {
    local file="$1"
    local label="$2"

    if [[ ! -f "$file" ]]; then
        warn "$label not found — skipping"
        return 0
    fi

    local current
    current="$(sudo grep -oE 'loglevel=[0-9]+' "$file" | head -1 || true)"

    if [[ "$current" == "loglevel=3" ]]; then
        ok "$label already uses loglevel=3"
        return 0
    fi

    sudo cp -a "$file" "${file}.bak-acpi-${STAMP}"

    if [[ -n "$current" ]]; then
        sudo sed -i -E 's/loglevel=[0-9]+/loglevel=3/g' "$file"
        ok "$label: $current → loglevel=3"
    else
        local body
        body="$(sudo sed -e 's/[[:space:]]*$//' "$file")"
        printf '%s%sloglevel=3\n' "$body" "${body:+ }" | sudo tee "$file" >/dev/null
        ok "$label: appended loglevel=3"
    fi
}

ensure_loglevel_three "$CMDLINE_FILE" "/etc/kernel/cmdline"
ensure_loglevel_three "$LIMINE_DROPIN" "Limine entry-tool drop-in"

# Rebuild the UKI so the embedded .cmdline is updated.
if command -v limine-mkinitcpio &>/dev/null; then
    msg "Rebuilding UKIs (limine-mkinitcpio)..."
    sudo limine-mkinitcpio >/dev/null 2>&1 || warn "limine-mkinitcpio failed"
elif command -v mkinitcpio &>/dev/null; then
    msg "Rebuilding UKIs (mkinitcpio -P)..."
    sudo mkinitcpio -P >/dev/null 2>&1 || warn "mkinitcpio -P failed"
else
    warn "No UKI builder found — reboot required to apply"
fi

# Limine reads its own generated cmdline from limine.conf.
if command -v limine-entry-tool &>/dev/null; then
    msg "Regenerating Limine entries..."
    sudo limine-entry-tool >/dev/null 2>&1 || warn "limine-entry-tool failed"
fi

# Stop the flood in the current session too — no reboot needed for this part.
sudo dmesg -n 3 >/dev/null 2>&1 || true

ok "ACPI messages still land in journalctl/dmesg — only TTY printing is reduced"
warn "Reboot to apply the boot-time change"
