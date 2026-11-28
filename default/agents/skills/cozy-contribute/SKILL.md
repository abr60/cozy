---
name: cozy-contribute
description: >
  Report a Cozy bug, suggest a feature, or submit a fix upstream to abr60/cozy: deciding whether it is
  Cozy's bug at all, where it belongs (issue, Discussions, Discord), gathering diagnostics and a capture,
  searching for duplicates, getting the user's go-ahead, filing or commenting with gh, and opening a pull
  request from a fork. Triggers: report a bug, file an issue, is this a Cozy bug, feature request, suggestion,
  contribute, submit a fix, open a PR to Cozy.
---

# Contributing to Cozy

Cozy lives at https://github.com/abr60/cozy. Route each request to the right place:

- **Verified bugs** → GitHub issues.
- **Feature ideas and suggestions** → https://github.com/abr60/cozy/discussions/categories/suggestions
- **Support and "is this a bug?" questions** → the project's Discord/community. Start there when the problem is not clearly a bug in Cozy itself.

## Is It Even Cozy's Bug?

Be strict. Cozy is a configuration layer over Arch Linux, so a bug inside a third-party application — a file
manager, a browser, a GNOME or Qt library — is almost always upstream in **that** project, not Cozy.

Cozy's sphere of control is roughly:

- the `cozy-*` commands and dispatcher
- the Hyprland, Waybar, Walker, Rofi, and terminal configuration it ships
- its themes and boot branding
- its install and update scripts
- how it packages and configures what it installs

A bug in a program Cozy merely installs is **not** a Cozy bug unless Cozy's own packaging or configuration is
implicated. If it is not Cozy's, say so and stop. Suggesting the right upstream project is useful; filing there
yourself is not part of this.

## Three Conditions, All Required

1. **It is a verified bug in Cozy's sphere**, established on evidence. Issues are for verified bugs only; an
   "is this even a bug?" question belongs in the community, and a feature idea belongs in Discussions.
2. **The user explicitly agreed.** Show them the exact title and body you propose, and wait for a yes.
   Never file unprompted.
3. **The machine can file it** — `gh auth status` must succeed. If `gh` is missing or unauthenticated, do not
   install or authenticate it. Say so and hand over the finished text for the user to submit.

## Gather the Details

```bash
cozy version
cozy debug --no-sudo --print
```

`cozy debug --no-sudo --print` also writes the log locally; include it or its shareable URL in the report.
Capture the problem on screen when it is visual: `cozy capture screenshot region`, or
`cozy screenrecord --fullscreen` and `cozy screenrecord --stop-recording`. Keep recordings short and focused.

## Search Before Filing

A duplicate issue costs a maintainer more time than no report at all.

```bash
gh search issues --repo abr60/cozy "<program> <symptom>"
gh issue list --repo abr60/cozy --state all --search "<distinctive words>"
```

Search on the program, the symptom, and distinctive details (an error message, a symbol from a backtrace) — not
on the wording of the title you were about to write. `gh search issues` accepts only `open` or `closed` for
`--state`; leaving it off searches both. Include **closed** issues: a matching issue closed as fixed, when the bug
still reproduces on a current system, is a regression worth reporting.

## Adding to an Existing Report

```bash
gh issue view <number> --repo abr60/cozy --comments
```

Confirm it is genuinely the same failure before commenting. Add a comment only when you have something the thread
does not already contain: a different reproduction, a symbolized stack where it has none, a narrower trigger, or a
version where it regressed. A comment that only says "me too" is noise.

```bash
gh issue comment <number> --repo abr60/cozy --body "..."
```

## Filing a New Issue

Only when search turns up no match:

```bash
gh issue create --repo abr60/cozy --title "..." --body "..."
```

Include what happened, what was expected, steps to reproduce, system details from `cozy version`, and diagnostics.
`gh` cannot attach media here; if a screenshot would help, save it and give the user the path to drag into the web
form.

## Signing

End the issue or comment with a line naming the model and agent harness that produced it:

> Filed by \<model name\> via \<agent harness\>.

Use your actual names. If you are not certain, say so plainly rather than inventing a version string.

## Submitting a PR

Never develop against a stowed copy. Clone a working copy instead:

```bash
gh repo fork abr60/cozy --clone
cd cozy
```

Follow this repository's `AGENTS.md` and `agents/skills/` guides. Keep commits atomic, run the focused checks from
[`testing.md`](../../../agents/skills/testing.md), then open the PR with `gh pr create`. Visual changes should include
before/after captures attached with `gh pr create --attach`.
