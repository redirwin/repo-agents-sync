# repo-agents-sync

One canonical folder for AI agent skills, commands, and rules. A small script mirrors it into the paths Cursor, Claude Code, and GitHub Copilot expect. Edit once, every supported agent picks it up.

## Why

- Skills, commands, and rules share the same markdown shape across the three major AI coding agents, but each tool reads them from a different path.
- Maintaining three copies by hand causes drift.
- Symlinks break on Windows without Developer Mode and also trip over Cursor's well-documented symlink bug, so they are not a portable answer.
- A tiny copy script gives you a single source of truth without any runtime dependency, git hook, or OS-specific trick.

## What you get

- `.agents/` as the single source of truth for skills, commands, and rules.
- `scripts/sync-agents.ps1` (Windows PowerShell 5.1+ or PowerShell 7) and `scripts/sync-agents.sh` (bash + rsync) to regenerate the tool-specific mirrors.
- Pointer files (`CLAUDE.md` and `.github/copilot-instructions.md`) so Claude Code and Copilot read the same `AGENTS.md` as Cursor and any other `agents.md`-aware tool.
- A demo `hello-world` skill and `/repo-hello-world` slash command you can use to verify the sync works in each agent, then delete.
- A starter `agents-maintain` skill that audits the `.agents/*/README.md` index files against what is actually on disk and re-runs the sync.
- A required `repo-` prefix on all command files (enforced by the sync script) so kit commands cannot collide with built-in or user-scoped commands. See [Naming conventions](#naming-conventions).

## Install

Copy these files and folders from this kit into your own repo root:

- `AGENTS.md` - customize the placeholders for your project
- `CLAUDE.md` - leave as-is
- `.github/copilot-instructions.md` - leave as-is
- `.agents/` - the canonical tree (keep, edit, or clear contents to taste)
- `scripts/sync-agents.ps1` and `scripts/sync-agents.sh`

Then run the sync script once from the repo root to generate the mirrors:

- Windows: `powershell -File scripts/sync-agents.ps1`
- macOS/Linux: `chmod +x scripts/sync-agents.sh && ./scripts/sync-agents.sh`

After the first sync you should have `.cursor/`, `.claude/`, and `.github/{skills,prompts,instructions}/` populated.

## Usage

### Editing skills, commands, or rules

1. Edit the canonical file under `.agents/`.
2. Run the sync script (or `/repo-sync-agents` from any agent that sees the command).
3. Commit both the canonical source and the regenerated mirrors, or gitignore the mirrors (see "Commit or gitignore the mirrors" below).

### Verifying the setup with the demo skill

The demo `hello-world` skill ships with the kit so you can confirm each agent reads its synced copy:

- In Cursor or Claude Code, type `/repo-hello-world`.
- In Copilot (VS Code agent mode), invoke the `repo-hello-world` prompt.

Each should respond with the confirmation line from `.agents/skills/hello-world/SKILL.md`. When you are satisfied, delete the demo:

```powershell
Remove-Item -Recurse -Force .agents/skills/hello-world
Remove-Item -Force .agents/commands/repo-hello-world.md
powershell -File scripts/sync-agents.ps1 -Clean
```

```bash
rm -rf .agents/skills/hello-world .agents/commands/repo-hello-world.md
./scripts/sync-agents.sh
```

### Adding a new skill

```text
.agents/skills/<skill-name>/
  SKILL.md           # YAML frontmatter (name, description) + body
  reference.md       # optional supporting material
```

Use the Claude Code / generic skill shape: a folder per skill containing a `SKILL.md` with at minimum:

```markdown
---
name: my-skill
description: >-
  Short description Cursor, Claude Code, and Copilot all use for skill loading.
  Describe when this skill should be invoked.
---

# My skill

Body: preconditions, steps, examples, anti-patterns.
```

### Adding a new command

```text
.agents/commands/repo-<command-name>.md
```

A command is a single markdown file. Its filename becomes the slash command:

- `.agents/commands/repo-foo.md` -> `/repo-foo` in Cursor and Claude Code
- The sync script renames it to `.github/prompts/repo-foo.prompt.md` for Copilot.

The `repo-` prefix is **required**. The sync script refuses to run if any file in `.agents/commands/` (other than `README.md`) lacks the prefix. See [Naming conventions](#naming-conventions) for the rationale.

### Adding a new rule

```text
.agents/rules/<rule-name>.md
```

Include any tool-specific frontmatter inline (for example Copilot's `applyTo:` glob). Agents that do not understand that frontmatter ignore it.

## Naming conventions

The kit enforces one naming rule: **all files in `.agents/commands/` (except `README.md`) must be named `repo-<name>.md`**. The sync script refuses to run otherwise, in both PowerShell and bash.

The reason is namespacing. A modern developer's slash-command picker can pull from several layers at once:

- Built-in commands shipped by the agent (`/init`, `/review`, `/security-review` in Claude Code; equivalents in other tools).
- User-scoped commands installed in personal config folders (e.g. `~/.claude/commands/`, `~/.codex/prompts/`, VS Code user `prompts/`).
- Repo-scoped commands shipped by this kit, mirrored into `.cursor/commands/`, `.claude/commands/`, and `.github/prompts/`.

Without a prefix scheme, all three layers compete in one flat namespace. The `repo-` prefix gives this kit's commands a consistent, easy-to-spot home.

Skills are deliberately **not** prefixed. The agent matches skills by their description, not by name; the user never types a skill name. A prefix on skill folders would add visual noise without functional benefit.

Rules are also unprefixed, for the same reason: they apply implicitly when the agent loads the relevant context, and the user never invokes them by name.

## User-scoped vs. repo-scoped

This kit is designed for **repo-scoped** agent config: skills, commands, and rules that ship with the repository and operate on its scaffolding. It does not address the parallel **user-scoped** layer that all the supported agents also recognize.

| Scope | What it is | Where it lives | Who manages it |
|---|---|---|---|
| Repo-scoped | Skills/commands/rules tied to this codebase | `.agents/` and the generated mirrors | Committed to the repo |
| User-scoped | Generic personal preferences and shortcuts | `~/.claude/`, `~/.codex/`, VS Code user folder | A personal dotfiles repo (recommended) |

Both layers can coexist. A developer using this kit might still have `/my-onboard`, `/my-nccp`, etc. installed in their user-scoped folders, available in every repo they work in. The `repo-` prefix on this kit's commands keeps the two layers from colliding.

For Cursor specifically: it does not currently support a user-scoped commands or skills folder. User-scoped behavior in Cursor is limited to **User Rules** (configured in **Settings -> Rules**, stored in Cursor's settings DB, not as discoverable files). When a developer needs a user-scoped shortcut to work in Cursor for a particular repo, the practical workaround is to copy the relevant file or skill into that repo's `.agents/` and run the sync.

## Layout

```text
your-repo/
  AGENTS.md                           canonical agent instructions
  CLAUDE.md                           pointer for Claude Code
  .github/copilot-instructions.md     pointer for Copilot

  .agents/                            source of truth (committed)
    skills/<name>/SKILL.md
    commands/<name>.md
    rules/<name>.md

  .cursor/                            generated mirrors
  .claude/
  .github/skills/
  .github/prompts/                    commands, renamed to *.prompt.md
  .github/instructions/               rules, renamed to *.instructions.md

  scripts/
    sync-agents.ps1                   Windows
    sync-agents.sh                    macOS/Linux
```

## Commit or gitignore the mirrors

Pick one. Never do both.

### Option A (recommended for most repos): commit the mirrors

A fresh clone works with any supported agent with zero setup. Cost: you must run the sync before committing any change to `.agents/`. Add a short note to your own `README.md`:

```markdown
## Local setup

After editing anything under `.agents/`, run the sync script before committing:

- Windows: `powershell -File scripts/sync-agents.ps1`
- macOS/Linux: `./scripts/sync-agents.sh`
```

### Option B: gitignore the mirrors

Keeps the repo small. Cost: every contributor must run the sync after cloning, and again after every pull that touches `.agents/`. Add to `.gitignore`:

```gitignore
# Generated agent config (source of truth is .agents/)
.cursor/skills/
.cursor/commands/
.cursor/rules/
.claude/skills/
.claude/commands/
.claude/rules/
.github/skills/
.github/prompts/
.github/instructions/
```

Do not gitignore `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, or anything under `.agents/`.

## Known limitations

- **Tool-specific frontmatter is lossy.** Copilot's `applyTo:` glob in `.github/instructions/*.instructions.md` has no equivalent in Cursor or Claude Code. Put the frontmatter in the canonical file; tools that do not understand it will ignore it.
- **Global Claude Code config lives outside the repo.** Claude Code also reads `~/.claude/` at the user level. Cross-repo preferences belong there, not in `.agents/`.
- **Cursor slash command naming.** Cursor turns `.cursor/commands/foo.md` into `/foo`. Pick your canonical filename with that mapping in mind.
- **Subagent and persona folders are not synced.** `.claude/agents/`, `.github/agents/`, and similar live outside this script. Extend the sync if you start using them.
- **Line endings on Windows.** If `core.autocrlf` is enabled, git may normalize line endings for the newly tracked mirror files. Expected, harmless, and a one-time event per file.

## Future extensions

- **MCP server configs.** The same source-of-truth pattern fits MCP definitions: a canonical `.agents/mcp.json` mirrored to `.cursor/mcp.json`, repo-root `.mcp.json` (Claude Code), and `.vscode/mcp.json` (Copilot / VS Code agent mode). Not shipped in v1. If you add it yourself, be aware of three things:
  - **Secrets.** Never commit raw API keys. Use `${env:FOO}`-style env var references, or keep personal MCPs in your user-level config (`~/.cursor/mcp.json`, `~/.claude.json`, or VS Code user settings) instead of the repo.
  - **Schema drift.** VS Code supports `inputs` (prompted variables); Cursor and Claude ignore it. Transport types (`stdio`, `sse`, `http`) and env var substitution syntax differ slightly. Stick to the common subset in the canonical file unless you maintain tool-specific overrides.
  - **Scope.** This kit only handles project-scoped configs. Personal servers belong at the user level.
- **Subagent and persona syncing.** Add a `.agents/agents/` folder plus a few lines to the script when you start using them.

## Credits and references

- [agents.md](https://agents.md/) - the cross-tool instruction file standard.
- [GitHub Copilot customization cheat sheet](https://docs.github.com/en/copilot/reference/customization-cheat-sheet) - Copilot instruction, skill, agent, and prompt file locations.
- [Anatomy of the .claude folder (2026)](https://codewithmukesh.com/blog/anatomy-of-the-claude-folder/) - Claude Code layout reference.
- ETH Zurich 2026 study on `AGENTS.md` efficiency - keeping the instruction file under ~200-300 lines measurably improves agent performance.

## License

MIT. See [LICENSE](LICENSE).
