---
name: sync-agents
description: >-
  Mirrors `.agents/skills`, `.agents/commands`, and `.agents/rules` into the
  tool-specific folders `.cursor/`, `.claude/`, and `.github/` by running
  `scripts/sync-agents.ps1` (Windows) or `scripts/sync-agents.sh` (macOS or
  Linux). Use after editing anything under `.agents/`, on fresh clones when
  the mirrors are gitignored, or when the user runs /sync-agents.
---

# Sync agents

Regenerates the tool-specific mirrors from the canonical `.agents/` tree so Cursor, Claude Code, and GitHub Copilot all pick up current skills, commands, and rules.

## Preconditions

- Run from the **repository root** (the folder that contains `.agents/`).
- Windows: Windows PowerShell 5.1+ (ships with Windows) or PowerShell 7 (`pwsh`).
- macOS/Linux: `bash` with `rsync` on the PATH.

## Steps

1. **Detect the platform** from shell context or by asking if unclear.
   - Windows: use `scripts/sync-agents.ps1`.
   - macOS or Linux: use `scripts/sync-agents.sh`.
2. **Run the script** from repo root:
   - Windows: `powershell -File scripts/sync-agents.ps1` (or `pwsh scripts/sync-agents.ps1` if PowerShell 7 is installed)
   - macOS/Linux: `./scripts/sync-agents.sh`
3. **Report** which tool folders were written and which source subfolders (`skills`, `commands`, `rules`) were mirrored.

## When to add `-Clean` / a fresh rebuild

Add `-Clean` (PowerShell) or wipe the target folders manually (bash) when:

- A skill or command was **renamed or deleted** in `.agents/` and a stale file may be lingering in `.cursor/`, `.claude/`, or `.github/`.
- The user explicitly asks for a clean rebuild.

By default, run without `-Clean` for a fast incremental copy.

## Safe defaults

- Never modify anything under `.agents/`. This script only reads from it.
- Never touch `AGENTS.md`, `CLAUDE.md`, or `.github/copilot-instructions.md`.
- If the generated mirrors are committed (the recommended default), run this sync before committing any change to `.agents/` so the mirrors stay in lockstep.
- If the mirrors are gitignored, run this after a fresh clone and after every pull that touches `.agents/`.

## Anti-patterns

- Editing inside `.cursor/`, `.claude/`, or `.github/skills/` directly. The next sync overwrites changes. Edit in `.agents/` and resync.
- Running the script from a subfolder rather than the repo root.
- Adding `-Clean` as a default habit. Incremental runs are faster and safer.

## Reference one-liners

Windows:

```powershell
powershell -File scripts/sync-agents.ps1           # incremental
powershell -File scripts/sync-agents.ps1 -Clean    # wipe targets first
```

macOS/Linux:

```bash
./scripts/sync-agents.sh
```
