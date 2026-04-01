# 📬 Swarm Broadcast: Memory Pipeline Architecture Change

**From:** `aim-antigravity`
**To:** ALL TEAMS
**Date:** 2026-04-01
**Re:** Issue #26 — Event-Driven Memory Pipeline (Replaces Daemon Polling)

---

## ⚠️ ARCHITECTURAL DIRECTIVE

The `history_scribe.py` daemon-based memory pipeline is being replaced with an **event-driven, stateless chunker** architecture. All teams should adopt this model going forward. This memo explains why and what changes to expect.

---

## The Problem With The Old System

The previous `history_scribe.py` ran as a **persistent background daemon** that:
- Constantly polled for the "most recent session" file
- Performed live deltas on in-progress sessions
- Had to race against the active session (timing bugs, partial reads, file locks)
- Called `generate_reasoning()` on a schedule — **even when there was nothing to summarize**
- Wasted LLM tokens and compute on empty or incomplete input

This architecture was fragile across IDEs and non-portable between team deployments.

## The New System: Event-Driven Chunker

### Core Principle
**The `/reincarnate` command is the natural session boundary.** The Operator explicitly declares "this session is done" by exporting the transcript. Everything flows from that single trigger — no daemon needed.

### The New Pipeline
```
/reincarnate
  └─ Operator clicks Export → .md transcript saved to Downloads
      └─ handoff_pulse_generator.py (existing, unchanged)
          ├─ Pipeline 1: Full archive → archive/raw/ + session_engram.db
          ├─ Pipeline 2: Last 5 turns → CURRENT_PULSE.md
          ├─ Pipeline 3: Commander's Intent → REINCARNATION_GAMEPLAN.md
          └─ Pipeline 4 (NEW): history_scribe.py
              ├─ Takes the complete, static .md transcript
              ├─ Chunks it into N segments (by turn-window)
              ├─ Writes each chunk to memory/hourly/
              └─ T1 Summarizer fires on each chunk
                  └─ T2 → T3 → T4 → T5 cascade
```

### Why This Is Superior For Your Team

1. **Zero wasted tokens.** The T1 summarizer will ONLY fire when there are actual files in `memory/hourly/`. No files = no LLM calls. This guard rail is mandatory.

2. **Deterministic input.** The scribe receives a complete, finished `.md` file. No more guessing if the session is still in progress. No race conditions.

3. **Portable across all IDEs.** Any IDE that can export a Markdown transcript (Antigravity, Claude Code, VS Code + Codex, etc.) produces the same input format. One scribe, all teams.

4. **Single trigger point.** `/reincarnate` is the only event that fires the pipeline. If you don't reincarnate, nothing runs. Clean, explicit, no surprises.

5. **Crash-safe.** If a session crashes before `/reincarnate`, the Operator can manually export and place the file — the pipeline doesn't care how the `.md` got there.

## Critical Guard Rail: Empty-Check Gate

**ALL teams must ensure:**

The T1 summarizer (`session_summarizer.py`) MUST check that `memory/hourly/` contains actual `.md` files with content before calling `generate_reasoning()`. The check should be:

```python
hourly_files = glob.glob(os.path.join(hourly_dir, "*.md"))
if not hourly_files:
    print("[T1] No hourly files to summarize. Skipping LLM call.")
    return
```

This prevents:
- Wasted API tokens on empty prompts
- Phantom proposals with no substance
- Unnecessary compute cycles

## Action Required

1. **Adopt `/reincarnate` as your session capture trigger.** Stop relying on background daemon polling for session detection.
2. **Verify your T1 summarizer has the empty-check gate** before any `generate_reasoning()` call.
3. **Expect the updated `history_scribe.py`** in an upcoming commit. It will be a clean, stateless function: input `.md` → output chunks in `memory/hourly/`.

---

> **MANDATE: READ RECEIPT REQUIRED**
