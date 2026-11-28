# Cozy — Agent Instructions

This repository is the source of truth for the Cozy Linux desktop.

## Task Guides

Deeper instructions for specific kinds of work live in `agents/skills/`. Read the matching guide before starting:

- [`agents/skills/contributing.md`](agents/skills/contributing.md) — repository conventions, install/update flow, before-commit checks
- [`agents/skills/skill-authoring.md`](agents/skills/skill-authoring.md) — adding or changing shipped agent skills
- [`agents/skills/command-metadata.md`](agents/skills/command-metadata.md) — adding or changing commands in `bin/`
- [`agents/skills/install-scripts.md`](agents/skills/install-scripts.md) — working under `install/` and on setup commands
- [`agents/skills/testing.md`](agents/skills/testing.md) — validation, portability checks, and agent-skill tests

## Documentation Layout

Three documentation trees, split by genre and audience:

- `agents/skills/` — task procedures for anyone working on this codebase
- `docs/` — reference on how the system is shaped; task guides link here for depth
- `default/agents/skills/` — shipped skills for end users, linked into every agent harness
- `manual/` — end-user documentation, never codebase internals

## Skill Rules

For end-user customization on an installed Cozy system, read and follow
`default/agents/skills/cozy/SKILL.md` and its matching topic guide:
`hyprland.md`, `waybar.md`, `theming.md`, `menu.md`, or `boot.md`.

- Edit files in this repo, not the stowed copies under `~/.config/`.
- `~/.local/share/Cozy` is a compatibility symlink to `$COZY_PATH`; do not treat it as a second copy.
- Shell scripts must stay `bash -n` clean; Lua configs must stay `luac -p` clean.
- The Cozy menu lives in `bin/menu` (Walker; symlink to `bin/libexec/cozy/desktop/menu`); Rofi remains installed for its standalone utilities.
- `cozy agent skills link` fans every shipped skill out to every harness and cleans stale own-links.
- `cozy agent instructions` links personal rules from `~/.agents/AGENTS.md` into harness-specific global files.
- `cozy test agent-skills` verifies linker behaviour and `SKILL.md` authoring rules.

## Style

- Two-space indentation in shell scripts; no tabs.
- Use bash conditionals: `[[ ]]` for strings/files, `(( ))` for numbers.
- Prefer `#!/bin/bash` for commands under `bin/`; install scripts may use `#!/usr/bin/env bash`.
- Use `cozy <group> <action>` in documentation, not bare bin names, unless explaining the source.
- Markdown docs use full lines; break only at structural boundaries.
