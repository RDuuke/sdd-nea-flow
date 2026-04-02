# AGENTS.md — sdd-nea-flow

Instrucciones para agentes IA que trabajan en este repositorio.
Este archivo describe como esta organizado el repo, sus convenciones y como contribuir correctamente.

## Que es este repo

`sdd-nea-flow` es una libreria de skills para Spec-Driven Development (SDD) con un patron de orquestacion de sub-agentes. Contiene:

- **Skills por fase** (`skills/flow-nea-*/SKILL.md`): instrucciones ejecutables para cada fase del flujo
- **Skills de soporte** (`skills/judgment-day/`, `skills/skill-registry/`, `skills/skill-creator/`)
- **Ejemplos por herramienta** (`examples/*/`): configuracion lista para usar en cada editor/CLI
- **Scripts de instalacion** (`scripts/install.sh`, `scripts/install.ps1`)

No hay codigo de aplicacion. Todo el valor esta en los archivos Markdown.

## Estructura del repo

```
sdd-nea-flow/
├── skills/
│   ├── flow-nea-init/SKILL.md
│   ├── flow-nea-explore/SKILL.md
│   ├── flow-nea-propose/SKILL.md
│   ├── flow-nea-spec/SKILL.md
│   ├── flow-nea-design/SKILL.md
│   ├── flow-nea-tasks/SKILL.md
│   ├── flow-nea-apply/SKILL.md
│   ├── flow-nea-verify/SKILL.md
│   ├── flow-nea-archive/SKILL.md
│   ├── flow-nea-continue/SKILL.md
│   ├── judgment-day/SKILL.md
│   ├── skill-registry/SKILL.md
│   ├── skill-creator/SKILL.md
│   └── _shared/
│       └── persistence-contract.md
├── examples/
│   ├── opencode/
│   │   ├── AGENTS.md              <- prompt del orquestador para OpenCode
│   │   ├── opencode.multi.json    <- config con modelos diferenciados por fase
│   │   └── opencode.single.json   <- config con un solo modelo
│   ├── claude-code/
│   │   ├── CLAUDE.md              <- prompt del orquestador para Claude Code
│   │   └── commands/              <- slash commands (/flow-nea-*.md)
│   ├── amazonq/
│   ├── gemini-cli/
│   ├── codex/
│   └── vscode/
├── scripts/
│   ├── install.sh
│   └── install.ps1
├── README.md
└── AGENTS.md                      <- este archivo
```

## Convenciones criticas

### Idioma

- **Contenido de artefactos**: SIEMPRE en espanol (proposal.md, specs, design.md, tasks.md, verify-report.md)
- **Nombres de archivos y rutas**: SIEMPRE en ingles
- **Codigo fuente y comentarios**: seguir el idioma del proyecto destino
- **Este repo (skills, ejemplos, README)**: espanol

### Formato de skills

Cada `SKILL.md` tiene:

1. **Frontmatter YAML** con `name`, `description`, `trigger`, `license`, `metadata`
2. **## Purpose** — que hace esta skill en una oracion
3. **## What You Receive** — parametros de entrada
4. **## Execution and Persistence Contract** — leer `skills/_shared/persistence-contract.md`
5. **## What to Do** — pasos numerados (Step 1, Step 2, ...)
6. **## Rules** — restricciones y limites
7. **## Output Contract (JSON)** — envelope de retorno exacto

### Output Contract (envelope estandar)

Todas las skills retornan este JSON:

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "resumen breve para el orquestador",
  "detailed_report": "analisis opcional cuando la complejidad lo requiere",
  "artifacts": [
    {
      "name": "nombre-del-artefacto",
      "path": "ruta/relativa/al/artefacto",
      "type": "markdown | yaml | directory"
    }
  ],
  "next_recommended": "NOMBRE_SIGUIENTE_FASE",
  "risks": ["lista de riesgos o bloqueadores"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```

`skill_resolution` indica si la skill fue cargada correctamente por el sub-agente:
- `injected`: el orquestador inyecto las reglas compactas exitosamente
- `fallback-registry`: el sub-agente uso `.atl/skill-registry.md` como fallback
- `fallback-path`: el sub-agente leyo el SKILL.md directamente
- `none`: el sub-agente no encontro las instrucciones

### Budgets de tamano (no superar)

| Artefacto | Limite |
|-----------|--------|
| tasks.md | 530 palabras |
| design.md | 800 palabras |
| proposal.md | 500 palabras |
| specs/ (por dominio) | 650 palabras |

### Grafo de dependencias del flujo

```
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```

SPEC y DESIGN son independientes (ambas leen PROPOSE). TASKS requiere ambas.

## Como agregar una nueva skill

1. Crear `skills/{nombre}/SKILL.md` siguiendo el formato de frontmatter y secciones descritas arriba
2. Si la skill es una fase del flujo, agregarla al grafo de dependencias en:
   - `examples/claude-code/CLAUDE.md`
   - `examples/opencode/AGENTS.md`
   - `examples/opencode/opencode.multi.json` y `opencode.single.json`
3. Si requiere instalacion, agregar a `scripts/install.sh` y `scripts/install.ps1`
4. Actualizar `README.md`: Estructura del repo + seccion Skills adicionales si aplica

## Como modificar una skill existente

1. Leer el `SKILL.md` completo antes de editar
2. Respetar el contrato de Output (no remover campos del JSON)
3. Si se modifica el budget de tamano, actualizar la tabla de budgets en este archivo
4. Probar mentalmente contra un cambio de ejemplo antes de hacer PR

## Como modificar los scripts de instalacion

Los scripts tienen marcadores idempotentes `<!-- BEGIN:flow-nea -->` / `<!-- END:flow-nea -->`.

- La lista de skills a instalar esta en `install_skills()` (bash) y `Install-Skills` (PowerShell)
- Las funciones de OpenCode (`install_opencode_config` / `Install-OpenCodeConfig`) usan `jq` para merge inteligente
- Siempre probar que el script es idempotente: ejecutar dos veces no debe duplicar contenido

## Lo que NO hacer

- No crear archivos de documentacion extra (`.md`) fuera de los directorios existentes sin justificacion
- No agregar logica de aplicacion (codigo ejecutable que no sea shell scripts de instalacion)
- No modificar `openspec/` — esa carpeta la genera el flujo en los proyectos destino, no pertenece a este repo
- No hardcodear nombres de modelos especificos en skills (usar placeholders o dejar que el orquestador los resuelva)
- No escribir contenido de artefactos en ingles (violaria la regla de idioma)
