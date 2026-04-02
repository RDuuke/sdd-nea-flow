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

### Asignacion de modelos

Lee esta tabla al inicio de la sesion (o antes de la primera delegacion), almacenala en cache y pasa el modelo en cada llamada Agent. Si el modelo asignado no esta disponible, usa `sonnet` y continua.

| Fase | Modelo | Razon |
|------|--------|-------|
| orchestrator | opus | Coordina y toma decisiones |
| flow-nea-explore | sonnet | Lee codigo, analisis estructural |
| flow-nea-propose | opus | Decisiones arquitectonicas |
| flow-nea-spec | sonnet | Escritura estructurada |
| flow-nea-design | opus | Decisiones de arquitectura |
| flow-nea-tasks | sonnet | Desglose mecanico |
| flow-nea-apply | sonnet | Implementacion |
| flow-nea-verify | sonnet | Validacion contra specs |
| flow-nea-archive | haiku | Copiar y cerrar |
| default | sonnet | Delegaciones generales |

### Delegacion

Principio: **¿esto infla mi contexto sin necesidad?** Si sí → delegar. Si no → hacer inline.

| Accion | Inline | Delegar |
|--------|--------|---------|
| Leer para decidir/verificar (1-3 archivos) | ✅ | — |
| Leer para explorar/entender (4+ archivos) | — | ✅ |
| Leer como preparacion para escribir | — | ✅ junto con el write |
| Escribir atomico (un archivo, mecanico, ya sabes que) | ✅ | — |
| Escribir con analisis (multiples archivos, nueva logica) | — | ✅ |
| Bash para estado (git, gh) | ✅ | — |
| Bash para ejecucion (test, build, install) | — | ✅ |

`delegate (async)` es el default para trabajo delegado. Usa `task (sync)` solo cuando necesitas el resultado antes de tu proxima accion.

- Usa el Agent tool para lanzar sub-agentes con contexto fresco.
- Cada sub-agente recibe compact rules pre-resueltas del skill registry como `## Project Standards (auto-resolved)`.
- No ejecutes trabajo de fases directamente (excepto tareas triviales del inline).

### Anti-patterns

Estas acciones SIEMPRE inflan el contexto sin necesidad — nunca hacerlas inline:
- Leer 4+ archivos para "entender" el codebase → delegar una exploracion
- Escribir un feature en multiples archivos → delegar
- Ejecutar tests o builds → delegar
- Leer archivos como preparacion para editar, luego editar → delegar todo junto

### Estado
- Antes de cada fase, lee openspec/changes/.status.yaml
- Construye el prompt del Agent incluyendo: change-name, artifact_store.mode,
  current_phase, pending_tasks

### Validacion de respuestas
- Si la respuesta del sub-agente no contiene al menos `status` y
  `executive_summary`, tratar como `status: "failed"` con mensaje:
  "Respuesta del sub-agente incompleta o malformada."
- Despues de cada delegacion, verifica el campo `skill_resolution`:
  - `injected` → correcto, las skills llegaron al sub-agente
  - `fallback-registry`, `fallback-path`, o `none` → el cache de skills se perdio (probable compaction). Vuelve a leer `.atl/skill-registry.md` e inyecta compact rules en todas las delegaciones siguientes.

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

Estos comandos los maneja el orquestador directamente. NO los invoques como skills.

- `/flow-nea-ff <change-name>`: lanza propose→spec→design→tasks en secuencia. Muestra resumen combinado al final, no entre fases.
- `/flow-nea-continue <change-name>`: lee `.status.yaml`, determina la proxima fase pendiente segun el grafo de dependencias y la lanza.
- `/flow-nea-judgment <change-name>`: lanza dos sub-agentes en paralelo con el mismo artefacto (proposal.md o tasks.md segun contexto), cada uno sin ver el resultado del otro. Sintetiza: `Confirmed`, `Suspect A/B` o `Contradiction` (visiones opuestas — detenerse y pedir decision al usuario).
- `/flow-nea-fix <change-name>`: lee `verify-report.md`, extrae la seccion `## Fallos Detectados`, lanza apply con ese contexto exacto, luego re-ejecuta verify. Maximo 2 intentos. Si persisten fallos, reporta y detiene.

## Flujo de fases

```
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```

SPEC y DESIGN son independientes (ambas leen de PROPOSE). TASKS requiere ambas.

## Persistencia

- artifact_store.mode: auto | openspec | none (default: auto)
- En modo openspec, solo escribe dentro de openspec/.
- openspec/ se crea con /flow-nea-init.
