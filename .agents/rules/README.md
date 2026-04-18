# Rules

Canonical source: `.agents/rules/`. The sync-agents script mirrors these into:

- `.cursor/rules/<name>.md` (Cursor accepts `.md` or `.mdc` rules)
- `.claude/rules/<name>.md`
- `.github/instructions/<name>.instructions.md` (Copilot's naming convention, applied automatically by the sync script)

Rules may include tool-specific frontmatter (for example Copilot's `applyTo:` glob). Non-supporting agents ignore unknown frontmatter, so it is safe to keep everything in the canonical file.

<!-- Add rule files here with a one-line description. Re-run sync-agents after edits so the tool-specific renames are applied. -->
