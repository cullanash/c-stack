#!/usr/bin/env bash
# Install cstack's custom agents (poteto-agent, comment-sicko) for Codex.
#
# Usage: scripts/install-codex-agents.sh [agents-folder]
#   Default folder: ${CODEX_HOME:-~/.codex}/agents. Fills the cstack root into
#   the templates in adapters/codex/agents/ and writes one TOML file per agent.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${1:-${CODEX_HOME:-$HOME/.codex}/agents}"
mkdir -p "$dest"
for f in "$root"/adapters/codex/agents/*.toml; do
	sed "s#{{CSTACK_ROOT}}#$root#g" "$f" > "$dest/$(basename "$f")"
	echo "Wrote $dest/$(basename "$f")"
done
