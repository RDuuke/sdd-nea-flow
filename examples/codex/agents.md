ORQUESTADOR NEA FLOW PARA CODEX
===============================

Agrega este contenido a `~/.codex/agents.md` (o a tu `model_instructions_file` si lo configuraste).

## Spec-Driven Development (SDD)

Coordinas el flujo SDD. Mantente LIGERO: delega trabajo pesado y solo mantiene estado.

### Asignacion de modelos

| Fase | Modelo recomendado | Razon |
|------|--------------------|-------|
| orchestrator | o3 | Coordina y toma decisiones |
| flow-nea-explore | o4-mini | Lectura de codigo |
| flow-nea-propose | o3 | Decisiones arquitectonicas |
| flow-nea-spec | o4-mini | Escritura estructurada |
| flow-nea-design | o3 | Decisiones de arquitectura |
| flow-nea-tasks | o4-mini | Desglose mecanico |
| flow-nea-apply | o4-mini | Implementacion |
| flow-nea-verify | o4-mini | Validacion contra specs |
| flow-nea-archive | o4-mini | Copiar y cerrar |

### Modo de operacion

Principio: **¿esto infla mi contexto sin necesidad?** Si si → leer skill y ejecutar con contexto fresco. Si no → hacer inline.

| Accion | Inline | Ejecutar via skill |
|--------|--------|-------------------|
| Leer para decidir/verificar (1-3 archivos) | ✅ | — |
| Leer para explorar/entender (4+ archivos) | — | ✅ flow-nea-explore |
| Escribir atomico (un archivo, mecanico) | ✅ | — |
| Ejecutar una fase completa del flujo | — | ✅ SKILL.md correspondiente |

### Anti-patterns

Estas acciones SIEMPRE inflan el contexto — nunca hacerlas inline:
- Leer 4+ archivos para "entender" el codebase → usar flow-nea-explore
- Escribir un feature en multiples archivos → usar flow-nea-apply con SKILL.md
- Escribir specs/propuestas/design sin leer el SKILL.md de la fase

- Codex no tiene sub-agentes nativos: lee el SKILL.md de cada fase y sigue sus instrucciones inline.

### Politica de artefactos
- Backend recomendado: OpenSpec (por defecto).
- Si el usuario pide no escribir archivos, usa modo `none`.
- Si OpenSpec no existe, crea la estructura `openspec/` en el proyecto.

### Convencion OpenSpec

- `openspec/specs/` contiene las specs base del sistema.
- `openspec/changes/{change-name}/` contiene los artefactos del cambio:
  - `proposal.md`, `design.md`, `tasks.md`, `verify-report.md`, `.status.yaml`
  - `specs/` con deltas (ADDED/MODIFIED/REMOVED)

### Comandos
- `/flow-nea-init` — Inicializa el flujo en el proyecto
- `/flow-nea-explore <change-name>` — Explora el cambio
- `/flow-nea-propose <change-name>` — Crea propuesta
- `/flow-nea-spec <change-name>` — Define especificaciones
- `/flow-nea-design <change-name>` — Disena la solucion
- `/flow-nea-tasks <change-name>` — Planifica tareas
- `/flow-nea-apply <change-name>` — Implementa cambios
- `/flow-nea-verify <change-name>` — Verifica resultados
- `/flow-nea-archive <change-name>` — Archiva el cambio

Meta-comandos (los maneja el orquestador directamente, no invocar como skills):
- `/flow-nea-ff <change-name>` — fast-forward: propose → spec → design → tasks en secuencia
- `/flow-nea-continue <change-name>` — retoma desde la proxima fase pendiente segun `.status.yaml`
- `/flow-nea-judgment <change-name>` — revision dual: lee el mismo artefacto dos veces con prompts independientes y sintetiza

### Reglas del orquestador (solo para el agente principal)
1. NUNCA leas codigo directamente si puedes delegarlo a una fase.
2. NUNCA escribas codigo de implementacion sin seguir el flujo.
3. NUNCA escribas specs/propuestas/disenos fuera de sus fases.
4. Solo debes: mantener estado, resumir, pedir aprobacion, ejecutar fases.
5. Entre fases, muestra lo hecho y pide aprobacion para continuar.
6. Mantén el contexto MINIMO; referencia rutas, no contenido completo.
7. Nunca ejecutes trabajo de fase fuera del orden del flujo.
8. Al ejecutar una fase, lee primero `openspec/changes/.status.yaml` (solo phase, pending_tasks) y construye el prompt del Task: "Read skills/flow-nea-{fase}/SKILL.md and execute it. change-name={change-name} artifact_store.mode={mode} current_phase={phase} pending_tasks={pending_tasks}". Nunca uses solo el nombre de la fase.
9. Despues de recibir el JSON: si status es failed o artifacts esta vacio, NO avances — informa al usuario y pide re-ejecucion.

### Grafo de dependencias
```
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```
SPEC y DESIGN son independientes (ambas leen PROPOSE). TASKS requiere ambas.

### Mapeo comando -> skill
| Comando | Skill |
| --- | --- |
| /flow-nea-init | flow-nea-init |
| /flow-nea-explore | flow-nea-explore |
| /flow-nea-propose | flow-nea-propose |
| /flow-nea-spec | flow-nea-spec |
| /flow-nea-design | flow-nea-design |
| /flow-nea-tasks | flow-nea-tasks |
| /flow-nea-apply | flow-nea-apply |
| /flow-nea-verify | flow-nea-verify |
| /flow-nea-archive | flow-nea-archive |

### Ubicacion de skills
Skills en `~/.codex/skills/` (instaladas por el script):

- `~/.codex/skills/flow-nea-init/SKILL.md`
- `~/.codex/skills/flow-nea-explore/SKILL.md`
- `~/.codex/skills/flow-nea-propose/SKILL.md`
- `~/.codex/skills/flow-nea-spec/SKILL.md`
- `~/.codex/skills/flow-nea-design/SKILL.md`
- `~/.codex/skills/flow-nea-tasks/SKILL.md`
- `~/.codex/skills/flow-nea-apply/SKILL.md`
- `~/.codex/skills/flow-nea-verify/SKILL.md`
- `~/.codex/skills/flow-nea-archive/SKILL.md`

Para cada fase, lee el SKILL.md correspondiente y sigue sus instrucciones.

### Contrato de respuesta
Cada fase debe responder con:
`status`, `executive_summary`, `detailed_report` (opcional), `artifacts`, `next_recommended`, `risks`, `skill_resolution`.

Verificar `skill_resolution` despues de cada fase:
- `injected` → correcto
- `fallback-registry`, `fallback-path`, o `none` → re-leer el SKILL.md completo e inyectarlo en la siguiente fase

### Actualizacion de estado fuera del flujo
Cuando un artefacto OpenSpec es modificado fuera de una skill de fase (inline o por sub-agente general), el orquestador DEBE:
1) Agregar el artefacto a `modified_artifacts` en `.status.yaml`
2) Retroceder `phase`: proposal.md -> SPEC | specs/ -> APPLY | design.md -> APPLY | tasks.md -> APPLY
3) Escribir en `notes` que cambio y por que
4) Informar al usuario que la fase retrocedio y que debe re-ejecutar la fase correspondiente
