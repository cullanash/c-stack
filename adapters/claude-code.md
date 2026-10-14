# cstack adapter: Claude Code

Read `AGENTS.md` first. This file maps Cursor words in the skills to Claude Code.

## Loading skills

- Run a skill with `/cstack:<name>` or `/<name>`.
- Invoke `poteto-mode` with the `Skill` tool. Read every other skill with the `Read` tool.

## Tools

| pstack says | Do this in Claude Code |
|---|---|
| `Task` tool, `Task` call | Use the `Agent` tool. |
| `subagent_type: generalPurpose` | Use `subagent_type: "general-purpose"`. |
| `subagent_type: "poteto-agent"` | Use `subagent_type: "cstack:poteto-agent"`. |
| `subagent_type: "Comment Sicko"` or `"comment-sicko"` | Use `subagent_type: "cstack:comment-sicko"`. |
| `model: <tier>` on a `Task` | Set `model` on the `Agent` call to the alias for that tier. See "Models". |
| `run_in_background: true`, `is_background: true` | Keep it. The `Agent` tool supports it. |
| Reasoning level, effort | Set `effort` on the `Agent` call (`max`, `xhigh`, `high`, `medium`, `low`). If the tool rejects it, omit it and say so once. |
| Fast mode, `-fast` slug | Ignore. Claude Code subagents have no fast mode. Lower `effort` one step if speed matters. |
| `readonly: true` | Use `subagent_type: "Explore"` when the job only reads. Otherwise tell the worker not to edit files. |
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
| Cursor Custom Mode, "Use as Mode" | Not needed. The cstack session hook makes poteto-mode the default. |
| `/visualize` (Cursor charts and diagrams) | Draw a Mermaid diagram, or write a small HTML or SVG file and show a screenshot of it. |
| `/create-skill` (Cursor built-in) | Use the `skill-creator` skill if it is installed. Otherwise write `SKILL.md` by hand. |
| Cursor built-in `/babysit` | Use the `babysit` playbook in `poteto-mode`. |

## Paths

| pstack path | Claude Code path |
|---|---|
| `.cursor/skills/` | `.claude/skills/` |
| `~/.cursor/skills/` | `~/.claude/skills/` |
| `~/.cursor/plugins/` | `~/.claude/plugins/` |
| `.cursor-plugin/plugin.json` | `.claude-plugin/plugin.json` |
| `docs/guide/` | `<cstack root>/docs/guide/` |
| `~/.cursor/projects/<slug>/agent-transcripts/<uuid>/<uuid>.jsonl` | `~/.claude/projects/<slug>/<uuid>.jsonl` |

The session context names this session's transcript when the hook could read it.
Otherwise use the slug rule: take the absolute project path, and replace each `/` and each `.` with `-`.
Keep the leading `-`. Example: `/Users/<user>/code/<repo>` becomes `-Users-<user>-code-<repo>`.
The current session is the newest `.jsonl` file in that folder.
Subagent transcripts are in `<uuid>/subagents/` next to the session file, when present.

## Models

| Tier | Claude Code alias |
|---|---|
| `strong` | `opus` |
| `fast` | `sonnet` |
| `small` | `haiku` |
| `inherit` | Omit `model`. |

A `claude-code <tier>: <alias>` line in `~/.cstack/models.md` overrides this table.
`fable` is a valid alias if the user's plan includes it. Use it only when the models file names it.
Full model IDs (for example `claude-opus-5-5`) are also valid.
A model from another vendor cannot run inside an `Agent` call. Use the cross-vendor method in `AGENTS.md`.
