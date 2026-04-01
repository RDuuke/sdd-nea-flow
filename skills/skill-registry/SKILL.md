---
name: skill-registry
description: >
  Scan and catalog all available skills in a project into a compact registry.
  Trigger: When user requests skill registry update, after installing/removing a skill, or on first sdd-init.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Genera un skill registry (`.atl/skill-registry.md`) que cataloga todas las skills disponibles y las compacta en reglas para inyectar en prompts de sub-agentes.

## Concepto clave

**Los sub-agentes NO leen el registry ni los archivos SKILL.md individuales.** En cambio, reciben resumenes compactos de reglas pre-resueltos en su prompt de lanzamiento. Esto optimiza el contexto por agente y por sesion.

## Que hace

### Paso 1: Escanear directorios

Recorre en orden:
- User-level: `~/.claude/skills/`
- Project-level: `skills/` (en la raiz del proyecto)

### Paso 2: Excluir skills del workflow SDD/NEA

No catalogar:
- `flow-nea-explore`, `flow-nea-propose`, `flow-nea-spec`, `flow-nea-design`
- `flow-nea-tasks`, `flow-nea-apply`, `flow-nea-verify`, `flow-nea-archive`
- `flow-nea-init`, `_shared`
- El propio `skill-registry`

Estas son reservadas para coordinacion del orquestador.

### Paso 3: Extraer compact rules

Para cada skill encontrada, extraer:
- Proposito (una linea desde `description`)
- 2-5 patrones criticos o restricciones del contenido
- Trigger/contexto de uso

Formato de compact rule (5-15 lineas):
```
## {Skill Name}

- {Patron critico 1}
- {Patron critico 2}
- {Patron critico 3}
- Usar cuando: {contexto de trigger}
```

### Paso 4: Escribir `.atl/skill-registry.md`

Estructura:

```markdown
# Skill Registry

Generated: {timestamp}

## Compact Rules

{Bloques de compact rules por skill}

## Metadata

- Total skills: {N}
- Scanned: skills/, ~/.claude/skills/
- Updated: {timestamp}
```

Crear el directorio `.atl/` si no existe. Agregar `.atl/` al `.gitignore` si no esta.

### Paso 5: Return Summary

Retornar envelope con: status, executive_summary, artifacts, risks.

## Rules

- NUNCA incluir codigo de implementacion en compact rules
- Compact rules DEBEN ser concisas (5-15 lineas cada una)
- No re-escanear en cada invocacion si el registry existe y es reciente (< 1 hora)
- Si no se encuentran skills, retornar registry vacio con metadata

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Registry updated. N skills cataloged.",
  "artifacts": [
    {
      "name": "skill_registry",
      "path": ".atl/skill-registry.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "none",
  "risks": ["list of risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
