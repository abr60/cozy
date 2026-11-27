---
name: cozy
description: >
  REQUIRED for the user's Cozy Arch Linux + Hyprland dotfiles and system config.
  Use when editing ~/.config/hypr/, ~/.config/waybar/, ~/.config/rofi/,
  ~/.config/walker/, or any file in ~/.config/ on a Cozy system, or when working inside
  the Cozy repo at $COZY_PATH / ~/.local/share/Cozy.
  Triggers: Hyprland, window rules, animations, keybindings, monitors,
  gaps, borders, blur, opacity, Waybar, Walker launcher/menu, Rofi utilities, themes, background,
  night light, idle, lock screen, screenshots, reminders, layer rules,
  workspace settings, display config, Limine, Plymouth, LUKS, and
  user-facing `cozy` commands.
---

# Cozy Skill

Manage **Cozy** — the user's personal Arch Linux + Hyprland setup and dotfiles.

Cozy is exposed at `$COZY_PATH` (default `~/.local/share/Cozy`, also exported as `$COZY_DIR`) during setup. That path is the **source of truth** for all scripts (`$COZY_PATH/default/`, `$COZY_PATH/config/`, `$COZY_PATH/bin/`, `$COZY_PATH/install/`).

> `~/.agents/skills/cozy` is a **symlink** to `~/.local/share/Cozy/default/agents/skills/cozy` (also linked into `~/.claude/skills/`, `~/.codex/skills/`, `~/.pi/agent/skills/`, `~/.gemini/config/skills/`, `~/.hermes/skills/`, and `~/.config/opencode/skills/`).

## When This Skill MUST Be Used

**Always invoke this skill for requests involving:**

- Editing ANY file in `~/.config/hypr/` (hyprland.lua, bindings.lua, monitors.lua, input.lua, looknfeel.lua, autostart.lua, hypridle/hyprlock/hyprsunset configs)
- Editing `~/.config/waybar/` (bar layout, modules)
- Editing `~/.config/rofi/` or Rofi utilities
- Editing the Cozy menu (`$COZY_PATH/bin/menu`), `~/.config/walker/`, or Elephant providers (`config/elephant/`)
- Editing ANY file in `~/.config/` on a Cozy system
- Window behavior, animations, opacity, blur, gaps, borders, workspaces
- Themes, backgrounds, fonts, appearance (`bin/theme-*`, `bin/theme-bg-*`, `bin/font-*`)
- Boot stack: Limine (`/boot/limine.conf`), Plymouth, LUKS (`/etc/kernel/cmdline`, `/etc/mkinitcpio.conf.d/`)
- User-facing `cozy`/`cozy` commands (`cozy theme ...`, `cozy refresh ...`, etc.)
- Working inside the Cozy repo itself (`$COZY_PATH/setup.sh`, `update.sh`, `install/`, `bin/`, `default/`, `config/`, `applications/`)

**If you're about to edit a config file in `~/.config/` or touch `$COZY_PATH/`, STOP and use this skill first.**

## Topic Guides

Deeper instructions live next to this file. Read the matching guide before starting:

- [`hyprland.md`](hyprland.md) — keybindings, monitors, window rules, Hyprland Lua config
- [`waybar.md`](waybar.md) — Waybar layout, modules, styling
- [`theming.md`](theming.md) — themes, backgrounds, fonts
- [`menu.md`](menu.md) — Walker menu (`bin/menu`), command dispatcher (`bin/cozy` / `bin/cozy-*/`)
- [`boot.md`](boot.md) — Limine + LUKS + Plymouth + mkinitcpio
- [`contributing.md`](contributing.md) — hacking on the Cozy repo itself

## Critical Safety Rules

**For end-user customization, NEVER modify `/usr/share/Cozy/` or the installed `~/.local/share/Cozy` copy directly** — edit the repo at `$COZY_PATH/` and re-run `install/` scripts or `update.sh`. Reading is always safe.

```
$COZY_PATH/                        # EDIT HERE (git repo, then update.sh)
├── bin/                         # Commands (cozy-*, cozy-*, menu, webapp-*, theme-*)
├── config/                      # Dotfiles deployed via stow (hypr, waybar, rofi, etc.)
├── default/                     # System defaults (limine/limine.conf, agents/skills/*)
├── applications/                # Desktop entries (Webapps/*.desktop, icons/*.png)
├── install/                     # Setup scripts (lib/helpers.sh, login/, system/, hardware/, packaging/)
├── themes/                      # Themes
├── setup.sh                     # First-time installer
└── update.sh                    # Remote-first updater (git fetch + re-apply)
```

**Safe edit locations:**
- `$COZY_PATH/config/<app>/` — dotfiles (stowed to `~/.config/`)
- `$COZY_PATH/default/agents/skills/cozy/` — this skill itself
- `$COZY_PATH/bin/menu` — Walker menu structure (symlink to `bin/libexec/cozy/desktop/menu`)
- `~/.config/` — live user config (overwritten by `update.sh` re-apply, so prefer editing the repo)

## Privilege Escalation

Interactive terminal work → `sudo`. Non-interactive / agent-launched → `pkexec`. Don't wrap commands that already handle privilege themselves (e.g. `cozy-*` wrappers).

## System Architecture

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor | `~/.config/hypr/*.lua` + `hypr*.conf` |
| **Waybar** | Status bar | `~/.config/waybar/` |
| **Rofi** | Retained utilities (power menu, emoji, clipboard) | `~/.config/rofi/`, `bin/rofi-*` |
| **Walker** | App launcher + Cozy menu | `~/.config/walker/`, `config/elephant/`, `bin/menu` |
| **Ly** | Display manager | `/etc/ly/config.ini`, `ly@ttyX.service` |
| **Limine** | Bootloader (with LUKS/snapshots) | `/boot/limine.conf`, `/etc/default/limine`, `/etc/limine-entry-tool.d/` |
| **Plymouth** | Boot splash | `/usr/share/plymouth/themes/cozy/`, `/etc/plymouth/plymouthd.conf` |
| **Alacritty/Foot/Ghostty/Kitty** | Terminals | `~/.config/<terminal>/` |

## Command Discovery

Cozy ships an `cozy` dispatcher (also available as `cozy` on some installs) that routes `cozy <group> <action>` to `cozy-*` / `cozy-*` binaries:

```bash
cozy commands              # list every documented command
cozy theme --help
cozy agent --help
cozy-agent --help
bin/menu --help 2>/dev/null || cat $COZY_PATH/bin/menu | head -20
```

Prefer `cozy <group> <action>` — it's self-documenting and stable. The underlying `bin/*` binaries remain readable for source.

## Agents

Cozy links `default/agents/skills/cozy` into every supported agent skills dir
(`~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.pi/agent/skills`,
`~/.gemini/config/skills`, `~/.hermes/skills`, and
`~/.config/opencode/skills`) via `install/login/agents.sh` (run during `setup.sh`
and `update.sh`). Hermes profiles get their own links automatically.
`diagnose-crash` is also linked for crash triage. `bin/restart-opencode` (SIGUSR2)
reloads opencode after skill changes.
