# Commands

Canonical source: `.agents/commands/`. The `sync-agents` script mirrors these into:

- `.cursor/commands/<name>.md` - invoked as `/<name>` in Cursor
- `.claude/commands/<name>.md` - invoked as `/<name>` in Claude Code
- `.github/prompts/<name>.prompt.md` - available as prompts in Copilot (VS Code agent mode)

## Naming: the `repo-` prefix is required

Every file in this folder (other than `README.md`) **must** be named `repo-<name>.md`. The `sync-agents` script enforces this and refuses to run if any command file is missing the prefix.

The prefix:

- Marks these as **repo-scoped**: they ship with this repository and operate on its scaffolding. They are distinct from **user-scoped** commands a developer may install in their personal config (e.g. `/my-*` from a dotfiles repo), which work in any working directory.
- Avoids collisions with built-in commands (`/init`, `/review`) and with any user-scoped commands installed in `~/.claude/commands/`, `~/.codex/prompts/`, or VS Code's user `prompts/` folder.

## Current commands

| Command | Purpose |
|---|---|
| [/repo-sync-agents](repo-sync-agents.md) | Run the sync script to mirror `.agents/` into each tool's folder. |
| [/repo-say-hello](repo-say-hello.md) | Demo command for verifying the sync works across all three agents. Delete once verified. |

<!-- Add new commands here with a one-line purpose. The repo- prefix is required; the sync script will refuse otherwise. -->
