# Persistencia y OpenSpec

## Modelo dual: OpenSpec + NeaBrain

OpenSpec y NeaBrain son complementarios. No se reemplazan.

| Responsabilidad | OpenSpec | NeaBrain |
|---|---|---|
| Artefactos de flujo (proposal, specs, design, tasks) | ✅ fuente de verdad | ❌ |
| Coordinacion de fase (.status.yaml) | ✅ | ❌ |
| Git-versionable, human-readable | ✅ | ❌ SQLite binario |
| Memoria cross-change (patrones, ADRs) | ❌ aislado por cambio | ✅ |
| Busqueda semantica entre cambios anteriores | ❌ | ✅ FTS5 |
| Contexto persistente entre sesiones | ❌ | ✅ sessions + observations |

Activar NeaBrain: `experimental.neabrain: true` en `openspec/config.yaml`.
Ver protocolo completo en `skills/_shared/persistence-contract.md`.

Instalacion: `neabrain setup claude-code --install`

## Rol de OpenSpec

OpenSpec es el backend de artefactos recomendado por `nea-flow`. Se usa para:

- mantener specs base del sistema actual
- registrar cambios activos
- guardar artefactos intermedios por fase
- permitir reanudacion, verificacion y archivo

Este repo define como usar OpenSpec, pero no lo implementa.

## Estructura esperada

```text
openspec/
├── config.yaml
├── specs/
│   └── {domain}/spec.md
└── changes/
    ├── {change-name}/
    │   ├── exploration.md
    │   ├── proposal.md
    │   ├── quick.md
    │   ├── specs/
    │   │   └── {domain}/spec.md
    │   ├── design.md
    │   ├── tasks.md
    │   ├── verify-report.md
    │   └── .execution-log.md
    ├── .status.yaml
    └── archive/
```

## Artefactos canonicos

### `proposal.md`

Explica por que existe el cambio, su alcance y el enfoque propuesto.

### `quick.md`

Artefacto minimo para la via rapida. Resume objetivo, area afectada, blueprint,
riesgos y verificacion de un fix pequeno y de bajo riesgo.

### `design.md`

Explica como se implementara el cambio a nivel tecnico.

### `tasks.md`

Descompone el trabajo en una lista ejecutable de implementacion.

### `verify-report.md`

Registra validaciones, pruebas y fallos detectados.

### `.status.yaml`

Coordina estado global del cambio. Debe representar al menos:

- cambio activo
- fase actual
- tareas pendientes
- artefactos modificados fuera del flujo
- necesidad de aprobacion

## Specs base vs specs delta

- `openspec/specs/`: describen como funciona HOY el sistema
- `openspec/changes/{change-name}/specs/`: describen solo la diferencia del cambio

Cuando el cambio se archiva, las delta specs se fusionan con las specs base.

## Presupuesto de tamano documental

Los budgets del repo siguen siendo:

| Artefacto | Limite |
| --- | --- |
| `tasks.md` | 530 palabras |
| `design.md` | 800 palabras |
| `proposal.md` | 500 palabras |
| `quick.md` | 350 palabras |
| `specs/` por dominio | 650 palabras |

## Cambios que fuerzan regresion de fase

Si se modifica fuera de la skill correspondiente:

- `proposal.md` -> forzar nueva fase `SPEC`
- `quick.md` -> forzar nueva fase `APPLY`
- `specs/` -> forzar nueva fase `APPLY`
- `design.md` -> forzar nueva fase `APPLY`
- `tasks.md` -> forzar nueva fase `APPLY`

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
