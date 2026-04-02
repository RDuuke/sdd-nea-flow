# Persistencia y OpenSpec

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
| `specs/` por dominio | 650 palabras |

## Cambios que fuerzan regresion de fase

Si se modifica fuera de la skill correspondiente:

- `proposal.md` -> forzar nueva fase `SPEC`
- `specs/` -> forzar nueva fase `APPLY`
- `design.md` -> forzar nueva fase `APPLY`
- `tasks.md` -> forzar nueva fase `APPLY`

## Lo que no pertenece a este repo

No debe existir una carpeta `openspec/` mantenida manualmente en este repo.
`openspec/` pertenece a los proyectos destino donde corre el flujo.
