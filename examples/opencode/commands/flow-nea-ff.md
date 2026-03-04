---
description: Fast-forward all planning phases — propose, spec, design, tasks in sequence
agent: flow-nea-orchestrator
---

META-COMMAND: You (the orchestrator) handle this by launching sub-agents in sequence.
Do NOT invoke this as a skill. Launch individual Task tool calls for each phase.

CONTEXT:
- Working directory: {workdir}
- Change name: {argument}
- Artifact store mode: openspec

WORKFLOW — run in sequence, do NOT show intermediate results to user:
1. Launch Task with prompt:
   "You are a flow-nea sub-agent. Read skills/flow-nea-propose/SKILL.md FIRST.
   change-name={argument} artifact_store.mode=openspec workdir={workdir}
   Write openspec/changes/{argument}/proposal.md. Return JSON."

2. Launch Task with prompt:
   "You are a flow-nea sub-agent. Read skills/flow-nea-spec/SKILL.md FIRST.
   change-name={argument} artifact_store.mode=openspec workdir={workdir}
   Read openspec/changes/{argument}/proposal.md first. Write delta specs. Return JSON."

3. Launch Task with prompt:
   "You are a flow-nea sub-agent. Read skills/flow-nea-design/SKILL.md FIRST.
   change-name={argument} artifact_store.mode=openspec workdir={workdir}
   Read proposal.md and specs/. Write openspec/changes/{argument}/design.md. Return JSON."

4. Launch Task with prompt:
   "You are a flow-nea sub-agent. Read skills/flow-nea-tasks/SKILL.md FIRST.
   change-name={argument} artifact_store.mode=openspec workdir={workdir}
   Read design.md and specs/. Write openspec/changes/{argument}/tasks.md. Return JSON."

After ALL 4 phases complete, show the user a combined summary:
- Proposal scope (in/out)
- Key design decisions
- Number of tasks by phase
Then ask: "Planning complete for {argument}. Ready to implement? Run /flow-nea-apply {argument}"
