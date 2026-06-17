---
description: Fast-forward the initiative layer - init, intake, then stop at the human-review gate before spec
---

META-COMMAND: You (the orchestrator) handle this by launching sub-agents in sequence.
Do NOT invoke this as a skill. Launch individual Agent tool calls for each phase.

CONTEXT:
- Initiative slug: $ARGUMENTS
- Artifact store mode: initiative

VALIDATION:
Before proceeding, validate that $ARGUMENTS is a valid slug:
- MUST match pattern: ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (lowercase alphanumeric + hyphens only, 3-50 chars)
- If INVALID: return error to user and stop.

WORKFLOW - run in sequence:
1. Launch Agent (model: haiku) with prompt:
   "You are a flow-nea executor for phase INITIATIVE-INIT. Do NOT delegate.
   Read skills/flow-nea-initiative-init/SKILL.md FIRST.
   slug=$ARGUMENTS artifact_store.mode=initiative
   Scaffold structure, write config + status, validate Definition of Ready. Return JSON."

   If init returns status: warning with DoR gaps, SHOW the gaps to the user and ask whether to
   continue (sources may be empty). Do not auto-proceed if 01-negocio/02-producto are empty.

2. Launch Agent (model: sonnet) with prompt:
   "You are a flow-nea executor for phase INTAKE. Do NOT delegate.
   Read skills/flow-nea-initiative-intake/SKILL.md FIRST.
   slug=$ARGUMENTS artifact_store.mode=initiative
   Inventory and ingest sources/01..06, consolidate intake.md + source-index.md. Return JSON."

HUMAN-REVIEW GATE:
After INTAKE, STOP. Show the user:
- Per-subfolder extraction summary
- Unreadable files (needs-conversion)
- The "Vacíos detectados" list from intake.md
Then ask: "Revisa initiative/intake/intake.md. ¿Apruebas para generar las specs generales (Features)? Run /flow-nea-initiative-spec $ARGUMENTS"

Do NOT run spec automatically. SPEC runs only after explicit human approval.
