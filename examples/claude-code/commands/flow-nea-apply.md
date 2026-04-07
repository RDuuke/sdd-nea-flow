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
1. Detect execution mode:
   - Normal flow: openspec/changes/$ARGUMENTS/tasks.md exists
   - Quick flow: openspec/changes/$ARGUMENTS/quick.md exists and tasks.md does not
2. Read the required planning artifacts:
   - Normal flow -> tasks.md, design.md, specs/
   - Quick flow -> quick.md only
3. Read openspec/config.yaml - check if TDD is configured (rules.apply.tdd)
4. Check if coding skills are needed based on file types to modify:
   - .ts files -> read skills/typescript-general/SKILL.md if it exists
   - *.test.ts -> read skills/testing/SKILL.md if it exists
   - .scss files -> read skills/scss/SKILL.md if it exists
5. Implement ONE BATCH of work (max one phase at a time - do not implement everything at once)
   - If TDD: write failing test first (RED), then implement (GREEN), then refactor (REFACTOR)
   - Follow existing code patterns in the project
   - In quick flow: implement only what quick.md describes
6. If normal flow, mark completed tasks as [x] in openspec/changes/$ARGUMENTS/tasks.md
7. Update openspec/changes/.status.yaml: phase: APPLY, pending_tasks: [remaining unchecked task ids or empty in quick flow], notes: "quick" if applicable

Return structured output with: status, executive_summary, detailed_report (files changed), artifacts, tasks_completed, tasks_pending, next_recommended.
