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

### Step 1: Detect Last Completed Phase

Primary source: read openspec/changes/.status.yaml
- Use `phase` and `change` fields directly.
- If `awaiting_approval: true` in status, stop and tell the user: "La propuesta está lista. Por favor revísala en openspec/changes/{change-name}/proposal.md y confirma para continuar a SPEC."
- If any field is missing (`pending_tasks`, `modified_artifacts`, `notes`, `schema_version`), fill with defaults and rewrite the file with the full template before continuing.

If .status.yaml is missing, check for legacy .status.json:
- If found, migrate values to .status.yaml with full template (including new fields), delete .status.json, and continue.

Fallback (if neither file exists), infer from files (first match wins):

| Condition | Resume at |
|---|---|
| verify-report.md exists | ARCHIVE |
| tasks.md all items checked | VERIFY |
| tasks.md has unchecked items | APPLY |
| tasks.md exists | APPLY |
| design.md exists | TASKS |
| specs/ folder exists | DESIGN |
| proposal.md exists | SPEC |
| exploration.md exists | PROPOSE |
| openspec/config.yaml only | EXPLORE |
| Nothing | INIT |

### Step 2: Report State

Tell the user:
- Last completed phase
- Next phase to execute
- Pending tasks if resuming APPLY (list unchecked items from tasks.md)

### Step 3: Resume

Invoke the next phase skill as the orchestrator would normally do, passing change-name and artifact_store.mode.

## Rules

- Never skip phases.
- If tasks.md has unchecked items, resume APPLY not VERIFY.
- If a required artifact is missing, report it and stop.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

{
  "status": "ok | warning | failed",
  "executive_summary": "Resumed from phase X. Next: Y.",
  "last_completed_phase": "PHASE_NAME",
  "next_phase": "PHASE_NAME",
  "pending_tasks": ["list if resuming APPLY"],
  "artifacts": [],
  "risks": ["list of blockers if any"]
}
