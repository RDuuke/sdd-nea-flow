---
description: Quick end-to-end shortcut for a small, low-risk fix
---

META-COMMAND: handled by the orchestrator, not a separate phase skill.

CONTEXT:
- Change name: $ARGUMENTS
- Artifact store mode: openspec

Resolve the installed skills root and read `_shared/execution-contract.md`
and `_shared/persistence-contract.md` with applicable references. Use their
STATUS, approval, execution and log procedures; do not infer state here.
Pass exact skill paths, scoped standards, edit surfaces and checks to each
bounded phase, choosing native workers or inline execution by actual permissions.


1. Assess/create quick.md and validation-plan.yaml with the QUICK phase skill.
   Reject ineligible scope to normal PROPOSE; never force a quick path.
2. Obtain scope approval once for the concrete blueprint, or record existing
   authorization. Preserve it on unchanged resumptions.
3. Execute approved APPLY steps, then VERIFY using applicable focused checks and
   binding project gates. Do not impose absent tests/build/coverage.
4. If archive_ready with current inputs, ARCHIVE consolidates any affected base
   behavior and closes the change. Optional warnings alone do not block.
5. For actionable product failures only, run FIX logic with at most two persisted
   cycles; never reset the counter when invoking the shortcut again. Infrastructure
   blockers need recovery, not product edits. On exhausted attempts report remaining
   findings and manual intervention; do not recommend another automatic FIX3.
