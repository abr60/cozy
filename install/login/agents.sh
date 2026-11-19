#!/usr/bin/env bash
# =============================================================================
# install/login/agents.sh — Link Cozy agent skills into all agent dirs
# Mirrors cozy migrations 1786098807 + 1786539345
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Agent Skills"

COZY_DIR="${COZY_DIR:-$HOME/.local/share/Cozy}"
SKILLS_SRC="$COZY_DIR/default/agents/skills"

if [[ ! -d "$SKILLS_SRC" ]]; then
    warn "Skills source not found at $SKILLS_SRC — skipping"
    exit 0
fi

# Discover skills shipped in default/agents/skills/*
skills=()
while IFS= read -r -d '' skill_dir; do
    skills+=("$(basename "$skill_dir")")
done < <(find "$SKILLS_SRC" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

if ((${#skills[@]} == 0)); then
    warn "No skills found in $SKILLS_SRC — skipping"
    exit 0
fi

msg "Found skills: ${skills[*]}"

# All agent skill directories (opencode, copilot, gemini, hermes, codex, pi, claude)
target_dirs=(
    "$HOME/.agents/skills"
    "$HOME/.claude/skills"
    "$HOME/.codex/skills"
    "$HOME/.pi/agent/skills"
    "$HOME/.copilot/skills"
    "$HOME/.gemini/config/skills"
    "$HOME/.hermes/skills"
    "$HOME/.config/opencode/skills"
)

# Hermes keeps a separate skills dir per profile.
for profile in "$HOME"/.hermes/profiles/*/; do
    [[ -d $profile ]] && target_dirs+=("${profile%/}/skills")
done

for target in "${target_dirs[@]}"; do
    mkdir -p "$target"
    for skill in "${skills[@]}"; do
        src="$SKILLS_SRC/$skill"
        dest="$target/$skill"
        ln -sfn "$src" "$dest"
        ok "Linked $skill → $dest"
    done
done

# Reload opencode if running (picks up new skills)
if command -v restart-opencode &>/dev/null; then
    restart-opencode 2>/dev/null || true
    ok "Opencode reloaded"
elif pgrep -x opencode &>/dev/null; then
    killall -SIGUSR2 opencode 2>/dev/null || true
    ok "Opencode reloaded (SIGUSR2)"
fi

ok "Agent skills linked (${#skills[@]} skills → ${#target_dirs[@]} dirs)"
