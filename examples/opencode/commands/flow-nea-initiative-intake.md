---
description: Ingest the initiative sources/ subfolders into a consolidated intake digest
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-initiative-intake/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Initiative slug: {argument}
- Artifact store mode: initiative

TASK:
1. Inventory every file under sources/01..06 into initiative/intake/source-index.md.
2. Read each file with graceful degradation (mark unreadable as needs-conversion, never fail the phase).
3. Extract per subfolder and consolidate into initiative/intake/intake.md (with Resumen ejecutivo and Vacíos detectados).
4. Update initiative/.status.yaml to phase: INTAKE; set awaiting_approval per gates.intake.require_human_review.

Return structured output with: status, executive_summary, artifacts, awaiting_approval, next_recommended, risks.
