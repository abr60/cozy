---
name: cozy
description: >
  REQUIRED for the user's Cozy Arch Linux + Hyprland dotfiles and system config.
  Use when editing ~/.config/hypr/, ~/.config/waybar/, ~/.config/rofi/,
  or any file in ~/.config/ on a Cozy system, or when working inside
  the Cozy repo at ~/Cozy / ~/.local/share/Cozy.
  Triggers: Hyprland, window rules, animations, keybindings, monitors,
  gaps, borders, blur, opacity, Waybar, Rofi menu, themes, background,
  night light, idle, lock screen, screenshots, reminders, layer rules,
  workspace settings, display config, Limine, Plymouth, LUKS, and
  user-facing `cozy` commands.
---

# Cozy Skill

Manage **Cozy** — the user's personal Arch Linux + Hyprland setup and dotfiles.

Cozy repo lives at `~/Cozy` (`/home/$USER/Cozy`) and is symlinked to `~/.local/share/Cozy` (`$COZY_DIR`) during setup. That symlink is the **source of truth** for all scripts (`$COZY_DIR/default/`, `$COZY_DIR/config/`, `$COZY_DIR/bin/`, `$COZY_DIR/install/`).

> `~/.agents/skills/cozy` is a **symlink** to `~/.local/share/Cozy/default/agents/skills/cozy` (also linked into `~/.claude/skills/`, `~/.codex/skills/`, `~/.pi/agent/skills/`, `~/.gemini/config/skills/`, `~/.hermes/skills/`, and `~/.config/opencode/skills/`).

## When This Skill MUST Be Used

**Always invoke this skill for requests involving:**

- Editing ANY file in `~/.config/hypr/` (hyprland.lua, bindings.lua, monitors.lua, input.lua, looknfeel.lua, autostart.lua, hypridle/hyprlock/hyprsunset configs)
- Editing `~/.config/waybar/` (bar layout, modules)
- Editing `~/.config/rofi/` or the Cozy menu (`~/Cozy/bin/menu`)
- Editing ANY file in `~/.config/` on a Cozy system
- Window behavior, animations, opacity, blur, gaps, borders, workspaces
- Themes, backgrounds, fonts, appearance (`bin/theme-*`, `bin/theme-bg-*`, `bin/font-*`)
- Boot stack: Limine (`/boot/limine.conf`), Plymouth, LUKS (`/etc/kernel/cmdline`, `/etc/mkinitcpio.conf.d/`)
- User-facing `cozy`/`cozy` commands (`cozy theme ...`, `cozy refresh ...`, etc.)
- Working inside the Cozy repo itself (`~/Cozy/setup.sh`, `update.sh`, `install/`, `bin/`, `default/`, `config/`, `applications/`)

**If you're about to edit a config file in `~/.config/` or touch `~/Cozy/`, STOP and use this skill first.**

## Topic Guides

Deeper instructions live next to this file. Read the matching guide before starting:

- [`hyprland.md`](hyprland.md) — keybindings, monitors, window rules, Hyprland Lua config
- [`waybar.md`](waybar.md) — Waybar layout, modules, styling
- [`theming.md`](theming.md) — themes, backgrounds, fonts
- [`menu.md`](menu.md) — Rofi menu (`bin/menu`), command dispatcher (`bin/cozy` / `bin/cozy-*/`)
- [`boot.md`](boot.md) — Limine + LUKS + Plymouth + mkinitcpio
- [`contributing.md`](contributing.md) — hacking on the Cozy repo itself

## Critical Safety Rules

**For end-user customization, NEVER modify `/usr/share/Cozy/` or the installed `~/.local/share/Cozy` copy directly** — edit the repo at `~/Cozy/` and re-run `install/` scripts or `update.sh`. Reading is always safe.

```
~/Cozy/                        # EDIT HERE (git repo, then update.sh)
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
- `~/Cozy/config/<app>/` — dotfiles (stowed to `~/.config/`)
- `~/Cozy/default/agents/skills/cozy/` — this skill itself
- `~/Cozy/bin/menu` — Rofi menu structure
- `~/.config/` — live user config (overwritten by `update.sh` re-apply, so prefer editing the repo)

## Privilege Escalation

Interactive terminal work → `sudo`. Non-interactive / agent-launched → `pkexec`. Don't wrap commands that already handle privilege themselves (e.g. `cozy-*` wrappers).

## System Architecture

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor | `~/.config/hypr/*.lua` + `hypr*.conf` |
| **Waybar** | Status bar | `~/.config/waybar/` |
| **Rofi** | App launcher + Cozy menu | `~/.config/rofi/`, `bin/menu` |
| **Ly** | Display manager | `/etc/ly/config.ini`, `ly@ttyX.service` |
| **Limine** | Bootloader (with LUKS) | `/boot/limine.conf`, `/etc/kernel/cmdline`, `/etc/limine-entry-tool.d/` |
| **Plymouth** | Boot splash | `/usr/share/plymouth/themes/cozy/`, `/etc/plymouth/plymouthd.conf` |
| **Alacritty/Foot/Ghostty/Kitty** | Terminals | `~/.config/<terminal>/` |

## Command Discovery

Cozy ships an `cozy` dispatcher (also available as `cozy` on some installs) that routes `cozy <group> <action>` to `cozy-*` / `cozy-*` binaries:

```bash
cozy commands              # list every documented command
cozy theme --help
cozy agent --help
cozy-agent --help
bin/menu --help 2>/dev/null || cat ~/Cozy/bin/menu | head -20
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
