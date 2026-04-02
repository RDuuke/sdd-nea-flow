<p align="center">
  <img src="assets/logo.png" alt="SSD NEA FLOW logo" width="240" />
</p>

# SSD NEA FLOW

**Orquestacion de equipos de agentes con sub-agentes IA**

> Un orquestador + sub-agentes especializados para desarrollo estructurado.
> Cero dependencias. Solo Markdown. Funciona en cualquier lugar.

Version: 1.5.0

Links rapidos: [Indice](#indice) • [Instalacion](#instalacion) • [OpenCode](#opencode) • [Amazon Q](#amazon-q) • [Gemini CLI](#gemini-cli) • [Codex](#codex) • [Claude Code](#claude-code) • [VS Code](#vs-code)

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
- [Claude Code](#claude-code)
- [VS Code](#vs-code)
- [Persistencia de artefactos](#persistencia-de-artefactos)
- [Especificaciones delta](#especificaciones-delta)
- [Palabras clave RFC 2119](#palabras-clave-rfc-2119)
- [Ciclo de archivo](#ciclo-de-archivo)
- [Contrato de respuesta de sub-agentes](#contrato-de-respuesta-de-sub-agentes)
- [Glosario](#glosario)
- [Skills adicionales](#skills-adicionales)
- [Troubleshooting](#troubleshooting)
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
- /flow-nea-explore <change-name>
- /flow-nea-propose <change-name>
- /flow-nea-spec <change-name>
- /flow-nea-design <change-name>
- /flow-nea-tasks <change-name>
- /flow-nea-apply <change-name>
- /flow-nea-verify <change-name>
- /flow-nea-archive <change-name>

Meta-comandos (manejados por el orquestador):

- /flow-nea-ff <change-name> — atajo: lanza propose → spec → design → tasks en secuencia
- /flow-nea-continue <change-name> — reanuda desde la proxima fase pendiente segun `.status.yaml`
- /flow-nea-judgment <change-name> — revision dual ciega en paralelo (dos jueces independientes)

No hay alias del flujo anterior. El unico flujo soportado es nea-flow.

## Requisitos

- OpenCode, Amazon Q, Gemini CLI, Codex o Claude Code
- Integracion del editor para orquestacion de skills
- PowerShell (para scripts de integracion en Windows)

## Estructura del repo

- skills/flow-nea-*/: skills de cada fase del flujo
- skills/judgment-day/: revision dual ciega en paralelo
- skills/skill-registry/: genera indice compacto de skills para el orquestador
- skills/skill-creator/: crea nuevas skills a partir de una descripcion
- skills/_shared/: contratos y reglas compartidas entre skills
- examples/opencode/: configuracion nativa multi-agente para OpenCode
- examples/amazonq/: configuracion base para Amazon Q
- examples/vscode/: configuracion base para VS Code
- examples/gemini-cli/: configuracion base para Gemini CLI
- examples/codex/: configuracion base para Codex
- examples/claude-code/: configuracion base para Claude Code
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

- OpenCode — Multi-agentes nativos (orquestador + sub-agentes dedicados por fase)
- Amazon Q — Soporta sub-agentes via Task tool
- Gemini CLI — Ejecuta skills inline (sin sub-agentes reales)
- Codex — Ejecuta skills inline (sin sub-agentes reales)
- Claude Code — Soporta sub-agentes via Agent tool
- VS Code (Copilot) — Modo agente con archivos de contexto

Links rapidos:
- [OpenCode](#opencode)
- [Amazon Q](#amazon-q)
- [Gemini CLI](#gemini-cli)
- [Codex](#codex)
- [Claude Code](#claude-code)
- [VS Code (Copilot)](#vs-code)

## OpenCode

OpenCode soporta multi-agentes nativos: el orquestador delega a sub-agentes
especializados con `delegate` tool. Cada fase corre en un agente separado con
contexto fresco.

1. Copiar las skills

```bash
# Usando el instalador (recomendado — instala tambien judgment-day, skill-registry, skill-creator)
./scripts/install.sh  # Opcion 1: OpenCode

# O manualmente (global)
mkdir -p ~/.config/opencode/skills
cp -r skills/flow-nea-* ~/.config/opencode/skills/
cp -r skills/judgment-day ~/.config/opencode/skills/
cp -r skills/skill-registry ~/.config/opencode/skills/
cp -r skills/skill-creator ~/.config/opencode/skills/
cp -r skills/_shared ~/.config/opencode/skills/
```

2. Elegir variante de configuracion

Hay dos variantes en `examples/opencode/`:

| Archivo | Modelos | Cuando usarlo |
|---------|---------|---------------|
| `opencode.multi.json` | opus para arquitectura, sonnet para ejecucion, haiku para archive | Maximo rendimiento por fase |
| `opencode.single.json` | mismo modelo para todo | Simplicidad o proveedor con un solo modelo |

Ambas incluyen `AGENTS.md` como prompt del orquestador via `{file:./AGENTS.md}`.

3. Instalar la configuracion

```bash
# Usando el instalador (te pregunta que variante quieres)
./scripts/install.sh  # Opcion 1: OpenCode

# O manualmente: fusiona el bloque "agent" en ~/.config/opencode/config.json
# El instalador usa jq para preservar tu configuracion existente
```

El instalador copia `AGENTS.md` a `~/.config/opencode/` y fusiona solo los
agentes `flow-nea-*`, `judgment-day` y `skill-registry`, sin tocar tus otros agentes.

4. Verificar

Abre OpenCode y ejecuta `/flow-nea-init`. Debe reconocer el comando.

Como usar en OpenCode:

- Inicia OpenCode en tu proyecto: `opencode`
- El agente `flow-nea-orchestrator` esta disponible como agente primario
- Ejecuta comandos: `/flow-nea-init`, `/flow-nea-ff <name>`, `/flow-nea-apply <name>`, etc.
- Usa `/flow-nea-continue <name>` para reanudar un cambio interrumpido
- Los sub-agentes se lanzan automaticamente; no necesitas cambiar de agente manualmente

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

## Claude Code

Claude Code (CLI de Anthropic) soporta delegacion real de sub-agentes via Agent tool,
lo que permite que cada fase del flujo se ejecute con contexto fresco.

1. Copiar las skills

```bash
# Usando el instalador
./scripts/install.sh  # Opcion 6: Claude Code

# O manualmente (local al proyecto)
mkdir -p .claude/skills
cp -r skills/flow-nea-* .claude/skills/
cp -r skills/_shared .claude/skills/
```

2. Copiar los comandos (slash commands)

```bash
mkdir -p .claude/commands
cp examples/claude-code/commands/*.md .claude/commands/
```

3. Agregar el orquestador a `CLAUDE.md`

Copia el contenido de `examples/claude-code/CLAUDE.md` al archivo `CLAUDE.md` en la
raiz del proyecto (o a `~/.claude/CLAUDE.md` para uso global).

4. Verificar

Abre Claude Code y ejecuta `/flow-nea-init`. Debe reconocer el comando.

Como usar en Claude Code:

- Abre Claude Code en tu proyecto: `claude`
- Los comandos se registran automaticamente desde `.claude/commands/`
- Ejecuta comandos: `/flow-nea-init`, `/flow-nea-propose <name>`, `/flow-nea-apply`, etc.
- El Agent tool lanza sub-agentes con contexto fresco para cada fase

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
  "status": "ok | warning | failed",
  "executive_summary": "short decision-grade summary",
  "detailed_report": "optional long-form analysis when needed",
  "artifacts": [
    {
      "name": "design",
      "path": "openspec/changes/{change-name}/design.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "TASKS",
  "risks": ["optional risk list"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```

`executive_summary` es intencionalmente breve. `detailed_report` se usa cuando
el analisis es complejo o requiere contexto adicional. `skill_resolution` le
indica al orquestador si la skill llego correctamente al sub-agente; si no es
`injected`, el orquestador re-inyecta las compact rules en la siguiente delegacion.

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

## Skills adicionales

Ademas de las skills de fases, el flujo incluye tres skills de soporte:

### judgment-day

Revision dual ciega en paralelo. Dos jueces analizan el mismo artefacto de
forma independiente y el orquestador sintetiza los resultados.

Trigger: `/flow-nea-judgment <change-name>`

Resultado: `Confirmed` (ambos de acuerdo), `Suspect A/B` (uno detecta un problema) o
`Contradiction` (visiones opuestas — requiere decision del usuario).

### skill-registry

Genera un indice compacto de todas las skills disponibles (5-15 lineas por skill)
en `.atl/skill-registry.md`. El orquestador lo usa para inyectar las reglas
de cada fase sin leer el SKILL.md completo, reduciendo el uso de contexto.

El instalador puede ejecutar esta skill automaticamente tras la instalacion.

### skill-creator

Crea nuevas skills siguiendo el formato y contratos del flujo a partir de una
descripcion del comportamiento esperado.

Util para extender el flujo con skills propias sin tener que escribir el
boilerplate manualmente.

## Troubleshooting

Problemas comunes y como resolverlos:

### .status.yaml corrupto o inconsistente

Si el archivo `.status.yaml` tiene datos invalidos o la fase no coincide con
los artefactos existentes:

1. Elimina `openspec/changes/.status.yaml`
2. Ejecuta `/flow-nea-continue <change-name>`
3. El sistema inferira la fase correcta a partir de los artefactos existentes

### Sub-agente devuelve JSON malformado

Si el orquestador reporta una respuesta incompleta:

1. Reintenta el comando (el orquestador reintenta automaticamente una vez)
2. Si persiste, ejecuta la fase manualmente: `/flow-nea-{fase} <change-name>`
3. Verifica que el SKILL.md correspondiente existe y es accesible

### Flujo bloqueado en una fase

Si el flujo no avanza y no hay error claro:

1. Revisa `.status.yaml` para ver el estado actual
2. Verifica que `awaiting_approval` no este en `true` (requiere confirmacion)
3. Revisa `pending_tasks` para ver si hay tareas sin completar
4. Usa `/flow-nea-continue <change-name>` para reanudar

### Skills no encontradas tras instalacion

Si los comandos `/flow-nea-*` no se reconocen:

1. Verifica que las skills estan en la ruta correcta para tu herramienta
2. Reinicia tu herramienta (algunos editores cachean los comandos)
3. Ejecuta el instalador de nuevo con `--agent <tu-herramienta>`

### Conflicto entre dos cambios activos

El flujo soporta un solo cambio activo a la vez. Si necesitas trabajar en otro:

1. Archiva o abandona el cambio actual: `/flow-nea-archive <change-actual>`
2. O renombra manualmente la carpeta en `openspec/changes/` y elimina `.status.yaml`
3. Inicia el nuevo cambio normalmente

### Reset completo del flujo

Para reiniciar desde cero (pierde todo el progreso del cambio actual):

1. Elimina la carpeta `openspec/changes/<change-name>/`
2. Elimina `openspec/changes/.status.yaml`
3. Ejecuta `/flow-nea-propose <change-name>` para empezar de nuevo

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
