# Testing Cozy

Read this before changing shell commands, installers, Lua config, or agent wiring.

## Always Run

```bash
bash -n bin/libexec/cozy/**/* setup.sh update.sh install/**/*.sh
luac -p ~/.config/hypr/*.lua
cozy check paths
cozy test paths
cozy test agent-skills
```

Only run the checks relevant to the files you changed, plus `cozy test agent-skills` whenever a shipped skill or
linker changes.

## Agent Skill Tests

`cozy test agent-skills` uses a fake `HOME` to verify:

- every shipped skill links into all harness dirs, OpenCode, and existing Hermes profiles
- links are relative and resolve to the active `$COZY_PATH`
- relinking repoints own-links, adds new skills, and drops retired ones
- user-owned folders and links with the same name survive untouched
- each `SKILL.md` has a matching `name:` and a folded `description` of 1–1024 characters

## Path Portability

`cozy test paths` generates config in a fake home and asserts no symlink contains an absolute user path.
`cozy check paths` audits tracked files for hardcoded home paths; `cozy relink` repairs Cozy-owned links.

## Test Policy

Write a test only when it catches a regression that would otherwise slip through. Do not add change detectors,
snapshot large outputs, or restate the implementation. Extend an existing test command where possible.
