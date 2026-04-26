#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/.agents"
[ -d "$SRC" ] || { echo ".agents/ not found"; exit 1; }

# Enforce: every file in .agents/commands/ (other than README.md) must start with "repo-".
# Rationale documented in README.md ("Naming conventions").
if [ -d "$SRC/commands" ]; then
    bad=()
    while IFS= read -r -d '' f; do
        name="$(basename "$f")"
        case "$name" in
            README.md) continue ;;
            repo-*) continue ;;
            *) bad+=("$f") ;;
        esac
    done < <(find "$SRC/commands" -maxdepth 1 -type f -name '*.md' -print0)
    if [ "${#bad[@]}" -gt 0 ]; then
        echo "Command files must be named repo-<name>.md. Offending file(s):" >&2
        for f in "${bad[@]}"; do echo "  $f" >&2; done
        echo "Rename each to repo-<name>.md and re-run. See README.md -> Naming conventions." >&2
        exit 1
    fi
fi

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

# --- MCP config sync ---
# Canonical: .agents/mcp.json (uses `mcpServers` top-level key).
# Emits:
#   .mcp.json          (Claude Code, project-scoped)        — `mcpServers`
#   .cursor/mcp.json   (Cursor)                             — `mcpServers`
#   .vscode/mcp.json   (VS Code Copilot Chat)               — `servers` (key renamed)
# See .agents/MCP-README.md for the convention. Block is a no-op when
# .agents/mcp.json is absent, so repos that don't use MCPs need no change.
mcp_src="$SRC/mcp.json"
if [ -f "$mcp_src" ]; then
    if ! command -v jq >/dev/null 2>&1; then
        echo "  WARN: jq not found; skipping MCP sync. Install jq to enable." >&2
    else
        cp "$mcp_src" "$ROOT/.mcp.json"
        mkdir -p "$ROOT/.cursor" "$ROOT/.vscode"
        cp "$mcp_src" "$ROOT/.cursor/mcp.json"
        # VS Code uses `servers` instead of `mcpServers`
        jq '{servers: .mcpServers}' "$mcp_src" > "$ROOT/.vscode/mcp.json"
        echo "  synced mcp.json -> .mcp.json, .cursor/mcp.json, .vscode/mcp.json"
    fi
fi

echo "Agent config sync complete."
