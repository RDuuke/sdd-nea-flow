---
name: flow-nea-status
description: >
  Read-only status engine. Produces a normalized envelope describing the
  active change, its phase, task progress, missing dependencies and the next
  recommended phase. Used by the orchestrator and by flow-nea-continue.
trigger: >
  When the orchestrator (or another skill) needs the current flow state for a
  change without re-implementing the detection logic.
license: MIT
metadata:
  author: juan-duque
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Resolve one change's state and next ready phase. Strictly read-only: never
initialize, migrate, rewrite or invoke another skill.

## What to Do

1. Validate explicit change-name, else read global selector (`active_change`,
   legacy `change` fallback). If unresolved, report a selection blocker; do not
   choose a folder arbitrarily. With no config report INIT as setup recommendation.
2. Read the selected change's local state. If absent, assess own artifacts and
   matching legacy/snapshot state under state-contract.md. Never use another
   change's global phase. Resolve explicitly archived changes by exact slug.
3. Check input hashes, completed phases and pending approvals. Count task
   checkboxes (`[x]` or `[X]`, `[ ]`) and use unchecked IDs over stale cached state.
   Quick progress comes from apply-progress.yaml, not an empty task count.
4. Compute the next phase using the shared dependency algorithm. Distinguish
   last attempted phase, completed phases and next phase. SPEC and DESIGN are
   independent; missing DESIGN does not imply SPEC must run again.
5. Check required predecessor outputs for the proposed transition: approved
   proposal for SPEC/DESIGN; valid specs and design for TASKS; tasks plus plan or
   approved quick plus plan for APPLY; implemented steps and agreed plan for
   VERIFY; current archive_ready evidence for ARCHIVE. Return missing dependencies
   and earliest recoverable predecessor, never jump to ARCHIVE from VERIFY alone.
6. Return blockers for pending approval, ambiguous/corrupt state, unavailable
   mandatory evidence or unresolved recovery. Missing local state with unambiguous
   inference is `recovery_required: true`; CONTINUE may persist it without another
   user decision. Any uncertain approval needs user input. Archived completion has
   next_phase null and archived_path set, no writes or repeated execution.

Read only structured fields relevant to state. Inspect legacy verify-report.md
only when YAML is absent and its meaning must be recovered. Logs never establish
canonical state. Preserve the standard JSON keys with artifacts empty (read-only
output is valid, not a failed phase).

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
  "next_recommended": "SPEC",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  },
  "change_name": "example-change",
  "current_phase": "PROPOSE",
  "phase_status": "ok",
  "completed_phases": [
    "PROPOSE"
  ],
  "next_phase": "SPEC",
  "awaiting_approval": false,
  "pending_approvals": [],
  "task_progress": {
    "mode": "normal",
    "complete": 0,
    "unchecked": 0,
    "unchecked_lines": []
  },
  "artifacts_present": [],
  "missing_dependencies": [],
  "recovery_required": false,
  "state_source": "local",
  "archived_path": null
}
```
