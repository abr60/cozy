# Authoring Agent Skills

Read this before adding or changing anything under `default/agents/skills/`.

## Layout

```text
default/agents/skills/
├── cozy/
│   ├── SKILL.md
│   └── hyprland.md
├── cozy-diagnose-crash/
│   └── SKILL.md
└── cozy-contribute/
    └── SKILL.md
```

Each skill is a directory with a `SKILL.md`. Companion guides stay beside it and are linked with relative
Markdown paths like [`hyprland.md`](../../default/agents/skills/cozy/hyprland.md). No installer edit is needed:
`cozy agent skills link` loops over every directory in the tree.

## Frontmatter

Use a folded `description` (YAML `>`), keep it under 1024 characters, and make it trigger-rich:

```yaml
---
name: cozy-diagnose-crash
description: >
  Diagnose why a program crashed on this machine, from a systemd-coredump core dump.
  Use when a process has segfaulted, aborted, or otherwise dumped core. Triggers:
  crash, segfault, SIGSEGV, SIGABRT, core dump, coredumpctl, "why did X crash".
  Reporting a confirmed Cozy bug upstream follows cozy-contribute.
---
```

Patterns to follow:

- Say `REQUIRED` when the skill truly must be loaded for a whole class of work.
- Include an explicit `Triggers:` phrase with the words a user would actually say.
- Add exclusions (`Not for ...`) and handoffs to other skills in the description, not only in the body.
- Keep the body focused: scope statement, topic guides, safety rules, procedure, decision framework.

## Names

Shipped skill directories use lowercase hyphenated names. The base desktop skill is `cozy`; all others use the
`cozy-` prefix (`cozy-diagnose-crash`, `cozy-contribute`) so they cannot collide with Omarchy's `omarchy-*` skills.

Renaming or removing a skill works: run `cozy agent skills link` and stale own-links are dropped. Do not manually
delete links in agent harness directories unless they are yours.

## Linking

`cozy-agent-skills-link` fans skills out into:

- `~/.agents/skills`
- `~/.claude/skills`
- `~/.codex/skills`
- `~/.pi/agent/skills`
- `~/.gemini/config/skills`
- `~/.hermes/skills` and each existing `~/.hermes/profiles/*/skills`
- `~/.config/opencode/skills`

It writes **relative** symlinks, preserves user-owned folders and links with the same name, repoints own-links
from another Cozy checkout, and removes own-links to skills that no longer exist.

Personal rules for every agent do **not** go here. They belong in `~/.agents/AGENTS.md`, linked by
`cozy agent instructions`.

## Validation

```bash
bash -n bin/libexec/cozy/agents/cozy-agent-skills-link
cozy test agent-skills
```

The test also enforces that each `SKILL.md` has a `name:` matching its directory and a description of 1–1024
characters after folded lines are joined.
