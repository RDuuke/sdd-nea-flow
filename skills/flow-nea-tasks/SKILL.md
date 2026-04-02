---
name: flow-nea-tasks
description: >
  Break down a change into an implementation task checklist.
trigger: >
  When the orchestrator launches you to create or update the task breakdown for a change.
license: MIT
metadata:
  author: juan-duque
  version: "2.0"
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
- Extract all task IDs from the tasks.md file just created (e.g., ["1.1", "1.2",
  "1.3", "2.1", etc.])
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: TASKS
  change: "{change-name}"
  awaiting_approval: false
  completed: false
  pending_tasks: ["1.1", "1.2", "1.3", "2.1", ...]
  modified_artifacts: []
  notes: ""
  ```

Note: `pending_tasks` should contain ALL task IDs at creation time. The
orchestrator updates this list as tasks are completed in the APPLY phase.

### Step 4: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

Each task MUST meet:

| Criterion | Example ✅ | Anti-example ❌ |
|-----------|-----------|----------------|
| **Specific** | "Create `internal/auth/middleware.go` with JWT validation" | "Add auth" |
| **Actionable** | "Add `ValidateToken()` method to `AuthService`" | "Handle tokens" |
| **Verifiable** | "Test: `POST /login` returns 401 without token" | "Make sure it works" |
| **Small** | One file or logical unit | "Implement the feature" |

Phase organization guide:

```
Phase 1: Foundation / Infrastructure
  └─ New types, interfaces, DB changes, config
  └─ What other tasks depend on first

Phase 2: Core Implementation
  └─ Main logic, business rules, core behavior

Phase 3: Integration / Wiring
  └─ Connect components, routes, UI wiring

Phase 4: Testing
  └─ Unit, integration, e2e tests
  └─ Verify against spec scenarios

Phase 5: Cleanup (if applicable)
  └─ Documentation, remove dead code, polish
```

- Always reference concrete file paths in tasks.
- Order tasks by dependency.
- Each task must be small enough for one session.
- **Each task must be completable in ONE work session** — if it feels large or ambiguous when writing it, split it into smaller subtasks. A task that spans more than one session is a blocking risk.
- **No circular dependencies** — a task cannot require results from a task in a later phase. If the ordering creates a cycle, redesign the task breakdown.
- Use hierarchical numbering (1.1, 1.2, etc.).
- If the project uses TDD, include RED -> GREEN -> REFACTOR tasks.
- All artifact content MUST be written in Spanish.
- **Size budget**: tasks.md artifact MUST be under 530 words. Each task: 1-2 lines max. Use checklist format, not paragraphs.
- NEVER include vague tasks like "implement feature" or "add tests".

## Output Contract (JSON)

```json
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
  "risks": ["list of risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
