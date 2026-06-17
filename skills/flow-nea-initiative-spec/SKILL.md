---
name: flow-nea-initiative-spec
description: >
  Synthesize general initiative specs (Azure Features) from the intake digest
  and emit impact-map.yaml (candidate User Stories per cl00xx project).
trigger: >
  When the orchestrator launches you to write initiative specs after intake is approved.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Turn the consolidated `intake.md` into **general specs** at business/product
altitude. Each spec domain is an Azure DevOps **Feature**. Then emit
`impact-map.yaml`, the seam a future change pipeline consumes to seed candidate
**User Stories (HU)** into each affected cl00xx project.

You write WHAT/WHY at initiative altitude. You never write technical detail
(endpoints, tables, classes) — that belongs to the per-project change flow.

## What You Receive

- Initiative slug
- The intake digest (`initiative/intake/intake.md`)
- Artifact store mode (`initiative` | `none`)

## Execution and Persistence Contract

Read and follow: skills/_shared/initiative-persistence-contract.md

## What to Do

### Step 1: Read Intake and Config

Read `initiative/intake/intake.md` and `initiative/config.yaml`. If
`intake.md` is missing, return `status: failed` (run INTAKE first). Note
`azure.area_path` and `target_projects` for metadata.

### Step 2: Identify Feature Domains

From the intake `## Producto` and `## Negocio` sections, group capabilities into
business domains (e.g. `facturacion`, `onboarding`, `cobranza`). Each domain
becomes one Feature spec. Validate every domain name as a slug.

### Step 3: Write General Specs (initiative mode only)

For each domain write `initiative/specs/{domain}/spec.md`:

```markdown
# Feature — {Dominio} / {Nombre}

> Azure: work_item_type=Feature · area_path={azure.area_path|—} · parent_epic={epic|—} · estado=draft

## Contexto
{por qué importa, 3-5 líneas}

## Objetivos
- O1: {resultado de negocio medible}

## Capacidades

### Capacidad: {Nombre}
El producto SHALL {resultado a nivel negocio/usuario}.
- **Motivación:** {valor de negocio}
- **Restricciones:** {negocio/regulatorias, NO técnicas}
- **Criterios de aceptación (Feature):**
  - DADO {situación de negocio}
  - CUANDO {evento de negocio}
  - ENTONCES {resultado observable de negocio}

## Fuera de alcance
- {lo que esta Feature NO cubre}

## Trazabilidad
| Capacidad | Proyectos impactados |
|---|---|
| {Nombre} | cl0095, cl0027 |
```

Altitude rule (mirrors flow-nea-spec "WHAT not HOW"): if a technical detail
appears (endpoint, table, class, library), it does NOT belong here — keep it for
the cl00xx HU/delta spec. Use RFC 2119 keywords (SHALL/SHOULD) at the
business-outcome level.

### Step 4: Emit impact-map.yaml (initiative mode only)

Write `initiative/impact-map.yaml`. Each `change_candidate` is one candidate
User Story bound to one target project:

```yaml
schema_version: "1.0"
initiative: {slug}
generated_from:
  intake: initiative/intake/intake.md
  specs:
    - initiative/specs/{domain}/spec.md
change_candidates:
  - candidate_id: cc-001
    title: "{título HU corto}"
    rationale: "{derivado de qué Feature/capacidad}"
    source_capabilities:
      - "{Dominio}/{Capacidad}"
    target_project:
      id: cl0095
      path: ../cl0095
    proposed_change_name: "{slug ^[a-z0-9][a-z0-9-]*[a-z0-9]$}"
    azure:
      work_item_type: "User Story"
      area_path: "{azure.area_path|}"
      parent_feature: "{Dominio}/{Capacidad}"
      acceptance_criteria:
        - "{criterio observable}"
    seed:
      summary: "{1-2 líneas para el proposal.md del cl00xx}"
      affected_domains: ["{dominio-tecnico-estimado}"]
      priority: high
    status: proposed
unmapped_scope:
  - capability: "{Dominio}/{Capacidad}"
    reason: "{por qué no se pudo mapear a un proyecto}"
```

Rules for the map:
- Map `target_project` only to projects listed in `config.yaml` `target_projects`.
  If a capability has no project, put it under `unmapped_scope` (never invent a
  project).
- `proposed_change_name` MUST be a valid slug; derive from the HU title.
- Every Feature capability MUST appear either in a `change_candidate` or in
  `unmapped_scope`. Nothing dropped silently.
- This skill only writes the map. It NEVER seeds changes into cl00xx (that is the
  future DECOMPOSE phase).

### Step 5: Persist State (initiative mode only)

Update `initiative/.status.yaml`:

```yaml
phase: SPEC
initiative: "{slug}"
awaiting_approval: false
completed: false
notes: ""
```

If `gates.spec.require_impact_map` is `true` and no map was produced, return
`status: warning`. Append a SPEC entry to `.execution-log.md`.

### Step 6: Return Summary

Return the JSON envelope with a per-domain table:

| Feature (dominio) | Capacidades | HU candidatas | Proyectos |
|---|---|---|---|
| facturacion | 2 | 3 | cl0095, cl0027 |

## Rules

- Specs describe business outcomes, never implementation. No endpoints/tables/classes.
- Every requirement uses RFC 2119 keywords and has business-level acceptance criteria.
- Every capability is mapped or explicitly unmapped.
- Never seed cl00xx projects; only emit `impact-map.yaml`.
- Never write outside `initiative/`.
- All artifact content MUST be written in Spanish.
- Size budget: each Feature spec under 650 words.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "N Features written; M candidate HUs mapped across K projects.",
  "detailed_report": "Per-domain table and unmapped scope.",
  "artifacts": [
    { "name": "spec", "path": "initiative/specs/{domain}/spec.md", "type": "markdown" },
    { "name": "impact-map", "path": "initiative/impact-map.yaml", "type": "yaml" }
  ],
  "next_recommended": "DECOMPOSE",
  "risks": ["unmapped capabilities, missing target projects"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
