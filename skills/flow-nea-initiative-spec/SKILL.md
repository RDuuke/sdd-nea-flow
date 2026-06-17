---
name: flow-nea-initiative-spec
description: >
  Write detailed general initiative specs (Azure Features) with capabilities.
  Stops at Features; User Stories are produced by flow-nea-initiative-hu.
trigger: >
  When the orchestrator launches you to write initiative Features after intake is approved.
license: MIT
metadata:
  author: juan-duque
  version: "2.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Turn the consolidated `intake.md` into **detailed general specs** at
business/product altitude. Each spec domain is an Azure DevOps **Feature**, with
its capabilities (`CAP-xxx`). This skill stops at the Feature level. The User
Stories (HU) with full body and the `impact-map.yaml` routing index are produced
by the next phase, `flow-nea-initiative-hu`.

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
`azure.area_path`, `domains` (if declared) and `target_projects`.

### Step 2: Identify Feature Domains and Capabilities

Group capabilities from the intake `## Producto`/`## Negocio` sections into
business domains (e.g. `parametrizacion`, `auditoria`, `proformas`). Each domain
becomes one Feature spec. If `config.yaml` declares `domains:`, reuse those
canonical slugs; otherwise derive and validate them as slugs.

Assign stable IDs (immutable; append on re-run, never renumber):
- Feature ID: `FEAT-{domain}` (one per spec).
- Capability ID: `CAP-001`, `CAP-002`, … unique within the Feature.

### Step 3: Write Detailed Feature Specs (initiative mode only)

For each domain write `initiative/specs/{domain}/spec.md`:

```markdown
# Feature — {Dominio} / {Nombre}

> Azure: work_item_type=Feature · area_path={azure.area_path|—} · parent_epic={epic|—} · estado=draft
> ID: FEAT-{dominio}

## Resumen
{2-4 líneas: qué resuelve y para quién}

## Contexto y problema
{situación actual, dolor, por qué ahora — del intake}

## Objetivos
- O1: {resultado de negocio medible}

## Reglas de negocio
- RN1: {regla derivada de las fuentes}
- RN2: ...

## Capacidades

### CAP-001 — {Nombre}
El producto SHALL {resultado a nivel negocio/usuario}.
- **Motivación:** {valor de negocio}
- **Restricciones:** {negocio/regulatorias, NO técnicas}
- **Criterios de aceptación (Feature):**
  - DADO {situación} CUANDO {evento} ENTONCES {resultado observable}

### CAP-002 — {Nombre}
...

## Supuestos y dependencias
- {supuesto / dependencia / "ninguna"}

## Fuera de alcance
- {lo que esta Feature NO cubre}

## Historias de Usuario (HU)
<!-- Esta sección la completa flow-nea-initiative-hu. No escribir HU aquí. -->
_Pendiente: las HU se generan en la fase HU._
```

Leave the `## Historias de Usuario (HU)` section as a placeholder; the HU phase
fills it. Each capability MUST carry ≥1 Feature-level acceptance criterion
(happy + edge where it applies).

Altitude rule (mirrors flow-nea-spec "WHAT not HOW"): no endpoints, tables,
classes, or libraries. Use RFC 2119 keywords (SHALL/SHOULD).

### Step 4: Self-Validate Before Returning

Checks; any failure -> `status: warning`, list under `risks`:
1. Every Feature has `FEAT-{domain}` and ≥1 `CAP-xxx`.
2. `CAP-xxx` unique within each Feature.
3. Each capability has ≥1 acceptance criterion.
4. No technical detail leaked (no endpoints/tables/classes).

### Step 5: Persist State (initiative mode only)

Update `initiative/.status.yaml`:

```yaml
phase: SPEC
initiative: "{slug}"
awaiting_approval: false
completed: false
notes: ""
```

Append a SPEC entry to `.execution-log.md`.

### Step 6: Return Summary

Return the JSON envelope with a per-domain table:

| Feature (dominio) | Capacidades | Proyectos tentativos |
|---|---|---|
| parametrizacion | 4 | cl0095, cl0027 |

## Rules

- Specs are detailed but stay at business altitude — no implementation detail.
- Do NOT write User Stories or `impact-map.yaml`; that is the HU phase.
- Leave the `## Historias de Usuario (HU)` placeholder in each spec.
- Never write outside `initiative/`.
- All artifact content MUST be written in Spanish.
- Size budget: each Feature spec under 900 words (capabilities only; HU added later).

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "N detailed Features written with capabilities.",
  "detailed_report": "Per-domain table and validation results.",
  "artifacts": [
    { "name": "spec", "path": "initiative/specs/{domain}/spec.md", "type": "markdown" }
  ],
  "next_recommended": "HU",
  "risks": ["validation failures, missing inputs"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
