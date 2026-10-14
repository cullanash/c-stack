#!/usr/bin/env bash
# SessionStart hook for Claude Code and Codex. Stdout becomes session context.
# Loads the cstack core (AGENTS.md), names this app's adapter, and points at
# the user's model file and this session's transcript.
#
# App detection: $CSTACK_APP if set; else Codex when $PLUGIN_ROOT is set
# (Codex sets it, Claude Code does not); else Claude Code.
root="${CLAUDE_PLUGIN_ROOT:-${PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}}"
if [ -n "${CSTACK_APP:-}" ]; then app="$CSTACK_APP"
elif [ -n "${PLUGIN_ROOT:-}" ]; then app="codex"
else app="claude-code"; fi
adapter="$root/adapters/$app.md"
[ -f "$adapter" ] || { app="generic"; adapter="$root/adapters/generic.md"; }

# Both apps pass a JSON object on stdin with transcript_path.
input=""
[ -t 0 ] || input="$(cat)"
transcript="$(printf '%s' "$input" | sed -n 's/.*"transcript_path" *: *"\([^"]*\)".*/\1/p' | head -1)"

models="${CSTACK_MODELS_FILE:-$HOME/.cstack/models.md}"
[ -f "$models" ] || [ ! -f "$HOME/.claude/cstack-models.md" ] || models="$HOME/.claude/cstack-models.md"

cat "$root/AGENTS.md"
echo
echo "cstack root: $root"
echo "cstack app: $app"
if [ "$app" = "claude-code" ]; then
	# Claude Code keeps the whole adapter in context, so no read is needed.
	echo
	cat "$adapter"
else
	# Codex shortens long hook output, so its adapter is read on demand.
	echo "cstack adapter: $adapter. Read it before you run any cstack skill."
fi
[ -n "$transcript" ] && echo "This session's transcript: $transcript"
echo
if [ -f "$models" ] && [ "$app" = "claude-code" ]; then
	echo "## cstack model configuration ($models)"
	echo
	cat "$models"
elif [ -f "$models" ]; then
	echo "cstack model configuration: $models. Read it before you pick a model or effort for a subagent."
else
	echo "cstack model configuration: none. Use the default tiers in AGENTS.md. Tell the user one time that setup-cstack can set models."
fi
exit 0
