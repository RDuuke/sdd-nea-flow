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
  version: "2.2"
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

For each capability (`CAP-xxx`), derive one or more User Stories.

**Numbering rule (codified):**
- `HU-xxx` is GLOBAL sequential across the whole initiative (HU-001, HU-002, …).
- `CAP-xxx` resets per Feature (each Feature has its own CAP-001…).
- On re-run, read existing `hu/HU-*` folders and CONTINUE numbering from the last
  one (append new HUs); never renumber or drop existing HUs.

**Create vs Update on re-run (no duplicates).** A HU's IDENTITY is
(`feature` + `capability` + normalized intent/title). Before creating, look up an
existing HU with the same identity in the impact-map / `hu/` folders:
- **Match found -> UPDATE in place.** Keep its `id`, `enrichment`, `status`,
  `blockers`. Refresh the body/criteria, bump `revision` (integer, +1) and set
  `last_updated` in both the HU header and its impact-map entry. Log it.
- **No match (new scope) -> CREATE** a new `HU-xxx` (next global id), `revision: 1`.
- **Capability removed from the spec** -> mark the orphaned HU `status: rejected`
  with a note (do NOT delete the file).
- HARD RULE: never two HUs with the same identity. The Step 7 validation enforces it.

Pick each HU's `target_project` from `config.target_projects`. **If the only
entries are placeholders** (`status: placeholder` or id `cl0000`), still map to it
but carry `target_project.status: placeholder` through to the impact-map and add a
WARNING (the impact-map will point to a non-existent project until the user sets a
real one). A capability that cannot be assigned to any project goes to
`unmapped_scope`.

### Step 3: Flag Enrichment Needs (architect / designer)

For each HU set `enrichment.architecture.required` and
`enrichment.design.required` with these heuristics:

- **architecture.required: true** when the HU involves external integrations or
  systems (SIIF, Zoho Sign, buses), undefined data/contracts, a formula/algorithm
  to specify (e.g. cálculo de liquidación), cross-project coordination, or
  explicit "por confirmar" / ambiguity.
- **design.required: true** when the HU implies user-facing output — screens,
  flujos, dashboard, reporte visual, portal, or a public API/contract surface — or
  the sources point to UX/UI material (Figma, pantallas, `05-ux-ui`). For a
  data-only HU (pure ETL/batch/validation with no UI) set `not-required`. Do NOT
  blanket-set all HUs to one value: decide per HU from its content.

For each role, set `status: pending` if `required: true`, else `not-required`.

**Blocked HUs:** if a HU depends on a gap flagged `[CRITICAL]` in
`intake.md` `## Vacíos detectados` (e.g. an undocumented query/insumo), set its
`status: blocked` and record the blocker (see Step 6 `blockers[]`). A blocked HU
is still written (with what is known) but clearly marked.

Because PMO runs this flow, RETURN both flagged lists
(`architecture_candidates`, `design_candidates`) so the orchestrator can ask PMO
to confirm/adjust before routing the architect or designer. Do NOT block; write
your best guess — PMO can flip a flag later.

### Step 4: Write One Folder per HU (initiative mode only)

For each HU write `initiative/specs/{domain}/hu/HU-xxx/HU-xxx.md` AND create its
`assets/` dir with a `.gitkeep` file (so the empty folder persists in git):

```markdown
# HU-001 — {Título}

> Feature: FEAT-{dominio} · Capacidad: CAP-001 · Proyecto: {cl00xx}
> Azure: work_item_type=User Story · area_path={...} · parent_feature=FEAT-{dominio} · story_id=—
> Prioridad: {Alta|Media|Baja} · status: {proposed|blocked|rejected} · revisión: {N} · actualizado: {YYYY-MM-DD}
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

## Bloqueos
<!-- Solo si status: blocked. Si no, "ninguno". -->
- {tipo} {ref del gap CRITICAL del intake} — {acción de resolución}

## Assets / documentos
- {enlace relativo a sources/..., Figma URL, o archivo en assets/, o "ninguno"}

## Notas de arquitecto
<!-- La completa flow-nea-initiative-enrich (role=architecture) si arquitectura.required. -->
_{Pendiente de arquitectura}_ | _No requiere arquitectura_

## Diseño (UX/UI)
<!-- La completa flow-nea-initiative-enrich (role=design): enlaces Figma, mockups en assets/. -->
_{Pendiente de diseño}_ | _No requiere diseño_

## Fuera de alcance
- {opcional}
```

Quality bar for HU bodies:
- Real `Descripción` + ≥3 acceptance criteria (happy + borde + error).
- **Criterios testables:** each AC names a concrete interface/output/format/log and
  a verifiable result — avoid vague terms ("el mapa funcional" without defining it).
  If the criterion needs an algorithm/contract not yet defined, either reference it
  or set `enrichment.architecture.required: true` (don't fake specificity).
- Keep business altitude — technical detail -> `## Notas de arquitecto`, UX/UI ->
  `## Diseño (UX/UI)` (added later by the enrich phase).
- **Anti-invención + glosario:** use canonical full names from `intake.md`
  `## Glosario`; never invent expansions, figures, thresholds, system/people names.
  Unknown -> `[sin confirmar]` or a `## Bloqueos` / `unmapped_scope` entry.

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
schema_version: "2.2"
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
    target_project: { id: cl0095, path: ../cl0095, status: confirmed }  # confirmed | placeholder
    proposed_change_name: "{slug ^[a-z0-9][a-z0-9-]*[a-z0-9]$}"
    azure:
      work_item_type: "User Story"
      area_path: "{area}"
      parent_feature: FEAT-parametrizacion
      feature_id: ""
      story_id: ""
    priority: high
    revision: 1               # +1 each time this HU is updated on re-run
    last_updated: ""          # YYYY-MM-DD of last write
    enrichment:
      architecture: { required: false, status: not-required }   # required:true -> pending|in-progress|done
      design:       { required: false, status: not-required }
    status: proposed          # proposed | blocked | created-in-azure | seeded | rejected
    blockers: []              # if status: blocked, list entries (schema below)
unmapped_scope:
  - capability: "{Dominio}/{CAP-id} — {detalle}"
    reason: "{por qué no se pudo mapear}"
```

`blockers[]` entry shape (schema 2.2, optional; present when `status: blocked`):
```yaml
    blockers:
      - type: "QUERY_UNDOCUMENTED"   # short machine code
        ref: "Query 3 (MURIC-001-003)"
        severity: "CRITICAL"
        resolution: "Obtener diseño de la query del equipo de datos"
```

Rules:
- `schema_version: "2.2"`. Honor `gates.hu.require_impact_map`: if `true` and no
  map was produced, return `status: warning`.
- One `user_stories` entry per HU folder — no more, no less.
- `spec_ref` MUST resolve to the HU file; `assets_dir` to its assets folder.
- `target_project.id` only from `config.target_projects`; carry `status`
  (placeholder|confirmed) through from config.
- `proposed_change_name` valid slug AND unique within its `target_project`.
- `status: blocked` HUs MUST have a non-empty `blockers[]`.
- Merge-safe: re-running keeps existing entries/IDs/status/`enrichment`/`blockers`;
  UPDATES a matching identity in place (bump `revision`, set `last_updated`),
  CREATES only for new scope, never duplicates. Never seed cl00xx.

### Step 7: Self-Validate Before Returning (BLOCKER)

Any failure -> `status: warning`, list under `risks`:
1. Coverage: every `CAP-xxx` referenced by ≥1 HU OR in `unmapped_scope`.
2. HU sync: every `hu/HU-xxx/HU-xxx.md` ⇔ exactly one entry whose `spec_ref`
   resolves; spec TOC row exists; `assets/.gitkeep` present.
3. Project validity: every `target_project.id` ∈ `config.target_projects`
   (warn if any is `status: placeholder`).
4. Slug rules: `proposed_change_name` valid + unique per target project.
5. ID uniqueness: `HU-*` unique initiative-wide.
6. HU body: each HU has `Descripción` + ≥3 testable acceptance criteria.
7. Blocked integrity: every `status: blocked` HU has ≥1 `blockers[]` entry; every
   `[CRITICAL]` gap in intake maps to at least one blocked HU (or is resolved).
8. Identity uniqueness: no two HUs share identity (`feature`+`capability`+intent).
   On re-run, an existing identity was UPDATED (revision bumped), not duplicated.

### Step 8: Persist State (initiative mode only)

Update `initiative/.status.yaml` to `phase: HU`. Append a HU entry to
`.execution-log.md` stating, for a re-run, how many HUs were CREATED vs UPDATED
(with revisions) vs marked REJECTED. If batching per Feature, set `notes` with
remaining Features.

### Step 9: Return Summary

Return the JSON envelope with a per-Feature table AND the HUs flagged for
`architecture` and `design` so the orchestrator can route specialists.

## Rules

- One folder per HU; rich body in the HU file, assets (incl. Figma exports) in its `assets/`.
- The Feature spec holds only a TOC of links, never HU bodies.
- `impact-map.yaml` is a lean routing index; `spec_ref` points to the HU file.
- HU bodies stay at business altitude; technical detail -> architect notes, UX/UI -> design notes.
- Merge-safe and idempotent: never renumber or drop existing HUs.
- Every HU `assets/` has a `.gitkeep`. `status: blocked` HUs carry `blockers[]`.
- Use glossary canonical names; never invent — unknown is `[sin confirmar]`/gap.
- Decide `design.required` per HU (UI/report/API => true; data-only => not-required);
  never blanket-set all HUs to one value.
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
  "blocked_hus": ["HU-017"],
  "remaining_features": [],
  "next_recommended": "ENRICH | DECOMPOSE",
  "risks": ["unmapped capabilities, validation failures"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
