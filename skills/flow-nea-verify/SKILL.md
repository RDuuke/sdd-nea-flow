---
name: flow-nea-verify
description: >
  Validate that implementation matches the declared change artifacts using real execution.
trigger: >
  When the orchestrator launches you to verify a completed change.
license: MIT
metadata:
  author: juan-duque
  version: "3.2"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Verify agreed criteria with executed, current evidence proportional to project
capabilities and change impact. Missing automation alone is not failed behavior.
This phase reports findings; it does not fix product code.

## What to Do

1. Read selected change state and tasks or quick steps. Retain incomplete IDs.
   Read specs/design and validation-plan.yaml; for legacy projects derive the
   plan from their existing agreement and mandatory gates, then persist it.
   Resolve contradictory policy before running checks.
2. Map every changed requirement scenario/quick criterion to checks and evidence.
   Use COMPLIANT, FAILING, UNVERIFIED, PARTIAL from validation-contract.md.
   Automated tests, direct API/CLI/browser and documented manual checks can
   establish compliance. Static inspection cannot prove runtime behavior.
3. Confirm design coherence and applicable strict TDD evidence in apply-progress.yaml
   (legacy Markdown fallback only if YAML absent). Non-behavioral exemptions need
   reasons. Unmet mandatory evidence remains blocking; never manufacture RED.
4. Confirm source normalization is complete. Use check-only commands; a command
   that mutates source requires input reconciliation and affected rechecks.
   Classify failure origin under the validation contract: change, reproduced
   baseline or unknown. Baseline attribution never waives a required gate.
   Refresh affected capability observations. Execute agreed required checks using
   existing project commands and wrappers. Test/build/coverage are optional when
   not applicable; honor full-suite/coverage/CI obligations explicitly configured.
   No universal 80 percent threshold. Expand focused checks only when impact
   warrants it, and record the reason. Do not install tooling merely to meet a
   generic phase template.
5. Reuse compatible passing evidence rather than rerunning it. Verify relevant
   input hashes, dirty-tree sources, test/config and environment identity. Record
   original execution and current compatibility; unavailable provenance requires
   rerunning the affected check, not all checks. Cancelled/skipped checks are not
   passed. Record unavailable runtime as blocked, not a product defect.
   After FIX, rerun the failed tests and regression checks affected by the repair;
   preserve independent current PASS evidence. Record any reason to expand to
   a complete suite under the validation contract.
6. Reconcile review-budget approval with the actual current diff and preserve
   exceptions scoped to this change. A new material input change invalidates the
   affected evidence/approval. Audit environment restoration when checks mutate
   persistent state and project policy requires it.
7. Read prior verify-report.yaml and apply repair refs before composing output.
   Follow [findings-contract.md](../_shared/findings-contract.md): retain IDs,
   earlier evidence/history and current resolution. Reassess affected closed
   findings; append real transitions rather than resetting the list. Resolve only
   with current proof of every associated criterion. No access means no verdict.
   Write verify-report.yaml with criteria, check results, evidence refs, input
   hashes, findings and incomplete_tasks. Findings distinguish product,
   infrastructure, evidence and policy; include blocking explicitly. Empty
   findings or report existence alone is not success.
8. Compute archive_ready under validation-contract.md. Required checks and criteria
   must pass, tasks be complete, gates satisfied and blockers resolved. Optional
   warnings may coexist with archive_ready. Persist actual phase/result and only
   complete VERIFY when archive_ready is true. Never clear pending tasks or
   approvals unconditionally.
9. Return ARCHIVE only for archive_ready and current evidence; else VERIFY for
   environment/evidence recovery, APPLY for targeted product repair, or null for
   unresolved decisions. NeaBrain capture, if enabled, uses the shared protocol.

## Rules

- Store concise structured reports; reference raw outputs without copying them.
- Missing optional skill/build/coverage is informational, not a gate failure.
- Preserve explicit configured obligations and authorized local exceptions.
- Keep genuine failures visible; proportional validation does not waive criteria.
- Mode none returns the same evidence/results inline without persistence.

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
      "name": "verify_report",
      "path": "openspec/changes/{change-name}/verify-report.yaml",
      "type": "yaml"
    }
  ],
  "next_recommended": "ARCHIVE | APPLY | VERIFY | null",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  },
  "archive_ready": false
}
```
