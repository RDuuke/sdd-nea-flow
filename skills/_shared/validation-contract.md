# Development Validation Contract

Applies to normal and quick project changes. Validation proves agreed behavior
using capabilities actually available, not a universal stack or testing template.

## Capability discovery

INIT records `capabilities` in config. EXPLORE refreshes affected entries using
manifests, existing tests, CI, project instructions and actual command wrappers.
Each entry has `status: available | absent | unknown | not_applicable`, `source`
(relative path or user instruction), optional `command`, `environment`, `reason`.
Record product context separately (CRM, CMS, framework application, docs, etc.).
Product labels do not imply API, build, test suite or coverage. Inspect existing
PHP/composer, .NET, JVM, Go, Python, JS or platform-native tooling when relevant;
do not restrict discovery to package.json. Unavailable runtime is `unknown` or
an execution blocker, not absence of infrastructure.

## Validation plan

DESIGN or QUICK writes `validation-plan.yaml` (schema 1.0, kind `validation_plan`)
using the audit envelope. Fields: `impact` (areas, shared dependencies, risk and
reason), `checks`, `exceptions`. Each check has `id`, `criteria` (scenario/quick
criterion refs), `method: automated | api | cli | browser | manual | inspection`,
`required`, `scope`, optional `command`, `expected`, `capability`, and `reason`.
Manual checks state repeatable steps, expected observations and who supplies the
evidence. An agent cannot claim a user's manual action without their evidence.

Choose focused existing checks first. Expand for shared components, security,
authorization, persistent data, migrations and broad regressions. Preserve CI
and explicit mandatory project gates; do not downgrade them silently. If broad
tests are optional, explain why selected tests cover the impact. TASKS includes
the agreed checks, not unit/integration/E2E layers that do not apply.

Config `validation.default_scope: impact` is the new default. TDD defaults off;
`gates.verify.coverage_threshold: null` means no flow-imposed threshold. Existing
numeric thresholds, strict TDD, commands and full-suite obligations are retained.
Resolve canonical `gates` values first, legacy structured `rules` keys second;
free-form prose project instructions and CI requirements also remain binding.
Do not reset custom `gates.test_tiers` or reinterpret prose as executable shell.
If policy is contradictory, resolve it before implementation.

Missing optional build/coverage/tests is not a warning by itself. Missing
mandatory tooling is a blocker; do not install a framework or create a suite
solely to satisfy a generic template. Additional automation must serve a concrete
behavior or regression risk. Strict TDD requires real RED/GREEN for behavioral
tasks; documentation, configuration-only preparation and other non-behavioral
tasks record `tdd.applicability: not_applicable` with justification. Behavioral
tasks lacking required RED/GREEN remain incomplete unless an explicit exception
is approved. Legacy evidence gaps are reported; never fabricate old RED runs.

## Results and evidence

For command documentation/removal checks, inspect callers, wrappers, help and
references. Use read-only or isolated probes; never execute a destructive or
remote-writing command solely to check its wording or exit message. If required
runtime proof needs such an action, retain the evidence gap until an authorized
safe validation environment is available.

Run agreed source-mutating formatters/code generation before the final verification
snapshot. VERIFY uses check-only commands; if a necessary command changes source,
record it, reconcile new inputs and rerun dependent evidence only. Later source,
path/mode, test, config or environment changes invalidate affected evidence under
the state contract. No cosmetic rewrites after VERIFY with a claim that the old
snapshot still covers them. Mandatory fresh-complete-run gates remain binding.

Attribute failures to the change, a verified baseline or unconfirmed origin.
Baseline attribution requires reproducing the same failing command and relevant
environment on an isolated comparable base, preserving user work; record base
identity, command, environment and evidence refs. Unchanged existing failures
outside accepted scope can be advisory with justification. Introduced defects
and unmet accepted criteria remain blocking. Baseline failure never turns a
failed required check into PASS or waives a gate: resolve the obligation or obtain
a scoped explicit exception. Without reproduction, origin remains unknown.

Check results: `passed | failed | blocked | not_run | not_applicable`.
Report scenario compliance separately: `COMPLIANT | FAILING | UNVERIFIED | PARTIAL`.
COMPLIANT requires executed evidence supporting the expected behavior, not
necessarily an automated test. Inspection can validate documentary/static
criteria; it cannot prove executed behavior. Required scenarios cannot be waived
as not_applicable merely because no automated infrastructure exists.

Evidence records include `id`, `method`, `command` or manual `steps`,
`observed`, `started_at`, `finished_at`, optional `exit_code`, `refs`,
`input_hashes`, `environment`, and `reused_from` when reused. Do not claim an
unexecuted or cancelled suite passed. Capture raw output separately, redact
credentials, use relative refs from the containing report directory.

Reuse passing evidence when relevant source/test/configuration hashes and runtime
identity match. Record the original execution and current compatibility check;
commit identity alone is insufficient for dirty working trees. Missing provenance
requires new execution of the affected check. Rerun only invalidated checks; no
blanket duplicate tests/builds. Changes to scope or gates also invalidate affected
results. Cross-change reuse names the source report and exact obligation covered.

After a failed test, FIX first reproduces that failure, then reruns the failing
test and the checks affected by the repair. Preserve independent passing results
whose inputs remain compatible. VERIFY after FIX is incremental verification,
not an automatic rerun of every suite. Shared fixture/setup, dependency or global
configuration changes can widen the affected set; document why. A binding gate
may require a full suite, but reuse a qualifying complete execution when its
inputs remain valid. If only part was invalidated and the gate permits combining
results, record the original run plus replacement checks; never present this as
a newly executed full suite. If the gate demands one fresh full run, honor it or
obtain an explicit change-local exception.

## Exceptions and closure

User exceptions are change-local approval records: original obligation, replacement
evidence, reason, exact user authorization and input scope. Keep global config
unchanged. A new material scope change requires renewed acceptance.

For an approved exception, retain the original obligation and actual result with
the approval reference. Define the explicitly accepted replacement checks and
criteria in the change-local plan. Closure evaluates those effective obligations;
never relabel an original failed run as passed or erase its evidence. A request
to archive alone is not authorization to waive a failed gate.

VERIFY reports `status: failed` for failed required checks/product defects;
`warning` with blockers for missing required evidence, unavailable infrastructure
or unresolved obligations; `ok` when all obligations are met. Optional findings
may yield warning without blocking. `archive_ready` is true only when tasks are
complete, every currently required applicable check (including accepted exception
replacements) passes, criteria are covered, applicable
strict TDD is satisfied, approvals are resolved and no blocker remains.
ARCHIVE uses `archive_ready` and input currency, not status or report existence
alone. Classify findings `critical | warning | suggestion` plus `blocking` and
`category: product | infrastructure | evidence | policy`; FIX consumes only
actionable product findings. An unresolved infrastructure problem does not
justify speculative product edits.

Follow [findings-contract.md](findings-contract.md) for active versus historical
findings and evidence-based resolutions. Retained resolved history does not
block closure; an open blocking finding or unresolved replacement does. Required
checks/criteria remain independent gates: dismissal/supersession never waives them.
