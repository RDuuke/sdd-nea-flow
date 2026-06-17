---
name: flow-nea-initiative-hu
description: >
  Decompose initiative Features into detailed User Stories, one folder per HU
  (body + assets), keep a table of contents in the Feature spec, flag HUs that
  need enrichment (architect and/or designer), and emit a lean impact-map.yaml.
trigger: >
  When the orchestrator launches you to create User Stories after Features (SPEC) are written.
license: MIT
metadata:
  author: juan-duque
  version: "2.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Read the Feature specs produced by `flow-nea-initiative-spec` and decompose each
Feature's capabilities into **detailed User Stories (HU)**. This flow is used by
**PMO**. Each HU is written as **its own folder** so many HUs scale cleanly,
specialists can enrich a single HU without touching others, and each HU can carry
its own external assets/documents (technical docs, Figma links, mockups):

```text
initiative/specs/{domain}/
  spec.md                      # Feature + capabilities + TOC linking to HUs
  hu/
    HU-001/
      HU-001.md                # HU body + assets links + architect & design notes
      assets/                  # external docs / diagrams / exports for THIS HU
    HU-002/
      HU-002.md
      assets/
```

The Feature `spec.md` keeps a **table of contents** (links to each HU file), not
the bodies. `impact-map.yaml` stays a **lean routing index**: one entry per HU,
`spec_ref` points to the HU FILE (clean unit for the future DECOMPOSE seed).

This is an Azure DevOps level: Feature -> User Story. A developer later pulls the
seeded HU/change in the target cl00xx project.

## Enrichment model

A HU often needs specialist input before implementation. Two roles, tracked
independently, filled later by `flow-nea-initiative-enrich`:

- **architecture** — technical design: integrations, data/contracts, formulas,
  cross-project coordination.
- **design** — UX/UI: screens, flows, mockups, **Figma links**.

Each role has `{ required: bool, status: not-required | pending | in-progress | done }`.

## What You Receive

- Initiative slug
- Optional `feature` filter: a `FEAT-{domain}` to process only that Feature.
- Artifact store mode (`initiative` | `none`)

## Execution and Persistence Contract

Read and follow: skills/_shared/initiative-persistence-contract.md

## What to Do

### Step 1: Read Features and Config

Read every `initiative/specs/{domain}/spec.md` (or only the filtered Feature) and
`initiative/config.yaml`. If no Feature specs exist, return `status: failed`
(run SPEC first). Note `azure.area_path`, `epic`, and `target_projects`.

### Step 2: Derive User Stories per Capability

For each capability (`CAP-xxx`), derive one or more User Stories. Assign IDs
`HU-001`, `HU-002`, … **unique across the WHOLE initiative**. Read existing
`hu/HU-*` folders first and continue numbering; never renumber existing HUs.

Pick each HU's `target_project` from `config.target_projects`. A capability that
cannot be assigned to any registered project goes to `unmapped_scope`.

### Step 3: Flag Enrichment Needs (architect / designer)

For each HU set `enrichment.architecture.required` and
`enrichment.design.required` with these heuristics:

- **architecture.required: true** when the HU involves external integrations or
  systems (SIIF, Zoho Sign, buses), undefined data/contracts, a formula/algorithm
  to specify (e.g. cálculo de liquidación), cross-project coordination, or
  explicit "por confirmar" / ambiguity.
- **design.required: true** when the HU has user-facing screens/flows, needs
  mockups or wireframes, or the sources point to UX/UI material (Figma, pantallas,
  flujos en `05-ux-ui`).

For each role, set `status: pending` if `required: true`, else `not-required`.

Because PMO runs this flow, RETURN both flagged lists
(`architecture_candidates`, `design_candidates`) so the orchestrator can ask PMO
to confirm/adjust before routing the architect or designer. Do NOT block; write
your best guess — PMO can flip a flag later.

### Step 4: Write One Folder per HU (initiative mode only)

For each HU write `initiative/specs/{domain}/hu/HU-xxx/HU-xxx.md` and create an
empty `assets/` dir beside it:

```markdown
# HU-001 — {Título}

> Feature: FEAT-{dominio} · Capacidad: CAP-001 · Proyecto: {cl00xx}
> Azure: work_item_type=User Story · area_path={...} · parent_feature=FEAT-{dominio} · story_id=—
> Prioridad: {Alta|Media|Baja} · status: proposed
> Enriquecimiento: arquitectura={not-required|pending} · diseño={not-required|pending}

## Historia
Como {rol} quiero {capacidad} para {beneficio}.

## Descripción
{3-6 renglones de contexto y detalle de negocio}

## Alcance funcional
- {punto concreto}

## Criterios de aceptación
- DADO {…} CUANDO {…} ENTONCES {…}   (happy)
- DADO {…} CUANDO {…} ENTONCES {…}   (borde)
- DADO {…} CUANDO {…} ENTONCES {…}   (error/negativo)

## Assets / documentos
- {enlace relativo a sources/04-referencias/... , Figma URL, o archivo en assets/, o "ninguno"}

## Notas de arquitecto
<!-- La completa flow-nea-initiative-enrich (role=architecture) si arquitectura.required. -->
_{Pendiente de arquitectura}_ | _No requiere arquitectura_

## Diseño (UX/UI)
<!-- La completa flow-nea-initiative-enrich (role=design): enlaces Figma, mockups en assets/. -->
_{Pendiente de diseño}_ | _No requiere diseño_

## Fuera de alcance
- {opcional}
```

Each HU MUST have a real `Descripción` and ≥3 acceptance criteria (happy + borde
+ error). Keep business altitude in the HU body — technical detail goes under
`## Notas de arquitecto`, UX/UI under `## Diseño (UX/UI)` (added later).

### Step 5: Maintain the Table of Contents in the Feature spec

Replace the `## Historias de Usuario (HU)` placeholder in each
`initiative/specs/{domain}/spec.md` with a TOC table (not bodies):

```markdown
## Historias de Usuario (HU)

| HU | Título | Capacidad | Proyecto | Arq. | Dis. | Estado | Detalle |
|----|--------|-----------|----------|------|------|--------|---------|
| HU-001 | Parametrizar tipos de compra | CAP-001 | cl0095 | no | no | proposed | [HU-001](hu/HU-001/HU-001.md) |
```

`Arq.`/`Dis.` = `no` or `sí (pending|in-progress|done)`. Keep in sync each run.

### Step 6: Emit / Update the Lean impact-map.yaml (initiative mode only)

Write/merge `initiative/impact-map.yaml` (keep prior entries, `status` and
`enrichment` state):

```yaml
schema_version: "2.1"
initiative: {slug}
generated_from:
  intake: initiative/intake/intake.md
features:
  - id: FEAT-parametrizacion
    spec: initiative/specs/parametrizacion/spec.md
    azure: { work_item_type: "Feature", area_path: "{area}", parent_epic: "{epic|}", feature_id: "" }
user_stories:
  - id: HU-001
    title: "{título HU}"
    feature: FEAT-parametrizacion
    capability: CAP-001
    spec_ref: "initiative/specs/parametrizacion/hu/HU-001/HU-001.md"   # the HU FILE (seed unit)
    assets_dir: "initiative/specs/parametrizacion/hu/HU-001/assets"
    target_project: { id: cl0095, path: ../cl0095 }
    proposed_change_name: "{slug ^[a-z0-9][a-z0-9-]*[a-z0-9]$}"
    azure:
      work_item_type: "User Story"
      area_path: "{area}"
      parent_feature: FEAT-parametrizacion
      feature_id: ""
      story_id: ""
    priority: high
    enrichment:
      architecture: { required: false, status: not-required }   # required:true -> pending|in-progress|done
      design:       { required: false, status: not-required }
    status: proposed          # proposed | created-in-azure | seeded | rejected
unmapped_scope:
  - capability: "{Dominio}/{CAP-id} — {detalle}"
    reason: "{por qué no se pudo mapear}"
```

Rules:
- One `user_stories` entry per HU folder — no more, no less.
- `spec_ref` MUST resolve to the HU file; `assets_dir` to its assets folder.
- `target_project.id` only from `config.target_projects`.
- `proposed_change_name` valid slug AND unique within its `target_project`.
- Merge-safe: re-running keeps existing entries/IDs/status and `enrichment`
  state; only adds new HUs. Never seed cl00xx.

### Step 7: Self-Validate Before Returning (BLOCKER)

Any failure -> `status: warning`, list under `risks`:
1. Coverage: every `CAP-xxx` referenced by ≥1 HU OR in `unmapped_scope`.
2. HU sync: every `hu/HU-xxx/HU-xxx.md` ⇔ exactly one entry whose `spec_ref`
   resolves; spec TOC row exists.
3. Project validity: every `target_project.id` ∈ `config.target_projects`.
4. Slug rules: `proposed_change_name` valid + unique per target project.
5. ID uniqueness: `HU-*` unique initiative-wide.
6. HU body: each HU has `Descripción` + ≥3 acceptance criteria.

### Step 8: Persist State (initiative mode only)

Update `initiative/.status.yaml` to `phase: HU`. Append a HU entry to
`.execution-log.md`. If batching per Feature, set `notes` with remaining Features.

### Step 9: Return Summary

Return the JSON envelope with a per-Feature table AND the HUs flagged for
`architecture` and `design` so the orchestrator can route specialists.

## Rules

- One folder per HU; rich body in the HU file, assets (incl. Figma exports) in its `assets/`.
- The Feature spec holds only a TOC of links, never HU bodies.
- `impact-map.yaml` is a lean routing index; `spec_ref` points to the HU file.
- HU bodies stay at business altitude; technical detail -> architect notes, UX/UI -> design notes.
- Merge-safe and idempotent: never renumber or drop existing HUs.
- Never seed cl00xx projects; only emit `impact-map.yaml`.
- Never write outside `initiative/`.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "M HUs (folder each) across N Features; flagged A for architect, D for design; impact-map validated.",
  "detailed_report": "Per-Feature table, validation, unmapped scope.",
  "artifacts": [
    { "name": "hu", "path": "initiative/specs/{domain}/hu/HU-xxx/HU-xxx.md", "type": "markdown" },
    { "name": "impact-map", "path": "initiative/impact-map.yaml", "type": "yaml" }
  ],
  "impact_map_valid": true,
  "validation_errors": [],
  "architecture_candidates": ["HU-004"],
  "design_candidates": ["HU-002"],
  "remaining_features": [],
  "next_recommended": "ENRICH | DECOMPOSE",
  "risks": ["unmapped capabilities, validation failures"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
