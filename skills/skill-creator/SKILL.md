---
name: skill-creator
description: >
  Creates new AI agent skills following the flow-nea skill spec.
  Trigger: When user asks to create a new skill, add agent instructions, or document patterns for AI.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Cuando crear una skill

Crear cuando:
- Un patron se usa repetidamente y el AI necesita guia
- Las convenciones del proyecto difieren de las mejores practicas genericas
- Workflows complejos necesitan instrucciones paso a paso
- Arboles de decision ayudan al AI a elegir el enfoque correcto

**No crear cuando:**
- Ya existe documentacion (crear una referencia en su lugar)
- El patron es trivial o autoexplicativo
- Es una tarea de una sola vez

---

## Estructura de una skill

```
skills/{skill-name}/
├── SKILL.md              # Requerido — archivo principal
├── assets/               # Opcional — templates, schemas, ejemplos
│   ├── template.ext
│   └── schema.json
└── references/           # Opcional — links a docs locales
    └── docs.md
```

---

## Template de SKILL.md

```markdown
---
name: {skill-name}
description: >
  {Descripcion en una linea de que hace esta skill}.
  Trigger: {Cuando el AI debe cargar esta skill}.
license: MIT
metadata:
  author: {autor}
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

{Proposito conciso}

## What You Receive

- {Input 1}
- {Input 2}

## What to Do

### Step 1: {Primer paso}

{Instrucciones}

### Step 2: {Segundo paso}

{Instrucciones}

## Rules

- {Regla critica 1}
- {Regla critica 2}

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "...",
  "artifacts": [],
  "next_recommended": "...",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
```

---

## Convenciones de nombres

| Tipo | Patron | Ejemplos |
|------|--------|----------|
| Skill generica | `{technology}` | `pytest`, `playwright` |
| Especifica del proyecto | `{project}-{component}` | `myapp-api`, `myapp-ui` |
| Workflow | `{action}-{target}` | `skill-creator`, `judgment-day` |

---

## Regla: assets/ vs references/

```
Necesitas templates de codigo?    → assets/
Necesitas schemas JSON?           → assets/
Necesitas ejemplos de config?     → assets/
Link a docs existentes?           → references/ (rutas LOCALES, no URLs web)
```

---

## Frontmatter requerido

| Campo | Requerido | Descripcion |
|-------|-----------|-------------|
| `name` | Si | Identificador (lowercase, hyphens) |
| `description` | Si | Que hace + Trigger en un bloque |
| `license` | Si | MIT |
| `metadata.author` | Si | Autor |
| `metadata.version` | Si | Version semantica como string |

---

## Checklist antes de crear

- [ ] La skill no existe ya (verificar en `skills/`)
- [ ] El patron es reutilizable (no es one-off)
- [ ] El nombre sigue las convenciones
- [ ] El frontmatter esta completo (description incluye trigger keywords)
- [ ] Los patrones criticos son claros
- [ ] Los ejemplos de codigo son minimos
- [ ] El Output Contract incluye `skill_resolution`
- [ ] Registrar en `checksums.sha256` si aplica

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Skill {name} created at skills/{name}/SKILL.md",
  "artifacts": [
    {
      "name": "{skill-name}",
      "path": "skills/{skill-name}/SKILL.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "none",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
