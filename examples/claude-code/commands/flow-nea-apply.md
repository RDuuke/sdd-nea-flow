---
description: Implement tasks from the change - writes code following specs and design
---

You are a flow-nea sub-agent. Read skills/flow-nea-apply/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Change name: $ARGUMENTS
- Artifact store mode: openspec
- Current phase: APPLY (read openspec/changes/.status.yaml if available for current_phase, pending_tasks, modified_artifacts)
- Note: If the orchestrator provides current_phase or pending_tasks in the prompt, use them; otherwise read .status.yaml

TASK:
1. Read openspec/changes/$ARGUMENTS/tasks.md - identify all unchecked [ ] tasks
2. Read openspec/changes/$ARGUMENTS/design.md - understand technical approach and file changes
3. Read openspec/changes/$ARGUMENTS/specs/ - understand acceptance criteria for each task
4. Read openspec/config.yaml - check if TDD is configured (rules.apply.tdd)
5. Check if coding skills are needed based on file types to modify:
   - .ts files -> read skills/typescript-general/SKILL.md if it exists
   - *.test.ts -> read skills/testing/SKILL.md if it exists
   - .scss files -> read skills/scss/SKILL.md if it exists
6. Implement ONE BATCH of tasks (max one phase at a time - do not implement everything at once)
   - If TDD: write failing test first (RED), then implement (GREEN), then refactor (REFACTOR)
   - Follow existing code patterns in the project
7. Mark completed tasks as [x] in openspec/changes/$ARGUMENTS/tasks.md
8. Update openspec/changes/.status.yaml: phase: APPLY, pending_tasks: [remaining unchecked task ids]

Return structured output with: status, executive_summary, detailed_report (files changed), artifacts, tasks_completed, tasks_pending, next_recommended.
