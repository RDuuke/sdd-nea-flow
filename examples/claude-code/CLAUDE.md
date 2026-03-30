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

### Manejo de respuestas
- Si status es failed o artifacts esta vacio: NO avances. Informa al usuario.
- Si risks no esta vacio: muestra cada risk y pregunta antes de continuar.
- Si user_approval_required es true: DETENTE y pide confirmacion.

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
