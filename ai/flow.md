# Flujo nea-flow

## Fases soportadas

- `INIT`
- `EXPLORE`
- `PROPOSE`
- `QUICK`
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

INIT/EXPLORE -> QUICK -> APPLY -> VERIFY -> ARCHIVE
```

Reglas:

- `SPEC` y `DESIGN` leen desde `PROPOSE`
- `QUICK` es una via rapida lateral para fixes pequenos y de bajo riesgo
- `TASKS` requiere `SPEC` y `DESIGN`
- `APPLY` implementa contra tareas y artefactos previos
- `VERIFY` compara implementacion contra specs
- `ARCHIVE` consolida el cambio y cierra estado

## Meta-comandos

- `/flow-nea-ff <change-name>`: ejecuta propose -> spec -> design -> tasks
- `/flow-nea-continue <change-name>`: retoma desde la siguiente fase valida
- `/flow-nea-judgment <change-name>`: revision dual ciega en paralelo
- `/flow-nea-fix <change-name>`: relee fallos de verify y reintenta apply + verify

## Via rapida

- `/flow-nea-quick <change-name>`: crea `quick.md`, espera una sola aprobacion y luego ejecuta `APPLY -> VERIFY -> ARCHIVE`

## Reglas de avance

El orquestador no debe avanzar automaticamente si:

- la fase devuelve `status: failed`
- `artifacts` viene vacio cuando se esperaba salida material
- existen riesgos no resueltos
- el usuario debe aprobar

En `QUICK`, la aprobacion ocurre una sola vez sobre `quick.md` antes de `APPLY`.
Despues de esa aprobacion, la via rapida no termina en implementacion parcial:
debe cerrar con `VERIFY` y `ARCHIVE` si la validacion sale bien.
Si `VERIFY` falla, el orquestador intenta hasta 2 ciclos de fix automatico (misma
logica que `/flow-nea-fix`) antes de detenerse. Si sigue fallando, deriva al usuario
a `/flow-nea-fix` para intervencion manual. El cambio nunca queda en el limbo.

## Reglas de regresion

Si un artefacto OpenSpec se modifica fuera de la skill esperada, el sistema
debe registrar `modified_artifacts` y retroceder fase para forzar revalidacion.

Reglas minimas:

- `proposal.md` modificado -> volver a `SPEC`
- `quick.md` modificado -> volver a `APPLY`
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
- despues de `QUICK`, antes de `APPLY`
- despues de `PROPOSE`, `SPEC`, `DESIGN` y `TASKS`
- cuando aparecen riesgos o bloqueadores
- entre lotes grandes de `APPLY`

## APPLY por lotes

Cuando `tasks.md` es largo, `APPLY` debe ejecutarse por lotes y registrar
progreso incremental para evitar cambios grandes sin control.

## Capa de iniciativa (upstream)

Capa que corre por encima del flujo de cambios, en un repositorio dedicado por
iniciativa. Ingiere documentos en `sources/01..06` y produce specs generales.
Es un grafo aparte, con su propio estado en `initiative/.status.yaml`:

```text
INITIATIVE-INIT -> INTAKE -> [gate revision humana] -> SPEC (Features) -> HU (Historias) -> (ENRICH opcional) -> (DECOMPOSE futuro)
```

- `INITIATIVE-INIT` (`flow-nea-initiative-init`): scaffold de `sources/` +
  `initiative/`, escribe `config.yaml`/`.status.yaml`, valida la Definition of
  Ready (no bloquea por DoR; reporta vacios como `risks`).
- `INTAKE` (`flow-nea-initiative-intake`): inventaria y lee `sources/` con
  degradacion gracil (archivos ilegibles -> `needs-conversion`, nunca falla la
  fase), consolida `intake.md` + `source-index.md`. Activa el gate de revision
  humana (`gates.intake.require_human_review`) antes de SPEC.
- `SPEC` (`flow-nea-initiative-spec`): escribe specs generales detalladas
  (Features de Azure con capacidades `CAP-xxx`). No escribe HU ni impact-map.
- `HU` (`flow-nea-initiative-hu`): descompone los Features en Historias de
  Usuario, **una carpeta por HU** (`specs/{domain}/hu/HU-xxx/` con `HU-xxx.md` +
  `assets/`), mantiene una tabla de contenido en el Feature spec, marca las HU
  que requieren arquitecto y/o disenador, y emite el `impact-map.yaml` (indice
  liviano de routing por HU). La usa PMO; puede ejecutarse por lotes.
- `ENRICH` (`flow-nea-initiative-enrich`): pase de especialista fuera de banda.
  El arquitecto (`/flow-nea-initiative-arch`) completa `## Notas de arquitecto`;
  el disenador (`/flow-nea-initiative-design`) completa `## Diseño (UX/UI)` con
  enlaces Figma y assets. Actualiza `enrichment.{role}.status` (pending -> done)
  en la HU, el impact-map y la TOC; no mueve la fase almacenada (como SPEC-FIX).
- `flow-nea-initiative-status`: motor de estado read-only + lint del
  `impact-map.yaml` (cobertura, sincronizacion HU, slugs unicos, refs validas) y
  reporte de `enrichment_pending` por rol.

Mapeo conceptual a Azure DevOps (solo metadata, sin API): iniciativa ≈ Epic,
spec general = Feature, change candidato = Historia de Usuario.

La costura con el flujo per-proyecto es `initiative/impact-map.yaml`. El paso
DECOMPOSE (sembrar el seed de cada HU en `openspec/changes/` del cl00xx) esta
fuera de alcance hoy; esta capa solo produce el mapa. Detalle del contrato de
artefactos en [`persistence.md`](persistence.md).

## Fuente de verdad de runtime

La semantica operativa final del flujo vive en:

- `skills/flow-nea-*/SKILL.md`
- prompts de `examples/`
- `.status.yaml` en el proyecto destino

Este documento existe para explicar el sistema, no para reemplazar esas fuentes.
