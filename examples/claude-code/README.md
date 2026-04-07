# Claude Code integration

Este ejemplo muestra como integrar nea-flow con Claude Code (CLI de Anthropic).

Claude Code soporta delegacion real de sub-agentes via Agent tool, lo que permite
que cada fase del flujo se ejecute con contexto fresco.

## Modos de instalacion

Hay dos formas de instalar, y se pueden combinar:

### Local (por proyecto)

Los archivos se instalan **dentro del proyecto**. Solo funcionan cuando abres
Claude Code en ese directorio. Si subes el proyecto a git, tu equipo tambien
los tendra al clonar.

```
tu-proyecto/
├── .claude/
│   ├── skills/       <- instrucciones de cada fase (solo lectura)
│   └── commands/     <- slash commands de Claude Code (solo lectura)
├── CLAUDE.md         <- comportamiento del orquestador (solo lectura)
└── openspec/         <- estado y artefactos del flujo (se escribe aqui)
```

Cuando usar local:
- Trabajas en equipo y quieres que todos tengan el flujo al clonar
- Necesitas una version especifica de las skills en este proyecto
- Quieres agregar reglas del orquestador propias del proyecto

### Global (todos los proyectos)

Los archivos se instalan en **tu directorio home** (`~/.claude/`). Funcionan
en cualquier proyecto que abras con Claude Code sin necesidad de instalar nada
en cada uno.

```
~/.claude/
├── skills/           <- instrucciones de cada fase (solo lectura)
├── commands/         <- slash commands disponibles en todo proyecto
└── CLAUDE.md         <- orquestador siempre activo
```

Cuando usar global:
- Trabajas solo o en multiples proyectos personales
- Quieres el flujo disponible siempre sin configurar cada repo
- No necesitas versionar las skills con el codigo

### Combinado (global + local)

Se pueden usar los dos juntos. Claude Code fusiona ambos: carga primero el
global, luego el del proyecto. Si hay conflicto, el proyecto gana.

Esto permite tener una base global y personalizar por proyecto:

```
~/.claude/CLAUDE.md            <- orquestador base (siempre activo)
~/.claude/commands/            <- comandos en todos los proyectos

tu-proyecto/CLAUDE.md          <- reglas adicionales de este proyecto
                                  (stack, convenciones, etc.)
```

### Importante: openspec/ siempre es local

Sin importar el modo de instalacion (global o local), `openspec/` se crea
siempre **dentro del proyecto** donde ejecutas `/flow-nea-init`. Cada proyecto
tiene su propio estado y historial. Nunca se mezclan.

```
~/proyecto-a/openspec/    <- estado y artefactos de proyecto-a
~/proyecto-b/openspec/    <- estado y artefactos de proyecto-b
```

Las instrucciones (skills, commands, CLAUDE.md) pueden ser globales.
El estado (openspec/) es siempre local al proyecto.

## Instalacion rapida

### Local (por proyecto)

```bash
# Unix/macOS
./scripts/install.sh --agent claude-code --scope local

# Windows
.\scripts\install.ps1 -Agent claude-code -Scope local
```

### Global (todos los proyectos)

```bash
# Unix/macOS
./scripts/install.sh --agent claude-code --scope global

# Windows
.\scripts\install.ps1 -Agent claude-code -Scope global
```

### Interactivo (pregunta scope)

```bash
# Unix/macOS
./scripts/install.sh --agent claude-code

# Windows
.\scripts\install.ps1 -Agent claude-code
```

## Instalacion manual

### Manual local

```bash
# Skills
mkdir -p .claude/skills
cp -r skills/flow-nea-* .claude/skills/
cp -r skills/_shared .claude/skills/

# Commands
mkdir -p .claude/commands
cp examples/claude-code/commands/*.md .claude/commands/

# Orchestrator
cp examples/claude-code/CLAUDE.md ./CLAUDE.md
```

### Manual global

```bash
# Skills
mkdir -p ~/.claude/skills
cp -r skills/flow-nea-* ~/.claude/skills/
cp -r skills/_shared ~/.claude/skills/

# Commands
mkdir -p ~/.claude/commands
cp examples/claude-code/commands/*.md ~/.claude/commands/

# Orchestrator
cp examples/claude-code/CLAUDE.md ~/.claude/CLAUDE.md
```

## Estructura resultante

### Local

```
tu-proyecto/
  .claude/
    skills/
      _shared/
        persistence-contract.md
      flow-nea-init/
        SKILL.md
      flow-nea-explore/
        SKILL.md
      ...
    commands/
      flow-nea-init.md
      flow-nea-explore.md
      flow-nea-propose.md
      flow-nea-spec.md
      flow-nea-design.md
      flow-nea-tasks.md
      flow-nea-apply.md
      flow-nea-quick.md
      flow-nea-verify.md
      flow-nea-archive.md
      flow-nea-continue.md
      flow-nea-ff.md
  CLAUDE.md          <- Instrucciones del orquestador
```

### Global

```
~/.claude/
  skills/
    _shared/
      persistence-contract.md
    flow-nea-init/
      SKILL.md
    ...
  commands/
    flow-nea-init.md
    flow-nea-explore.md
    ...
  CLAUDE.md          <- Instrucciones del orquestador
```

## Uso

1. Abre Claude Code en tu proyecto: `claude`
2. Ejecuta `/flow-nea-init` para inicializar el contexto (crea openspec/)
3. Usa los comandos del flujo:
   - `/flow-nea-explore <topic>` — investigar antes de proponer
   - `/flow-nea-quick <name>` — via rapida para un fix pequeno y de bajo riesgo
   - `/flow-nea-propose <name>` — crear propuesta
   - `/flow-nea-ff <name>` — fast-forward: propose+spec+design+tasks en secuencia
   - `/flow-nea-apply <name>` — implementar codigo
   - `/flow-nea-verify <name>` — correr tests y validar
   - `/flow-nea-archive <name>` — cerrar y archivar el cambio
   - `/flow-nea-continue <name>` — reanudar un flujo interrumpido

## Ventajas de Claude Code

- **Delegacion real**: El Agent tool lanza sub-agentes con contexto fresco (como OpenCode Task)
- **Slash commands nativos**: Los archivos en `commands/` se registran automaticamente
- **CLAUDE.md**: Instrucciones del orquestador se cargan automaticamente al iniciar
- **Global + local**: Instalar una vez, personalizar por proyecto
