#!/usr/bin/env bash
# =============================================================================
# install/login/agents.sh — Wire Cozy's agent skills and instructions
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Agent Skills"

COZY_PATH="${COZY_PATH:-${COZY_DIR:-$HOME/.local/share/Cozy}}"
linker="$COZY_PATH/bin/cozy-agent-skills-link"
instructions="$COZY_PATH/bin/cozy-agent-instructions"

if [[ ! -x $linker ]]; then
    warn "Agent skill linker not found at $linker — skipping"
    exit 0
fi

"$linker" "$COZY_PATH"

if [[ -x $instructions ]]; then
    "$instructions" >/dev/null || warn "Could not link agent instructions"
fi

ok "Agent skills linked from $COZY_PATH/default/agents/skills"
