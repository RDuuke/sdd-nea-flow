---
name: flow-nea-propose
description: >
  Create a change proposal with intent, scope, and approach.
trigger: >
  When the orchestrator launches you to create or update a proposal for a change.
license: MIT
metadata:
  author: juan-duque
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Create a proposal that defines intent, scope, approach, risks, and rollback plan.

## What You Receive

- Change name
- Exploration analysis (or direct user description)
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read skills/_shared/persistence-contract.md and its state, execution, validation and audit references. Resolve them from the installed skills root.

## What to Do

### Step 1: Load Context

- If openspec, read openspec/changes/{change-name}/exploration.md if present.
- Read openspec/config.yaml → check `rules.proposal` for custom rules to apply.
  Apply any project-specific proposal rules on top of the defaults in this skill.

### Step 2: Create or Update proposal.md (openspec mode)

openspec/changes/{change-name}/proposal.md

Read the relevant PROPOSE example in
[planning-examples.md](../_shared/planning-examples.md) when useful.
Retain the agreed scope, criteria, risks and applicable rollback/validation
details; adapt structure to the change.

### Step 3: Persist (openspec mode)

- Save proposal to openspec/changes/{change-name}/proposal.md
- Merge `openspec/changes/{change-name}/.status.yaml` under state-contract.md;
  record PROPOSE completion and typed scope approval (pending unless already
  explicitly approved for unchanged scope), update input
  hashes and preserve independent completed phases, approvals and pending work.

### Step 4: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- **Rollback plan is NON-NEGOTIABLE.** If it is not possible to define how to revert the change, do not advance — report as `status: warning` with a blocking action_context.
- **Success criteria is NON-NEGOTIABLE.** If verifiable criteria cannot be defined, do not advance — report as `status: warning` with a blocking action_context.
- Use concrete file paths in Affected Areas, not vague descriptions.
- Apply custom rules from `openspec/config.yaml → rules.proposal` if they exist.
- All artifact content MUST be written in Spanish.
- Keep scope concise without truncating criteria, dependencies or rollback. No fixed word-count gate.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Summary of proposal and scope.",
  "detailed_report": "Reasoning or persistence notes.",
  "artifacts": [
    {
      "name": "proposal",
      "path": "openspec/changes/{change-name}/proposal.md",
      "type": "markdown"
    }
  ],
  "next_recommended": null,
  "user_approval_required": true,
  "risks": [],
  "action_context": {"blocked": true, "reason": "scope_approval", "requires_user_input": true},
  "scope_summary": {
    "added": ["list of features"],
    "modified": ["list of existing features"],
    "excluded": ["what remains out"]
  },
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```

The example represents a pending scope approval. For already approved unchanged
scope, return user_approval_required=false, an unblocked action_context and the
next ready phase from the state contract. Do not recreate a pending gate.
