# Flujo nea-flow

## Fases soportadas

- `INIT`
- `EXPLORE`
- `PROPOSE`
- `SPEC`
- `DESIGN`
- `TASKS`
- `APPLY`
- `VERIFY`
- `ARCHIVE`

## Grafo de dependencias

```text
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```

Reglas:

- `SPEC` y `DESIGN` leen desde `PROPOSE`
- `TASKS` requiere `SPEC` y `DESIGN`
- `APPLY` implementa contra tareas y artefactos previos
- `VERIFY` compara implementacion contra specs
- `ARCHIVE` consolida el cambio y cierra estado

## Meta-comandos

- `/flow-nea-ff <change-name>`: ejecuta propose -> spec -> design -> tasks
- `/flow-nea-continue <change-name>`: retoma desde la siguiente fase valida
- `/flow-nea-judgment <change-name>`: revision dual ciega en paralelo
- `/flow-nea-fix <change-name>`: relee fallos de verify y reintenta apply + verify

## Reglas de avance

El orquestador no debe avanzar automaticamente si:

- la fase devuelve `status: failed`
- `artifacts` viene vacio cuando se esperaba salida material
- existen riesgos no resueltos
- el usuario debe aprobar

## Reglas de regresion

Si un artefacto OpenSpec se modifica fuera de la skill esperada, el sistema
debe registrar `modified_artifacts` y retroceder fase para forzar revalidacion.

Reglas minimas:

- `proposal.md` modificado -> volver a `SPEC`
- `specs/` modificadas -> volver a `APPLY`
- `design.md` modificado -> volver a `APPLY`
- `tasks.md` modificado -> volver a `APPLY`

## Retry policy

Una fase puede reintentarse una sola vez cuando el fallo parece transitorio:

- timeout
- JSON truncado
- error de parseo
- respuesta incompleta

Si falla dos veces seguidas, el orquestador debe detenerse e informar opciones
al usuario.

## Approval gates

Las aprobaciones del usuario importan especialmente en:

- despues de `EXPLORE`, si hay cambios de enfoque
- despues de `PROPOSE`, `SPEC`, `DESIGN` y `TASKS`
- cuando aparecen riesgos o bloqueadores
- entre lotes grandes de `APPLY`

## APPLY por lotes

Cuando `tasks.md` es largo, `APPLY` debe ejecutarse por lotes y registrar
progreso incremental para evitar cambios grandes sin control.

## Fuente de verdad de runtime

La semantica operativa final del flujo vive en:

- `skills/flow-nea-*/SKILL.md`
- prompts de `examples/`
- `.status.yaml` en el proyecto destino

Este documento existe para explicar el sistema, no para reemplazar esas fuentes.
