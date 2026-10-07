# Development State Contract (schema 2.0)

Applies to project changes only, never to the initiative layer. Read this with
`persistence-contract.md`. STATUS is read-only; phase writers and CONTINUE own
state persistence. No state or artifact writes in mode `none`.

## Locations and selection

- `openspec/changes/.status.yaml`: selector only: `schema_version: "2.0"`,
  `active_change: null` (or validated slug). INIT preserves an existing selector.
- `openspec/changes/{change-name}/.status.yaml`: canonical change state.
- Explicit change-name wins over selector. Never transfer another change's
  phase, approval, tasks or verification to the requested change.
- Switching the selector preserves all other change states. One writer per
  change; concurrent writers must stop on a revision mismatch. SPEC and DESIGN
  may run in either order but state writes must be serialized and merged.
- For explicit archived changes, enumerate immediate children of
  `openspec/changes/archive/` and resolve date-prefixed names by exact slug.
  Return archive location with no next phase; multiple matches require selection.
  Do not recursively search the project or create a new active folder.

## Change state template

```yaml
schema_version: "2.0"
change: example-change
revision: 1
path: normal  # normal | quick
phase: PROPOSE  # last attempted phase, NOT next phase or proof of completion
phase_status: ok  # ok | warning | failed | running
completed_phases: [EXPLORE, PROPOSE]
completed: false  # true only after ARCHIVE finishes
pending_tasks: []
modified_artifacts: []
artifact_hashes: {}  # relative path -> SHA-256 of planning inputs
approvals: []
blockers: []
fix_attempts: 0
archive_path: null
notes: ""
```

Persist successful phase completion only when its required output is valid and
its phase-specific completion conditions hold. Warnings may complete a phase
if they are informational; a blocked, partial or failed phase never completes.
PROPOSE/QUICK can complete artifact creation while approval remains pending.
APPLY completes only when all tasks (or all quick steps) are complete. VERIFY
completes only when `archive_ready: true` under the validation contract.
Read/merge latest state before each write, increment revision, and preserve
unrelated fields. Never clear approvals, pending tasks or blockers wholesale.
Task checkboxes are authoritative for task completion; reconcile pending IDs
from `tasks.md` rather than treating an empty cached list as proof. Quick step
completion is recorded in `apply-progress.yaml`.

Hash task definitions with checkbox marks normalized, so progress updates do not
invalidate planning. Verification hashes cover relevant source, tests, config,
planning and environment inputs, excluding generated reports/logs/state. Updating
input paths or relevant executable modes also invalidates dependent evidence;
record these identities alongside content hashes in the verification provenance.
Updating
an audit summary does not invalidate executed behavior. Store input paths from
the project root; artifact/evidence refs in reports are relative to their file.
Relocation during ARCHIVE preserves original input provenance and records the
new location; it is not a product change requiring repeated tests.

## Approval and blockers

Each approval contains `id`, `kind` (scope | review_budget | validation_exception
| material_change), `status` (pending | approved | rejected), `artifact_refs`,
`input_hashes`, `scope`, `reason`, and, when approved, `user_instruction` and
`approved_at` (ISO datetime with zone). Review budget scope includes diff lines,
limit, sensitive paths and the reviewed diff fingerprint. A validation exception
names the replaced obligation and accepted evidence. Never infer approval from
silence. Preserve authorization already given in the conversation by recording it.

Blockers contain `code`, `phase`, `reason`, `requires_user_input` and optional
`artifact_refs`. Approval is derived from pending approval records, not `notes`.
Request scope approval once for proposal/quick. No gates after SPEC, DESIGN,
TASKS or every APPLY batch by default. Report progress and continue authorized
work. Ask again only for a material scope/approach change, new unresolved risk or
an explicit configured gate. Informational warnings and missing optional skills
do not block. Existing project-specific approval requirements remain binding.

## Next phase algorithm

First return pending approvals, unresolved blockers or recovery requirements.
Otherwise choose the earliest unmet dependency:

| Condition | Next phase |
|---|---|
| completed and archive folder exists | null |
| quick, QUICK output incomplete | QUICK |
| normal, no EXPLORE completion and no direct PROPOSE entry | EXPLORE |
| normal, no completed PROPOSE | PROPOSE |
| normal, proposal approved, SPEC incomplete | SPEC |
| normal, proposal approved, DESIGN incomplete | DESIGN |
| normal, SPEC and DESIGN complete, TASKS incomplete | TASKS |
| normal tasks unchecked or APPLY incomplete | APPLY |
| quick approved but quick steps or APPLY incomplete | APPLY |
| APPLY complete, VERIFY incomplete/invalidated | VERIFY |
| current VERIFY archive_ready, ARCHIVE incomplete | ARCHIVE |

Direct proposal and quick commands may bypass EXPLORE when sufficient context
exists. Direct DESIGN may run before SPEC. A failed VERIFY recommends VERIFY
for an environment/evidence retry, or targeted FIX/APPLY for a product defect;
never ARCHIVE. Persist `fix_attempts` across sessions, maximum two automatic
product-fix cycles; infrastructure retries are separate, limited to one per
transient attempt. No FIX for non-applicability or absence of optional tooling.

ARCHIVE running with a transaction journal is resumed as ARCHIVE, including
after its folder has moved, not reported as finished until its close report and
completed state are valid. VERIFY failure/incompletion overrides any historical
VERIFY completion, and unchecked tasks override cached APPLY completion. A failed
re-attempt cannot inherit the previous success of that same phase. Direct phase
commands may select either ready SPEC or DESIGN; they still require predecessors.

## Invalidation

Record changed artifacts and compare input hashes, not file existence alone.
Remove completion of downstream phases, retaining unrelated valid completion:

| Changed input | Invalidate |
|---|---|
| proposal.md | SPEC, DESIGN, TASKS, APPLY, VERIFY, ARCHIVE |
| specs/ or design.md | TASKS, APPLY, VERIFY, ARCHIVE |
| tasks.md definition (not checkbox progress) | APPLY, VERIFY, ARCHIVE |
| quick.md | APPLY, VERIFY, ARCHIVE |
| implementation or validation inputs | VERIFY, ARCHIVE |

Material proposal/quick edits invalidate scope approval. Editorial changes may
retain approval with a recorded explanation. SPEC-FIX/DESIGN-FIX may preserve
TASKS/APPLY completion only after explicitly reconciling tasks, implementation
and validation obligations; invalidate VERIFY regardless. Do not force needless
code changes when the already implemented behavior remains correct.

## Legacy recovery (read-only assessment, then targeted write)

STATUS checks local 2.0 state first. If absent, assess local `.paused-state.yaml`,
then legacy global YAML/JSON only when its `change` matches, then own artifacts.
Malformed present canonical state is a recovery blocker, not permission to ignore
it. Never overwrite corruption or uncertain approval without resolution.

Artifact inference identifies candidate progress, not proven success. Existing
proposal/quick with unknown approval requires confirmation; an explicit matching
legacy `awaiting_approval: false` plus completed proposal/quick is carried forward
as legacy authorization (source recorded). SPEC and DESIGN are inferred separately
from valid, nonempty artifacts. All checked tasks suggest VERIFY, not verified
success. Failed/warning verification needs its obligations assessed; report
existence alone never permits archive. Archived folder plus close report can
establish completion. Execution logs are informational, never canonical state.

CONTINUE (or the first phase writer) migrates only the selected change after
assessment, preserving original files as legacy evidence. Do not delete JSON,
paused snapshots or Markdown reports. Before replacing a legacy global state
with a selector, preserve its full contents as that matching change's
`.legacy-status.yaml` (or `.legacy-status.json`); do not overwrite an existing
backup. If selection differs, recover/preserve the former active change first.
Unresolved conflict stops migration. No bulk conversion of archives.
