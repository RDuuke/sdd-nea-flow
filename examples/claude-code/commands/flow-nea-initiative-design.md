---
description: Designer enriches a User Story with UX/UI notes and Figma links
---

You are a flow-nea sub-agent. Read skills/flow-nea-initiative-enrich/SKILL.md FIRST, then follow it exactly.

CONTEXT:
- Initiative slug + HU id: $ARGUMENTS  (e.g. "compra-de-cartera HU-002")
- role: design
- Artifact store mode: initiative

TASK:
1. Resolve the HU from initiative/impact-map.yaml (spec_ref + assets_dir).
2. Fill the `## Diseño (UX/UI)` section of the HU file (Figma url, pantallas/flujos, recursos).
3. Place exports/mockups under the HU assets/ folder; record Figma links.
4. Set enrichment.design.status (done | in-progress) in the HU header, impact-map entry, and the Feature spec TOC row.
5. Append an ENRICH-DESIGN entry to .execution-log.md. Do not move the stored phase.

Return structured output with: status, executive_summary, artifacts, role, hu, pending_for_role, next_recommended, risks.
