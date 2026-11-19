#!/usr/bin/env bash
# =============================================================================
# config/applications.sh
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Applications"

COZY_DIR="${COZY_DIR:-$HOME/.local/share/Cozy}"

SRC="$COZY_DIR/system/applications"
DEST="$HOME/.local/share/applications"

# ─── Applications ─────────────────────────────────────────────────────────────

if [[ ! -d "$SRC" ]]; then
    warn "Applications directory not found: $SRC"
    exit 0
fi

mkdir -p "$DEST"

# Copy everything exactly as-is
cp -a "$SRC"/. "$DEST"/
ok "Copied Cozy applications"

# Expand portable Icon=~ paths to absolute $HOME for this user
# (repo templates use ~/.local/... so they work for any username)
while IFS= read -r -d '' desktop; do
    if grep -q 'Icon=~/' "$desktop"; then
        sed -i "s|Icon=~/|Icon=$HOME/|g" "$desktop"
    fi
done < <(find "$DEST" -type f -name '*.desktop' -print0 2>/dev/null)
ok "Expanded Icon paths for $USER"

# Remove any top-level desktop files that also exist in hidden/
HIDDEN_DIR="$DEST/hidden"

if [[ -d "$HIDDEN_DIR" ]]; then
    while IFS= read -r -d '' hidden_file; do
        name="$(basename "$hidden_file")"
        target="$DEST/$name"

        if [[ -f "$target" ]]; then
            rm -f "$target"
            ok "Removed hidden application: $name"
        fi
    done < <(find "$HIDDEN_DIR" -type f -name '*.desktop' -print0)
fi

# ─── Update caches ────────────────────────────────────────────────────────────

update-desktop-database "$DEST" 2>/dev/null \
    && ok "Desktop database updated" \
    || true