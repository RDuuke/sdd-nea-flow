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
  sources/01..06/            # input humano (read-only para las skills)
  initiative/
    config.yaml              # identidad + mapeo Azure + gates + target_projects
    .status.yaml             # estado (schema 1.0: INIT | INTAKE | SPEC)
    intake/intake.md         # digest consolidado de las 6 subcarpetas
    intake/source-index.md   # inventario auditable + legibilidad
    specs/{domain}/spec.md   # specs generales = Features de Azure
    impact-map.yaml          # costura: Features -> HU candidatas por cl00xx
    .execution-log.md
```

Reglas clave:

- Modo `initiative`: escritura solo dentro de `initiative/`. Lectura permitida en
  `sources/` y referencia read-only a los proyectos cl00xx registrados.
- Estado en `initiative/.status.yaml`, nunca en `openspec/changes/.status.yaml`.
- `impact-map.yaml` es el unico artefacto que consume el futuro pipeline de
  descomposicion; cada `change_candidate` es una HU ligada a un proyecto cl00xx,
  o queda en `unmapped_scope`. Esta capa nunca siembra changes en los proyectos.
- Mapeo conceptual a Azure (solo metadata): iniciativa ≈ Epic, spec = Feature,
  change candidato = Historia de Usuario.

## Lo que no pertenece a este repo

No debe existir una carpeta `openspec/` ni `initiative/` mantenida manualmente en
este repo plantilla. `openspec/` pertenece a los proyectos destino donde corre el
flujo de cambios; `initiative/` pertenece a cada repositorio de iniciativa.
