# Skills index

Canonical source: `.agents/skills/`. The sync-agents script mirrors these into `.cursor/skills/`, `.claude/skills/`, and `.github/skills/`.

Each skill lives in its own folder with a `SKILL.md` (YAML frontmatter + body) and any supporting reference files.

| Skill | Purpose |
|---|---|
| [sync-agents](sync-agents/SKILL.md) | Regenerate the tool-specific mirrors from `.agents/`. |
| [hello-world](hello-world/SKILL.md) | Demo skill to verify each agent picks up the synced tree. Delete once verified. |

<!-- Add new skills here with a one-line purpose. Keep canonical content under .agents/skills/<name>/SKILL.md and re-run sync-agents after edits. -->
