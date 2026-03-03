---
name: flow-nea-apply
description: >
  Implement tasks from the change, writing actual code following specs and design.
trigger: >
  When the orchestrator launches you to implement one or more tasks from a change.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Related Skills

- **typescript-general** - Type safety and code organization (load for .ts files)
- **testing** - Test structure and TDD patterns (load for *.test.ts files)
- **form-controls** - Form component patterns (load for form/input components)
- **scss** - Styling tokens and patterns (load for .scss files)

## Purpose

Implement assigned tasks, update task status, and report progress.

## What You Receive

- Change name
- Specific tasks to implement
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Read Context

Check `openspec/config.yaml` for `experimental.neabrain: true`.
If enabled, consult the Neabrain index for paths and relationships before reading files.
Otherwise, use direct relative paths from the project root.
Read file bodies only when needed:
- Specs (what)
- Design (how)
- Tasks (what to do next)
- Relevant code and conventions

### Step 2: Detect TDD Mode

Detect TDD from (priority order):
1) openspec/config.yaml -> rules.apply.tdd
2) skills/testing/SKILL.md (if present, TDD patterns apply)
3) Existing test patterns
Default: standard mode

If TDD is active, use RED -> GREEN -> REFACTOR.

### Step 2.5: Load Coding Skills (autonomous)

Based on files to be modified, load the corresponding skill before implementing.
Do not wait for the orchestrator to specify them — this is the sub-agent's responsibility:
- .ts files -> read skills/typescript-general/SKILL.md
- *.test.ts files -> read skills/testing/SKILL.md
- Form/input components -> read skills/form-controls/SKILL.md
- .scss files -> read skills/scss/SKILL.md

### Step 3: Implement Tasks

- Implement only assigned tasks
- Follow existing code patterns
- Keep batch small

### Step 4: Mark Tasks Complete

- If openspec mode, update openspec/changes/{change-name}/tasks.md
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: APPLY
  change: "{change-name}"
  awaiting_approval: false
  completed: false
  ```

### Step 5: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Load coding skills autonomously based on files to be modified; do not wait for the orchestrator to specify them.
- Always follow design decisions.
- Use OpenSpec as the source of truth; do not copy code unless needed.
- If blocked, stop and report.
- In TDD mode, always write failing test first.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

{
  "status": "ok | warning | failed",
  "executive_summary": "Implemented tasks X.Y through Z.W.",
  "detailed_report": "Technical summary and notes.",
  "tasks_completed": ["1.1", "1.2"],
  "tasks_pending": ["1.3"],
  "artifacts": [
    {
      "name": "tasks",
      "path": "openspec/changes/{change-name}/tasks.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "APPLY | VERIFY",
  "risks": ["list of risks or blockers"]
}
