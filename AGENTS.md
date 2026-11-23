# Cozy — Agent Instructions

This repository is the source of truth for the Cozy Linux desktop.

Before changing anything in this repo, read and follow the Cozy skill:

- `default/agents/skills/cozy/SKILL.md`
- Use the matching guide when relevant: `hyprland.md`, `waybar.md`, `theming.md`, `menu.md`, `boot.md`, `contributing.md`.

Key rules:

- Edit files in this repo, not the stowed copies under `~/.config/`.
- Shell scripts must stay `bash -n` clean; Lua configs must stay `luac -p` clean.
- The Cozy menu lives in `bin/menu` (Walker; symlink to `bin/libexec/cozy/desktop/menu`); Rofi remains installed for its standalone utilities. Agent install/launch entries live under Install → AI → Coding Agents.
- `install/login/agents.sh` links this skill into every supported agent skill directory, including OpenCode, Gemini, Codex, Claude, Pi, and Hermes.
