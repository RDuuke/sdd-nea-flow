---
description: Unattended initiative run - init, intake (auto-approved), spec, hu end-to-end
---

META-COMMAND: You (the orchestrator) handle this by launching sub-agents in sequence.
Do NOT invoke this as a skill. Use this when PMO is absent and the human-review gate must be auto-approved.

CONTEXT:
- Initiative slug: $ARGUMENTS
- Artifact store mode: initiative

VALIDATION:
Validate that $ARGUMENTS is a valid slug: ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (3-50 chars). If INVALID, stop.

WORKFLOW - run in sequence, auto-approving the intake gate:
1. INITIATIVE-INIT (skills/flow-nea-initiative-init): scaffold + config + Definition of Ready.
   - If 01-negocio OR 02-producto is EMPTY, STOP and report (no real input to ingest). Do not continue.
2. INTAKE (skills/flow-nea-initiative-intake): ingest sources/01..06.
   - AUTO-APPROVE the human-review gate for this run (do not wait). Note in the execution log that intake was auto-approved (PMO absent).
3. SPEC (skills/flow-nea-initiative-spec): detailed Features + capabilities.
4. HU (skills/flow-nea-initiative-hu): one folder per HU + impact-map.yaml. Accept the skill's enrichment flags as-is.

STOP CONDITIONS:
- Any phase returns status: failed -> STOP and report (retry once if the error looks transient).
- Empty 01-negocio/02-producto at INIT -> STOP.

AFTER COMPLETION (report, do not run):
- Show the per-Feature summary, HU count, and impact-map validation result.
- List architecture_candidates and design_candidates so specialists can be routed later with /flow-nea-initiative-arch and /flow-nea-initiative-design.
- Tell the user ENRICH and DECOMPOSE were NOT run.

NOTES:
- This command does NOT edit config.yaml; it overrides the gate only for this run.
- To make auto-approval permanent, set gates.intake.require_human_review: false in initiative/config.yaml.
