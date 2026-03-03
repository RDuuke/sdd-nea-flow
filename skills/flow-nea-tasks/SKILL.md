---
name: flow-nea-tasks
description: >
  Break down a change into an implementation task checklist.
trigger: >
  When the orchestrator launches you to create or update the task breakdown for a change.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Create tasks.md with concrete, actionable steps organized by phase.

## What You Receive

- Change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Analyze the Design

Check `openspec/config.yaml` for `experimental.neabrain: true`.
If enabled, consult the Neabrain index for paths and relationships before reading files.
Otherwise, use direct relative paths from the project root.
Read file bodies only when needed.
Identify files to create/modify/delete and dependency order.

### Step 2: Write tasks.md (openspec mode)

openspec/changes/{change-name}/tasks.md

Format:

# Tasks: {Change Title}

## Phase 1: Foundation
- [ ] 1.1 ...
- [ ] 1.2 ...

## Phase 2: Core Implementation
- [ ] 2.1 ...

## Phase 3: Integration
- [ ] 3.1 ...

## Phase 4: Testing
- [ ] 4.1 ...

## Phase 5: Cleanup
- [ ] 5.1 ...

### Step 3: Persist (openspec mode)

- Save tasks to openspec/changes/{change-name}/tasks.md
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: TASKS
  change: "{change-name}"
  awaiting_approval: false
  completed: false
  ```

### Step 4: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Always reference concrete file paths in tasks.
- Order tasks by dependency.
- Each task must be small enough for one session.
- Use hierarchical numbering (1.1, 1.2, etc.).
- If the project uses TDD, include RED -> GREEN -> REFACTOR tasks.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

{
  "status": "ok | warning | failed",
  "executive_summary": "Task list complete. X phases and Y tasks.",
  "detailed_report": "Notes or persistence info.",
  "artifacts": [
    {
      "name": "tasks",
      "path": "openspec/changes/{change-name}/tasks.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "APPLY",
  "risks": ["list of risks or blockers"]
}
