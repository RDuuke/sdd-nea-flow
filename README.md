<p align="center">
  <img src="assets/logo.png" alt="SSD NEA FLOW logo" width="240" />
</p>

# SSD NEA FLOW

**Orquestacion de equipos de agentes con sub-agentes IA**

> Un orquestador + sub-agentes especializados para desarrollo estructurado.
> Cero dependencias. Solo Markdown. Funciona en cualquier lugar.

Version: 1.1.1

Links rapidos: [Indice](#indice) • [Instalacion](#instalacion) • [OpenCode](#opencode) • [Amazon Q](#amazon-q) • [Gemini CLI](#gemini-cli) • [Codex](#codex) • [VS Code](#vs-code)

## Indice

- [El Problema](#el-problema)
- [La Solucion](#la-solucion)
- [Que es](#que-es)
- [Arquitectura](#arquitectura)
- [Flujo nea-flow](#flujo-nea-flow)
- [Requisitos](#requisitos)
- [Estructura del repo](#estructura-del-repo)
- [Instalacion](#instalacion)
- [Instalacion por herramienta](#instalacion-por-herramienta)
- [OpenCode](#opencode)
- [Amazon Q](#amazon-q)
- [Gemini CLI](#gemini-cli)
- [Codex](#codex)
- [VS Code](#vs-code)
- [Persistencia de artefactos](#persistencia-de-artefactos)
- [Especificaciones delta](#especificaciones-delta)
- [Palabras clave RFC 2119](#palabras-clave-rfc-2119)
- [Ciclo de archivo](#ciclo-de-archivo)
- [Contrato de respuesta de sub-agentes](#contrato-de-respuesta-de-sub-agentes)
- [Glosario](#glosario)
- [Contribuir](#contribuir)
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

## Que es

Plantilla base agnostica de editor para operar un flujo SDD (Spec-Driven
Development) con skills de nea-flow y artefactos OpenSpec. Incluye orquestador,
ejemplos por editor y scripts de integracion para incorporar el flujo en otros
proyectos.

## Arquitectura

```
┌──────────────────────────────────────────────────────────┐
│  ORCHESTRATOR (agente principal)                          │
│                                                          │
│  Responsabilidades:                                      │
│  • Detectar cuando SDD es necesario                      │
│  • Lanzar sub-agentes via Task tool                      │
│  • Mostrar resumenes al usuario                          │
│  • Pedir aprobacion entre fases                          │
│  • Mantener estado de artefactos                         │
│                                                          │
│  Uso de contexto: MINIMO (solo estado + resumenes)       │
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

Grafo de dependencias

```
                    proposal
                   (nodo raiz)
                       │
         ┌─────────────┴─────────────┐
         │                           │
         ▼                           ▼
      specs                       design
   (requisitos                 (enfoque
    + escenarios)               tecnico)
         │                           │
         └─────────────┬─────────────┘
                       │
                       ▼
                    tasks
                (checklist de
                 implementacion)
                       │
                       ▼
                    apply
                (escribir codigo)
                       │
                       ▼
                    verify
               (puerta de calidad)
                       │
                       ▼
                   archive
               (fusionar specs,
                cerrar cambio)
```

## Flujo nea-flow

Comandos del flujo:

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

## Requisitos

- OpenCode, Amazon Q, Gemini CLI o Codex
- Integracion del editor para orquestacion de skills
- PowerShell (para scripts de integracion en Windows)

## Estructura del repo

- skills/: skills nea-flow y shared
- examples/opencode/: configuracion base para OpenCode
- examples/amazonq/: configuracion base para Amazon Q
- examples/vscode/: configuracion base para VS Code
- examples/gemini-cli/: configuracion base para Gemini CLI
- examples/codex/: configuracion base para Codex
- scripts/: instalacion automatizada

## Instalacion

Instalacion rapida (recomendada):

```bash
git clone https://github.com/RDuuke/sdd-nea-flow.git
cd sdd-nea-flow
./scripts/install.sh
```

El instalador pregunta que herramienta usas y copia las skills al lugar correcto.

Siguiente paso: ve a [Instalacion por herramienta](#instalacion-por-herramienta).

## Instalacion por herramienta

Guia por herramienta soportada:

- OpenCode — Soporta sub-agentes via Task tool
- Amazon Q — Soporta sub-agentes via Task tool
- Gemini CLI — Ejecuta skills inline (sin sub-agentes reales)
- Codex — Ejecuta skills inline (sin sub-agentes reales)
- VS Code (Copilot) — Modo agente con archivos de contexto

Links rapidos:
- [OpenCode](#opencode)
- [Amazon Q](#amazon-q)
- [Gemini CLI](#gemini-cli)
- [Codex](#codex)
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

1. Copiar las skills (proyecto)

```bash
# Usando el instalador
./scripts/install.sh  # Opcion 2: Amazon Q

# O manualmente
mkdir -p .amazonq/rules
cp -r skills/flow-nea-* .amazonq/rules/
cp -r skills/_shared .amazonq/rules/
```

2. Agregar el prompt (perfil del usuario)

```bash
mkdir -p ~/.aws/amazonq/prompts
cp examples/amazonq/amazonq-instructions.md ~/.aws/amazonq/prompts/amazonq-instructions.md
```

Rutas por sistema operativo:

- macOS: `~/.aws/amazonq/prompts/amazonq-instructions.md`
- Linux: `~/.aws/amazonq/prompts/amazonq-instructions.md`
- Windows: `%USERPROFILE%\.aws\amazonq\prompts\amazonq-instructions.md`

3. Verificar

Abre Amazon Q y ejecuta `/flow-nea-init`.

## Gemini CLI

1. Copiar las skills

```bash
# Usando el instalador
./scripts/install.sh  # Opcion Gemini CLI

# O manualmente (global)
mkdir -p ~/.gemini/skills
cp -r skills/flow-nea-* ~/.gemini/skills/
cp -r skills/_shared ~/.gemini/skills/

# O manualmente (local al proyecto)
mkdir -p ./.gemini/skills
cp -r skills/flow-nea-* ./.gemini/skills/
cp -r skills/_shared ./.gemini/skills/
```

2. Agregar el orquestador a `~/.gemini/GEMINI.md`

Anexa el contenido de `examples/gemini-cli/GEMINI.md` al archivo de prompt del sistema
(crealo si no existe).

Asegurate de tener `GEMINI_SYSTEM_MD=1` en `~/.gemini/.env` para que Gemini cargue el prompt.

Nota: el prompt es global (usuario), aunque las skills pueden ser locales.

3. Verificar

Abre Gemini CLI y ejecuta `/flow-nea-init`.

Nota: Gemini CLI no tiene una Task tool nativa para delegacion de sub-agentes. Las skills
se ejecutan inline y el orquestador las lee directamente.

## Codex

1. Copiar las skills

```bash
# Usando el instalador
./scripts/install.sh  # Opcion Codex

# O manualmente (global)
mkdir -p ~/.codex/skills
cp -r skills/flow-nea-* ~/.codex/skills/
cp -r skills/_shared ~/.codex/skills/

# O manualmente (local al proyecto)
mkdir -p ./.codex/skills
cp -r skills/flow-nea-* ./.codex/skills/
cp -r skills/_shared ./.codex/skills/
```

2. Agregar instrucciones del orquestador

Agrega el contenido de `examples/codex/agents.md` a `~/.codex/agents.md`
(o a tu `model_instructions_file` si lo configuraste).

Nota: el prompt es global (usuario), aunque las skills pueden ser locales.

3. Verificar

Abre Codex y ejecuta `/flow-nea-init`.

Nota: Codex ejecuta las skills inline y no crea sub-agentes reales. Las fases de
planificacion funcionan bien; el orquestador maneja la implementacion por lotes.

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

Alternativa con instrucciones personalizadas:

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

## Persistencia de artefactos

OpenSpec es el mecanismo por defecto. Cada cambio produce un folder
auto-contenido:

Nota: el contenido de todos los artefactos debe estar en espanol. Los nombres
de archivos y rutas se mantienen en ingles.

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
    │   ├── verify-report.md           <- Verification results
│   └── .status.yaml               <- Flow phase tracking
    └── archive/                       <- Completed changes (audit trail)
        └── 2026-02-16-fix-auth/
```

## Especificaciones delta

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

## Palabras clave RFC 2119

Las specs usan un lenguaje estandarizado para la fuerza de cada requerimiento:

Keyword | Meaning
--- | ---
MUST / SHALL | Absolute requirement
SHOULD | Recommended, exceptions may exist
MAY | Optional

## Ciclo de archivo

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

## Glosario

- Orquestador: agente principal que coordina fases sin implementar directamente.
- Sub-agente: agente especializado que ejecuta una fase con contexto fresco.
- Prompt: instrucciones que guian el comportamiento del agente.
- Skills: paquetes de instrucciones y reglas por fase.
- Artefactos: archivos generados por el flujo (proposal, specs, design, tasks).
- Especificaciones delta: cambios parciales que se fusionan con las specs base.
- OpenSpec: backend de artefactos y estructura de cambios.
- Task tool: herramienta para lanzar sub-agentes en paralelo o por fases.
- MCP: protocolo para integrar herramientas externas con el agente.

## Contribuir

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
