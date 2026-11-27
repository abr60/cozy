#!/usr/bin/env bash
# =============================================================================
# install/login/plymouth.sh — Install Cozy Plymouth theme + mkinitcpio hooks
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Plymouth Boot Splash"

COZY_DIR="${COZY_DIR:-$HOME/.local/share/Cozy}"
THEME_SRC="$COZY_DIR/default/plymouth/cozy"
THEME_DEST="/usr/share/plymouth/themes/cozy"

ensure_installed plymouth
ensure_installed ttf-liberation

if [[ ! -d "$THEME_SRC" ]]; then
  warn "Plymouth theme source not found at $THEME_SRC — skipping"
  exit 0
fi

sudo mkdir -p "$THEME_DEST"
sudo cp -a "$THEME_SRC"/. "$THEME_DEST/"
if [[ -f "$COZY_DIR/default/plymouth/plymouth.png" ]]; then
  sudo cp "$COZY_DIR/default/plymouth/plymouth.png" "$THEME_DEST/plymouth.png"
fi
ok "Theme files installed to $THEME_DEST"

sudo mkdir -p /etc/plymouth
printf '[Daemon]\nTheme=cozy\n' | sudo tee /etc/plymouth/plymouthd.conf >/dev/null
ok "Wrote /etc/plymouth/plymouthd.conf (Theme=cozy)"

# mkinitcpio drop-ins: keep Cozy LUKS/Plymouth/btrfs-overlayfs boot stack.
sudo mkdir -p /etc/mkinitcpio.conf.d
sudo tee /etc/mkinitcpio.conf.d/cozy_hooks.conf >/dev/null <<'HOOKS_EOF'
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs)

# Drop kms when NVIDIA owns every GPU (avoids pulling nouveau + 100MB GSP fw).
# Hybrid systems keep kms for iGPU early KMS at LUKS prompt.
if [[ " ${MODULES[*]:-} " == *" nvidia_drm "* ]]; then
  _cozy_nvidia_gpu=0
  _cozy_other_gpu=0
  for _cozy_pci in "${COZY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"/*; do
    if [[ ! -r $_cozy_pci/class || ! -r $_cozy_pci/vendor ]]; then
      _cozy_other_gpu=1
      continue
    fi
    [[ $(<"$_cozy_pci/class") == "0x03"* ]] || continue
    if [[ $(<"$_cozy_pci/vendor") == "0x10de" ]]; then
      _cozy_nvidia_gpu=1
    else
      _cozy_other_gpu=1
    fi
  done
  if ((_cozy_nvidia_gpu && !_cozy_other_gpu)); then
    _cozy_hooks=()
    for _cozy_hook in "${HOOKS[@]}"; do
      [[ $_cozy_hook == "kms" ]] || _cozy_hooks+=("$_cozy_hook")
    done
    HOOKS=("${_cozy_hooks[@]}")
  fi
  unset _cozy_nvidia_gpu _cozy_other_gpu _cozy_pci _cozy_hooks _cozy_hook
fi

# Bundle vconsole.conf so Plymouth uses the configured layout at LUKS prompt,
# but only for Latin layouts — bundling Hebrew/Cyrillic/Arabic would make the
# Latin passphrase untypeable and lock the user out.
if [[ -f /etc/vconsole.conf ]]; then
  case $(. /etc/vconsole.conf && echo "${XKBLAYOUT%%,*}") in
    af | am | ara | bd | bg | by | et | ge | gr | il | in | iq | ir | kg | kh | kz | la | lk | mk | mm | mn | mv | np | rs | ru | sy | th | tj | ua) ;;
    *) FILES+=(/etc/vconsole.conf) ;;
  esac
fi
HOOKS_EOF
ok "Wrote /etc/mkinitcpio.conf.d/cozy_hooks.conf"

if [[ ! -f /etc/mkinitcpio.conf.d/cozy_resume.conf ]]; then
  sudo tee /etc/mkinitcpio.conf.d/cozy_resume.conf >/dev/null <<'RESUME_EOF'
HOOKS+=(resume)
RESUME_EOF
  ok "Wrote /etc/mkinitcpio.conf.d/cozy_resume.conf"
fi

msg "Rebuilding initramfs / UKIs..."
if command -v limine-mkinitcpio &>/dev/null; then
  sudo limine-mkinitcpio
  ok "UKIs rebuilt via limine-mkinitcpio"
elif command -v mkinitcpio &>/dev/null; then
  sudo mkinitcpio -P
  ok "initramfs rebuilt via mkinitcpio -P"
else
  warn "No initramfs rebuild tool found"
fi

if command -v limine-snapper-sync &>/dev/null; then
  sudo limine-snapper-sync || true
fi

ok "Plymouth setup complete"
