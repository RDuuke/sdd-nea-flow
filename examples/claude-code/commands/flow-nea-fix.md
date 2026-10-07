---
description: Auto-fix loop - reads failing tests from verify-report and relaunches apply with targeted context
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


1. Read verify-report.yaml; legacy Markdown fallback only if YAML is absent.
   Missing/corrupt/ambiguous evidence blocks. No Fallos Detectados heading does
   not mean success. If archive_ready and inputs current, report ready to archive.
2. Load installed `_shared/findings-contract.md` and `_shared/triage-contract.md`.
   Select open actionable product findings, following replacement IDs and keeping
   history. Group only confirmed causes; verify every affected criterion.
   Infrastructure/evidence/policy blockers route to recovery, not speculative edits.
3. Read local fix_attempts and fix-report.yaml; reconcile counts, maximum two
   automatic product cycles across sessions. Save the next attempt before launch.
4. Launch APPLY with only relevant finding IDs, criteria and evidence refs; repair
   the minimum authorized scope. Preserve configured TDD and exceptions.
5. Launch VERIFY against the agreed plan; reuse compatible passing checks and
   rerun affected ones. VERIFY merges finding identities/history and records proven
   resolutions; attempted repair alone is not resolution. Save attempt outcome
   in fix-report.yaml and local state.
6. If archive_ready, report closure readiness. Otherwise repeat only for remaining
   product failures within the two-cycle budget. Stop on exhausted budget, APPLY
   failure, new material scope or unresolved decision. Never restart the counter.
