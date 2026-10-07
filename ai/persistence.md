# Persistencia del flujo de desarrollo

OpenSpec conserva contratos y estado versionables. NeaBrain es memoria opcional
entre cambios; no sustituye los artefactos ni decide si una fase puede avanzar.

## Estado por cambio

`openspec/changes/.status.yaml` es un selector con schema 2.0 y `active_change`.
Cada cambio tiene su propio `.status.yaml`: ultima fase intentada, resultado,
fases completadas, pendientes, aprobaciones tipadas, hashes e intentos FIX.
Un cambio explicito nunca hereda el estado de otro. SPEC y DESIGN son
independientes; sus escrituras de estado se serializan y fusionan.

STATUS solo lee. CONTINUE recupera el cambio seleccionado cuando falta estado,
preserva snapshots/JSON/YAML anteriores y no interpreta existencia como exito.
Un resultado VERIFY fallido o una aprobacion desconocida nunca habilita archivo.
Cambios archivados se consultan por su ubicacion sin repetir fases.

Contrato operativo: [state-contract.md](../skills/_shared/state-contract.md).

## Artefactos y auditoria

```text
openspec/
  config.yaml
  specs/{domain}/spec.md
  changes/
    .status.yaml                 # seleccion del activo
    {change-name}/
      .status.yaml               # estado canonico del cambio
      exploration.md
      proposal.md                # o quick.md
      specs/{domain}/spec.md
      design.md
      tasks.md
      validation-plan.yaml
      apply-progress.yaml
      verify-report.yaml
      fix-report.yaml
      .execution-log.yaml
    archive/YYYY-MM-DD-{change-name}/
      archive-report.yaml
```

La planeacion permanece en Markdown. Auditoria nueva en YAML: registros breves,
identidades estables, fechas con zona y referencias a evidencia. No se duplica
la misma auditoria en Markdown. Salidas extensas y capturas van por separado.
El log es historico; el estado del cambio gobierna continuidad.

FIX consume hallazgos estructurados y conserva hasta dos intentos entre sesiones.
VERIFY combina el informe anterior: mantiene IDs, evidencia e historial de los
hallazgos. `resolution` distingue open, resolved, dismissed y superseded; una
reparacion declarada por APPLY no demuestra resolucion. Los cierres incluyen
evidencia y hashes pertinentes; las sustituciones conservan las obligaciones
pendientes. Un informe antiguo sin resolution se interpreta como abierto.
No hay otro ledger ni autoridad de estado. Contrato:
[findings-contract.md](../skills/_shared/findings-contract.md).

Ausencia de una seccion en un informe antiguo no demuestra verificacion aprobada.
Informes Markdown antiguos se leen solo cuando falta el YAML, sin borrarlos ni
convertir archivos historicos masivamente.

Contrato y ejemplos: [audit-contract.md](../skills/_shared/audit-contract.md),
[audit-examples.md](../skills/_shared/audit-examples.md).

## Especificaciones consolidadas

`changes/{change}/specs/` contiene el delta; `openspec/specs/{domain}/spec.md`
describe el comportamiento actual completo de ese dominio. Al cerrar, ARCHIVE
integra altas, reemplaza requisitos modificados y retira los eliminados.
Preserva requisitos ajenos, identidades y escenarios no afectados.

La base no acumula copias por cambio ni secciones ADDED/MODIFIED/REMOVED.
Los deltas originales quedan en el cambio archivado. Una spec completa nueva
no autoriza reemplazar contenido previo de un dominio existente.

ARCHIVE prepara y valida todos los dominios antes de escribir, registra hashes,
operaciones y respaldos en `.archive-transaction.yaml`, y permite recuperar una
fusion parcial. Ante conflictos se detiene; no sobrescribe ni declara cerrado.
Solo despues de consolidar, verificar referencias y mover se marca completado.

## Escrituras verificadas y documentos concisos

Leer, combinar y validar antes de reemplazar; despues comprobar lo persistido
antes de declarar exito. Un fallo de lectura posterior requiere reconciliar
el contenido real, sin repetir a ciegas una escritura ni perder progreso previo.
No se usa Engram ni un espejo de tareas en memoria.

No hay limites universales de palabras. Propuestas, quick, diseno, tareas y deltas
deben ser concisos y completos. Nunca se recortan criterios, dependencias ni
requisitos vigentes para reducir longitud. Los ejemplos se cargan cuando ayudan
desde [planning-examples.md](../skills/_shared/planning-examples.md).
Registros YAML y referencias separan detalle y resumen sin perder trazabilidad.

## Invalidacion

Modificar propuesta invalida SPEC, DESIGN y fases dependientes; modificar specs
o diseno invalida TASKS y posteriores. Cambiar definicion de tareas o quick
invalida implementacion/verificacion dependiente. Cambiar codigo o entradas de
validacion invalida la evidencia afectada. Actualizar un checkbox no equivale a
redefinir tareas. Correcciones acotadas pueden preservar trabajo ya reconciliado.
Solo cambios materiales renuevan aprobaciones; se conserva autorizacion vigente.

## Persistencia de la capa de iniciativa

La capa upstream usa un backend propio, `initiative/`, separado de `openspec/`.
Vive en un repositorio dedicado por iniciativa (junto a `sources/`). Contrato
completo en [`skills/_shared/initiative-persistence-contract.md`](../skills/_shared/initiative-persistence-contract.md).

Estructura:

```text
<repo-iniciativa>/
  sources/01..06/            # input humano (SIEMPRE `sources/`, read-only para las skills)
  resources/                 # data del repo general — NO input (las skills la ignoran)
  initiative/
    config.yaml              # identidad + mapeo Azure + gates + target_projects
    .status.yaml             # estado (schema 1.0: INIT | INTAKE | SPEC | HU)
    intake/intake.md         # digest consolidado + ## Glosario
    intake/source-index.md   # inventario (Estado: parsed|encoding|unsupported-format|empty)
    intake/needs-review.md   # archivos a revisar por humano (encoding UTF-8 / formato)
    specs/{domain}/spec.md   # Feature + capacidades CAP-xxx + TOC de HU
    specs/{domain}/hu/HU-xxx/HU-xxx.md   # cuerpo de la HU
    specs/{domain}/hu/HU-xxx/assets/     # docs/Figma de esa HU (con .gitkeep)
    impact-map.yaml          # indice liviano de routing por HU (schema 2.2)
    .execution-log.md
```

Reglas clave:

- `sources/` es fijo; `resources/` y cualquier dir fuera de `sources/`+`initiative/`
  se ignora. Escritura solo dentro de `initiative/`. Estado en
  `initiative/.status.yaml`, nunca en `openspec/changes/.status.yaml`.
- Cada HU es una carpeta (`hu/HU-xxx/`); el Feature spec solo lleva una tabla de
  contenido. `impact-map.yaml` (schema 2.2) es un indice liviano: una entrada por
  HU con `id`, `spec_ref` (al archivo de la HU), `assets_dir`, `target_project`
  (+`status`), `proposed_change_name`, metadata Azure, `enrichment`
  {architecture,design}, `priority`, `revision`, `last_updated`, `status`
  (proposed|blocked|...) y `blockers[]`. Capacidades sin proyecto -> `unmapped_scope`.
- Re-run de HU: por identidad (feature+capacidad+intencion) ACTUALIZA en sitio
  (bump `revision`), CREA solo scope nuevo, marca `rejected` lo eliminado; nunca
  duplica ni borra.
- Anti-fabricacion: toda afirmacion rastrea a una fuente o queda `[sin confirmar]`/gap;
  el `## Glosario` del intake fija nombres canonicos (siglas solo si la fuente las define).
- Mapeo conceptual a Azure (solo metadata): iniciativa ≈ Epic, Feature, HISTORIA = HU.

## Lo que no pertenece a este repo

No debe existir una carpeta `openspec/` ni `initiative/` mantenida manualmente en
este repo plantilla. `openspec/` pertenece a los proyectos destino donde corre el
flujo de cambios; `initiative/` pertenece a cada repositorio de iniciativa.
