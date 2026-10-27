# cstack adapter: Codex

Read `AGENTS.md` first. This file maps Cursor words in the skills to Codex (CLI and desktop app).

## Loading skills

- The user runs a skill with `$<name>` (for example `$poteto-mode`), or picks it from `/skills`.
- Only `poteto-mode` loads by itself. The other skills set `allow_implicit_invocation: false` in their `agents/openai.yaml`.
- Read a skill by path with the shell (`cat <cstack root>/skills/<name>/SKILL.md`).
- Where a skill says `/<name>`, the Codex form is `$<name>`.

## Tools

| pstack says | Do this in Codex |
|---|---|
| `Task` tool, `Task` call | Spawn a Codex subagent. Give it the full brief, then wait for its result. |
| `subagent_type: generalPurpose` | Use the built-in `worker` agent. |
| `readonly: true` | Use the built-in `explorer` agent, and tell it not to edit files. |
| `subagent_type: "poteto-agent"` | Use the custom agent `poteto-agent`. If it is not installed, use `worker` and tell it to read `<cstack root>/agents/poteto-agent.md` first. |
| `subagent_type: "Comment Sicko"` or `"comment-sicko"` | Use the custom agent `comment-sicko`. If it is not installed, use `worker` and pass it `<cstack root>/agents/comment-sicko.md`. |
| `model: <tier>` on a `Task` | Pass the model for that tier when you spawn. See "Models". |
| Reasoning level, effort | Pass the reasoning effort when you spawn (`max`, `xhigh`, `high`, `medium`, `low`). Codex also has `ultra` above `max`. Use it only when the models file says so. |
| Fast mode, `-fast` slug | Ignore. Lower the effort one step if speed matters. |
| `run_in_background: true` | Spawn the subagents together, keep working, and collect their results before you depend on them. |
| `readonly: false`, "agent mode" | Ignore. Subagents inherit this session's sandbox and approvals. |
| `environment: "cloud"`, `cloud_base_branch` | Run the worker in its own `git worktree` on that branch. For work that must outlive this session, start a Codex cloud task. |
| `environment: "local"` | Run in the current checkout. |
| Cursor restart, Cursor dashboard, Cursor settings | Restart Codex, or edit `~/.codex/config.toml`. |
| `AskQuestion` | Ask in chat with short numbered options, and mark your recommendation. |
| Todo list | Use Codex's plan tool. If it is not available, keep a checklist in your replies. |
| Cursor `/loop` | Run `codex exec "<prompt>"` in a shell loop or a scheduled script. |
| Cursor plan mode | Write the plan first and wait for the user's go-ahead before editing. |
| Cursor Custom Mode, "Use as Mode" | Not needed. The cstack session hook or `~/.codex/AGENTS.md` makes poteto-mode the default. |
| `/visualize` | Draw a Mermaid diagram, or write a small HTML or SVG file and show a screenshot of it. |
| `/create-skill` | Use the built-in `$skill-creator` skill. |
| Cursor built-in `/babysit` | Use the `babysit` playbook in `poteto-mode`. |
| "Verify via the control skill", Cursor browser, Design Mode | Web app on localhost: the Codex app's built-in browser first, then a Playwright MCP server, then `control-ui`. Desktop app or anything only the screen shows: Computer Use (`@Computer` or `@<AppName>`) if it is enabled, else `control-ui`. Terminal programs: `control-cli` (Computer Use cannot drive terminals). |

## Paths

| pstack path | Codex path |
|---|---|
| `.cursor/skills/` | `.agents/skills/` |
| `~/.cursor/skills/` | `~/.agents/skills/` |
| `~/.cursor/plugins/` | The folder Codex installed cstack into. The session context names it. |
| `.cursor-plugin/plugin.json` | `plugin.json` at the cstack root. |
| `docs/guide/` | `<cstack root>/docs/guide/` |
| `~/.cursor/projects/<slug>/agent-transcripts/` | `~/.codex/sessions/` (one `rollout-*.jsonl` file per session, in dated folders) |

The session context names this session's transcript when the hook could read it.
Otherwise the current session is the newest `rollout-*.jsonl` under `~/.codex/sessions/` whose `cwd` is this project.
Never read other projects' sessions.

## Models

Codex model names change often, so cstack ships no defaults for them.

| Tier | Codex model |
|---|---|
| `strong` | The `codex strong:` line in `~/.cstack/models.md`. If it is missing, use this session's model. |
| `fast` | The `codex fast:` line. If it is missing, use this session's model with effort two steps lower. |
| `small` | The `codex small:` line. If it is missing, use `fast`. |
| `inherit` | Leave the model unset. |

Run `$setup-cstack` to fill these lines in. It can also install the `poteto-agent` and `comment-sicko` custom agents.

## If the session hook did not run

Codex runs plugin hooks only after the user trusts them in `/hooks`.
If the session context has no cstack section, `$setup-cstack` adds a short pointer to `~/.codex/AGENTS.md` so every session still loads cstack.
