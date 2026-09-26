---
name: setup-cstack
description: Configure which Claude model cstack uses per role. Writes ~/.claude/cstack-models.md, which overrides the skill defaults. Use for /setup-cstack, /setup-pstack, "configure cstack models", or changing cstack's model choices.
---

# Setup cstack

Write `~/.claude/cstack-models.md`.
This file sets the model for each cstack role.
The cstack session hook loads it into every new session.

## Steps

### 1. Find available models

Claude Code accepts these aliases for the `model` field of an `Agent` call: `opus`, `sonnet`, `haiku`, and `inherit`.
`fable` is available on some plans.
Ask the user if their plan includes `fable`. Use `AskUserQuestion`.
Do not write `fable` unless the user confirms it.
Full model IDs (for example `claude-opus-5-5`) are also valid.
Write a full ID only if the user gives it.

### 2. Load current state

If `~/.claude/cstack-models.md` exists, read it.
Treat its `# budget` line and role lines as the current choices.
If it does not exist, start from the defaults in step 5.
Drop any line whose role is not in step 5. Tell the user which lines you dropped.

### 3. Ask for a budget

Use `AskUserQuestion` with these options:

- `max — best model per role`
- `balanced — sonnet for code, opus for judgment` (the default)
- `lean — haiku for bulk work, sonnet for judgment`

Apply the budget:

- `max`: use `fable` where the default is `opus`, if the user has `fable`. Otherwise keep `opus`. Use `opus` for code delegates.
- `balanced`: use the defaults in step 5.
- `lean`: change `opus` to `sonnet`, and change `sonnet` to `haiku`, except for `hardest tasks`, which stays `opus`.

### 4. Confirm

Show every role and its model in a table.
Ask the user to accept, or to change specific roles. Use `AskUserQuestion`.
Panel roles take a list. One subagent runs per entry, so the list length sets the count.
A panel entry can also be `codex` or `gemini`. The AGENTS.md adapter explains how those run.
`inherit` means the role uses the parent session model.

### 5. Write the file

Overwrite the whole file. This keeps re-runs idempotent. Shape:

```
# cstack model configuration. One line per role.
# Delete a line to use the default. `inherit` runs the role on the parent model.
# budget: balanced
feature, refactoring: sonnet
bug-fix: sonnet
perf-issue: sonnet
hillclimb: sonnet
judgment and prose: opus
hardest tasks: opus
how explorer: sonnet
how explainer: opus
why investigators: sonnet
why synthesizer: opus
reflect tooling: opus
reflect judgment, divergent, synthesizer: opus
arena runners: opus, sonnet, haiku
arena cross-judge pool: opus, sonnet, haiku
swarm workers: sonnet
architect runners: opus, sonnet, haiku
interrogate reviewers: opus, sonnet, haiku
```

### 6. Tell the user

Say that the file is written and that it applies to new sessions.
Say that they can run `/setup-cstack` again to change it.

### 7. Offer a verification skill (optional)

Check if the project has a way to drive the real app for proof (a `verify-*` skill in `.claude/skills/`, or a test harness).
If not, offer this one time: "Do you want a project-local verification skill, so agents can drive the app and prove that changes work? I can make one with /create-verification-skill."
If the user says yes, run `/create-verification-skill`.
If the user says no, continue.
