---
description: Fast-forward the initiative layer — init, intake, then stop at the human-review gate before spec
agent: flow-nea-orchestrator
---

META-COMMAND: You (the orchestrator) handle this by launching sub-agents in sequence.
Do NOT invoke this as a skill. Launch individual Task tool calls for each phase.

CONTEXT:
- Working directory: {workdir}
- Initiative slug: {argument}
- Artifact store mode: initiative

VALIDATION:
Validate that {argument} is a valid slug: ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (3-50 chars).
If INVALID: return error to user and stop.

WORKFLOW — run in sequence:
1. Launch Task with prompt:
   "You are a flow-nea executor for phase INITIATIVE-INIT. Do NOT delegate.
   Read skills/flow-nea-initiative-init/SKILL.md FIRST.
   slug={argument} artifact_store.mode=initiative workdir={workdir}
   Scaffold structure, write config + status, validate Definition of Ready. Return JSON."

   If init returns status: warning with DoR gaps, SHOW the gaps and ask whether to continue.
   Do not auto-proceed if 01-negocio/02-producto are empty.

2. Launch Task with prompt:
   "You are a flow-nea executor for phase INTAKE. Do NOT delegate.
   Read skills/flow-nea-initiative-intake/SKILL.md FIRST.
   slug={argument} artifact_store.mode=initiative workdir={workdir}
   Inventory and ingest sources/01..06, consolidate intake.md + source-index.md. Return JSON."

HUMAN-REVIEW GATE:
After INTAKE, STOP. Show the user the per-subfolder summary, unreadable files (needs-conversion),
and the "Vacíos detectados" list from intake.md. Then ask:
"Revisa initiative/intake/intake.md. ¿Apruebas para generar las specs generales (Features)? Run /flow-nea-initiative-spec {argument}"

Do NOT run spec automatically. SPEC runs only after explicit human approval.
