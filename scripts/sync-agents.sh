#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/.agents"
[ -d "$SRC" ] || { echo ".agents/ not found"; exit 1; }

sync_pair() {
    local src_sub="$1" dst_sub="$2" base="$3" suffix="${4-}"
    local src="$SRC/$src_sub"
    local dst="$base/$dst_sub"
    [ -d "$src" ] || return 0
    mkdir -p "$dst"
    rsync -a --delete "$src/" "$dst/"
    if [ -n "$suffix" ]; then
        rm -f "$dst/README.md"
        find "$dst" -maxdepth 1 -type f -name '*.md' ! -name "*$suffix" ! -name 'README.md' -print0 |
            while IFS= read -r -d '' f; do
                mv "$f" "${f%.md}$suffix"
            done
    fi
    echo "  synced $src_sub -> ${dst#$ROOT/}"
}

sync_pair skills   skills       "$ROOT/.cursor"
sync_pair commands commands     "$ROOT/.cursor"
sync_pair rules    rules        "$ROOT/.cursor"

sync_pair skills   skills       "$ROOT/.claude"
sync_pair commands commands     "$ROOT/.claude"
sync_pair rules    rules        "$ROOT/.claude"

sync_pair skills   skills       "$ROOT/.github"
sync_pair commands prompts      "$ROOT/.github" ".prompt.md"
sync_pair rules    instructions "$ROOT/.github" ".instructions.md"

echo "Agent config sync complete."
