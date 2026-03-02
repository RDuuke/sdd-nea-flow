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
---

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

- Consult the Neabrain index for paths and relationships before reading files.
- Read file bodies only when needed.
- Specs (what)
- Design (how)
- Tasks (what to do next)
- Relevant code and conventions

### Step 2: Detect TDD Mode

Detect TDD from (priority order):
1) openspec/config.yaml -> rules.apply.tdd
2) Installed coding skills (tdd)
3) Existing test patterns
Default: standard mode

If TDD is active, use RED -> GREEN -> REFACTOR.

### Step 3: Implement Tasks

- Implement only assigned tasks
- Follow existing code patterns
- Keep batch small

### Step 4: Mark Tasks Complete

- If openspec mode, update openspec/changes/{change-name}/tasks.md

### Step 5: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Never implement tasks not assigned.
- Always follow design decisions.
- Use OpenSpec as the source of truth; do not copy code unless needed.
- If blocked, stop and report.
- In TDD mode, always write failing test first.

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
