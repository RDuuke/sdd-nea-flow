---
name: flow-nea-design
description: >
  Create technical design document with architecture decisions and approach.
trigger: >
  When the orchestrator launches you to write or update technical design for a change.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Produce design.md describing how the change will be implemented.

## What You Receive

- Change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Read the Codebase

Check `openspec/config.yaml` for `experimental.neabrain: true`.
If enabled, consult the Neabrain index for paths and relationships before reading files.
Otherwise, use direct relative paths from the project root.
Read file bodies only when needed.
Identify patterns, entry points, and dependencies relevant to the change.

### Step 2: Write design.md (openspec mode)

openspec/changes/{change-name}/design.md

Format:

# Design: {Change Title}

## Technical Approach
{Overall strategy}

## Architecture Decisions
### Decision: {Title}
Choice: ...
Alternatives: ...
Rationale: ...

## Data Flow
{ASCII diagram if helpful}

## File Changes
| File | Action | Description |
|------|--------|-------------|
| path/to/file | Create/Modify/Delete | ... |

## Interfaces / Contracts
{New interfaces, APIs, types}

## Testing Strategy
| Layer | What to Test | Approach |
|------|-------------|----------|

## Migration / Rollout
{Plan or "No migration required"}

## Open Questions
- [ ] ...

### Step 3: Persist (openspec mode)

- Save design to openspec/changes/{change-name}/design.md
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: DESIGN
  change: "{change-name}"
  awaiting_approval: false
  completed: false
  pending_tasks: []
  modified_artifacts: []
  notes: ""
  ```

### Step 4: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Always read real code before designing.
- Use OpenSpec as the source of truth; do not copy code unless needed.
- Every decision must include rationale.
- Use concrete file paths.
- Follow existing patterns unless the change is about refactoring them.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

{
  "status": "ok | warning | failed",
  "executive_summary": "Design complete. X decisions documented.",
  "detailed_report": "Design notes or persistence info.",
  "artifacts": [
    {
      "name": "design",
      "path": "openspec/changes/{change-name}/design.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "TASKS",
  "risks": ["list of risks or blockers"]
}
