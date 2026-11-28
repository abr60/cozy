# Command Metadata

Read this before adding or changing commands in `bin/`.

Commands in `bin/` can declare CLI metadata in comments near the top of the file. `bin/cozy` scans the first
80 lines; tests expect metadata to remain valid.

## Shape

```bash
#!/bin/bash

# cozy:summary=Link Cozy's agent skills into every agent harness
# cozy:args=[cozy-root]
# cozy:name=skills link
# cozy:group=agent
# cozy:examples=cozy agent skills link | cozy agent skills link "$COZY_PATH"
```

Supported keys include `summary`, `args`, `examples`, `group`, `name`, `aliases`, `requires-sudo`, and
`hidden`. `hidden=true` means the command still routes but is omitted from browse output.

## Routes

- A bin symlink named `cozy-<name>` is auto-discovered: `cozy <group> <name>`.
- Without explicit metadata, `cozy-agent-skills-link` falls back to group `agent`, name `skills-link`, route
  `cozy agent skills-link`. Use `# cozy:name=skills link` when you want a multi-word action.
- Add a `GROUP_DESCRIPTIONS[...]` entry in `bin/cozy` when introducing a new top-level group.
- Prefer `cozy <group> <action>` in docs and menu prompts; underlying binaries stay readable for source.

## Placement

- Implementation: `bin/libexec/cozy/<group>/<name>`
- Public symlink: `bin/<name>` → `libexec/cozy/<group>/<name>`
- `chmod +x` both the implementation and the symlink target.

## Examples

```bash
cozy commands
cozy commands --json
cozy agent --help
cat "$(which cozy-theme-set)"
```
