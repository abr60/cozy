#!/usr/bin/env bash
# Compatibility shim: canonical script lives in install/system/acpi-loglevel.sh
set -euo pipefail
COZY_DIR="${COZY_DIR:-$HOME/.local/share/Cozy}"
exec bash "$COZY_DIR/install/system/acpi-loglevel.sh" "$@"
