# Contributing to Cozy

Read this before changing the Cozy repository itself. End-user customization follows
`default/agents/skills/cozy/SKILL.md` instead.

- Repo: `git@github.com:abr60/cozy.git` (`$COZY_PATH`, branch `main`, remote `origin`). Public.
- Helpers: `install/lib/helpers.sh` — `section/msg/ok/warn/err/die`, `ensure_installed`, `is_installed` (`pacman -Q`), `run_step <script> <label> [critical]`, `COZY_DIR`, colors, `print_logo`, `gum` prompts, `enable_system_service`/`enable_user_service`.
- Install flow: `setup.sh` → packages → shell (zsh) → dotfiles (stow) → system/hardware/services → login (Ly, Limine, Plymouth, agents).
- Update flow: `update.sh` (remote-first: `git fetch` + re-apply, then boot sync, config symlinks, reload UI). Logs to `~/.local/state/Cozy/update-report.txt`.
- Adding a shipped skill: create `default/agents/skills/<name>/SKILL.md` with YAML `name:` and folded `description:`, add companion guides, then run `cozy agent skills link`. See [`skill-authoring.md`](skill-authoring.md).
- Adding a menu entry: edit `bin/libexec/cozy/desktop/menu` (`bin/menu` is a symlink), wire into the parent menu + `go_to_menu()`. Keep `menu()` width 295px, listview 15 lines.
- Adding a bin command: create `bin/libexec/cozy/<group>/<name>`, symlink `bin/<name>` to it, add `# cozy:summary=` metadata, `chmod +x`; dispatcher `bin/cozy` auto-discovers it. See [`command-metadata.md`](command-metadata.md).
- Portability: `cozy check paths` audits tracked files for hardcoded home paths and non-relative symlinks; `cozy relink` repairs Cozy-owned symlinks with relative targets; `cozy test paths` verifies generation with a fake `HOME`.
- Before commit: `bash -n` every changed shell script, `luac -p` changed Lua, and `cozy test agent-skills`.
- Commits should be atomic and messages succinct.

## Paths

`$COZY_PATH` is the source of truth. `~/.local/share/Cozy` is a compatibility symlink, not a second editable copy.
Never hardcode `/home/<user>` in a tracked file; use `$COZY_PATH`, `$COZY_DIR`, `$HOME`, or relative links.
