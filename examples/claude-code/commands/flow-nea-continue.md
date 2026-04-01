---
description: Continue the flow from the current phase - reads state and launches the next ready phase
---

META-COMMAND: You (the orchestrator) handle this by reading state and launching the next phase.
Do NOT invoke this as a skill.

CONTEXT:
- Change name: $ARGUMENTS (optional — if not provided, read from .status.yaml)
- Artifact store mode: openspec

WORKFLOW:

1. Read `openspec/changes/.status.yaml` to get:
   - `change` (use instead of $ARGUMENTS if not provided)
   - `current_phase`
   - `pending_tasks`
   - `awaiting_approval`

2. If `awaiting_approval: true`, STOP and tell the user:
   "El cambio {change} esta esperando aprobacion en fase {phase}. Revisa los artefactos y confirma para continuar."

3. Determine next phase using the dependency graph:

```
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```

| Current Phase | Next Phase | Condition |
|---------------|------------|-----------|
| INIT | EXPLORE | always |
| EXPLORE | PROPOSE | always |
| PROPOSE | SPEC + DESIGN | launch both (SPEC reads proposal, DESIGN reads proposal) |
| SPEC or DESIGN | TASKS | only when BOTH spec and design artifacts exist |
| TASKS | APPLY | always |
| APPLY | APPLY or VERIFY | if pending_tasks is empty → VERIFY, else → APPLY next batch |
| VERIFY | ARCHIVE | always |
| ARCHIVE | — | tell user the change is complete |

4. Launch the next phase sub-agent with:
   - change-name
   - artifact_store.mode: openspec
   - current model assignment from Model Assignments table

5. Show the user: "Continuando {change-name}: {current_phase} → {next_phase}"

VALIDATION:
- If $ARGUMENTS is provided, validate it matches ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (3-50 chars)
- If invalid: return error "Invalid change name."
- If .status.yaml does not exist: return error "No active change found. Run /flow-nea-propose <change-name> to start."
