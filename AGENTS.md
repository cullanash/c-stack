# cstack

cstack is pstack (by Lauren Tan, "poteto") made to run in any coding agent app.
The skills come from upstream pstack.
The skills were written for Cursor.
This file is the shared core. It applies in every app.
Each app also has an adapter in `adapters/` that maps Cursor tools, paths, and models to that app.

## Pick your adapter

| You are running in | Read |
|---|---|
| Claude Code | `adapters/claude-code.md` |
| Codex (CLI or desktop app) | `adapters/codex.md` |
| Any other app (Gemini CLI, OpenCode, Cursor, a local-model harness, and so on) | `adapters/generic.md` |

Paths are relative to the cstack root. The session context names the root.
If the session context already includes your adapter, do not read it again.
Apply your adapter every time a cstack skill names a Cursor tool, path, or model.

## Default workflow

- Use `poteto-mode` for all non-trivial engineering work in this session.
- You do not need the user to type `/poteto-mode`.
- If a task needs rigor, load the `poteto-mode` skill and follow it.
- If the task is trivial (a one-line answer, a typo fix), skip the playbook.
- The user can turn this off. Stop when the user says "no poteto-mode" or similar.

## Loading skills

- Upstream marks most skills `disable-model-invocation`. The user can still run them by name.
- Only `poteto-mode` loads by itself.
- When a skill tells you to use another skill or a `principle-*` skill, read it by path.
- The path is `<cstack root>/skills/<name>/SKILL.md`.
- Paths inside a skill (for example `playbooks/bug-fix.md` or `scripts/watch-pr`) are relative to that skill's folder.

## Models

Skills name a model tier, not a model.
Your adapter maps each tier to a real model in your app.

| Tier | Meaning | pstack's original |
|---|---|---|
| `strong` | Best judgment. Plans, reviews, prose, the hardest code. | Opus |
| `fast` | Quick and good at code. Delegates, explorers, swarm workers. | Grok |
| `small` | Optional. Cheap bulk work, such as a local model. | none |
| `inherit` | The parent session's model. | `inherit-parent`, `auto` |

cstack reads `~/.cstack/models.md`. Run `setup-cstack` to write it.
Each role line can name a tier, a real model, or `inherit`.
Lines that start with an app name (`claude-code strong: opus`) map a tier for that app.
If the file or a line is missing, use these defaults:

| Role | Default |
|---|---|
| Code delegates (feature, refactoring, bug-fix, perf-issue, hillclimb) | `fast` |
| Hardest tasks | `strong` |
| Judgment and prose | `strong` |
| Explorers and investigators (`how`, `why`) | `fast` |
| Explainers and synthesizers | `strong` |
| Swarm workers | `fast` |
| Panels (arena, architect, interrogate) | `strong, fast`. One subagent per entry. |

Older installs may have `~/.claude/cstack-models.md` instead. Read it the same way. Its values are Claude models.

### Small and local models

Small models (about 30B parameters and under) lose track of long playbooks.
Never run `poteto-mode` itself, a panel judge, or a synthesizer on `small`.
Give `small` only bulk jobs: reading code, searching, and simple edits that a `strong` or `fast` model reviews.

### Effort

pstack picks a reasoning level for each subagent.

- Start from the `effort` line in `~/.cstack/models.md`. If it is missing, start at `xhigh`.
- The ladder is `max` > `xhigh` > `high` > `medium` > `low`.
- Follow poteto-mode's "Match the model to the job" rule: up one step for the hardest work, down one for judgment, down two or more for routine work.
- Verification workers keep the starting effort.
- Your adapter says how to set effort. If your app has no effort setting, skip this.

### Cross-vendor panel entries (optional)

pstack gets its best review signal from different model families.
A panel entry can name another vendor's command-line tool: `claude`, `codex`, or `gemini`.
For such an entry, spawn a `fast` subagent and tell it to run the review through that tool with the shell.
Examples: `claude -p "<prompt>"`, `codex exec "<prompt>"`, `gemini -p "<prompt>"`.
If the tool is not installed, skip the entry and say so in the report.

## The control skill

pstack's playbooks say "verify on the matching surface via the control skill".
cstack ships both halves, vendored from `cursor-team-kit` (same repo as pstack, MIT, see `LICENSE.cursor-team-kit`):

| Surface | Skill |
|---|---|
| Browser, web app, Electron, IDE | `control-ui` |
| CLI, TUI, terminal program | `control-cli` |

Both run on the shell, so they work in any app.
`control-cli` uses `tmux` or a short PTY script. `control-ui` uses a short Playwright script, or CDP for Electron.
If your app also has a browser tool (for example a Playwright MCP server), use it first.

## Skills that pstack references but does not ship

| Reference | Substitute |
|---|---|
| `deslop` | Use the `unslop` skill. |

## Not supported

- The `benny` Slack automation pack.
- Cursor Design Mode. Use `control-ui` screenshots instead.

## Rules for adapters

- Do not edit upstream skill text to fix a Cursor reference. Apply your adapter.
- If a Cursor reference is not in your adapter, pick the closest equivalent in your app.
- Say what you picked in one line in your reply.
