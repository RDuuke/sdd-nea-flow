# Flujo de desarrollo nea-flow

## Dependencias

```text
INIT -> EXPLORE -> PROPOSE aprobado -> SPEC ---+
                                     DESIGN -+-> TASKS -> APPLY -> VERIFY -> ARCHIVE
INIT/EXPLORE -> QUICK aprobado -> APPLY -> VERIFY -> ARCHIVE
```

PROPOSE directo puede omitir EXPLORE si hay contexto suficiente. SPEC y DESIGN
leen la propuesta aprobada en cualquier orden; TASKS exige ambas. La ruta quick
es explicita, para ajustes acotados de bajo riesgo.

## Continuidad y autorizacion

STATUS calcula el siguiente paso desde estado propio y dependencias. CONTINUE
aplica recuperacion dirigida cuando hace falta. El selector global no guarda
fases; cada cambio conserva progreso, aprobaciones y bloqueos al alternar trabajo.

Se aprueba alcance una vez sobre propuesta o quick. No hay aprobaciones rutinarias
despues de SPEC, DESIGN, TASKS o cada lote. Se informa progreso y se sigue trabajo
autorizado; cambios materiales, riesgos nuevos o gates configurados requieren
decision. Advertencias informativas no bloquean por si solas.

FF respeta el gate de propuesta y termina en TASKS; no implementa por su cuenta.
QUICK aprobado completa APPLY, VERIFY y ARCHIVE cuando cumple las obligaciones.
JUDGMENT conserva revision independiente. FIX repara solo hallazgos de producto,
con un maximo de dos ciclos persistidos; infraestructura se recupera por separado.

Ante un bug, EXPLORE/APPLY/FIX separan sintoma y causa propuesta. Agrupan fallos
solo con evidencia de una causa compartida y comprueban cada criterio afectado.
Una reparacion parcial conserva lo pendiente; no reinicia el presupuesto FIX.
Reglas: [triage-contract.md](../skills/_shared/triage-contract.md).

## Verificacion por impacto

INIT/EXPLORE detectan capacidades reales. DESIGN/QUICK acuerdan un plan YAML de
criterios, metodos y evidencia; TASKS incluye esas comprobaciones. No se exige
build, cobertura o pruebas automatizadas solo por una etiqueta CRM/CMS/framework.

Se ejecutan checks focales por impacto, ampliando por dependencias/riesgo o gates
obligatorios. Se aceptan evidencias ejecutadas de pruebas, API, CLI, navegador y
comprobaciones manuales documentadas. Inspeccion estatica no prueba runtime.

Si falla una prueba, despues de reparar se repite esa prueba y los checks afectados
por la reparacion. Resultados PASS independientes y vigentes se conservan. No se
repite toda la suite automaticamente; una ampliacion debe justificar impacto o
una obligacion explicita de ejecucion completa fresca.

VERIFY distingue fallo, bloqueo, pendiente y no aplicable. Solo archive_ready con
evidencia vigente, tareas completas y obligaciones satisfechas habilita ARCHIVE.
Cobertura/TDD no se activan por defecto; se respetan gates existentes y excepciones
autorizadas por cambio. Nunca se fabrica RED para tareas documentales.

Detalles: [validation.md](validation.md) y contrato operativo
[validation-contract.md](../skills/_shared/validation-contract.md).

## Cierre y recuperacion

Antes de la verificacion final, ejecutar normalizacion que modifica fuentes.
VERIFY usa comandos check-only; una mutacion posterior invalida evidencia
dependiente y requiere comprobaciones afectadas, sin repetir todo por defecto.
Un fallo solo se atribuye al baseline con reproduccion comparable aislada.
Esto no convierte un check obligatorio fallido en PASS ni permite archivo.

ARCHIVE consolida requisitos vigentes por dominio, preserva contenido no afectado
y guarda el historial en el cambio archivado. Prepara todos los merges y usa un
journal recuperable; no cierra con conflicto o verificacion pendiente.

Reintentos transitorios: uno por intento de fase, reconciliando outputs validos
antes de repetir. No restaurar ciegamente fase ni descartar trabajo completado.
Invalidaciones y correcciones SPEC-FIX/DESIGN-FIX se registran y se comprueba
coherencia de propuesta, specs, diseno, tareas y obligaciones antes de verificar.

Auditoria YAML compacta; informes anteriores se conservan como evidencia legacy.
Contratos: [persistence.md](persistence.md), [validation.md](validation.md).

## Investigacion y entrega opcionales

EXPLORE/diseno puede investigar preguntas externas concretas con fuentes y
vacios visibles; no agrega una fase obligatoria. Commits, issues y PR se preparan
solo cuando se solicita entrega, conservando rama y autorizacion vigentes.
No hay issue aprobada, etiquetas o limite de 400 lineas universales. Las unidades
de revision agrupan comportamiento, checks y documentacion relacionados.

Contratos: [research-contract.md](../skills/_shared/research-contract.md),
[delivery-contract.md](../skills/_shared/delivery-contract.md).

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
- `INTAKE` (`flow-nea-initiative-intake`): lee SOLO `sources/` (ignora
  `resources/`), con degradacion gracil — errores de encoding (no UTF-8) o
  formatos binarios NO rompen la fase; se clasifican (`encoding` /
  `unsupported-format` / `empty`) y se listan en `intake/needs-review.md` para que
  un humano los arregle. Consolida `intake.md` (incl. `## Glosario`) +
  `source-index.md`. Activa el gate de revision humana antes de SPEC. No fabrica.
- `SPEC` (`flow-nea-initiative-spec`): escribe specs generales detalladas
  (Features de Azure con capacidades `CAP-xxx`). No escribe HU ni impact-map.
- `HU` (`flow-nea-initiative-hu`): descompone los Features en Historias de
  Usuario, **una carpeta por HU** (`specs/{domain}/hu/HU-xxx/` con `HU-xxx.md` +
  `assets/.gitkeep`), mantiene la TOC en el Feature spec, marca las HU que
  requieren arquitecto y/o disenador, marca `blocked` + `blockers[]` las que
  dependen de un gap `[CRITICAL]`, y emite el `impact-map.yaml` (schema 2.2). En
  re-run ACTUALIZA por identidad (bump `revision`), no duplica. La usa PMO; por lotes.
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
