#!/usr/bin/env bash
# SessionStart hook. Stdout becomes session context in Claude Code.
# Loads the cstack adapter and the user's model config.
root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
models="${CSTACK_MODELS_FILE:-$HOME/.claude/cstack-models.md}"

cat "$root/AGENTS.md"
echo
echo "cstack plugin root: $root"
if [ -f "$models" ]; then
	echo
	echo "## cstack model configuration ($models)"
	echo
	cat "$models"
else
	echo
	echo "cstack model configuration: none. Use the defaults in the Models table. Tell the user one time that /setup-cstack can set models."
fi
exit 0
