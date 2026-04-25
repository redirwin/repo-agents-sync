# Skills index

Canonical source: `.agents/skills/`. The `sync-agents` script mirrors these into `.cursor/skills/`, `.claude/skills/`, and `.github/skills/`.

These are **repo-scoped** skills: they ship with this repository and the agent loads them when their description matches the user's request. **User-scoped** skills (generic personal behavior that follows you across every repo) live in user-level folders such as `~/.claude/skills/` and `~/.codex/skills/` and are managed outside this repo (typically through a personal dotfiles setup).

Each skill lives in its own folder with a `SKILL.md` (YAML frontmatter + body) and any supporting reference files. Skill names are **not** prefixed (unlike commands) because the agent matches them by description, not by user-typed name.

| Skill | Purpose |
|---|---|
| [agents-maintain](agents-maintain/SKILL.md) | Audit and update `.agents/` README indexes, then run sync-agents. |
| [hello-world](hello-world/SKILL.md) | Demo skill to verify each agent picks up the synced tree. Delete once verified. |
| [skill-authoring](skill-authoring/SKILL.md) | Standards and steps for creating or editing skills in this repo. |
| [sync-agents](sync-agents/SKILL.md) | Regenerate the tool-specific mirrors from `.agents/`. |

<!-- Add new skills here with a one-line purpose. Keep canonical content under .agents/skills/<name>/SKILL.md and re-run sync-agents after edits. -->
