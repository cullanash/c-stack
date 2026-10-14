#!/usr/bin/env bash
# Install cstack's skills for an app without a cstack plugin install.
#
# Usage: scripts/install.sh <skills-folder>
#   Links each skill into <skills-folder> (for example ~/.agents/skills, which
#   Codex and several other apps scan), then prints the block to add to the
#   app's AGENTS.md. Re-running replaces the links. Existing folders that are
#   not cstack links are left alone.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
[ $# -eq 1 ] || { echo "usage: $0 <skills-folder>" >&2; exit 2; }
dest="$1"
mkdir -p "$dest"

linked=0; skipped=""
for d in "$root"/skills/*/; do
	name="$(basename "$d")"
	target="$dest/$name"
	if [ -L "$target" ] || [ ! -e "$target" ]; then
		ln -sfn "${d%/}" "$target"
		linked=$((linked + 1))
	else
		skipped="$skipped $name"
	fi
done

echo "Linked $linked cstack skills into $dest."
[ -z "$skipped" ] || echo "Skipped (a non-cstack folder already uses the name):$skipped"
cat <<BLOCK

Add this block to your app's AGENTS.md (global or project):

## cstack
cstack is installed at $root.
Before engineering work, read $root/AGENTS.md and $root/adapters/generic.md.
BLOCK
