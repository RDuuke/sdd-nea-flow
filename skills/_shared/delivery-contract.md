# Optional Development Delivery

Apply when asked to prepare commits, an issue or a PR, during/after development.
Delivery is not a required SDD phase or an implication of ARCHIVE. Keep the user's
branch and delivery strategy. No mandatory issue, label, fixed diff limit,
remote service or memory provider is introduced.

## Prepare a reviewable result

Inspect the actual diff/branch and preserve unrelated changes. Read repository
contribution rules, conventions, templates and required checks. Resolve host,
repository and base branch from actual configuration/metadata; do not assume
`main` or confuse a fork with the destination. If essential information is
missing, prepare independent local work before surfacing that specific decision.

Group commits by delivered behavior, repair, migration or documentation unit.
Keep implementation, applicable checks and related docs together. TASKS can
identify units/dependencies; they are not one commit per phase, task, file type
or layer. Include validation and rollback implications when useful. Do not stage
unrelated work or the whole tree blindly. Follow project message conventions,
using conventional commits when appropriate; never invent author identity.

Draft a concrete title/body around final behavior and the actual template, with
observed evidence, pending checks and limitations. Checkboxes need evidence.
Use [documentation-contract.md](documentation-contract.md) to identify the useful
review order and keep details linked rather than repeating the whole workflow.
Reference real relevant issues and preserve closing/non-closing intent. An
approved issue or `type:*` label is required only by applicable project policy.

For unwieldy diffs, propose coherent units with dependencies and review/rollback
value. Honor configured budgets, not a universal 400-line limit. Do not remove
useful docs, tests or formatting to meet size targets. Never automatically create
stacked branches/PRs or override the selected strategy.

## Actions and observed results

Preparation does not authorize commit, push, issue/PR publication, merge or deploy.
Reuse explicit authorization already given. When additional authorization is
needed, finish the concrete draft first, subject to environment permissions.
Do not mutate others' labels/status without authorization.

For a requested issue, read destination forms/policy and check current duplicates.
Adapt to the actual tracker; never fabricate facts, issue numbers, labels or
consent. Inspect outbound content for credentials/private material. Use structured
bodies or safely written temporary files instead of unsafe shell interpolation.

Read back authorized mutations and classify confirmed, no_write or unknown.
Reconcile unknown outcomes before another mutation; no blind retries that could
duplicate issues, comments or PRs. Report real URLs/identifiers when confirmed.
For bug-related issue closure, confirm each reported symptom with named current
evidence under [triage-contract.md](triage-contract.md); partial repair does not
justify claiming the whole issue fixed. This does not authorize a remote action.
Required CI and destination policy determine readiness; drafts and optional
pending checks are not merge-readiness evidence. Use
[validation-contract.md](validation-contract.md) for failure/baseline attribution.
Never stash/pop user work to manufacture a clean baseline.
