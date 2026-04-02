---
name: flow-nea-propose
description: >
  Create a change proposal with intent, scope, and approach.
trigger: >
  When the orchestrator launches you to create or update a proposal for a change.
license: MIT
metadata:
  author: juan-duque
  version: "2.0"
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

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Load Context

- If openspec, read openspec/changes/{change-name}/exploration.md if present.
- Read openspec/config.yaml → check `rules.proposal` for custom rules to apply.
  Apply any project-specific proposal rules on top of the defaults in this skill.

### Step 2: Create or Update proposal.md (openspec mode)

openspec/changes/{change-name}/proposal.md

Format:

# Proposal: {Change Title}

## Intent
{Problem and why}

## Scope
### In Scope
- ...

### Out of Scope
- ...

## Approach
{High-level technical approach}

## Affected Areas
| Area | Impact | Description |
|------|--------|-------------|
| src/path/to/file.ts | New/Modified/Removed | descripcion concreta |

> Use concrete file paths, not vague descriptions like "auth module".

## Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| ... | Low/Med/High | ... |

## Rollback Plan
> MANDATORY. Describe how to revert this change if it fails in production.
> Minimum: which files to restore, which migrations to revert, whether feature flags are involved.

{Como revertir}

## Dependencies
- ...

## Success Criteria
> MANDATORY. List of verifiable conditions that must be met to consider this change successful.
> Each criterion must be checkable (test, metric, observable behavior).

- [ ] ...

### Step 3: Persist (openspec mode)

- Save proposal to openspec/changes/{change-name}/proposal.md
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: PROPOSE
  change: "{change-name}"
  awaiting_approval: true
  completed: false
  pending_tasks: []
  modified_artifacts: []
  notes: ""
  ```

### Step 4: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- **Rollback plan is NON-NEGOTIABLE.** If it is not possible to define how to revert the change, do not advance — report as `status: blocked`.
- **Success criteria is NON-NEGOTIABLE.** If verifiable criteria cannot be defined, do not advance — report as `status: blocked`.
- Use concrete file paths in Affected Areas, not vague descriptions.
- Apply custom rules from `openspec/config.yaml → rules.proposal` if they exist.
- All artifact content MUST be written in Spanish.
- **Size budget**: proposal.md artifact MUST be under 400 words. Concise scope, not exhaustive.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | blocked",
  "executive_summary": "Summary of proposal and scope.",
  "detailed_report": "Reasoning or persistence notes.",
  "artifacts": [
    {
      "name": "proposal",
      "path": "openspec/changes/{change-name}/proposal.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "SPEC",
  "user_approval_required": true,
  "scope_summary": {
    "added": ["list of features"],
    "modified": ["list of existing features"],
    "excluded": ["what remains out"]
  },
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
