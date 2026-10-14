---
name: setup-cstack
description: Configure which models cstack uses per role, the default reasoning effort, and (in Codex or other apps) the install steps that make cstack load in every session. Writes ~/.cstack/models.md. Use for /setup-cstack, $setup-cstack, /setup-pstack, "configure cstack models", or changing cstack's model choices.
---

# Setup cstack

Write `~/.cstack/models.md`.
This file sets the model tier for each cstack role, the model for each tier in each app, and the starting effort.
Read `AGENTS.md` ("Models") and your app's adapter before you start.

## Steps

### 1. Name the app

Use the `cstack app` line from the session context: `claude-code`, `codex`, or `generic`.
For `generic`, ask the user for a short app name (for example `gemini` or `opencode`). Use it as `<app>` below.

### 2. Load current state

If `~/.cstack/models.md` exists, read it.
If only `~/.claude/cstack-models.md` exists, read that. Its role values are Claude aliases. Turn `opus` into `strong`, `sonnet` into `fast`, and `haiku` into `small`, and keep any other value.
Treat the `# budget` line, the `effort` line, the tier lines, and the role lines as the current choices.
Keep tier lines for other apps exactly as they are.
Drop any role line whose role is not in step 6. Tell the user which lines you dropped.

### 3. Map the tiers for this app

- `claude-code`: the defaults are `strong: opus`, `fast: sonnet`, `small: haiku`. Ask if the user's plan includes `fable`. Use `fable` for `strong` only if they confirm.
- `codex`: list the models this session can pass to a subagent, if you can see them. Otherwise ask the user to paste the model names they have. Ask which one is `strong` and which is `fast`. Never write a model name you have not confirmed.
- `generic`: ask the user which models their app can run, and which is `strong`, `fast`, and (optional) `small`. If one is a small local model (about 30B parameters or under), map it only to `small`, and explain why in one line (see "Small and local models" in `AGENTS.md`).

Ask with the question tool your adapter names. Offer short options and mark your recommendation.

### 4. Ask for a budget

Offer these options:

- `max — strongest model everywhere it helps, max effort`
- `balanced — fast for code, strong for judgment, xhigh effort` (the default)
- `lean — small for bulk work where you have one, high effort`

Apply the budget:

- `max`: set code delegates to `strong`. Set `effort: max`.
- `balanced`: use the defaults in step 6. Set `effort: xhigh`.
- `lean`: if the app has a `small` tier, set explorers, investigators, and swarm workers to `small`. Keep `hardest tasks` on `strong`. Set `effort: high`.

The `effort` line is the starting reasoning effort for every subagent.
poteto-mode raises or lowers it per job. `AGENTS.md` explains how.

### 5. Confirm

Show every role with its tier, and every tier with its model for this app, in one table.
Ask the user to accept, or to change specific roles.
A role can also name a real model, or `inherit` (the parent session's model).
Panel roles take a list. One subagent runs per entry, so the list length sets the count.
A panel entry can also be `claude`, `codex`, or `gemini`. `AGENTS.md` explains how those run.

### 6. Write the file

Overwrite the whole file, so re-runs stay idempotent. Keep other apps' tier lines. Shape:

```
# cstack model configuration. One line per role.
# Values: a tier (strong, fast, small), a real model, or inherit.
# "<app> <tier>: <model>" lines map a tier to a model in one app.
# budget: balanced
effort: xhigh
claude-code strong: opus
claude-code fast: sonnet
claude-code small: haiku
feature, refactoring: fast
bug-fix: fast
perf-issue: fast
hillclimb: fast
judgment and prose: strong
hardest tasks: strong
how explorer: fast
how explainer: strong
why investigators: fast
why synthesizer: strong
reflect tooling: fast
reflect judgment, divergent, synthesizer: strong
arena runners: strong, fast
arena cross-judge pool: strong, fast
swarm workers: fast
architect runners: strong, fast
interrogate reviewers: strong, fast
```

Create `~/.cstack/` if it does not exist.

### 7. Make cstack load every session (Codex and generic only)

- `codex`: if the session context has no cstack section, the plugin hook is not trusted yet. Tell the user to trust it in `/hooks`. Also offer to add this block to `~/.codex/AGENTS.md` (create the file if needed, and never remove what is there):

  ```
  ## cstack
  cstack is installed at <cstack root>.
  Before engineering work, read <cstack root>/AGENTS.md and <cstack root>/adapters/codex.md.
  ```

  Then offer to run `<cstack root>/scripts/install-codex-agents.sh`, which installs the `poteto-agent` and `comment-sicko` custom agents.
- `generic`: offer to run `<cstack root>/scripts/install.sh <skills-folder>` for the app's skills folder, and to add the block it prints to the app's `AGENTS.md`.

### 8. Tell the user

Say that the file is written and that it applies to new sessions.
Say that they can run setup again in any app. Each app keeps its own tier lines.

### 9. Offer a verification skill (optional)

Check if the project has a way to drive the real app for proof (a `verify-*` skill in the project's skills folder, or a test harness).
If not, offer this one time: "Do you want a project-local verification skill, so agents can drive the app and prove that changes work? I can make one with create-verification-skill."
If the user says yes, run `create-verification-skill`.
If the user says no, continue.
