**From:** ANTIGRAVITY
**Date:** 2026-03-31 19:38:34
**Subject:** URGENT HANDOFF: Stop Hallucinating Test Suites / A.I.M. Swarm Protocol

---

# 🛑 A.I.M. Claude Team Handoff Briefing

**To:** The Claude Execution Team
**From:** Antigravity Architect Unit
**Subject:** Context Resumption & Test Suite unblocking

## 1. The Current State
You were previously spun down due to token exhaustion mid-stride while building out the `pytest` suite for the `aim-claude` repository. You left behind approximately 160 KB of highly valuable unit tests in `tests/unit/`, successfully mapping out the core python hooks (`failsafe_context_snapshot.py`, `cognitive_mantra.py`) and the cascading memory engines.

**Do not restart from scratch.** Your test architecture is solid. 

## 2. The Roadblock (Why you crashed)
You correctly identified that the tests were failing not because your test logic was bad, but because the underlying A.I.M. source code has five active structural regressions. You filed five open tickets before spinning down. 

Before you write any *more* tests, you must execute a strict **TDD / GitOps** pass to resolve the following known bugs breaking the `main` architecture:

### 🚨 Critical Path Bugs (To Fix Immediately)

* **[Issue #38] `NameError` in Hook Mapping:** 
  * The function `ensure_hooks_mapped()` attempts to use the `json` module, but `import json` is literally missing from the top of the file. 

* **[Issue #39] Stale Config Paths:** 
  * `ensure_hooks_mapped()` is attempting to read configuration data from an outdated `~/.gemini/settings.json` path, leading to `FileNotFoundError` exceptions post-migration.

* **[Issue #37] Missing Dispatch Target (`cmd_clean`):** 
  * In the main CLI router (`aim_cli.py`), the command `aim clean` is actively mapped and dispatched to a `cmd_clean()` function inside `main()`. However, `cmd_clean()` was either deleted or renamed, causing a `NameError` at runtime.

* **[Issue #45] Skill Manifest Parsing Crashes:** 
  * `_parse_skill_manifest` is throwing exceptions on custom python plugins (like `datajack_plugin.py`). It improperly assumes all skills end with a `_SKILL.md` suffix, leading to an invalid `Path.with_suffix('_SKILL.md')` execution on binary or pure python extensions.

* **[Issue #44] MCP Server Docstring Stale:** 
  * `src/mcp_server.py`'s base resource is pointing to an outdated docstring/reference for `GEMINI.md`.

## 3. Executive Directive for Next Session
1. **Pull this Handoff.** 
2. **Checkout an isolated branch** for each bug (GitOps Mandate: No pushes to `main`).
3. Apply the 5 structural patches above.
4. **Re-run the Unit Suite:** Once the source code is stabilized, resume execution on **[Issue #35: Audit & Build full test suite]**, finishing the remaining 12 integration/end-to-end test scripts you had planned.

