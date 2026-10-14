# cstack adapter

cstack is pstack (by Lauren Tan, "poteto") adapted for Claude Code.
The skills come from upstream pstack.
The skills were written for Cursor.
This file tells you how to run them in Claude Code.
Apply this file every time a cstack skill tells you to use a Cursor tool, path, or model.

## Default workflow

- Use `/poteto-mode` for all non-trivial engineering work in this session.
- You do not need the user to type `/poteto-mode`.
- If a task needs rigor, load the `poteto-mode` skill and follow it.
- If the task is trivial (a one-line answer, a typo fix), skip the playbook.
- The user can turn this off. Stop when the user says "no poteto-mode" or similar.

## Loading skills

- Upstream marks most skills `disable-model-invocation`. The user can still run them with `/cstack:<name>` or `/<name>`.
- cstack lets you invoke only `poteto-mode` with the `Skill` tool.
- When a skill tells you to use another skill or a `principle-*` skill, read it with the `Read` tool.
- The path is `<cstack plugin root>/skills/<name>/SKILL.md`. The session context gives the plugin root.
- Paths inside a skill (for example `playbooks/bug-fix.md` or `scripts/watch-pr`) are relative to that skill's folder.

## Tools

| pstack says | Do this in Claude Code |
|---|---|
| `Task` tool, `Task` call | Use the `Agent` tool. |
| `subagent_type: generalPurpose` | Use `subagent_type: "general-purpose"`. |
| `subagent_type: "poteto-agent"` | Use `subagent_type: "cstack:poteto-agent"`. |
| `subagent_type: "Comment Sicko"` or `"comment-sicko"` | Use `subagent_type: "cstack:comment-sicko"`. |
| `model: <slug>` on a `Task` | Set `model` on the `Agent` call to an alias from the model table below. |
| `run_in_background: true`, `is_background: true` | Keep it. The `Agent` tool supports it. |
| Reasoning level, effort (`max`, `xhigh`, `high`, `medium`, `low`) | Set `effort` on the `Agent` call. See "Effort" below. |
| Fast mode, `-fast` slug | Ignore. Claude Code subagents have no fast mode. Lower `effort` one step if speed matters. |
| `readonly: false`, "agent mode" | Ignore. Claude Code subagents get tools from their agent definition. |
| `environment: "cloud"` | Use `isolation: "worktree"` for workers that edit files. Omit it for read-only workers. |
| `environment: "local"` | Omit `isolation`. |
| `cloud_base_branch` | Tell the worker to check out that branch in its worktree. |
| Cursor cloud agent (for example, one per PR) | A background `Agent` with `isolation: "worktree"`. For work that must outlive this session, a Claude Code cloud session. |
| Cursor restart, Cursor dashboard, Cursor settings | Restart Claude Code, or use `/config` and `/plugin`. |
| `AskQuestion` | Use `AskUserQuestion`. |
| Todo list | Use `TaskCreate` and `TaskUpdate`. If they are not available, use `TodoWrite`. |
| Cursor `/loop` | Use Claude Code `/loop`. For unattended runs, use headless `claude -p` in a script. |
| Cursor plan mode | Use Claude Code plan mode. |
| Cursor Custom Mode, "Use as Mode" | Not needed. The cstack session hook loads poteto-mode as the default. See "Default workflow". |
| `/visualize` (Cursor charts and diagrams) | Draw a Mermaid diagram, or write a small HTML or SVG file and show a screenshot of it. |
| `/create-skill` (Cursor built-in) | Use the `skill-creator` skill if it is installed. Otherwise write `SKILL.md` by hand. |
| Cursor built-in `/babysit` | Use the `babysit` playbook in `poteto-mode`. |

## Paths

| pstack path | Claude Code path |
|---|---|
| `~/.cursor/rules/pstack-models.mdc` | `~/.claude/cstack-models.md` |
| `.cursor/skills/` | `.claude/skills/` |
| `~/.cursor/skills/` | `~/.claude/skills/` |
| `~/.cursor/plugins/` | `~/.claude/plugins/` |
| `.cursor-plugin/plugin.json` | `.claude-plugin/plugin.json` |
| `docs/guide/` (pstack guide) | `<cstack plugin root>/docs/guide/`. Copied from upstream by the sync script. |
| `.cursor/automations/` | Not supported. See "Not supported" below. |
| `~/.cursor/projects/<slug>/agent-transcripts/<uuid>/<uuid>.jsonl` | `~/.claude/projects/<slug>/<uuid>.jsonl` |

Transcript slug rule for Claude Code: take the absolute project path.
Replace each `/` and each `.` with `-`.
Keep the leading `-`.
Example: `/Users/<user>/code/<repo>` becomes `-Users-<user>-code-<repo>`.
The current session transcript is the newest `.jsonl` file in that folder.
Subagent transcripts are in `<uuid>/subagents/` next to the session file, when present.

## Models

cstack reads `~/.claude/cstack-models.md`.
Run `/setup-cstack` to write it.
If the file or a role line is missing, use these defaults.

| Role | Default | Why |
|---|---|---|
| Code delegates (feature, refactoring, bug-fix, perf-issue, hillclimb) | `sonnet` | Fast and strong at code. |
| Hardest tasks | `opus` | Strongest judgment that every plan has. |
| Judgment and prose | `opus` | Same. |
| Explorers and investigators (`how`, `why`) | `sonnet` | Bulk reading. |
| Explainers and synthesizers | `opus` | Judgment. |
| Swarm workers | `sonnet` | Parallel bulk work. |
| Panels (arena, architect, interrogate) | `opus, sonnet` | One subagent per entry. Two seats, like upstream. Add `haiku`, `codex`, or `gemini` for more views. |

Map Cursor model slugs that you still see in a skill:

| Cursor slug | Claude alias |
|---|---|
| `claude-opus-*` | `opus` |
| `gpt-*-sol-*` | `opus` |
| `grok-*`, `cursor-grok-*`, `composer-*` | `sonnet` |
| `inherit-parent`, `auto` | Omit `model`. The subagent uses the parent model. |

`fable` is a valid alias if the user's plan includes it.
Use `fable` only when `~/.claude/cstack-models.md` names it.

### Effort

pstack picks a reasoning level for each subagent. In Claude Code this is the `effort` field on the `Agent` call.

- Start from the `effort` line in `~/.claude/cstack-models.md`. If it is missing, start at `xhigh`.
- The ladder is `max` > `xhigh` > `high` > `medium` > `low`.
- Follow poteto-mode's "Match the model to the job" rule: up one step for the hardest work, down one for judgment, down two or more for routine work.
- Verification workers keep the starting effort.
- A Cursor slug's effort token (for example the `xhigh` in `claude-opus-5-5-xhigh`) maps to `effort`, not to the model.
- If the `Agent` tool rejects `effort`, omit it and say so once.

### Cross-vendor panel entries (optional)

pstack gets its best review signal from different model families.
A panel entry can be `codex` or `gemini`.
For such an entry, spawn a `general-purpose` subagent on `sonnet`.
Tell it to run the review through that vendor's CLI with Bash.
Example: `codex exec "<prompt>"`.
If the CLI is not installed, skip the entry and say so in the report.

## The control skill

pstack's own playbooks say "verify on the matching surface via the control skill"
(bug-fix, perf-issue, runtime-forensics, visual-parity, prototype,
multi-phase-plan, orchestrate). cstack ships both halves of that, vendored
from `cursor-team-kit` (same repo as pstack, MIT, see `LICENSE.cursor-team-kit`):

| Surface | Skill |
|---|---|
| Browser, web app, Electron, IDE | `control-ui` |
| CLI, TUI, terminal program | `control-cli` |

Both are already Claude Code compatible: no Cursor tool names, no Cursor
paths. Read the matching skill with `Read` when a playbook calls for it, the
same way you load a `principle-*` skill. They run on tools you already have:

- `control-cli` builds a `tmux` session or a short Python/Node PTY script with
  Bash. Use this for anything interactive (a menu, a prompt, a wizard, a REPL).
- `control-ui` runs a short Playwright script with Bash (`node script.mjs`),
  or connects over CDP for Electron. This is a plain script, separate from
  any Playwright MCP tool this session may also have; use whichever is
  available, and the MCP tool first if both are.

Both skills already say: reuse the repo's own test/demo harness first, keep
the harness temporary unless asked to keep it, and clean up sessions,
processes, and temp files when done.

## Skills that pstack references but does not ship

| Reference | Claude Code substitute |
|---|---|
| `deslop` | Use the `unslop` skill. |

## Not supported

- The `benny` Slack automation pack. Use the Claude Code GitHub Action or Claude in Slack.
- Mixing non-Claude models inside one `Agent` call. Use the CLI method above.
- Cursor Design Mode. Use `control-ui` screenshots instead.

## Rules for this adapter

- Do not edit upstream skill text to fix a Cursor reference. Apply this file.
- If a Cursor reference is not in this file, pick the closest Claude Code equivalent.
- Say what you picked in one line in your reply.
