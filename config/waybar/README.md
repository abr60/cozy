# Waybar (Cozy)

Two styles, four positions, composed from shared layers so both styles stay in
sync.

## Styles

| Style | File | Character |
| --- | --- | --- |
| **Minimal** | `css/minimal.css` | flat, quiet, low-contrast |
| **Intricate** | `css/intricate.css` | Material-3 expressive shapes |

## Positions

- `top`, `bottom` — horizontal bars
- `left`, `right` — vertical sidebars

Style and position are independent: switching position keeps the current style,
and switching style keeps the current position.

## Structure

```
css/
  base.css            structural reset
  spacing.css         shared 4/8px rhythm
  minimal.css         style identity only
  intricate.css
  horizontal.css      top/bottom refinements
  vertical.css        left/right refinements + hidden modules
  combos/             base + spacing + style + orientation entrypoints
layouts/              thin position files (includes do the work)
modules/              shared module definitions
modules/groups/       horizontal group layouts + tray drawer
overrides/vertical.jsonc   orientation-critical module overrides
```

## Commands

```bash
waybar-control style minimal|intricate
waybar-control position top|bottom|left|right
waybar-control cycle-style
waybar-control status
```

`SUPER + B` cycles **Minimal → Intricate → Minimal**. The bar menu exposes the
same actions under **Waybar Style** and **Waybar Position**.

## Vertical module policy

`left` and `right` show the compact set: workspaces, status indicators, updates,
MPRIS, the tray drawer, backlight, Bluetooth, network, audio, power profile,
battery, VPN, menu, and clock.

Horizontal-only modules are hidden by `vertical.css`: `temperature`,
`custom/weather`, `custom/timer`, `custom/mako`, `custom/hdd`, `custom/lens`,
`custom/display-scale`, `custom/power`, and the raw `tray`.

## Adding a style

1. Add `css/<name>.css` with colors/chrome only — no spacing.
2. Add `css/combos/<name>-horizontal.css` and `<name>-vertical.css`.
3. Add the name to `STYLES` / `STYLE_LABELS` in
   `config/matugen/bin/generate-menu` and to the `menu-actions` in
   `modules/menu.jsonc`.
4. Run `waybar-control style <name>`.
