---
name: flow-nea-spec
description: >
  Write specifications with requirements and scenarios (delta specs for changes).
trigger: >
  When the orchestrator launches you to write or update specs after a proposal is approved.
license: MIT
metadata:
  author: juan-duque
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Write delta specs describing what is added, modified, or removed.

## What You Receive

- Change name
- Proposal content
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read skills/_shared/persistence-contract.md and its state, execution, validation and audit references. Resolve them from the installed skills root.

## What to Do

Before writing, resolve the selected change state and scope approval. Never clear a pending approval by writing SPEC.

### Step 1: Identify Affected Domains

From proposal "Affected Areas", reuse existing domain identities before adding new ones. Do not create a domain per change. Retain existing requirement IDs or exact names and identify delta operations unambiguously for consolidation.

### Step 2: Read Existing Specs

- If openspec mode and openspec/specs/{domain}/spec.md exists, read it.

### Step 3: Write Delta Specs (openspec mode)

openspec/changes/{change-name}/specs/{domain}/spec.md

Read the relevant SPEC example in
[planning-examples.md](../_shared/planning-examples.md) when useful.
Retain the agreed scope, criteria, risks and applicable rollback/validation
details; adapt structure to the change.

If no existing spec exists, write a FULL spec instead of delta.

When replacing a requirement, include its complete resulting contract and
scenarios, retaining unaffected scenarios. REMOVED names the exact identity;
renames explicitly identify old and new names. Do not use a full spec to imply
deletion of unrelated base requirements. This makes ARCHIVE consolidation safe.

### Step 4: Persist (openspec mode)

- Save delta specs under openspec/changes/{change-name}/specs/{domain}/spec.md
- Merge `openspec/changes/{change-name}/.status.yaml` under state-contract.md;
  record SPEC completion only for valid complete output, update input
  hashes and preserve independent completed phases, approvals and pending work.

### Step 5: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

Include a summary table per domain:

| Domain | Type | Requirements | Scenarios |
|--------|------|--------------|-----------|
| Auth | ADDED | 2 | 3 |
| API | MODIFIED | 1 | 2 |
| Total | | 3 | 5 |

## Rules

- Use Given/When/Then format for scenarios.
- Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY).
- Every requirement must have at least one scenario.
- Include applicable happy, edge and error cases; no fixed scenario quota.
- Do not include implementation details.
- **Specs describe WHAT, never HOW** — no mention of classes, methods, libraries, or implementation decisions. If you are describing how, move it to design.md.
- Include relevant happy, edge and error cases; do not invent an error state for a documentary or non-behavioral requirement. SPEC and DESIGN are independent after approved PROPOSE.
- Every scenario must be verifiable with an appropriate observable method. Automated tests are one option; use the validation contract for direct/manual checks. Unverifiable criteria remain a blocker.
- All artifact content MUST be written in Spanish.
- Keep deltas concise while preserving the complete resulting contract and unaffected scenarios. No fixed word or scenario-line limit.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Specs written and persisted.",
  "detailed_report": "Notes or persistence info.",
  "artifacts": [
    {
      "name": "spec",
      "path": "openspec/changes/{change-name}/specs/{domain}/spec.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "DESIGN | TASKS",
  "risks": [
    "list of risks or blockers"
  ],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  }
}
```

Return a single next_recommended phase from the state contract, not the literal
union shown in examples. Set action_context.blocked=true for unresolved required
inputs, material decisions or scope approval; optional warnings stay unblocked.
