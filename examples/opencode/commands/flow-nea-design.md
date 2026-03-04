---
description: Create technical design document for a change
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-design/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Change name: {argument}
- Artifact store mode: openspec

TASK:
1. Read openspec/config.yaml for stack and conventions
2. Read openspec/changes/{argument}/proposal.md and openspec/changes/{argument}/specs/
3. Read relevant source files to understand current patterns and entry points
4. Write openspec/changes/{argument}/design.md with:
   - Technical Approach, Architecture Decisions (with rationale), Data Flow, File Changes table,
     Interfaces/Contracts, Testing Strategy, Migration/Rollout, Open Questions
5. Update openspec/changes/.status.yaml: phase: DESIGN, change: {argument}

Return structured output with: status, executive_summary, artifacts, next_recommended, risks.
