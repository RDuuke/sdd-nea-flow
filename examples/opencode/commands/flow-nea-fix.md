---
description: Auto-fix loop - reads failing tests from verify-report and relaunches apply with targeted context
---

META-COMMAND: You (the orchestrator) handle this directly. Do NOT invoke as a skill.

CONTEXT:
- Change name: $ARGUMENTS
- Artifact store mode: openspec
- Max fix attempts: 2

VALIDATION:
Validate $ARGUMENTS (^[a-z0-9][a-z0-9-]*[a-z0-9]$, 3-50 chars). If invalid, return error.

PRE-CHECK:
Read openspec/changes/$ARGUMENTS/verify-report.md.
- No file → error "No verify report found. Run /flow-nea-verify $ARGUMENTS first."
- No "## Fallos Detectados" section → "No hay fallos. El cambio esta verificado correctamente."
- Section present → extract failing tests, build errors, incomplete tasks.

WORKFLOW (max 2 attempts):

**Attempt N:**

1. Delegate to apply agent:
   "Eres un ejecutor flow-nea para la fase APPLY. Lee ~/.config/opencode/skills/flow-nea-apply/SKILL.md.
   change-name=$ARGUMENTS artifact_store.mode=openspec

   CONTEXTO DE FIX DIRIGIDO:
   La verificacion anterior fallo. Corrige SOLO estos problemas especificos:

   {seccion ## Fallos Detectados del verify-report.md}

   No reescribas codigo no relacionado. Aplica el minimo cambio para que los tests pasen.
   Sigue RED-GREEN-REFACTOR si TDD esta configurado. Retorna JSON."

2. Delegate to verify agent:
   "Eres un ejecutor flow-nea para la fase VERIFY. Lee ~/.config/opencode/skills/flow-nea-verify/SKILL.md.
   change-name=$ARGUMENTS artifact_store.mode=openspec
   Retorna JSON con status y fallos restantes si los hay."

3. Evaluar:
   - Status ok + sin "## Fallos Detectados" → SUCCESS: "Tests pasan. Continua con /flow-nea-archive $ARGUMENTS"
   - Aun con fallos → si intentos < 2, repetir con nuevo verify-report.md

**Si falla despues de 2 intentos:**
- STOP. No reintentar.
- Reportar: "No se pudo auto-corregir en 2 intentos. Fallos: {lista}. Requiere intervencion manual."
- Sugerir: "/flow-nea-apply $ARGUMENTS para continuar manualmente"

REGLAS:
- Maximo 2 ciclos fix
- Siempre re-verificar despues de cada apply — nunca asumir que el fix funciono
- Si apply retorna status: failed, detener inmediatamente
