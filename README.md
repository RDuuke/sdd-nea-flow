<p align="center">
  <img src="assets/logo.png" alt="SSD NEA FLOW logo" width="240" />
</p>

# SSD NEA FLOW

**Orquestacion de equipos de agentes con sub-agentes IA**

> Un orquestador + sub-agentes especializados para desarrollo estructurado.
> Cero dependencias. Solo Markdown. Funciona en cualquier lugar.

Version: 1.0.2

Links rapidos: [El Problema](#el-problema) • [La Solucion](#la-solucion) • [Arquitectura](#arquitectura) • [Flujo nea-flow](#flujo-nea-flow) • [Instalacion](#instalacion) • [OpenCode](#opencode) • [Amazon Q](#amazon-q) • [VS Code](#vs-code)

## Indice

- [El Problema](#el-problema)
- [La Solucion](#la-solucion)
- [Arquitectura](#arquitectura)
- [Que es](#que-es)
- [Flujo nea-flow](#flujo-nea-flow)
- [Dependencias](#dependencias)
- [Estructura del repo](#estructura-del-repo)
- [Uso rapido](#uso-rapido)
- [Instalacion](#instalacion)
- [OpenCode](#opencode)
- [Amazon Q](#amazon-q)
- [VS Code](#vs-code)
- [Artifact Persistence (Default)](#artifact-persistence-default)
- [Delta Specs](#delta-specs)
- [RFC 2119 Keywords](#rfc-2119-keywords)
- [The Archive Cycle](#the-archive-cycle)
- [Contrato de respuesta de sub-agentes](#contrato-de-respuesta-de-sub-agentes)
- [Contributing](#contributing)
- [Notas](#notas)

## El Problema

Los asistentes de codigo son potentes, pero fallan en features complejas:

- Context overload: conversaciones largas llevan a compresion, perdida de detalles y alucinaciones
- No structure: "Build me dark mode" produce resultados impredecibles
- No review gate: se escribe codigo antes de acordar que se va a construir
- No memory: las specs viven en el chat y se pierden

## La Solucion

NEA Flow es un patron de orquestacion de equipos de agentes donde un
coordinador liviano delega el trabajo a sub-agentes especializados. Cada
sub-agente inicia con contexto fresco, ejecuta una tarea puntual y devuelve
un resultado estructurado.

Ejemplo (nea-flow):

YOU: "Quiero agregar exportacion CSV"

ORQUESTADOR (solo delega, contexto minimo):

- Lanza sub-agente EXPLORE -> devuelve analisis del codebase
- Muestra resumen y pide aprobacion
- Lanza sub-agente PROPOSE -> devuelve artefacto proposal
- Lanza sub-agente SPEC -> devuelve artefacto spec
- Lanza sub-agente DESIGN -> devuelve artefacto design
- Lanza sub-agente TASKS -> devuelve artefacto tasks
- Muestra todo y pide aprobacion
- Lanza sub-agente APPLY -> devuelve codigo implementado y tareas cerradas
- Lanza sub-agente VERIFY -> devuelve artefacto verify
- Lanza sub-agente ARCHIVE -> devuelve cambio archivado

Insight clave: el orquestador NUNCA hace trabajo de fases directamente. Solo
coordina sub-agentes, mantiene estado y sintetiza resultados. Esto mantiene el
hilo principal estable y con contexto pequeno.

## Arquitectura

```
┌──────────────────────────────────────────────────────────┐
│  ORCHESTRATOR (agente principal)                          │
│                                                          │
│  Responsibilities:                                       │
│  • Detect when SDD is needed                             │
│  • Launch sub-agents via Task tool                       │
│  • Show summaries to user                                │
│  • Ask for approval between phases                       │
│  • Track state: which artifacts exist, what's next       │
│                                                          │
│  Context usage: MINIMAL (only state + summaries)         │
└──────────────┬───────────────────────────────────────────┘
               │
               │ Task(subagent_type: 'general', prompt: 'Read skill...')
               │
    ┌──────────┴──────────────────────────────────────────┐
    │                                                      │
    ▼          ▼          ▼         ▼         ▼           ▼          ▼          ▼
┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐
│EXPLORE ││PROPOSE ││  SPEC  ││ DESIGN ││ TASKS  ││ APPLY  ││ VERIFY ││ ARCHIVE│
│        ││        ││        ││        ││        ││        ││        ││        │
│ Fresh  ││ Fresh  ││ Fresh  ││ Fresh  ││ Fresh  ││ Fresh  ││ Fresh  ││ Fresh  │
│context ││context ││context ││context ││context ││context ││context ││context │
└────────┘└────────┘└────────┘└────────┘└────────┘└────────┘└────────┘└────────┘
```

The Dependency Graph

```
                    proposal
                   (root node)
                       │
         ┌─────────────┴─────────────┐
         │                           │
         ▼                           ▼
      specs                       design
   (requirements                (technical
    + scenarios)                 approach)
         │                           │
         └─────────────┬─────────────┘
                       │
                       ▼
                    tasks
                (implementation
                  checklist)
                       │
                       ▼
                    apply
                (write code)
                       │
                       ▼
                    verify
               (quality gate)
                       │
                       ▼
                   archive
              (merge specs,
               close change)
```

## Que es

Plantilla base agnostica de editor para operar un flujo SDD (Spec-Driven
Development) con skills de nea-flow y artefactos OpenSpec. Incluye orquestador,
ejemplos por editor y scripts de integracion para incorporar el flujo en otros
proyectos.

## Flujo nea-flow

Los comandos del flujo son:

- /flow-nea-init
- /flow-nea-explore <topic>
- /flow-nea-propose <change-name>
- /flow-nea-spec <change-name>
- /flow-nea-design <change-name>
- /flow-nea-tasks <change-name>
- /flow-nea-apply <change-name>
- /flow-nea-verify <change-name>
- /flow-nea-archive <change-name>

No hay alias del flujo anterior. El unico flujo soportado es nea-flow.

## Dependencias

- OpenCode o Amazon Q
- Plugin o integracion de cada editor para orquestacion de skills
- PowerShell (para scripts de integracion)

## Estructura del repo

- skills/: skills nea-flow y shared
- examples/opencode/: configuracion base para OpenCode
- examples/amazonq/: configuracion base para Amazon Q
- examples/vscode/: configuracion base para VS Code
- scripts/: instalacion automatizada

## Uso rapido

1. Instalar las skills

```bash
git clone https://github.com/RDuuke/sdd-nea-flow.git
cd sdd-nea-flow
./scripts/install.sh
```

El instalador pregunta que herramienta usas y copia las skills al lugar correcto.

2. Agregar el orquestador a tu agente

Ver la seccion [Instalacion](#instalacion) segun tu herramienta.

Luego ve a: [OpenCode](#opencode)

## Instalacion

Guia de instalacion por herramienta soportada:

- OpenCode — Full sub-agent support via Task tool
- Amazon Q — Full sub-agent support via Task tool
- VS Code (Copilot) — Agent mode with context files

Links rapidos:
- [OpenCode](#opencode)
- [Amazon Q](#amazon-q)
- [VS Code (Copilot)](#vs-code)

## OpenCode

1. Copiar las skills

```bash
# Usando el instalador
./scripts/install.sh  # Opcion 1: OpenCode

# O manualmente (local al proyecto)
mkdir -p .opencode/skills
cp -r skills/flow-nea-* .opencode/skills/
cp -r skills/_shared .opencode/skills/
```

2. Agregar el orquestador a `.opencode/opencode.json`

Fusiona el bloque `agent` desde `examples/opencode/opencode.json`.

Puedes:
- Agregarlo a tu agente actual (anexar las instrucciones al prompt principal)
- Crear un agente dedicado (usar el bloque tal cual)

Setup recomendado:
- Mantener tu asistente diario como primary
- Usar `flow-nea-orchestrator` solo cuando quieras el flujo SDD

3. Verificar

Abre OpenCode y ejecuta `/flow-nea-init`. Debe reconocer el comando.

Como usar en OpenCode:

- Inicia OpenCode en tu proyecto: `opencode .`
- Abre el selector de agente (Tab) y elige `flow-nea-orchestrator`
- Ejecuta comandos: `/flow-nea-init`, `/flow-nea-propose <name>`, `/flow-nea-apply`, etc.
- Vuelve a tu agente normal (Tab) para el trabajo diario

## Amazon Q

1. Copiar las skills

```bash
# Usando el instalador
./scripts/install.sh  # Opcion 2: Amazon Q

# O manualmente
mkdir -p .amazonq/rules
cp -r skills/flow-nea-* .amazonq/rules/
cp -r skills/_shared .amazonq/rules/
```

2. Agregar el prompt

Copia el archivo de prompt a la ruta de Amazon Q en tu perfil:

```bash
mkdir -p ~/.aws/amazonq/prompts
cp examples/amazonq/amazon-instructions.md ~/.aws/amazonq/prompts/amazon-instructions.md
```

## VS Code

VS Code soporta MCP e instrucciones personalizadas de forma nativa. Las skills
funcionan con el modo agente de Copilot y cualquier extension compatible con MCP.

1. Copiar las skills al workspace

```bash
# Por proyecto (recomendado)
cp -r skills/flow-nea-* ./tu-proyecto/.vscode/skills/
cp -r skills/_shared ./tu-proyecto/.vscode/skills/

# O usando el instalador
./scripts/install.sh  # Opcion 3: VS Code
```

2. Agregar instrucciones del orquestador

Crea un archivo `copilot-instructions.md` en la carpeta de prompts del usuario
y copia el contenido desde `examples/vscode/copilot-instructions.md`.

Ruta recomendada de prompts:

- macOS: `~/Library/Application Support/Code/User/prompts/sdd-orchestrator.instructions.md`
- Linux: `~/.config/Code/User/prompts/sdd-orchestrator.instructions.md`
- Windows: `%APPDATA%\Code\User\prompts\sdd-orchestrator.instructions.md`

Alternativa con Custom Instructions:

- Abre Settings (Cmd+, / Ctrl+,)
- Busca `github.copilot.chat.codeGeneration.instructions`
- Agrega las instrucciones del orquestador

Si tambien configuras MCP a nivel usuario:

- macOS: `~/Library/Application Support/Code/User/mcp.json`
- Linux: `~/.config/Code/User/mcp.json`
- Windows: `%APPDATA%\Code\User\mcp.json`

3. Verificar

Abre VS Code, abre el Chat (Ctrl+Cmd+I / Ctrl+Alt+I) y ejecuta `/flow-nea-init`.

Nota: VS Code Copilot soporta modo agente con tool use. Las skills funcionan
como archivos de contexto. Para delegacion real de sub-agentes con contexto
fresco, usa OpenCode.

## Artifact Persistence (Default)

OpenSpec es el mecanismo por defecto. Cada cambio produce un folder
auto-contenido:

```
openspec/
├── config.yaml                        <- Project context (stack, conventions)
├── specs/                             <- Source of truth: how the system works TODAY
│   ├── auth/spec.md
│   ├── export/spec.md
│   └── ui/spec.md
└── changes/
    ├── add-csv-export/                <- Active change
    │   ├── exploration.md             <- Analysis and discovery (optional)
    │   ├── proposal.md                <- WHY + SCOPE + APPROACH
    │   ├── specs/                     <- Delta specs (ADDED/MODIFIED/REMOVED)
    │   │   └── export/spec.md
    │   ├── design.md                  <- HOW (architecture decisions)
    │   ├── tasks.md                   <- WHAT (implementation checklist)
    │   └── verify-report.md           <- Verification results
    └── archive/                       <- Completed changes (audit trail)
        └── 2026-02-16-fix-auth/
```

## Delta Specs

En lugar de reescribir specs completas, cada cambio describe solo la diferencia:

```md
## ADDED Requirements

### Requirement: CSV Export
The system SHALL support exporting data to CSV format.

#### Scenario: Export all observations
- GIVEN the user has observations stored
- WHEN the user requests CSV export
- THEN a CSV file is generated with all observations
- AND column headers match the observation fields

## MODIFIED Requirements

### Requirement: Data Export
The system SHALL support multiple export formats.
(Previously: The system SHALL support JSON export.)
```

Cuando el cambio se archiva, estos deltas se fusionan automaticamente con las
specs principales.

## RFC 2119 Keywords

Las specs usan un lenguaje estandarizado para la fuerza de cada requerimiento:

Keyword | Meaning
--- | ---
MUST / SHALL | Absolute requirement
SHOULD | Recommended, exceptions may exist
MAY | Optional

## The Archive Cycle

1. Specs describen el comportamiento actual
2. Los cambios proponen modificaciones (como deltas)
3. La implementacion vuelve reales los cambios
4. Archive fusiona los deltas en las specs
5. Las specs describen el nuevo comportamiento
6. El siguiente cambio parte de specs actualizadas

## Contrato de respuesta de sub-agentes

Cada sub-agente responde con un payload estructurado. El contenido es flexible
segun la complejidad, pero siempre mantiene esta forma base:

```json
{
  "status": "ok | warning | blocked | failed",
  "executive_summary": "short decision-grade summary",
  "detailed_report": "optional long-form analysis when needed",
  "artifacts": [
    {
      "name": "design",
      "store": "engram | openspec | none",
      "ref": "observation-id | file-path | null"
    }
  ],
  "next_recommended": ["tasks"],
  "risks": ["optional risk list"]
}
```

`executive_summary` es intencionalmente breve. `detailed_report` se usa cuando
el analisis es complejo o requiere contexto adicional.

## Contributing

PRs bienvenidos. Las skills son Markdown y faciles de mejorar.

Para agregar un nuevo sub-agente:

1. Crear `skills/flow-nea-{name}/SKILL.md` siguiendo el formato existente
2. Agregarlo al grafo de dependencias en las instrucciones del orquestador
3. Actualizar ejemplos y README

Para mejorar un sub-agente existente:

1. Editar el `SKILL.md` directamente
2. Probar ejecutando nea-flow en un proyecto real
3. Enviar PR con ejemplos antes/despues

## Notas

- Usa ASCII en archivos nuevos.
- No incluir secretos en la configuracion.
