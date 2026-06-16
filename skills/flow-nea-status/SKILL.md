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
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Single source of truth for flow-nea state. Replaces ad-hoc reads of
`.status.yaml` and the phase-inference table that used to live inside
`flow-nea-continue` and the orchestrator.

This skill is strictly read-only. It MUST NOT modify any file.

## What You Receive

- `change_name` (optional): if absent, derive from `.status.yaml`
- Artifact store mode (`openspec` | `none`)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

This skill never writes.

## What to Do

### Step 1: Resolve Active Change

1. If `change_name` was passed, use it.
2. Otherwise read `openspec/changes/.status.yaml` and use its `change` field.
3. If neither is available, report `status: warning` and
   `action_context.blocked: true` with reason `"No active change resolved"`.

### Step 2: Detect Current Phase

Priority order:

1. `.status.yaml` -> `phase` field (canonical).
2. If `.status.yaml` is missing, infer from artifacts (first match wins):

   | Condition | Phase |
   |---|---|
   | `verify-report.md` exists and reports `status: ok` | ARCHIVE |
   | `verify-report.md` exists | VERIFY |
   | `tasks.md` with all items checked | VERIFY |
   | `tasks.md` with unchecked items | APPLY |
   | `quick.md` exists and no `tasks.md` | APPLY (quick) |
   | `design.md` exists | TASKS |
   | `specs/` folder exists | DESIGN |
   | `proposal.md` exists | SPEC |
   | `exploration.md` exists | PROPOSE |
   | `openspec/config.yaml` only | EXPLORE |
   | nothing | INIT |

3. If `.status.json` (legacy) exists and `.status.yaml` does not, the skill
   reports the inferred phase but does NOT migrate the file (write is forbidden).
   Add a risk: `"Legacy .status.json present; flow-nea-init should migrate it"`.

### Step 3: Compute Task Progress

If `openspec/changes/{change-name}/tasks.md` exists:

1. Count lines matching `- [x]` and `- [ ]`.
2. Capture the literal unchecked lines (max 50, trimmed).

If `quick.md` exists and no `tasks.md`:
- `task_progress` = `{ "mode": "quick", "complete": 0, "unchecked": 0, "unchecked_lines": [] }`.

### Step 4: Check Dependencies

Map each phase to its required predecessor artifacts:

| Phase | Required artifacts |
|-------|--------------------|
| SPEC | `proposal.md` |
| DESIGN | `proposal.md` |
| TASKS | `specs/` (non-empty) AND `design.md` |
| APPLY | `tasks.md` OR `quick.md` |
| VERIFY | implementation + (`tasks.md` OR `quick.md`) |
| ARCHIVE | `verify-report.md` with `status: ok` |

If the current phase's predecessor is missing, list it under
`missing_dependencies`.

### Step 5: Determine Next Phase

Use the dependency graph:

```text
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```

Special cases:

- Quick path: `QUICK` -> `APPLY` -> `VERIFY` -> `ARCHIVE` (skipping SPEC/DESIGN/TASKS).
- If `awaiting_approval: true`, `next_phase` is the same as `current_phase`
  and `action_context.blocked: true` with reason `"awaiting_approval"`.
- If `pending_tasks` is non-empty and current phase is APPLY, `next_phase` is
  APPLY (not VERIFY).

### Step 6: Action Context

Populate `action_context` to tell the orchestrator whether it can proceed:

- `blocked`: `true` when phase cannot advance (awaiting approval, missing
  dependency, ambiguous change selection, etc.).
- `reason`: short string (max 80 chars) explaining the block.
- `requires_user_input`: `true` if the orchestrator must ask the user.

## Rules

- This skill never writes. If status files are corrupted, report and stop.
- Do not invoke other skills.
- Do not summarize artifact contents; only count and classify.
- All artifact content read in espanol; reports/fields stay in English keys.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Active change X is at phase APPLY with 2 unchecked tasks.",
  "change_name": "my-change",
  "current_phase": "APPLY",
  "next_phase": "VERIFY",
  "awaiting_approval": false,
  "task_progress": {
    "mode": "normal | quick",
    "complete": 4,
    "unchecked": 2,
    "unchecked_lines": ["- [ ] 2.1 Wire X", "- [ ] 2.2 Cover edge Y"]
  },
  "artifacts_present": ["proposal.md", "specs/", "design.md", "tasks.md"],
  "missing_dependencies": [],
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  },
  "next_recommended": "VERIFY",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
