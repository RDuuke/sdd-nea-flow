---
description: Resume a stalled or interrupted flow-nea change
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-continue/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Change name: {argument}
- Artifact store mode: openspec

TASK:
1. Read openspec/changes/.status.yaml
   - If missing fields (older schema): fill defaults and rewrite with full template
   - If awaiting_approval: true — stop and tell user to approve the proposal first
2. If .status.yaml is missing entirely: infer phase from existing artifacts:
   - verify-report.md exists -> ARCHIVE
   - tasks.md has unchecked items -> APPLY
   - tasks.md exists (all checked) -> VERIFY
   - design.md exists -> TASKS
   - specs/ exists -> DESIGN
   - proposal.md exists -> SPEC
   - exploration.md exists -> PROPOSE
   - config.yaml only -> EXPLORE
3. Report to user: last completed phase, next phase, pending tasks if resuming APPLY
4. Invoke the next phase skill

Return structured output with: status, executive_summary, last_completed_phase, next_phase, pending_tasks, artifacts, risks.
