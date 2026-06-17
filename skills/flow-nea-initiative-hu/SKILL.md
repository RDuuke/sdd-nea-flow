---
name: flow-nea-initiative-hu
description: >
  Decompose initiative Features into detailed User Stories (HU) written inside
  each Feature spec, and emit a lean impact-map.yaml routing index for the
  future change pipeline. Orchestrator-driven, batchable per Feature.
trigger: >
  When the orchestrator launches you to create User Stories after Features (SPEC) are written.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Read the Feature specs produced by `flow-nea-initiative-spec` and decompose each
Feature's capabilities into **detailed User Stories (HU)**. The rich HU body is
written **inside the Feature spec file** (the `## Historias de Usuario (HU)`
section). Then emit `impact-map.yaml`, a **lean routing index** the future change
pipeline consumes: one entry per HU, pointing to its body via `spec_ref`, with
the target cl00xx project, proposed change name and Azure metadata.

Division of responsibility:
- **Specs** = human-facing. Features + capabilities (`CAP-xxx`) + full HU bodies
  (`HU-xxx`) appended by this skill.
- **impact-map.yaml** = machine-facing, lean. IDs, `spec_ref`, target, Azure
  metadata, status. The pipeline reads this; it never re-parses prose.

This is an Azure DevOps level: Feature -> User Story. A developer later pulls the
seeded HU/change in the target cl00xx project.

## What You Receive

- Initiative slug
- Optional `feature` filter: a `FEAT-{domain}` to process only that Feature
  (the orchestrator may drive this skill one Feature at a time / in batches).
- Artifact store mode (`initiative` | `none`)

## Execution and Persistence Contract

Read and follow: skills/_shared/initiative-persistence-contract.md

## What to Do

### Step 1: Read Features and Config

Read every `initiative/specs/{domain}/spec.md` (or only the filtered Feature) and
`initiative/config.yaml`. If no Feature specs exist, return `status: failed`
(run SPEC first). Note `azure.area_path`, `epic`, and `target_projects`.

### Step 2: Derive User Stories per Capability

For each capability (`CAP-xxx`), derive one or more User Stories. Assign IDs:
- `HU-001`, `HU-002`, … **unique across the WHOLE initiative**. Read existing
  `HU-*` headings first and continue numbering; never renumber existing HUs.

Choose the `target_project` for each HU from `config.target_projects`. If a
capability cannot be assigned to any registered project, record it in
`unmapped_scope` (never invent a project).

### Step 3: Write HU Bodies Inside the Feature Spec (initiative mode only)

Replace the `## Historias de Usuario (HU)` placeholder in each
`initiative/specs/{domain}/spec.md` with the real HUs. Append, do not overwrite
existing HUs:

```markdown
## Historias de Usuario (HU)

### HU-001 — {Título}
- **Como** {rol} **quiero** {capacidad} **para** {beneficio}.
- **Capacidad:** CAP-001
- **Proyecto destino:** {cl00xx}
- **Prioridad:** {Alta | Media | Baja}
- **Descripción:** {3-6 renglones de contexto y detalle de negocio}
- **Alcance funcional:**
  - {punto concreto}
  - {punto concreto}
- **Criterios de aceptación:**
  - DADO {…} CUANDO {…} ENTONCES {…}   (happy path)
  - DADO {…} CUANDO {…} ENTONCES {…}   (borde)
  - DADO {…} CUANDO {…} ENTONCES {…}   (error/negativo)
- **Notas / dependencias:** {SIIF, Zoho Sign, etc., o "ninguna"}
- **Fuera de alcance:** {opcional}

### HU-002 — {Título}
...
```

Each HU MUST have a real `Descripción` and ≥3 acceptance criteria (happy + borde
+ error/negativo). This is the "cuerpo"; the impact-map will NOT duplicate it.
Keep business altitude — no endpoints/tables/classes.

Also update the Feature `## Trazabilidad` table (HU | Capacidad | Proyecto |
change propuesto).

### Step 4: Emit / Update the Lean impact-map.yaml (initiative mode only)

Write `initiative/impact-map.yaml` (merge if it exists; keep prior entries and
their `status`). It is a ROUTING INDEX, not a content store:

```yaml
schema_version: "2.0"
initiative: {slug}
generated_from:
  intake: initiative/intake/intake.md
features:
  - id: FEAT-parametrizacion
    spec: initiative/specs/parametrizacion/spec.md
    azure:
      work_item_type: "Feature"
      area_path: "{azure.area_path|}"
      parent_epic: "{epic|}"
      feature_id: ""          # filled after manual creation in Azure
user_stories:
  - id: HU-001
    title: "{título HU}"
    feature: FEAT-parametrizacion
    capability: CAP-001
    spec_ref: "initiative/specs/parametrizacion/spec.md#hu-001"   # rich body lives here
    target_project:
      id: cl0095
      path: ../cl0095
    proposed_change_name: "{slug ^[a-z0-9][a-z0-9-]*[a-z0-9]$}"
    azure:
      work_item_type: "User Story"
      area_path: "{azure.area_path|}"
      parent_feature: FEAT-parametrizacion
      feature_id: ""
      story_id: ""
    priority: high            # high | medium | low
    status: proposed          # proposed | created-in-azure | seeded | rejected
unmapped_scope:
  - capability: "{Dominio}/{CAP-id} — {detalle}"
    reason: "{por qué no se pudo mapear a un proyecto}"
```

Rules:
- One `user_stories` entry per HU heading in the specs — no more, no less.
- `spec_ref` MUST resolve to the spec file + the HU heading anchor (build from
  the HU id: `### HU-001 …` -> `#hu-001`).
- `target_project.id` only from `config.target_projects`.
- `proposed_change_name` valid slug AND unique within its `target_project`.
- Merge-safe: re-running keeps existing entries/IDs and their `status`; only adds
  new HUs. Never seed cl00xx (that is the future DECOMPOSE phase).

### Step 5: Self-Validate Before Returning (BLOCKER)

Run these; any failure -> `status: warning`, list under `risks`:
1. **Coverage:** every `CAP-xxx` is referenced by ≥1 HU OR in `unmapped_scope`.
2. **HU sync:** every `HU-xxx` heading ⇔ exactly one `user_stories` entry whose
   `spec_ref` resolves (file + anchor).
3. **Project validity:** every `target_project.id` ∈ `config.target_projects`.
4. **Slug rules:** `proposed_change_name` valid + unique per target project.
5. **ID uniqueness:** `HU-*` unique initiative-wide.
6. **HU body:** each HU has a `Descripción` and ≥3 acceptance criteria.

Report results in `detailed_report` (counts + any violations).

### Step 6: Persist State (initiative mode only)

Update `initiative/.status.yaml`:

```yaml
phase: HU
initiative: "{slug}"
awaiting_approval: false
completed: false
notes: ""
```

Append a HU entry to `.execution-log.md`. If the orchestrator is batching per
Feature, set `notes` to which Features remain.

### Step 7: Return Summary

Return the JSON envelope with a per-Feature table:

| Feature | Capacidades | HU | Proyectos | Validación |
|---|---|---|---|---|
| FEAT-parametrizacion | 4 | 4 | cl0095, cl0027 | ok |

## Rules

- The rich HU body lives inside the Feature spec; `impact-map.yaml` is a lean
  routing index. Do not duplicate AC prose in YAML.
- Every capability is mapped (HU) or explicitly unmapped.
- HU stay at business altitude — no implementation detail.
- Merge-safe and idempotent: never renumber or drop existing HUs.
- Never seed cl00xx projects; only emit `impact-map.yaml`.
- Never write outside `initiative/`.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "M HUs written across N Features; impact-map validated.",
  "detailed_report": "Per-Feature table, validation results, unmapped scope.",
  "artifacts": [
    { "name": "spec", "path": "initiative/specs/{domain}/spec.md", "type": "markdown" },
    { "name": "impact-map", "path": "initiative/impact-map.yaml", "type": "yaml" }
  ],
  "impact_map_valid": true,
  "validation_errors": [],
  "remaining_features": [],
  "next_recommended": "DECOMPOSE",
  "risks": ["unmapped capabilities, validation failures"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
