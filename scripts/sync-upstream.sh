#!/usr/bin/env bash
# Rebuild cstack's skills/ and agents/ from upstream pstack.
#
# Usage:
#   scripts/sync-upstream.sh                 # clone cursor/plugins main
#   scripts/sync-upstream.sh <path-to-pstack> # use a local pstack folder
#   PSTACK_REF=<git-ref> scripts/sync-upstream.sh
#
# The script is idempotent. It overwrites skills/ and agents/ each run.
# Files in overrides/ always win over upstream files.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
ref="${PSTACK_REF:-main}"
tmp=""
cleanup() { [ -n "$tmp" ] && rm -rf "$tmp"; }
trap cleanup EXIT

if [ $# -ge 1 ]; then
	src="$(cd "$1" && pwd)"
	commit="local"
else
	tmp="$(mktemp -d)"
	git clone --quiet --depth 1 --branch "$ref" https://github.com/cursor/plugins.git "$tmp/plugins"
	src="$tmp/plugins/pstack"
	commit="$(git -C "$tmp/plugins" rev-parse HEAD)"
fi

[ -d "$src/skills" ] || { echo "error: $src/skills not found" >&2; exit 1; }
version="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$src/.cursor-plugin/plugin.json" 2>/dev/null || true)"

# 1. Fresh copy of upstream skills and agents.
rm -rf "$root/skills" "$root/agents"
cp -R "$src/skills" "$root/skills"
mkdir -p "$root/agents"
cp "$src/agents/comment-sicko.md" "$root/agents/comment-sicko.md"

# 2. Drop upstream parts that cstack replaces.
rm -rf "$root/skills/setup-pstack"

# 3. Mechanical rewrites on text files.
find "$root/skills" "$root/agents" -type f \
	\( -name '*.md' -o -name '*.sh' -o -name '*.mjs' -o -name '*.ts' -o -name '*.json' \) \
	! -name 'bun.lock' -print0 |
	xargs -0 sed -i.bak -E -f "$root/scripts/rewrite.sed"
find "$root/skills" "$root/agents" -name '*.bak' -delete

# 4. Claude Code agent names must be kebab-case.
sed -i.bak -E '1,5s/^name: Comment Sicko$/name: comment-sicko/' "$root/agents/comment-sicko.md"
rm -f "$root/agents/comment-sicko.md.bak"

# 5. Claude Code transcript layout for the worktree audit script.
audit="$root/skills/poteto-mode/scripts/worktree-audit.sh"
if [ -f "$audit" ]; then
	python3 - "$audit" <<'PY'
import sys, re
p = sys.argv[1]
s = open(p).read()
old = re.compile(r"# Transcripts dir: ~/\.cursor/projects/.*?\n.*?\ntranscripts=\"\$HOME/\.cursor/projects/\$slug/agent-transcripts\"\n")
new = ('# Transcripts dir (Claude Code): ~/.claude/projects/<slug>, slug = path with "/" and "." as "-".\n'
       "slug=$(printf '%s' \"$main_wt\" | sed 's#[/.]#-#g')\n"
       'transcripts="$HOME/.claude/projects/$slug"\n')
s2, n = old.subn(new, s)
if n != 1:
    sys.exit("warn: worktree-audit.sh transcript block not found; check upstream changes")
open(p, "w").write(s2)
PY
fi

# 5a. Claude Code skill names must be kebab-case. Use the folder name.
for f in "$root"/skills/*/SKILL.md; do
	n="$(basename "$(dirname "$f")")"
	sed -i.bak -E "1,10s/^name: .*/name: $n/" "$f" && rm -f "$f.bak"
done

# 5b. Let Claude auto-enter poteto-mode. Upstream marks every skill
# disable-model-invocation. Other skills stay manual; poteto-mode reads them by path.
for name in ${CSTACK_MODEL_INVOCABLE:-poteto-mode}; do
	f="$root/skills/$name/SKILL.md"
	[ -f "$f" ] && sed -i.bak '1,10{/^disable-model-invocation: true$/d;}' "$f" && rm -f "$f.bak"
done

# 6. Overrides win.
cp -R "$root/overrides/skills/." "$root/skills/"
cp -R "$root/overrides/agents/." "$root/agents/"

# 7. Record the upstream source.
cat > "$root/UPSTREAM" <<EOF
source: https://github.com/cursor/plugins/tree/main/pstack
ref: $ref
commit: $commit
pstack_version: ${version:-unknown}
synced: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

# 8. Report Cursor references left for AGENTS.md to translate.
left="$(grep -rniE 'cursor|\bTask\b.*(call|tool)|environment: "cloud"|cursor-team-kit|control-(ui|cli)' "$root/skills" "$root/agents" | wc -l | tr -d ' ')"
echo "cstack synced from pstack ${version:-?} ($commit)."
echo "Cursor references left for the AGENTS.md adapter: $left"
