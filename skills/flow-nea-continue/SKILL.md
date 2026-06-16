---
name: flow-nea-continue
description: >
  Resume a stalled or interrupted flow-nea phase for a given change.
trigger: >
  When the orchestrator needs to resume a change that was interrupted or a skill got stuck.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Detect the last completed phase of a change and resume from where it stopped.

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Query State

Invoke `flow-nea-status` (read-only) and consume its envelope. Do not
re-implement phase detection here — `flow-nea-status` is the single source
of truth for `current_phase`, `next_phase`, `task_progress`, and
`action_context`.

If `action_context.blocked: true`:
- `reason == "awaiting_approval"` and current phase is QUICK:
  stop and tell the user: "El quick blueprint está listo. Por favor revísalo en openspec/changes/{change-name}/quick.md y confirma para continuar a APPLY."
- `reason == "awaiting_approval"` (other phases): stop and tell the user:
  "La propuesta está lista. Por favor revísala en openspec/changes/{change-name}/proposal.md y confirma para continuar a SPEC."
- `reason` mentions `review_budget`: stop and tell the user: "El cambio
  excede el presupuesto de revisión. Aprueba en `.status.yaml.notes` o
  reduce el alcance antes de continuar."
- Any other blocking reason: surface it verbatim to the user and stop.

If `.status.yaml` is missing fields against the current schema, write the
full template before resuming (this is the one persistence side-effect this
skill performs — `flow-nea-status` itself stays read-only).

If `.status.json` (legacy) exists and `.status.yaml` does not, migrate the
legacy file to the current template here and delete the JSON.

### Step 2: Report State

Tell the user:
- Last completed phase
- Next phase to execute
- Pending tasks if resuming APPLY (list unchecked items from tasks.md)

### Step 3: Resume

Invoke the next phase skill as the orchestrator would normally do, passing change-name and artifact_store.mode.

Next phase mapping:

- `QUICK` -> `APPLY`
- `VERIFY` -> `ARCHIVE`
- standard phases follow the normal dependency chain

## Rules

- Never skip phases inside the selected path.
- If tasks.md has unchecked items, resume APPLY not VERIFY.
- If a required artifact is missing, report it and stop.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Resumed from phase X. Next: Y.",
  "last_completed_phase": "PHASE_NAME",
  "next_phase": "PHASE_NAME",
  "pending_tasks": ["list if resuming APPLY"],
  "artifacts": [],
  "risks": ["list of blockers if any"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
