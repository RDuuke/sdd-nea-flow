---
name: flow-nea-propose
description: >
  Create a change proposal with intent, scope, and approach.
trigger: >
  When the orchestrator launches you to create or update a proposal for a change.
license: MIT
metadata:
  author: juan-duque
  version: "2.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Create a proposal that defines intent, scope, approach, risks, and rollback plan.

## What You Receive

- Change name
- Exploration analysis (or direct user description)
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Load Context

- If openspec, read openspec/changes/{change-name}/exploration.md if present.
- Read openspec/config.yaml → check `rules.proposal` for custom rules to apply.
  Apply any project-specific proposal rules on top of the defaults in this skill.

### Step 2: Create or Update proposal.md (openspec mode)

openspec/changes/{change-name}/proposal.md

Format:

# Proposal: {Change Title}

## Intent
{Problem and why}

## Scope
### In Scope
- ...

### Out of Scope
- ...

## Approach
{High-level technical approach}

## Affected Areas
| Area | Impact | Description |
|------|--------|-------------|
| src/path/to/file.ts | New/Modified/Removed | descripcion concreta |

> Usar rutas concretas de archivos, no descripciones vagas como "modulo de auth".

## Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| ... | Low/Med/High | ... |

## Rollback Plan
> OBLIGATORIO. Describir como revertir este cambio si falla en produccion.
> Minimo: que archivos restaurar, que migraciones revertir, si hay feature flags.

{Como revertir}

## Dependencies
- ...

## Success Criteria
> OBLIGATORIO. Lista de condiciones verificables que deben cumplirse para considerar este cambio exitoso.
> Cada criterio debe ser comprobable (test, metrica, comportamiento observable).

- [ ] ...

### Step 3: Persist (openspec mode)

- Save proposal to openspec/changes/{change-name}/proposal.md
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: PROPOSE
  change: "{change-name}"
  awaiting_approval: true
  completed: false
  pending_tasks: []
  modified_artifacts: []
  notes: ""
  ```

### Step 4: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- **Rollback plan es NO NEGOCIABLE.** Si no se puede definir como revertir el cambio, no avanzar — reportar como `status: blocked`.
- **Success criteria es NO NEGOCIABLE.** Si no se pueden definir criterios verificables, no avanzar — reportar como `status: blocked`.
- Usar rutas concretas de archivos en Affected Areas, no descripciones vagas.
- Aplicar reglas custom de `openspec/config.yaml → rules.proposal` si existen.
- All artifact content MUST be written in Spanish.
- **Size budget**: El artefacto proposal.md DEBE tener menos de 400 palabras. Scope conciso, no exhaustivo.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | blocked",
  "executive_summary": "Summary of proposal and scope.",
  "detailed_report": "Reasoning or persistence notes.",
  "artifacts": [
    {
      "name": "proposal",
      "path": "openspec/changes/{change-name}/proposal.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "SPEC",
  "user_approval_required": true,
  "scope_summary": {
    "added": ["list of features"],
    "modified": ["list of existing features"],
    "excluded": ["what remains out"]
  },
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
