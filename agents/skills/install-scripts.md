# Install Scripts

Read this before working under `install/` or on system/user setup commands.

## Conventions

- Use `#!/usr/bin/env bash`, `set -euo pipefail`, then source `install/lib/helpers.sh` relative to `${BASH_SOURCE[0]}`.
- Start with a banner comment: `# install/<path> — <purpose>`.
- Use `section`, `msg`, `ok`, `warn`, `err`, `die`, `run_step`, `ensure_installed`, and `enable_*_service` from the helpers.
- Use `$COZY_PATH` / `$COZY_DIR` instead of hardcoded home paths. `~/.local/share/Cozy` is a compatibility symlink.
- Two-space indentation; `[[ ]]` for strings/files and `(( ))` for numbers.

## Flow

- `setup.sh` → packages → shell (zsh) → dotfiles (stow) → system/hardware/services → login (Ly, Limine, Plymouth, agents).
- `update.sh` is remote-first: fetch/re-apply, then boot sync, config symlinks, agent relink, UI reload.
- Agent setup lives in `install/login/agents.sh`; it delegates to `cozy-agent-skills-link` and
  `cozy-agent-instructions` instead of maintaining its own target list.

## Privilege

Interactive terminal work → `sudo`. Non-interactive / agent-launched work → `pkexec` with a reason.
Don't wrap commands that already handle privilege themselves.

## Validation

```bash
bash -n install/**/*.sh setup.sh update.sh
cozy check paths
cozy test paths
```
