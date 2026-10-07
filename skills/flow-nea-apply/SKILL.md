---
name: flow-nea-apply
description: >
  Implement tasks from the change, writing actual code following specs and design.
trigger: >
  When the orchestrator launches you to implement one or more tasks from a change.
license: MIT
metadata:
  author: juan-duque
  version: "3.2"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Implement assigned tasks or approved quick steps, preserving scoped progress
and collecting only the validation evidence needed by the change.

## What to Do

1. Read selected local state, tasks/design/specs (normal), or quick (quick path),
   and validation-plan.yaml. Reconcile pending IDs with actual checkboxes. If a
   legacy change lacks a plan, recover its agreed validation without inventing
   broader obligations. Confirm scope approval and dependencies before code.
   For repairs load [triage-contract.md](../_shared/triage-contract.md) and
   [findings-contract.md](../_shared/findings-contract.md); follow active finding
   IDs/replacements, not historical closed findings. Reproduce the symptom and
   repair a shared cause only when corroborated. Record attempted repair evidence
   against each affected ID; VERIFY determines resolution, not APPLY self-report.
2. Follow existing code patterns and project standards. Optional related skills
   may be loaded for affected files; absence is informational, not a blocker.
   If experimental.neabrain is enabled, use the shared availability protocol;
   memory cannot override code or OpenSpec.
3. Resolve TDD from canonical gates.apply.tdd, then legacy rules.apply.tdd.
   Default off; an optional testing skill does not enable a strict gate. In
   strict mode each behavioral task requires real failing RED before production
   code, GREEN after, optional triangulation/refactor. Non-behavioral tasks record
   not_applicable with reason. Missing mandatory infrastructure/evidence blocks
   that task unless an explicit change-local exception is approved.
4. Implement only assigned tasks in small dependency-ordered batches. Execute
   focused agreed checks; broaden only for demonstrated impact or binding gates.
   Preserve passing compatible evidence, record command/result/provenance and
   store long output separately. Do not rerun all builds/tests after every batch.
   Run agreed source-mutating formatters/code generation before the final
   verification snapshot; record changed inputs and invalidate affected evidence.
5. Check configured review budget (canonical gates, legacy fallback). Measure
   the change's tracked staged/unstaged and relevant untracked changes against
   its recorded baseline; exclude unrelated preexisting work and audit artifacts.
   Do not mix HEAD-only and main-branch baselines. If attribution is uncertain,
   report it. Approval covers the reviewed diff fingerprint, size and paths;
   new material changes outside that scope need a new gate decision.
6. Persist task records in apply-progress.yaml and completed checkboxes in tasks.md.
   Merge local state, recompute pending IDs, record phase APPLY and actual result.
   Add APPLY to completed_phases only when every task/quick step is complete.
   Preserve pending approvals, fix attempts and unrelated blockers. A budget gate
   creates a typed pending approval, never just a note string.
7. Report batch progress and continue authorized batches without routine approval
   pauses. Stop for unresolved mandatory gates or new material scope/risk. If a
   spec/design contradiction emerges, use scoped reconciliation and invalidate
   stale verification under the state contract before continuing.

## Evidence

Use task records and evidence references defined in audit-contract.md, not
Markdown RED/GREEN paragraphs. Do not mark behavioral tasks complete when
configured strict TDD cannot be honored. Do not claim documentation needs a
fabricated failing test. In mode none return progress inline without file writes.

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
  "artifacts": [
    {
      "name": "apply_progress",
      "path": "openspec/changes/{change-name}/apply-progress.yaml",
      "type": "yaml"
    }
  ],
  "next_recommended": "APPLY | VERIFY",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  },
  "tasks_completed": [],
  "tasks_pending": [],
  "tdd_evidence": {
    "mode": "off | strict",
    "tasks": []
  },
  "review_budget": {
    "checked": false,
    "tripped": false,
    "diff_lines": 0,
    "limit": 0,
    "sensitive_paths_touched": []
  }
}
```
