# Development Audit Contract (schema 1.0)

New operational records are YAML, with English keys and Spanish summaries,
reasons and observations. Planning remains Markdown. Applies only to development
changes; initiative logs retain their own contract.

For concrete file examples read [audit-examples.md](audit-examples.md). They are
illustrative schemas, not execution evidence; never copy their sample observations
or hashes into a real report.

## Envelope and files

Each document is one YAML mapping (no multi-document stream):

```yaml
schema_version: "1.0"
kind: verify_report
change: example-change
updated_at: "2026-10-06T15:42:00-05:00"
status: ok
summary: "Criterios verificados con evidencia vigente."
artifact_refs: []
```

Required envelope keys above; `status: ok | warning | failed`. Allowed kinds:
`execution_log`, `apply_progress`, `validation_plan`, `verify_report`,
`fix_report`, `archive_report`. All refs are relative to the containing file,
including archived reports; provenance paths inside raw legacy evidence need
not be rewritten. Preserve external evidence and cross-change refs on archive.
Never embed secrets, full stdout, source code or repeated narrative in records.

| File | Additional required fields |
|---|---|
| `.execution-log.yaml` | `events` |
| `apply-progress.yaml` | `tasks` |
| `validation-plan.yaml` | `impact`, `checks`, `exceptions` |
| `verify-report.yaml` | `archive_ready`, `input_hashes`, `criteria`, `checks`, `evidence`, `findings`, `incomplete_tasks` |
| `fix-report.yaml` | `attempts` |
| `archive-report.yaml` | `archive_path`, `verification_ref`, `domains` |

An execution event contains `id`, `phase`, `started_at`, `finished_at`, `status`,
`summary`, `artifact_refs`, `risks`, `attempt`, `retried`. Timestamp strings use
ISO 8601 with timezone; capture actual time, never invent time to satisfy shape.
Maintain events in order. Repeated delivery of the same event ID is a no-op;
conflicting payload for an existing ID is a blocker. New attempts get new IDs
and increasing attempt numbers. Log after state/output persistence; log failure
does not justify rerunning successful product work. Append the final ARCHIVE
event at the archived path, never recreate the moved active folder.

Task records: `id`, `status: pending | in_progress | complete | blocked`,
`summary`, `evidence_refs`, `tdd` (applicability, reason, red/green refs where
required). Quick uses stable step IDs `q1`, `q2`, etc. Preserve previous evidence
when updating a task; completion must agree with Markdown checkboxes.

VERIFY criteria: `id`, `source_ref`, `status` (compliance label from validation
contract), `check_ids`, `evidence_ids`. Results in `checks` include `id`,
`required`, `result`, `reason`, `evidence_ids`. Findings include `id`, `category`,
`severity`, `blocking`, `summary`, `criterion_ids`, `artifact_refs`. An empty
findings array is not proof of success: inspect archive_ready and all obligations.

For continuity and additive resolution/history fields, read
[findings-contract.md](findings-contract.md). Existing 1.0 findings remain readable;
missing resolution means open. New VERIFY output preserves earlier identities,
evidence and observations instead of erasing corrected findings.

FIX attempts: `number` (1 or 2), `finding_ids`, `started_at`, `finished_at`,
`status`, `apply_ref`, `verify_ref`, `summary`. Preserve attempts across sessions.
ARCHIVE domains: `domain`, `base_ref`, `before_hash`, `after_hash`, `added`,
`modified`, `removed`, `unchanged_count`, `status`. Counts alone do not prove a
merge: retain requirement identities and before/after hashes.

## Safe persistence and compact reads

Read existing mapping before update, preserve unknown fields, serialize valid
YAML with duplicate keys forbidden, validate, then replace via a temporary file
in the same directory. Do not append ad-hoc YAML fragments or truncate history.
Serialize writes; stop on changed revision/input hashes. Read back replaced records,
verifying intended identities/updates before reporting persistence success.
Failed readback needs reconciliation, not a blind second write. Read summaries/status
and only relevant task/finding/evidence records for handoff. Load raw evidence
only when checking a specific obligation. No parallel Markdown audit duplicate.

## Legacy compatibility

Prefer new YAML if present; a malformed YAML report is a blocker, never a reason
to silently fall back to Markdown. If absent, read legacy `.execution-log.md`,
`apply-progress.md`, `verify-report.md`, `fix-report-*.md`, `archive-report.md`.
Preserve originals; convert selected records only when their meaning is known.
Reference legacy evidence without rewriting history or inventing observations.
Unknown compliance or approval remains unresolved. Logs remain informational.
The absence of `## Fallos Detectados` does not establish successful verification.

## Phase JSON response

Preserve `status`, `executive_summary`, `detailed_report` (optional), `artifacts`,
`next_recommended`, `risks`, `skill_resolution`. YAML artifacts use `type: yaml`.
Add `action_context` with `blocked`, `reason`, `requires_user_input`, plus
`archive_ready` for VERIFY. Human-readable risks alone do not imply a blocking
gate. `next_recommended: null` for finished or unresolved blocked transitions.
Return actual enum values and one next phase in executions; union strings in
skill JSON examples describe accepted values and are not literal runtime output.
