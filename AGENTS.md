# AGENTS.md

<!--
  Replace this comment with a one- or two-sentence description of the project:
  what it does, who it is for, and any top-level context an AI agent needs that
  it cannot infer from the code. Keep the whole file under ~200-300 lines;
  detail belongs in skills, not here.
-->

## Conventions

<!--
  Project-specific behavior, output, or style rules the agent must follow.
  Examples: which package manager to use, where generated files must not live,
  tone for user-facing copy, whether to ask before installing dependencies, etc.
  Delete this section if there is nothing project-specific to say yet.
-->

## Skills

See [.agents/skills/README.md](.agents/skills/README.md) for the skill index and when to load each skill.

## Commands

See [.agents/commands/README.md](.agents/commands/README.md) for the available slash commands.

## Editing agent config

The `.agents/` tree is the canonical source for all skills, commands, and rules. After editing anything under `.agents/`, run `scripts/sync-agents.ps1` (Windows) or `scripts/sync-agents.sh` (macOS/Linux) from the repo root before committing so the `.cursor/`, `.claude/`, and `.github/` mirrors stay in lockstep.
