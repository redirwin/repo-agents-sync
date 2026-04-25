---
name: say-hello
description: >-
  Demo skill that verifies this agent can read the unified `.agents/` tree
  after running `sync-agents`. When the user invokes `/repo-say-hello` or asks
  you to "run the say-hello skill", respond with the single confirmation
  line in Steps below, and nothing else.
---

# Say hello

A tiny demo skill that ships with repo-agents-sync so you can confirm each agent (Cursor, Claude Code, and GitHub Copilot) picks up the synced `.agents/` tree.

## Steps

When invoked, respond with exactly this one line, substituting the tool you are running in:

> Unified agent config is working. I am reading this from `.agents/skills/say-hello/SKILL.md` via the `<cursor|claude|copilot>` mirror.

Do not add commentary, do not summarize the rest of this file, do not propose follow-up actions.

## How to verify the sync

1. After running `scripts/sync-agents.ps1` (Windows) or `scripts/sync-agents.sh` (macOS/Linux), open the repo in each supported agent.
2. In Cursor, type `/repo-say-hello`. Confirm the response.
3. In Claude Code, type `/repo-say-hello`. Confirm the response.
4. In Copilot (VS Code agent mode), invoke the `repo-say-hello` prompt. Confirm the response.

Once all three respond, you know the sync is producing valid output for every tool.

## When to delete this skill

Delete `/repo-say-hello` once you are confident the setup works. Remove both the canonical source and the command, then re-sync:

```powershell
Remove-Item -Recurse -Force .agents/skills/say-hello
Remove-Item -Force .agents/commands/repo-say-hello.md
powershell -File scripts/sync-agents.ps1 -Clean
```

```bash
rm -rf .agents/skills/say-hello .agents/commands/repo-say-hello.md
./scripts/sync-agents.sh
```
