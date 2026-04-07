---
description: Implement tasks from the change — writes code following specs and design
agent: flow-nea-orchestrator
subtask: true
---

You are a flow-nea sub-agent. Read skills/flow-nea-apply/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Change name: {argument}
- Artifact store mode: openspec
- Current status: read openspec/changes/.status.yaml (check pending_tasks and modified_artifacts)

TASK:
1. Detect execution mode:
   - Normal flow: openspec/changes/{argument}/tasks.md exists
   - Quick flow: openspec/changes/{argument}/quick.md exists and tasks.md does not
2. Read the required planning artifacts:
   - Normal flow -> tasks.md, design.md, specs/
   - Quick flow -> quick.md only
3. Read openspec/config.yaml — check if TDD is configured (rules.apply.tdd)
4. Check if coding skills are needed based on file types to modify:
   - .ts files -> read skills/typescript-general/SKILL.md if it exists
   - *.test.ts -> read skills/testing/SKILL.md if it exists
   - .scss files -> read skills/scss/SKILL.md if it exists
5. Implement ONE BATCH of work (max one phase at a time — do not implement everything at once)
   - If TDD: write failing test first (RED), then implement (GREEN), then refactor (REFACTOR)
   - Follow existing code patterns in the project
   - In quick flow: implement only what quick.md describes
6. If normal flow, mark completed tasks as [x] in openspec/changes/{argument}/tasks.md
7. Update openspec/changes/.status.yaml: phase: APPLY, pending_tasks: [remaining unchecked task ids or empty in quick flow], notes: "quick" if applicable

Return structured output with: status, executive_summary, detailed_report (files changed), artifacts, tasks_completed, tasks_pending, next_recommended.
