---
name: judgment-day
description: >
  Dual blind adversarial review system. Two independent judges review the same target simultaneously.
  Trigger: When user says "judgment day", "dual review", "revision dual", or "juzgar".
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Deploy two independent blind judges simultaneously to evaluate the same target, then synthesize their findings. Maximizes confidence in critical issues.

## What You Receive

- Change name (required)
- Artifact store mode (openspec | none)
- Evaluation criteria (optional — default: spec compliance, design adherence, code quality)

## Execution Flow

### Step 1: Resolve Project Skills

Read `.atl/skill-registry.md` to obtain compact rules relevant to the codebase. Inject into both judges.

### Step 2: Launch Judges in Parallel (async)

Launch Judge A and Judge B simultaneously with:
- Identical access to: specs, design, tasks, implemented code
- Identical evaluation criteria
- **NO knowledge of the other judge** (separate contexts)

Prompt for each judge:
```
You are an independent code reviewer. Review the implementation of change '{change-name}'.
Read: openspec/changes/{change-name}/specs/, design.md, tasks.md and the affected code.
Evaluate: spec compliance, design coherence, code quality, tests.
Categorize each finding as: CRITICAL | WARNING | SUGGESTION
Return a list of findings with: category, file:line, description, evidence.
```

### Step 3: Synthesize Verdicts

Compare results from both judges:

| Status | Condition | Action |
|--------|-----------|--------|
| **Confirmed** | Found by both judges | Apply fix |
| **Suspect A** | Judge A only | Review manually |
| **Suspect B** | Judge B only | Review manually |
| **Contradiction** | Judges disagree on the same issue | Escalate to user |

### Step 4: Show Verdict to User

Verdict table:
```
| Severity | Finding | Source | Status |
|----------|---------|--------|--------|
| CRITICAL   | ...   | Both   | Confirmed |
| WARNING    | ...   | Judge A | Suspect A |
```

Ask: "Should we apply the confirmed fixes?"

### Step 5: Apply Fixes (if user confirms)

Delegate to a separate Fix Agent (NEVER a judge applies fixes).
After applying, re-launch both judges (maximum 2 cycles).

### Step 6: Escalate if No Convergence

If after 2 cycles there are still confirmed critical issues: report to the user with the full history. Do not keep looping.

## Rules

- The orchestrator NEVER reviews code directly — only launches judges, reads results, and synthesizes
- Judges work blind to each other — no cross-contamination
- The Fix Agent is a separate delegation — a judge never applies fixes
- Maximum 2 fix+re-judge cycles before escalating
- Confirmed CRITICAL issues block ARCHIVE

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Judgment Day complete. N confirmed issues, M suspects.",
  "detailed_report": "Verdict table with all findings.",
  "artifacts": [],
  "confirmed_issues": ["list of confirmed issues"],
  "suspect_issues": ["list of single-judge issues"],
  "contradictions": ["list of contradictions"],
  "next_recommended": "ARCHIVE | APPLY",
  "risks": ["list of blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
