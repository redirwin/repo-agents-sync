# Commands

Canonical source: `.agents/commands/`. The sync-agents script mirrors these into:

- `.cursor/commands/<name>.md` - invoked as `/<name>` in Cursor
- `.claude/commands/<name>.md` - invoked as `/<name>` in Claude Code
- `.github/prompts/<name>.prompt.md` - available as prompts in Copilot (VS Code agent mode)

| Command | Purpose |
|---|---|
| [/sync-agents](sync-agents.md) | Run the sync script to mirror `.agents/` into each tool's folder. |
| [/hello-world](hello-world.md) | Demo command for verifying the sync works across all three agents. Delete once verified. |

<!-- Add new commands here with a one-line purpose. Cursor turns .cursor/commands/foo.md into /foo, so pick canonical filenames with that mapping in mind. -->
