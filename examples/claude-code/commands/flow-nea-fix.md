---
description: Auto-fix loop - reads failing tests from verify-report and relaunches apply with targeted context
---

META-COMMAND: You (the orchestrator) handle this directly. Do NOT invoke as a skill.

CONTEXT:
- Change name: $ARGUMENTS
- Artifact store mode: openspec
- Max fix attempts: 2

VALIDATION:
Validate that $ARGUMENTS is a valid change-name (^[a-z0-9][a-z0-9-]*[a-z0-9]$, 3-50 chars).
If invalid, return error. If valid, proceed.

PRE-CHECK:
Read openspec/changes/$ARGUMENTS/verify-report.md.
- If file does not exist: return error "No verify report found. Run /flow-nea-verify $ARGUMENTS first."
- If "## Fallos Detectados" section is NOT present: return "No hay fallos detectados en el reporte. El cambio ya esta verificado correctamente."
- If section IS present: extract the failing tests, build errors, and incomplete tasks listed there.

WORKFLOW:

**Attempt 1:**

1. Launch Agent with prompt:
   "You are a flow-nea sub-agent. Read skills/flow-nea-apply/SKILL.md FIRST, then follow its instructions.
   change-name=$ARGUMENTS artifact_store.mode=openspec

   IMPORTANT — Targeted fix context:
   The previous verification failed. Focus ONLY on fixing these specific issues:

   {paste the full ## Fallos Detectados section from verify-report.md here}

   Do NOT rewrite unrelated code. Fix the minimum necessary to make the failing tests pass.
   Follow RED-GREEN-REFACTOR if TDD is configured. Return JSON with status and files changed."

2. After apply completes, launch Agent for re-verification:
   "You are a flow-nea sub-agent. Read skills/flow-nea-verify/SKILL.md FIRST, then follow its instructions.
   change-name=$ARGUMENTS artifact_store.mode=openspec
   Return JSON with status and any remaining failures."

3. Evaluate re-verification result:
   - If status ok and no "## Fallos Detectados" → SUCCESS: "Todos los tests pasan. Puedes continuar con /flow-nea-archive $ARGUMENTS"
   - If still failing → proceed to Attempt 2

**Attempt 2 (if needed):**

Repeat the same apply + verify cycle with the updated verify-report.md.
If still failing after attempt 2:
- DO NOT retry again
- Show the user: "No se pudo auto-corregir en 2 intentos. Fallos restantes: {list}. Requiere intervencion manual."
- Suggest: "/flow-nea-apply $ARGUMENTS para continuar manualmente"

RULES:
- Never attempt more than 2 fix cycles
- Never modify files outside the failing test scope
- Always re-run verify after each fix attempt — do not assume the fix worked
- If apply returns status: failed, stop immediately and report the error
