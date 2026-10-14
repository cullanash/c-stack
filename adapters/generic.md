# cstack adapter: any other app

Read `AGENTS.md` first. Use this file in an app that has no adapter of its own,
for example Gemini CLI, OpenCode, Cursor, or a harness that runs local models.
It assumes only that the app reads an `AGENTS.md` file, can read files, and can run shell commands.

## Install

1. Run `scripts/install.sh <skills-folder>` from the cstack root.
   It links every cstack skill into the folder your app scans for skills (for example `~/.agents/skills`).
   Skip this if your app does not support skills. You can still read them by path.
2. Add this block to your app's global or project `AGENTS.md`. The install script prints it with the real path filled in:

   ```
   ## cstack
   cstack is installed at <cstack root>.
   Before engineering work, read <cstack root>/AGENTS.md and <cstack root>/adapters/generic.md.
   ```

## Loading skills

- If your app lists skills, run them the way it runs any skill.
- Otherwise read `<cstack root>/skills/<name>/SKILL.md` and follow it.

## Tools

| pstack says | Do this |
|---|---|
| `Task` tool, `Task` call | Use your app's subagent tool if it has one. If it does not, do the step yourself, one task at a time, and say so once. |
| `subagent_type: "poteto-agent"` | Tell the subagent to read `<cstack root>/agents/poteto-agent.md` first. |
| `subagent_type: "comment-sicko"` | Tell the subagent to read `<cstack root>/agents/comment-sicko.md` first. |
| `subagent_type: generalPurpose` | A general subagent. |
| `readonly: true` | Tell the subagent not to edit files. |
| `model: <tier>` | The model for that tier. See "Models". |
| Reasoning level, effort | Use your app's effort or thinking setting if it has one. Otherwise ignore it. |
| Fast mode, `run_in_background`, `readonly: false`, `environment` | Use the closest feature your app has, or ignore it. |
| `AskQuestion` | Ask in chat with short numbered options, and mark your recommendation. |
| Todo list | Your app's todo tool, or a checklist in your replies. |
| Cursor `/loop`, plan mode, Custom Mode, `/visualize`, `/create-skill` | The closest feature your app has. Otherwise do it by hand and say so. |
| Cursor built-in `/babysit` | Use the `babysit` playbook in `poteto-mode`. |

## Without subagents

Panels (arena, architect, interrogate) and swarms need several independent views.
If your app cannot spawn subagents, run each panel seat yourself, one at a time, and write each seat's answer before you read the next brief.
Say in the report that the views were not independent.
Cross-vendor entries (see `AGENTS.md`) still give independent views when those command-line tools are installed.

## Paths

| pstack path | Here |
|---|---|
| `.cursor/skills/`, `~/.cursor/skills/` | Your app's project and user skill folders. `.agents/skills/` is the most common. |
| `~/.cursor/plugins/`, `.cursor-plugin/plugin.json` | `<cstack root>` and `<cstack root>/plugin.json`. |
| `docs/guide/` | `<cstack root>/docs/guide/` |
| Transcripts | Wherever your app saves chat logs. If you cannot find them, skip the step that needs them and say so. |

## Models

| Tier | Model |
|---|---|
| `strong` | The `<app> strong:` line in `~/.cstack/models.md`, else this session's model. |
| `fast` | The `<app> fast:` line, else this session's model. |
| `small` | The `<app> small:` line, else `fast`. |
| `inherit` | This session's model. |

`<app>` is a short name you pick for your app, such as `gemini` or `opencode`. Use the same name every time.
See "Small and local models" in `AGENTS.md` before you map a tier to a small model.
