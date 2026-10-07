---
name: flow-nea-archive
description: >
  Sync delta specs to main specs and archive a completed change.
trigger: >
  When the orchestrator launches you to archive a change after verification.
license: MIT
metadata:
  author: juan-duque
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Consolidate accepted behavior into one current specification per domain and
archive the change. Never copy each change into base specs or append delta history.

## What to Do

### 1. Guard

Read selected local state and current verify-report.yaml (legacy fallback under
the audit contract). Require archive_ready: tasks/quick steps complete, accepted
criteria and required checks supported, input hashes current, no unresolved
approval/blocker. Never accept VERIFY phase or report existence as proof.
Resolve missing/legacy state via shared recovery, never borrow global state.
If already archived, validate/report that location without merging twice.

### 2. Prepare all domains before writes

Read each affected base spec and delta/full spec. Match requirements by existing
stable ID, otherwise exact unambiguous name within its domain. Do not fuzzy-match
or invent renames. ADDED introduces absent identities; an identical existing
requirement is an idempotent no-op, conflicting content blocks. MODIFIED replaces
the identified requirement and its scenarios with the specified current contract;
REMOVED removes that exact requirement. Preserve unrelated requirements/scenarios.
For new domains normalize full specs; normalize ADDED-only deltas into a base
document. Missing MODIFIED/REMOVED targets block unless a saved merge journal
proves this exact operation was already applied.

Base specs describe current behavior, with no ADDED/MODIFIED/REMOVED sections,
duplicate identities, per-change copies or obsolete requirements. Full-spec input
for an existing domain is not permission to replace unrelated content: identify
explicit accepted changes or stop for clarification. Conciseness guidance never
limits consolidated bases; never trim valid requirements to fit a word count.

Detect conflicts with base changes since planning. If a requirement changed
independently, reconcile explicitly rather than silently overwriting it. Validate
all proposed outputs and affected refs before any base write.

### 3. Journal and commit consolidation

Prepare .archive-transaction.yaml inside the selected change, with schema_version
1.0, change, verification fingerprint, destination, status, per-domain before/after
hashes, requirement operations and backup/prepared-file refs. Preserve exact base
bytes in local transaction backups. Recheck base hashes immediately before writes.
Atomically replace each prepared base file and update journal progress. On failure,
do not mark closed or move the change. Resume only when each current base hash
matches its recorded before or after hash; otherwise stop for conflict resolution.
This makes partial multi-domain consolidation recoverable without duplicate merges.

### 4. Move and close

After all domains match prepared results, move the change to
openspec/changes/archive/YYYY-MM-DD-{change-name}/. Validate resolved source and
destination, never overwrite an existing archive. Verify hashes and refs after
moving; rewrite relative refs in new structured reports for the new location,
preserving raw historical evidence bytes. Record original provenance separately.
Quick changes without specs still close; if they change documented behavior,
update the affected base contract from the approved quick criteria with the same
merge safeguards. Pure implementation fixes require no invented domain.

Write archive-report.yaml with verification_ref, destination and per-domain
operations/hashes. Persist archived local state with completed=true, ARCHIVE
complete, archive_path set. Update selector only if it selected this change;
never reset another active change. Append final event to archived execution log.
If interrupted after move, recover using the journal at the exact archive path;
never recreate the active folder. NeaBrain capture remains optional.

## Rules

No product tests, code repair, commit, push or deployment as part of ARCHIVE.
Never merge on stale evidence, unresolved conflicts or unsatisfied obligations.
Mode none reports proposed consolidation inline, without claiming persisted closure.

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
      "name": "archive_report",
      "path": "openspec/changes/archive/YYYY-MM-DD-{change-name}/archive-report.yaml",
      "type": "yaml"
    }
  ],
  "next_recommended": null,
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  }
}
```
