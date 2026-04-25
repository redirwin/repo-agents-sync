---
name: agents-maintain
description: >-
  Audits and updates the README index files inside `.agents/skills/`,
  `.agents/commands/`, and `.agents/rules/` so they accurately reflect the
  files on disk, then runs the sync-agents script to push changes to all
  tool-specific mirrors. Use when skills, commands, or rules have been added,
  renamed, or deleted and the READMEs may be stale, or when the user asks to
  "update agent readmes", "refresh agents", or "maintain agents".
---

# Agents maintain

Keeps the three `.agents/` README index files in sync with what is actually on disk, then re-mirrors everything with `sync-agents`.

## What "up to date" means for each README

| File | Must contain one row per... | Source of truth |
| ---- | --------------------------- | --------------- |
| `.agents/skills/README.md` | Folder inside `.agents/skills/` that contains a `SKILL.md` | Folder names |
| `.agents/commands/README.md` | `.md` file inside `.agents/commands/` (excluding `README.md`) | File names |
| `.agents/rules/README.md` | `.md` file inside `.agents/rules/` (excluding `README.md`) | File names |

## Steps

1. **Scan each subfolder**
   - List all skill folders (`*/SKILL.md` present) in `.agents/skills/`.
   - List all `*.md` files (excluding `README.md`) in `.agents/commands/`.
   - List all `*.md` files (excluding `README.md`) in `.agents/rules/`.

2. **Diff against each README**
   - Read the current README table rows.
   - Identify: (a) entries in the README that have no corresponding file on disk (stale), and (b) files on disk that have no entry in the README (missing).

3. **Update the READMEs**

   **Skills README** - for each missing skill:
   - Read its `SKILL.md` frontmatter `description` field.
   - Derive a one-line purpose (first sentence of `description`, or paraphrase to <= 12 words).
   - Add a row: `| [<name>](<name>/SKILL.md) | <purpose> |`
   - Remove any stale rows (folder no longer exists).
   - Keep alphabetical order.

   **Commands README** - for each missing command file:
   - Read the file's first non-blank line to extract the expanded instruction (or a short paraphrase <= 12 words).
   - Add a row: `| \`/<name>\` | <intent> |`
   - Remove any stale rows (file no longer exists).
   - Keep alphabetical order within the table.

   **Rules README** - for each missing rule file:
   - Read the file and derive a one-line description from its content or frontmatter.
   - Add a row: `| [<name>](<name>.md) | <description> |` - if the README has no table yet, add one under the existing prose.
   - Remove any stale rows.

4. **Run sync-agents**
   - Windows: `powershell -File scripts/sync-agents.ps1`
   - macOS/Linux: `./scripts/sync-agents.sh`
   - Use `-Clean` (PowerShell) or wipe targets manually (bash) if any file was renamed or deleted.

5. **Report** - one short summary: which READMEs changed, what was added/removed, and that sync ran.

## Safe defaults

- Do not modify any `SKILL.md` or command/rule body content. This skill only updates README index rows and runs the sync.
- Preserve any prose, comments, or HTML comments above and below each table.
- If a README has no table yet (e.g. a brand-new rules folder), add one under the existing prose rather than overwriting the file.

## Anti-patterns

- Editing the mirrored READMEs in `.cursor/`, `.claude/`, or `.github/skills/` directly. Edit only the canonical README under `.agents/`.
- Adding rows for `README.md` itself.
- Reordering table rows beyond alphabetical sort. Keep diffs minimal.
