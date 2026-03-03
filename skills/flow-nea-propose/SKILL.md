---
name: flow-nea-propose
description: >
  Create a change proposal with intent, scope, and approach.
trigger: >
  When the orchestrator launches you to create or update a proposal for a change.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
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
| path/to/area | New/Modified/Removed | ... |

## Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| ... | Low/Med/High | ... |

## Rollback Plan
{How to revert}

## Dependencies
- ...

## Success Criteria
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

- Always include rollback plan and success criteria.
- Keep proposal concise.
- Use concrete file paths in Affected Areas when possible.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

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
  }
}
