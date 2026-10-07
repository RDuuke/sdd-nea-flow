---
name: flow-nea-tasks
description: >
  Break down a change into an implementation task checklist.
trigger: >
  When the orchestrator launches you to create or update the task breakdown for a change.
license: MIT
metadata:
  author: juan-duque
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Create a concrete task checklist organized by dependency and reviewable work
units, retaining accepted criteria and the project's applicable validation.

## Workflow

1. Read selected state, approved proposal, specs, design and validation-plan.yaml.
   Require valid SPEC/DESIGN and resolved scope approval. Use actual project paths;
   optional NeaBrain remains enrichment only under its availability protocol.
2. Cross-check behavior, externally observable names/messages, quantities and
   data contracts across artifacts. Design must implement, not override, accepted
   outcomes. Do not require internal classes/methods to appear in WHAT-only specs.
   Reconcile obligations and exceptions. On contradiction, return a blocking
   warning with affected IDs and SPEC/DESIGN recommendation; do not write tasks.
3. Write openspec/changes/{change-name}/tasks.md in Spanish. Group related behavior,
   checks and docs into coherent dependency-ordered units; use only stages needed
   by this change. Hierarchical stable IDs (1.1, 1.2, ...) identify checkboxes.
   For each task identify the concrete action/paths, criterion and verification
   method/check ID. Include dependencies when non-obvious. Split ambiguous or
   unwieldy tasks rather than promising an arbitrary one-session deadline.
4. Classify TDD applicability. Include real RED/GREEN steps only where configured
   and behavioral; non-behavioral tasks need justified non-applicability. Include
   agreed checks, not invented unit/integration/E2E layers or automatic suites.
5. Merge updates without losing checked progress/evidence. Changed definitions
   trigger shared invalidation; a checkbox alone does not redefine a task. Save
   and read back the checklist, then merge local state and pending unchecked IDs.
   Complete TASKS only for a coherent actionable plan. No circular dependencies.
6. Return the standard envelope. Optional delivery planning can identify work
   units, validation refs and rollback effects under
   [delivery-contract.md](../_shared/delivery-contract.md); it creates no mandatory
   commit task or publication gate. Keep prose concise without a fixed word/line
   count or five-stage skeleton.

## Execution and Persistence Contract

Read the installed skills/_shared/persistence-contract.md and its applicable
state, execution, validation and audit references. Mode none returns the plan
inline without project writes. Preserve phase scope and existing authorization.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Task list complete. X phases and Y tasks.",
  "detailed_report": "Notes or persistence info.",
  "artifacts": [
    {
      "name": "tasks",
      "path": "openspec/changes/{change-name}/tasks.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "APPLY",
  "risks": [
    "list of risks or blockers"
  ],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  }
}
```

Return a single next_recommended phase from the state contract, not the literal
union shown in examples. Set action_context.blocked=true for unresolved required
inputs, material decisions or scope approval; optional warnings stay unblocked.
