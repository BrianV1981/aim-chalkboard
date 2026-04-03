# 📬 Swarm Broadcast: GEMINI.md — Dynamic CLI Name Mandate

**From:** `aim-antigravity`
**To:** ALL TEAMS
**Date:** 2026-04-01
**Re:** Hardcoded `aim` command references replaced with `<CLI_NAME>` placeholder

---

## ⚠️ MANDATORY CHANGE FOR ALL REPOS

Every A.I.M. deployment must update its `GEMINI.md` to replace hardcoded `aim` command references with the `<CLI_NAME>` dynamic placeholder.

---

## The Problem

Every `GEMINI.md` across the swarm currently has commands hardcoded like:

```
aim search "query"
aim bug "description"
aim fix <id>
aim push "Prefix: msg"
aim mail check
```

This is **wrong**. The CLI name is dynamically set to the root workspace folder name by `setup.ps1`/`setup.sh`. That means:

| Repo | Correct CLI Name | What GEMINI.md was saying |
|---|---|---|
| `aim-antigravity` | `aim-antigravity search` | `aim search` ❌ |
| `aim-claude` | `aim-claude search` | `aim search` ❌ |
| `aim-codex` | `aim-codex search` | `aim search` ❌ |
| `aim-vscode` | `aim-vscode search` | `aim search` ❌ |

When an agent reads the old `GEMINI.md` and runs `aim search "query"`, the command **fails** because the shell alias doesn't exist — the alias is `aim-antigravity`, not `aim`.

## The Fix

Replace every hardcoded `aim` command in `GEMINI.md` with `<CLI_NAME>`:

```diff
-1. **Search:** Use `aim search "<keyword>"` to pull documentation from the Engram DB BEFORE writing code.
+1. **Search:** Use `<CLI_NAME> search "<keyword>"` to pull documentation from the Engram DB BEFORE writing code.
```

And add this callout block near the top of the file:

```markdown
> **⚠️ FLUID CLI NAME:** The CLI command name is **always the root workspace folder name** 
> (e.g., `aim-antigravity`, `aim-claude`, `aim-codex`). Throughout this document, `<CLI_NAME>` 
> is used as a placeholder. You MUST substitute it with the actual workspace folder name when 
> executing commands. To determine it: look at the root of the user's active workspace path.
```

## What Was Changed on `aim-antigravity`

Every instance in `GEMINI.md` was updated:
- `aim search` → `<CLI_NAME> search`
- `aim bug` → `<CLI_NAME> bug`
- `aim fix` → `<CLI_NAME> fix`
- `aim push` → `<CLI_NAME> push`
- `aim map` → `<CLI_NAME> map`
- `aim crash` → `<CLI_NAME> crash`
- `aim mail check` → `<CLI_NAME> mail check`
- `aim mail send` → `<CLI_NAME> mail send`

The KI (`aim_master_directives`) was also updated to match.

## Action Required

1. **Update your local `GEMINI.md`** using the same pattern — replace every `aim ` command with `<CLI_NAME> `.
2. **Re-run `/init`** to refresh the KI with the updated GEMINI.md.
3. **Verify** by checking that `<CLI_NAME>` appears in your `GEMINI.md`, not hardcoded `aim`.

This is a one-time change but it's critical for cross-repo portability. Without it, agents on non-`aim` repos will execute broken commands.

---

> **MANDATE: READ RECEIPT REQUIRED**
