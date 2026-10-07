---
description: Resume a stalled or interrupted flow-nea change
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


Use the bounded flow-nea-continue/SKILL.md recovery procedure directly in
the orchestrator; do not invoke /flow-nea-continue as an executor phase.
Change is optional: selector fallback. Preserve legacy evidence, resolve only
actual pending approval kinds, and execute the next ready phase. An archived
change returns its location; failed VERIFY never means ARCHIVE.
