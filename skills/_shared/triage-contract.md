# Development Triage

Load for bug investigation or product findings in EXPLORE/APPLY/FIX. This is a
bounded procedure in existing phases, not a new gate, mandatory backlog audit
or permission to mutate remote issues.

## Reproduce and classify

Separate the symptom from the proposed cause. Record actual input/steps, expected
and observed outcomes, environment and evidence. Reproduce on the failing surface,
not a test taught to agree with a suspected implementation. If the symptom fails
but a proposed-cause test already passes, revisit the hypothesis. Do not edit
fixtures/expectations just to turn a regression green; reconcile real contract
changes explicitly.

Distinguish bug, duplicate, feature request, unclear report, or behavior covered
by a known change. These are analytical dispositions, not label/close authority.
Covered-by-change is provisional until current execution proves the reported
behavior. Missing environment is infrastructure, not a confirmed product defect.
Continue independent authorized work when possible.

Group findings by shared cause only with evidence. Reuse stable finding IDs;
optional `root_cause` metadata records `status: hypothesis | confirmed`, concise
`summary`, optional `group_id`, and `evidence_refs`. A hypothesis is not permission
to patch a common component. A confirmed group may get one repair, then verify
every affected symptom/criterion. An isolated bug needs no invented cluster;
similar severity, stack or subsystem alone proves no common cause.

## Repair and bounded continuation

Prefer a demonstrated cause correction to per-symptom patches. Check existing
contracts before adding states, flags, verbs, gates or duplicate representations.
New mechanisms can be justified; net line reduction is not a correctness gate.
Do not expand into unrelated tracked work; reconcile material scope changes.

When removing commands/options, inspect messages, help, wrappers, references
and affected callers. Continuation messages name available applicable routes.
Use help/read-only or isolated probes when safe; never run destructive or remote
mutations just to check a message's command.

Repair within authorization and the existing FIX budget. Rerun failed/affected
checks, preserving compatible PASS. Use [findings-contract.md](findings-contract.md)
to retain outcomes. Partial repair does not resolve a multi-symptom report.
Remote close/reopen/comments require separate authorization under
[delivery-contract.md](delivery-contract.md).
