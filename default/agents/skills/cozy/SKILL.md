---
name: cozy
description: >
  REQUIRED for end-user customization of the user's Cozy Arch Linux + Hyprland desktop, and when editing
  ANY file in ~/.config/ on a Cozy system or working inside the Cozy repo at $COZY_PATH. Triggers:
  Hyprland, keybindings, monitors, window rules, gaps, borders, blur, opacity, animations, workspaces,
  Waybar, Walker launcher/menu, Rofi utilities, themes, backgrounds, fonts, night light, idle, lock
  screen, screenshots, reminders, layer rules, display config, Limine, Plymouth, LUKS, and user-facing
  cozy commands. Not for Cozy source development. Making something new or contributing upstream follows
  the repo's agents/skills/ guides; reporting a bug follows cozy-contribute, and crash triage follows
  cozy-diagnose-crash.
---

# Cozy Skill

Manage **Cozy** — the user's personal Arch Linux + Hyprland setup and dotfiles.

This skill is for end-user customization on an installed Cozy system.
It is not for contributing to Cozy source code; read the repository task guides in `agents/skills/` for that.

Cozy is exposed at `$COZY_PATH` (also exported as `$COZY_DIR`). `~/.local/share/Cozy` is only a compatibility
symlink to that checkout. `$COZY_PATH` is the source of truth
for scripts, dotfiles under `config/`, defaults under `default/`, and installers under `install/`.

## When This Skill MUST Be Used

**Always invoke this skill for requests involving:**

- Editing ANY file in `~/.config/` on a Cozy system, especially `hypr/`, `waybar/`, `rofi/`, and `walker/`
- The Cozy menu (`$COZY_PATH/bin/menu`), Walker/Elephant providers, or Walker launcher behaviour
- Window behaviour, animations, opacity, blur, gaps, borders, workspaces, layer rules
- Themes, backgrounds, fonts, appearance (`theme-*`, `theme-bg-*`, `font-*` commands)
- Boot stack: Limine (`/boot/limine.conf`), Plymouth, LUKS (`/etc/kernel/cmdline`, `/etc/mkinitcpio.conf.d/`)
- Power, night light, idle, lock screen, screenshots, recording, reminders
- User-facing `cozy` commands (`cozy theme ...`, `cozy refresh ...`, `cozy agent ...`)

**If you're about to edit a config file in `~/.config/` or touch `$COZY_PATH/`, STOP and use this skill first.**

## Topic Guides

Deeper instructions live next to this file. Read the matching guide before starting:

- [`hyprland.md`](hyprland.md) — keybindings, monitors, window rules, Hyprland Lua config
- [`waybar.md`](waybar.md) — Waybar layout, modules, styling
- [`theming.md`](theming.md) — themes, backgrounds, fonts
- [`menu.md`](menu.md) — Walker menu (`bin/menu`) and command dispatcher
- [`boot.md`](boot.md) — Limine + LUKS + Plymouth + mkinitcpio

Making something new or changing Cozy itself belongs to the repository task guides in
`$COZY_PATH/agents/skills/`. Crash triage follows `cozy-diagnose-crash`; reporting a confirmed Cozy bug
upstream follows `cozy-contribute`.

## Critical Safety Rules

**For end-user customization, NEVER modify `/usr/share/Cozy/` or treat `~/.local/share/Cozy` as a second
editable copy.** On this machine those paths point at the checkout; edit `$COZY_PATH/` and re-run `install/`
scripts or `update.sh`. Reading is always safe.

```
$COZY_PATH/                        # EDIT HERE (git repo, then update.sh)
├── bin/                         # Commands (cozy-*, menu, theme-*, wrappers)
├── config/                      # Dotfiles deployed via stow (hypr, waybar, rofi, etc.)
├── default/                     # System defaults and shipped agent skills
├── install/                     # Setup scripts (lib/, login/, system/, hardware/, ...)
├── setup.sh                     # First-time installer
└── update.sh                    # Remote-first updater (fetch + re-apply)
```

**Safe edit locations:**

- `$COZY_PATH/config/<app>/` — dotfiles stowed to `~/.config/`
- `$COZY_PATH/default/agents/skills/<skill>/` — shipped agent skills
- `$COZY_PATH/bin/libexec/cozy/desktop/menu` — Walker menu (`bin/menu` is a symlink)
- `~/.config/` — live user config; `update.sh` re-applies the repo version, so prefer editing the repo

## Privilege Escalation

Interactive terminal work → `sudo`. Non-interactive / agent-launched work → `pkexec` with a reason.
Don't wrap commands that already manage privilege themselves.

## System Architecture

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor | `~/.config/hypr/*.lua` + `hypr*.conf` |
| **Waybar** | Status bar | `~/.config/waybar/` |
| **Rofi** | Retained utilities (power menu, emoji, clipboard) | `~/.config/rofi/`, `bin/rofi-*` |
| **Walker** | App launcher + Cozy menu | `~/.config/walker/`, `config/elephant/`, `bin/menu` |
| **Ly** | Display manager | `/etc/ly/config.ini`, `ly@ttyX.service` |
| **Limine** | Bootloader (LUKS/snapshots) | `/boot/limine.conf`, `/etc/default/limine` |
| **Plymouth** | Boot splash | `/usr/share/plymouth/themes/cozy/` |
| **Alacritty/Foot/Ghostty/Kitty** | Terminals | `~/.config/<terminal>/` |

## Command Discovery

Cozy ships one `cozy` dispatcher that routes `cozy <group> <action>` to the underlying `cozy-*` binaries.
Prefer it — it is self-documenting and stable.

```bash
cozy commands                       # list every documented command
cozy agent --help
cozy theme --help
cozy agent skills link              # relink shipped skills into every harness
cozy agent instructions             # relink personal global agent instructions
```

Read a command's source with `cat "$(which cozy-theme-set)"` or look under `$COZY_PATH/bin/libexec/cozy/`.

## Agents

Shipped skills live in `$COZY_PATH/default/agents/skills/` and are linked by `cozy-agent-skills-link`
into `~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.pi/agent/skills`,
`~/.gemini/config/skills`, `~/.hermes/skills`, `~/.config/opencode/skills`, and existing Hermes profiles.
A folder or link of your own with the same name wins. Renamed and removed skills are cleaned up on relink.

Personal rules for every agent live in `~/.agents/AGENTS.md`, linked into each harness's own global
instructions file by `cozy agent instructions`. Keep personal rules there, not in the shipped skill tree.

## Safe Customization Patterns

1. Read the live config and the repo source.
2. Edit `$COZY_PATH/config/<app>/` (or `~/.config/` only for a quick, non-repo change).
3. Validate: `hyprctl reload && hyprctl configerrors` for Hyprland; `bash -n` for shell scripts.
4. Apply with the relevant `cozy` command (`cozy restart ...`, `cozy refresh ...`).

## Decision Framework

1. Is there a user-facing `cozy` command? Use it.
2. Is it a config edit? Edit `$COZY_PATH/config/` and re-apply; never `/usr/share/Cozy/`.
3. Is it a new theme, command, menu entry, or other Cozy development task? Read `$COZY_PATH/agents/skills/`.
4. Is it a crash? Use `cozy-diagnose-crash`. A confirmed Cozy bug goes to `cozy-contribute`.
5. Unsure a command exists? Run `cozy commands`.

## Out of Scope

Do not use this skill to develop Cozy itself, add migrations, or write repository tests. Follow
`$COZY_PATH/AGENTS.md` and the guides in `$COZY_PATH/agents/skills/` instead.
