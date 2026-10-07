---
description: Fast-forward all planning phases — propose, spec, design, tasks in sequence
agent: flow-nea-orchestrator
---

META-COMMAND: handled by the orchestrator, not a separate phase skill.

CONTEXT:
- Change name: {argument}
- Artifact store mode: openspec

Resolve the installed skills root and read `_shared/execution-contract.md`
and `_shared/persistence-contract.md` with applicable references. Use their
STATUS, approval, execution and log procedures; do not infer state here.
Pass exact skill paths, scoped standards, edit surfaces and checks to each
bounded phase, choosing native workers or inline execution by actual permissions.


1. Create/update PROPOSE via its phase executor, unless unchanged valid output
   already exists. Show concrete scope and request its approval only if pending.
   FF does not bypass scope approval; record authorization already supplied.
2. Once approved, complete missing SPEC and DESIGN independently from proposal.
   Serialize state writes; neither depends on the other.
3. Run TASKS after both outputs and validation-plan.yaml are valid and coherent.
4. Return the combined planning summary and task count. Do not ask approval after
   every planning phase. FF ends at TASKS; do not implement without a user request.
Stop on unresolved blockers/material decisions. Resume without recreating valid
artifacts or resetting approvals.
