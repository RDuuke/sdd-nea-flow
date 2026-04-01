# Flow-NEA: Spec-Driven Development

Este proyecto usa flow-nea para cambios complejos. Los comandos `/flow-nea-*`
activan un flujo estructurado de fases con sub-agentes.

## Cuando se activa el flujo

El flujo se activa SOLO cuando:
1. El usuario ejecuta un comando `/flow-nea-*` explicitamente
2. El usuario pide iniciar el flujo expresamente

Para todo lo demas (fix, preguntas, ediciones, refactors simples), trabaja
normalmente sin el flujo.

## Deteccion automatica (solo sugerir, nunca forzar)

Si el usuario describe un cambio que involucra multiples archivos, multiples
dominios o requiere investigacion previa, puedes sugerir:
"Esto parece un buen candidato para el flujo. Quieres que empiece con
/flow-nea-ff <nombre-sugerido>?"

No sugiereas el flujo para: ediciones de un archivo, fixes rapidos, preguntas
sobre el codigo, configuracion, o tareas de menos de 3 pasos.

## Reglas del orquestador (aplican solo dentro del flujo)

Cuando el usuario invoca un comando `/flow-nea-*`:

### Delegacion
- Usa el Agent tool para lanzar sub-agentes con contexto fresco.
- Cada sub-agente lee su SKILL.md y ejecuta la fase.
- No ejecutes trabajo de fases directamente (excepto tareas triviales).

### Estado
- Antes de cada fase, lee openspec/changes/.status.yaml
- Construye el prompt del Agent incluyendo: change-name, artifact_store.mode,
  current_phase, pending_tasks

### Validacion de respuestas
- Si la respuesta del sub-agente no contiene al menos `status` y
  `executive_summary`, tratar como `status: "failed"` con mensaje:
  "Respuesta del sub-agente incompleta o malformada."

### Registro de ejecucion
- Despues de que CADA sub-agente completa una fase, AGREGA una entrada a
  openspec/changes/{change-name}/.execution-log.md con el formato:
  ```markdown
  ### {FASE} — {timestamp}
  - **Status:** {ok | warning | failed}
  - **Summary:** {executive_summary}
  - **Artifacts:** {nombres o "none"}
  - **Risks:** {lista o "none"}
  - **Retried:** {yes | no}
  ```
- Esto proporciona audit trail para diagnosticar problemas.

### Manejo de respuestas
- Si status es failed o artifacts esta vacio: NO avances. Informa al usuario.
- Si risks no esta vacio: muestra cada risk y pregunta antes de continuar.
- Si user_approval_required es true: DETENTE y pide confirmacion.

### Reintento ante fallos transitorios
- Si un sub-agente devuelve `status: "failed"` y el error parece transitorio
  (timeout, error de parseo JSON, respuesta truncada): reintentar UNA vez con
  el mismo prompt.
- Si falla dos veces consecutivas: NO reintentar. Informar al usuario con el
  detalle del error y ofrecer opciones: (a) reintentar manualmente, (b)
  continuar desde la fase anterior, (c) abandonar el cambio.
- Antes de reintentar, verificar que `.status.yaml` no haya sido modificado
  por el intento fallido. Si fue modificado, restaurar la fase anterior.

### Actualizacion de estado fuera del flujo
- Si un artefacto OpenSpec es modificado fuera de una skill:
  1) Agregar a modified_artifacts en .status.yaml
  2) Retroceder phase: proposal.md -> SPEC | specs/ -> APPLY | design.md -> APPLY | tasks.md -> APPLY
  3) Informar al usuario

### Apply strategy
- Para listas de tareas grandes, divide en lotes.
- Despues de cada lote, muestra progreso y pregunta si continuar.

### Meta-comandos
- /flow-nea-ff: lanza propose->spec->design->tasks en secuencia.
  Muestra resumen combinado al final, no entre fases.

## Flujo de fases

INIT -> EXPLORE -> PROPOSE -> SPEC -> DESIGN -> TASKS -> APPLY -> VERIFY -> ARCHIVE

## Persistencia

- artifact_store.mode: auto | openspec | none (default: auto)
- En modo openspec, solo escribe dentro de openspec/.
- openspec/ se crea con /flow-nea-init.
