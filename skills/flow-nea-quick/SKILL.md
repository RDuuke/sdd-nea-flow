---
name: flow-nea-quick
description: >
  Create a minimal quick blueprint for a small, low-risk fix with a single approval gate.
trigger: >
  When the orchestrator needs a low-bureaucracy path for a trivial or tightly scoped change.
license: MIT
metadata:
  author: juan-duque
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Create a minimal OpenSpec artifact for a small fix that does not justify the full
planning chain. This is a shortcut for low-risk work, not a replacement for the
normal flow.

## What You Receive

- Change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read skills/_shared/persistence-contract.md and its state, execution, validation and audit references. Resolve them from the installed skills root.

## Eligibility Rules

Quick mode is allowed only when all of these are true:

- the change is a small fix, validation tweak, local rename, null check, tiny UI adjustment, or similarly bounded task
- the implementation has one tightly scoped impact and direct validation; file count alone does not determine eligibility
- there is no architecture change
- there is no need for a substantial `SPEC` or `DESIGN` discussion
- risk is low and verification is direct

Quick mode must be rejected when any of these are true:

- the change spans multiple domains or subsystems
- the behavior change is ambiguous
- the work affects core flows or broad contracts
- the implementation requires non-trivial design decisions
- the task would still need normal `proposal.md`, `specs/`, `design.md`, or `tasks.md` to be executed safely

## What to Do

### Step 1: Assess Scope

- Read only the minimum context needed to judge size, impact, and verification path
- Decide whether the change qualifies for quick mode

### Step 2: Handle Rejection

If the change does not qualify:

- Do NOT write `quick.md`
- Return `status: warning`
- Explain why the shortcut is unsafe
- Recommend the normal path with `next_recommended: "PROPOSE"`

### Step 3: Write Quick Blueprint

If openspec mode is enabled and the change qualifies:

- Create `openspec/changes/{change-name}/quick.md`
- The file MUST be written in Spanish
Read the relevant QUICK example in
[planning-examples.md](../_shared/planning-examples.md) when useful.
Retain the agreed scope, criteria, risks and applicable rollback/validation
details; adapt structure to the change.

Include outcome, affected files/area, actionable blueprint steps, risks and
repeatable verification criteria. The referenced example does not replace these
required inputs to APPLY and the validation plan.

### Step 4: Persist State

If the blueprint was created, merge the selected local .status.yaml using
state-contract.md, set path: quick, record QUICK completion, input hashes and
a typed scope approval. Preserve already approved unchanged scope. Write
validation-plan.yaml from the Verificacion criteria under validation-contract.md.
Do not enable build/tests/coverage that are absent or not applicable.

### Step 5: Return Summary

Return the standard envelope with:

- `status`
- `executive_summary`
- `detailed_report` when needed
- `artifacts`
- `next_recommended`
- `risks`

## Rules

- Use quick mode only for genuinely small, low-risk work
- Never create `proposal.md`, `specs/`, `design.md`, or `tasks.md` in this skill
- If the change is not clearly eligible, reject quick mode and recommend the normal flow
- All artifact content MUST be written in Spanish
- Keep quick.md concise without a fixed word ceiling; execution evidence belongs in YAML records and refs.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Quick blueprint created or rejected with reason.",
  "detailed_report": "Optional explanation of scope, files, and eligibility.",
  "artifacts": [
    {
      "name": "quick_blueprint",
      "path": "openspec/changes/{change-name}/quick.md",
      "type": "markdown"
    }
  ],
  "next_recommended": null,
  "risks": [
    "list of risks or blockers"
  ],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": true,
    "reason": "scope_approval",
    "requires_user_input": true
  }
}
```

Return a single next_recommended phase from the state contract, not the literal
union shown in examples. Set action_context.blocked=true for unresolved required
inputs, material decisions or scope approval; optional warnings stay unblocked.
The example shows a created blueprint awaiting approval; after unchanged
approved scope, retain authorization and recommend APPLY without another gate.
