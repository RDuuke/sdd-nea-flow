# Development Finding Continuity

Use existing verify-report.yaml and fix-report.yaml: no separate ledger, state
authority, engine or retry budget. Envelope remains 1.0; fields are additive.
Old findings without resolution are open with original category/blocking intact.
Do not invent historical verdicts.

## Identity and current disposition

Keep existing keys from [audit-contract.md](audit-contract.md). New writers add:

- `resolution: open | resolved | dismissed | superseded`.
- `history`: compact append-only real transitions, each with `at` (ISO time with
  zone), `resolution`, `blocking`, `summary`, `evidence_refs`, `input_hashes`.
  Preserve old entries/raw evidence, without copied stdout.
- For non-open resolution: `resolution_reason`, `resolution_at`,
  `resolution_evidence_ids` referencing evidence in this report.
- For resolved/dismissed: nonempty `resolution_input_hashes` for relevant current
  inputs, not merely a commit. Check execution/environment compatibility under
  [validation-contract.md](validation-contract.md).
- For superseded: nonempty `superseded_by` IDs in the same report, without missing
  targets, self-reference or replacement cycles.

`blocking` describes the current finding; terminal resolutions are nonblocking
and history retains earlier failure. Open informational findings may be
nonblocking; never downgrade an unmet obligation just to remove a blocker.
Older findings need no fabricated history; record the first real observation
when updating them. Preserve unknown fields and original identities.

## Merge and verify transitions

Read prior report before replacing. Keep IDs for the same unambiguous symptom
and criterion; no renumbering per run or reset through an empty findings array.
Retain prior findings/evidence/history with current results. If matching is
uncertain, preserve the open finding and record a linked new one instead of
silently merging distinct problems.

- **open:** actionable or missing required proof. APPLY/FIX records attempted
  repairs; VERIFY owns evidence-based resolution. Reappearing symptoms reuse
  their original ID.
- **resolved:** current executed evidence proves all associated criteria repaired.
  Inspection alone cannot resolve runtime defects. Validate all grouped symptoms;
  split partially repaired findings explicitly when necessary.
- **dismissed:** evidence establishes false positive, duplicate advisory or a
  justified out-of-scope baseline observation. State why; it does not waive an
  accepted criterion/required check. Exceptions keep separate typed approvals
  and accepted replacement obligations.
- **superseded:** active finding(s) describe the same obligation more accurately,
  with rationale/evidence and retained original history. Replacements inherit
  unresolved criteria/blocking obligations. Supersession is not proof of repair.

On relevant input/environment changes, reassess resolution proof. Retain closed
results only with current compatible evidence; otherwise reopen and append the
real observation, preserving old proof. Unrelated changes do not invalidate it.
When reopening, clear current terminal-resolution fields; retain their prior
values in historical evidence/entries, without presenting them as current proof.
Failed inspection/access is no completed verdict.

FIX selects open product findings following supersession, keeps finding_ids in
attempts and uses [triage-contract.md](triage-contract.md). Groups do not reset
or extend the two-cycle budget. Closed history does not trigger automatic repair.
Infrastructure/evidence/policy need recovery, not speculative product changes.

Closure evaluates required checks, current criteria, tasks, approvals, open
blockers and replacement targets. Retained valid history is not itself a blocker
or proof of success. Review does not replace functional verification or authorize
commit/push/publication.
