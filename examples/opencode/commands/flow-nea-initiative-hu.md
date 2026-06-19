---
description: Decompose initiative Features into detailed User Stories (inside specs) and emit impact-map.yaml
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-initiative-hu/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Initiative slug: {argument}
- Artifact store mode: initiative
- Optional Feature filter: pass feature=FEAT-{domain} to process a single Feature (batching).

PRECONDITION:
- At least one initiative/specs/{domain}/spec.md with CAP-xxx capabilities MUST exist. If none, return status: failed (run spec first).

TASK:
1. Read the Feature specs and initiative/config.yaml.
2. Derive User Stories (HU-xxx, unique initiative-wide) per capability; choose target cl00xx from config.target_projects.
3. Write the rich HU body INSIDE each Feature spec (## Historias de Usuario section); update the Trazabilidad table.
4. Emit/merge initiative/impact-map.yaml: one lean routing entry per HU (id, spec_ref anchor, target_project, proposed_change_name, azure metadata, status); unmapped capabilities under unmapped_scope.
5. Self-validate (coverage, HU sync, slugs unique, refs resolve). Update initiative/.status.yaml to phase: HU.

Return structured output with: status, executive_summary, artifacts, impact_map_valid, validation_errors, remaining_features, next_recommended, risks.
