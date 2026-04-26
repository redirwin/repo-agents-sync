# MCP servers index

Canonical source: `.agents/mcp.json`. The sync-agents script emits per-tool MCP config files from this single source so every agent in the repo sees the same servers.

This file is **optional** — repos that don't use project-scoped MCPs can omit `.agents/mcp.json` entirely; the sync script skips the MCP step gracefully.

## Generated files

| Tool | Path | Top-level key | Notes |
|---|---|---|---|
| Claude Code | `.mcp.json` (repo root) | `mcpServers` | Project-scoped; auto-loaded by Claude Code in this directory. |
| Cursor | `.cursor/mcp.json` | `mcpServers` | Project-scoped; auto-loaded by Cursor. |
| VS Code (Copilot Chat) | `.vscode/mcp.json` | `servers` | Top-level key is renamed during sync (VS Code uses `servers`, not `mcpServers`). |

After editing `.agents/mcp.json`, run `scripts/sync-agents.ps1` (Windows) or `scripts/sync-agents.sh` (macOS/Linux) from the repo root. Never hand-edit the generated files; they are overwritten on next sync.

## Codex (user-level only)

OpenAI Codex CLI reads `~/.codex/config.toml` and (as of this writing) does not honor a project-level MCP config. To make a project's MCP available there, add a per-server snippet once per machine:

```toml
[mcp_servers.<name>]
url = "https://example.com/mcp"
```

If the Codex version in use rejects HTTP transport, check Codex's current MCP docs for the right field shape.

A common pattern is to manage user-level MCPs (including ones you want available in Codex) from a personal dotfiles repo, separate from this project-scoped `.agents/mcp.json`.

## Canonical file shape

```json
{
  "mcpServers": {
    "example-server": {
      "type": "http",
      "url": "https://example.com/mcp"
    }
  }
}
```

`type` is typically `"http"` (Streamable HTTP) or `"sse"` for older SSE-style remote servers. For local stdio servers use `"command"` + `"args"` per the target tool's schema.

## Adding a new MCP server

1. Create `.agents/mcp.json` (if it doesn't exist) and add an entry under `mcpServers`.
2. Run the sync script.
3. Commit `.agents/mcp.json` and the regenerated `.mcp.json`, `.cursor/mcp.json`, `.vscode/mcp.json` (or gitignore the mirrors per the repo's policy).

## Secrets

Do not put API keys, tokens, or other secrets directly in `.agents/mcp.json` — the file is committed. For MCP servers that need authentication:

- Prefer servers that handle auth at connection time (OAuth flows in the agent).
- Otherwise, use environment variable references in the per-tool format the target tool supports, and document the required env vars here.
- For purely personal MCPs, keep them at the user level (dotfiles, `~/.cursor/mcp.json`, `~/.claude.json`, VS Code user settings) instead of in this repo.

## Schema drift across tools

VS Code supports an `inputs` array (prompted variables) that Cursor and Claude ignore. Transport types and env var substitution syntax differ slightly between tools. Stick to the common subset in `.agents/mcp.json` unless you maintain tool-specific overrides outside the sync.
