---
description: Write delta specifications for a change
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-spec/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Change name: {argument}
- Artifact store mode: openspec

TASK:
1. Read openspec/changes/{argument}/proposal.md — identify affected domains from "Affected Areas"
2. For each domain, read openspec/specs/{domain}/spec.md if it exists
3. Write delta specs at openspec/changes/{argument}/specs/{domain}/spec.md
   - Use ADDED / MODIFIED / REMOVED sections
   - Every requirement needs at least one Given/When/Then scenario
   - Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY)
4. Update openspec/changes/.status.yaml: phase: SPEC, change: {argument}

Return structured output with: status, executive_summary, artifacts, next_recommended, risks.
