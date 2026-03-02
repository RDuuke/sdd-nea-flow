# tdd-nea-flow

Plantilla base agnostica de editor para operar un flujo SDD (Spec-Driven
Development) con skills de nea-flow y artefactos OpenSpec. Incluye orquestador,
ejemplos por editor y scripts de integracion para incorporar el flujo en otros
proyectos.

Version: 1.0.1

## Que es

Este repo empaqueta un flujo completo de trabajo con agentes y una base
agnostica de editor para:

- Explorar un cambio
- Proponer el alcance
- Definir especificaciones
- Disenar la solucion
- Planificar tareas
- Implementar
- Verificar
- Archivar

El objetivo es mantener trazabilidad y consistencia entre idea, specs y codigo.

## Flujo (nea-flow)

Los comandos del flujo son:

- /flow-nea-init
- /flow-nea-explore <topic>
- /flow-nea-new <change-name>
- /flow-nea-propose <change-name>
- /flow-nea-spec <change-name>
- /flow-nea-design <change-name>
- /flow-nea-tasks <change-name>
- /flow-nea-apply <change-name>
- /flow-nea-verify <change-name>
- /flow-nea-archive <change-name>
- /flow-nea-ff <change-name>
- /flow-nea-continue <change-name>

No hay alias del flujo anterior. El unico flujo soportado es nea-flow.

## Dependencias

- OpenCode o Amazon Q
- Plugin o integracion de cada editor para orquestacion de skills
- PowerShell (para scripts de integracion)

## Arquitectura

La plantilla se organiza en capas:

- Orquestacion: reglas del flujo y comandos por editor
- Skills: fases del flujo y utilidades compartidas
- Artefactos: OpenSpec con specs, cambios y archivos de soporte
- Integracion: scripts para instalar la plantilla en un proyecto objetivo

## Backend de artefactos

Por defecto se usa OpenSpec como backend de artefactos.

## Estructura del repo

- .opencode/opencode.json: orquestador nea-flow (OpenCode)
- skills/: skills nea-flow y shared
- .opencode/package.json: dependencia @opencode-ai/plugin
- openspec/: template de artefactos (config.yaml, specs/, changes/archive/)
- examples/opencode/: configuracion base para OpenCode
- examples/amazonq/: configuracion base para Amazon Q
- examples/vscode/: configuracion base para VS Code
- scripts/: integracion automatizada

## Uso rapido

PowerShell:

```powershell
.\scripts\integrate-opencode.ps1 -Target "C:\path\to\project"
```

El script copia archivos del template al proyecto destino.

## OpenCode

- Copia el contenido de `.opencode/` al proyecto que va a usar OpenCode.
- Copia la carpeta `skills/` en la raiz del proyecto.
- Ver ejemplo en `examples/opencode/opencode.json`.

## Amazon Q

La integracion para Amazon Q usa el mismo flujo nea-flow y los mismos skills.
Ver ejemplo en `examples/amazonq/agent.js`.

## Artifact Persistence (Optional)

When openspec mode is enabled, a change can produce a self-contained folder:

```
openspec/
├── config.yaml                        <- Project context (stack, conventions)
├── specs/                             <- Source of truth: how the system works TODAY
│   ├── auth/spec.md
│   ├── export/spec.md
│   └── ui/spec.md
└── changes/
    ├── add-csv-export/                <- Active change
    │   ├── proposal.md                <- WHY + SCOPE + APPROACH
    │   ├── specs/                     <- Delta specs (ADDED/MODIFIED/REMOVED)
    │   │   └── export/spec.md
    │   ├── design.md                  <- HOW (architecture decisions)
    │   └── tasks.md                   <- WHAT (implementation checklist)
    └── archive/                       <- Completed changes (audit trail)
        └── 2026-02-16-fix-auth/
```

## Notas

- Usa ASCII en archivos nuevos.
- No incluir secretos en la configuracion.
