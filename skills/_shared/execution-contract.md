# Development Execution Contract

Applies to development only, activated by an explicit flow command/request.
Ordinary work does not enter the flow automatically. Resolve contracts from the
installed skills root, not an assumed directory in the target project.

## Routing and bounded context

Keep phase boundaries even inline. Select inline execution or an authorized
worker by uncertainty, risk, independence and context volume, not file counts.
Understood mechanical edits and focused checks can run inline. Delegate broad
investigation when it crowds out decision context; use independent verification
when consequences warrant it. Executable Markdown prompts/policies are not
automatically low risk merely because they are documentation.

Use actual permitted delegation capabilities. Otherwise execute sequential
bounded phase units and disclose unavailable required independent review.
Do not simulate a second independent agent. Explicit dual review needs independent
reviewers. Parallelize independent reads; serialize shared artifact/state writes.
Observe terminal worker results before consuming them or advancing dependencies.

Resolve applicable project standards and exact skill paths once, refreshing when
inputs change. Prefer applicable project skills over global alternatives. A
registry locates skills; it does not replace reading their bodies. Supply this
bounded handoff to inline/delegated executors:

```text
Execute only {phase}; do not delegate or switch phases.
change-name={change-name} artifact_store.mode={mode}
## Skills to load before work
{resolved exact phase SKILL.md path; read it in full}
{resolved exact paths of applicable contracts/related skills}
## Project Standards (auto-resolved)
{compact relevant project rules and scope}
## Task context
{required artifacts, task/finding IDs, accepted decisions and criteria}
## Authorized edit surfaces
{repository-relative paths/narrow globs; read-only if appropriate}
## Validation
{agreed checks/commands and reusable evidence references}
```

The coordinator derives surfaces from authorized scope; do not ask the user to
author path lists. Include dependencies of the objective, not the entire chat or
every skill. Workers return decision gaps without inventing choices. Reconcile
unexpected edits with authorization before writing; already authorized dependencies
do not require another routine approval.

Treat worker summaries as claims, not independent proof. Inspect returned diffs,
persisted identities/hashes and actual evidence for relevant obligations before
reporting success. Missing access or unverifiable evidence is an incomplete
result. Do not repeat valid checks merely because another worker ran them.
Use native permitted workers with bounded missions; no provider-specific tool
name or persistent worker profile is a requirement.

Preserve `skill_resolution: injected | fallback-registry | fallback-path | none`.
`injected` means supplied skill paths were read and supplied standards applied.
Fallbacks report actual resolution. Correct missing rules and the next handoff;
do not repeat valid work solely to change a reporting label.

## Phase coordination

These steps belong to the coordinator. An executor performs only its assigned
phase and reports results; it does not launch phases or write coordinator logs.

1. Run read-only STATUS for the explicit/selected change before each other phase, using
   [state-contract.md](state-contract.md). Recover missing predecessors or selected
   legacy state with CONTINUE. Logs, report existence and another change's global
   phase are not proof of success.
2. Honor typed approvals and unresolved blockers, recording authorization already
   given. Scope approval is once per proposal/quick; renew only for material
   changes, unresolved decisions or configured gates. For review_budget quote
   diff size, limit and sensitive paths and bind approval to the diff fingerprint.
   Informational risks are not new gates.
3. Load the exact phase skill and applicable contracts. SPEC/DESIGN are independent;
   serialize and merge state writes. Large APPLY lists use dependency-ordered
   batches, with progress and continued authorization, not repeated approval.
4. Validate the JSON envelope in [audit-contract.md](audit-contract.md), including
   phase-specific fields. Malformed results are failed attempts. Empty artifacts
   are valid for read-only, inline and completed results. Expected persisted
   artifacts need readback. Failed/incomplete outputs never advance dependencies.
5. Log actual attempts with unique event IDs under the audit contract. After ARCHIVE
   log at the archived path, never recreate the active folder. Finish with a full
   handoff; a persistence tool result alone is not completion feedback.

Retry transient transport/parse failures at most once after reconciling outputs
and state. Do not discard completed work or repeat product execution because
logging failed. Product FIX retains its existing persisted two-cycle limit;
infrastructure recovery is distinct. Do not introduce another retry counter.
After a failure, rerun failed/affected checks under
[validation-contract.md](validation-contract.md), reusing compatible PASS.
Full-suite reexecution requires demonstrated impact or a binding fresh-run gate.

For bug investigation/FIX, load [triage-contract.md](triage-contract.md) and
[findings-contract.md](findings-contract.md). Select open actionable product
findings and preserve identities/history across reports. Group only corroborated
causes, validate every affected criterion, and retain partial outcomes. Never
interpret closed historical findings as another repair request or drop a blocker
by rewriting the report. Review conclusions remain candidate/evidence-bound;
they do not add an authority lifecycle or authorize delivery.

For a late contradiction, pause VERIFY, reconcile through the affected phase
skill and log SPEC-FIX/DESIGN-FIX. Check criteria, plan, tasks and code together;
invalidate stale VERIFY while preserving justified APPLY progress. Corrections
are not new phases or authorization to alter accepted scope.

Follow [persistence-contract.md](persistence-contract.md) for storage/readback.
Planning examples are guidance, not word-count gates or fixed task stages.
Load [research-contract.md](research-contract.md) for relevant research and
[delivery-contract.md](delivery-contract.md) only for requested delivery.
For human-facing planning/review documents, load
[documentation-contract.md](documentation-contract.md) when relevant.
