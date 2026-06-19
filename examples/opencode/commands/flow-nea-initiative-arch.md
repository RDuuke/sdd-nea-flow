---
description: Architect enriches a User Story with technical design notes
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-initiative-enrich/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Initiative slug + HU id: {argument}  (e.g. "compra-de-cartera HU-004")
- role: architecture
- Artifact store mode: initiative

TASK:
1. Resolve the HU from initiative/impact-map.yaml (spec_ref + assets_dir).
2. Fill the `## Notas de arquitecto` section of the HU file (enfoque técnico, integraciones, datos/contratos, riesgos, referencias).
3. Place provided assets under the HU assets/ folder; record links.
4. Set enrichment.architecture.status (done | in-progress) in the HU header, impact-map entry, and the Feature spec TOC row.
5. Append an ENRICH-ARCHITECTURE entry to .execution-log.md. Do not move the stored phase.

Return structured output with: status, executive_summary, artifacts, role, hu, pending_for_role, next_recommended, risks.
