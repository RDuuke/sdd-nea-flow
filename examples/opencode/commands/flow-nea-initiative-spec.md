---
description: Write general initiative specs (Azure Features) and emit impact-map.yaml
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-initiative-spec/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Initiative slug: {argument}
- Artifact store mode: initiative

PRECONDITION:
- initiative/intake/intake.md MUST exist and be human-approved. If missing, return status: failed (run intake first).

TASK:
1. Read initiative/intake/intake.md and initiative/config.yaml.
2. Group capabilities into Feature domains; write initiative/specs/{domain}/spec.md (business altitude, no technical detail).
3. Emit initiative/impact-map.yaml: candidate User Stories bound to registered cl00xx projects; unmapped capabilities under unmapped_scope.
4. Update initiative/.status.yaml to phase: SPEC.

Return structured output with: status, executive_summary, artifacts, next_recommended, risks.
