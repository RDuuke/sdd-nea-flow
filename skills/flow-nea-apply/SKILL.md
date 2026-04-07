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

## Related Skills (optional, load if available)

- **typescript-general** - Type safety and code organization (load for .ts files)
- **testing** - Test structure and TDD patterns (load for *.test.ts files)
- **form-controls** - Form component patterns (load for form/input components)
- **scss** - Styling tokens and patterns (load for .scss files)

If a related skill file does not exist at the expected path, skip it silently
and continue with implementation using your general knowledge. Do NOT fail or
block because an optional coding skill is missing. Report any missing skills as
a warning in the output envelope `risks` field.

## Purpose

Implement assigned work, update execution state, and report progress.

## What You Receive

- Change name
- Specific tasks to implement, or a quick blueprint to execute
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Read Context

Check `openspec/config.yaml` for `experimental.neabrain: true`.
If enabled, consult the Neabrain index for paths and relationships before reading files.
Otherwise, use direct relative paths from the project root.
Read file bodies only when needed:
- `tasks.md`, `design.md`, and `specs/` for the normal flow
- `quick.md` for quick mode
- relevant code and conventions

### Step 2: Detect TDD Mode

Detect TDD from (priority order):
1) openspec/config.yaml -> rules.apply.tdd
2) skills/testing/SKILL.md (if present, TDD patterns apply)
3) Existing test patterns
Default: standard mode

If TDD is active, use RED -> GREEN -> REFACTOR.

### Step 2.5: Load Coding Skills (autonomous)

Based on files to be modified, attempt to load the corresponding skill before implementing.
Do not wait for the orchestrator to specify them — this is the sub-agent's responsibility:
- .ts files -> read skills/typescript-general/SKILL.md
- *.test.ts files -> read skills/testing/SKILL.md
- Form/input components -> read skills/form-controls/SKILL.md
- .scss files -> read skills/scss/SKILL.md

If a skill file does not exist, skip it and proceed with general knowledge.
Add `"Missing optional skill: {skill-name}"` to the `risks` field in your output.

### Step 3: Detect Execution Mode

Normal mode:
- `openspec/changes/{change-name}/tasks.md` exists

Quick mode:
- `openspec/changes/{change-name}/quick.md` exists and `tasks.md` does not exist, or
- `.status.yaml` indicates `phase: QUICK`

If quick mode is detected:
- read `quick.md` as the single source of implementation scope
- do not require `design.md` or `specs/`
- implement only the blueprint described in `quick.md`

### Step 4: Implement Work

- Implement only assigned tasks
- Follow existing code patterns
- Keep batch small

In quick mode:

- implement only the bounded fix defined in `quick.md`
- do not invent additional work beyond the blueprint

### Step 5: Persist Progress

- If openspec mode and normal mode, update `openspec/changes/{change-name}/tasks.md`
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: APPLY
  change: "{change-name}"
  awaiting_approval: false
  completed: false
  pending_tasks: ["list of unchecked task ids"]
  modified_artifacts: []
  notes: "quick when applicable"
  ```

In quick mode, `pending_tasks` stays empty and `notes` should mention `quick`.

### Step 6: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Load coding skills autonomously based on files to be modified; do not wait for the orchestrator to specify them.
- Always follow design decisions when `design.md` exists.
- Use OpenSpec as the source of truth; do not copy code unless needed.
- If blocked, stop and report.
- In TDD mode, always write failing test first.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Implemented tasks X.Y through Z.W.",
  "detailed_report": "Technical summary and notes.",
  "tasks_completed": ["1.1", "1.2"],
  "tasks_pending": ["1.3"],
  "artifacts": [
    {
      "name": "tasks_or_quick_blueprint",
      "path": "openspec/changes/{change-name}/tasks.md | openspec/changes/{change-name}/quick.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "APPLY | VERIFY",
  "risks": ["list of risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
