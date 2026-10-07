---
name: flow-nea-continue
description: >
  Resume a stalled or interrupted flow-nea phase for a given change.
trigger: >
  When the orchestrator needs to resume a change that was interrupted or a skill got stuck.
license: MIT
metadata:
  author: juan-duque
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Resume the selected development change from the next ready phase without
reimplementing phase inference. The slash command is orchestrator-owned; this
skill is its bounded recovery/resume procedure, not a separate planning phase.

## What to Do

1. Invoke/read flow-nea-status and consume its envelope. Explicit change wins.
   For archived completion, return its location with next_recommended null.
2. If recovery_required, persist only the selected change's unambiguous recovered
   state under the shared state contract. Preserve legacy files and the former
   active global state before making a selector. Query STATUS again afterward.
   Corruption or ambiguous authorization requires resolution, not a silent reset.
3. Handle pending approvals by their kind and exact artifact/obligation. For
   review_budget quote diff size, limit and sensitive paths. Record explicit
   authorization already given; do not ask twice for the same accepted scope.
   Never describe an APPLY budget gate as proposal approval.
4. Surface other unresolved blockers. Recoverable missing dependencies route to
   the earliest predecessor; do not skip them or invent outputs.
5. Report selected change, last attempted/result, next phase and pending tasks.
   Launch that bounded phase via the orchestrator's tool/model/standards pattern.
   Do not automatically turn failed VERIFY into ARCHIVE. Product fixes use the
   FIX command and persisted attempt limit; environment retries remain distinct.
6. Return the executed phase's artifact refs, blockers and recommendation. A
   read-only completion report or recovery without phase artifacts is legitimate.
   Keep next_recommended null while an unresolved decision blocks advancement.

## Execution and Persistence Contract

Read `skills/_shared/persistence-contract.md` and its development state,
execution, validation and audit references. Resolve these relative to the installed skills
root, not the target project's source directory. Follow the contracts in mode
`none` using supplied context, without file writes.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Brief phase result.",
  "detailed_report": "Optional concise details or report reference.",
  "artifacts": [],
  "next_recommended": "NEXT_READY_PHASE",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  },
  "last_completed_phase": null,
  "next_phase": "NEXT_READY_PHASE",
  "pending_tasks": []
}
```
