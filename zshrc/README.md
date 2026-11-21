# zshrc layout

This folder is the source of truth for the interactive shell. It lives in the
Cozy repo and is linked into place as `~/.zshrc -> ~/zshrc/rc` (where `~/zshrc`
itself points at `$COZY_PATH/zshrc`).

`rc` sources the parts below in this order — keep the order intact:

| File | Purpose |
|------|---------|
| `envs` | Paths, history options, Oh My Zsh + plugin setup |
| `prompt` | Theme-aware prompt (uses the terminal palette, no external prompt tool) |
| `cleancozy` | Maintenance helper — loaded only when you call `cleancozy` |
| `aliases` | Everyday aliases and repo sync shortcuts |
| `functions` | `zd`/`zi`, clipboard helpers, `hide_waydroid`, `cozy`, `cleancozy` lazy loader |
| `init` | Guarded init for zoxide and fzf |

Any part that is missing is reported but does not stop the shell from loading.
Edit files here, not in `~/.zshrc` (which is only a symlink to `rc`).
