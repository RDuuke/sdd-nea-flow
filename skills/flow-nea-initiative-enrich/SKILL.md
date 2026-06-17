---
name: flow-nea-initiative-enrich
description: >
  Specialist enrichment of a User Story. An architect adds technical design
  notes, or a designer adds UX/UI notes and Figma links + assets. Updates the HU
  file, its enrichment status, the impact-map and the Feature TOC.
trigger: >
  When an architect or designer enters with /flow-nea-initiative-arch or
  /flow-nea-initiative-design to enrich a HU flagged by the HU phase.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Let a specialist enrich a User Story AFTER PMO has produced it. Two roles share
this skill:

- **role=architecture** — the architect fills `## Notas de arquitecto` with
  technical design: integrations, data/contracts, formulas, constraints, and
  links to design assets. Technical detail IS allowed here (unlike the
  business-altitude HU body) — it is design guidance to carry into the cl00xx
  change later.
- **role=design** — the designer fills `## Diseño (UX/UI)` with screens/flows,
  **Figma links**, and exports placed under the HU `assets/` folder.

This skill works on **one HU at a time** (or a small batch the orchestrator
passes). It never seeds cl00xx.

## What You Receive

- Initiative slug
- `role`: `architecture` | `design`
- `hu`: the target HU id (e.g. `HU-004`); optionally a list for a batch
- Optional payload from the specialist: notes text, Figma URLs, asset file names
- Artifact store mode (`initiative` | `none`)

## Execution and Persistence Contract

Read and follow: skills/_shared/initiative-persistence-contract.md

## What to Do

### Step 1: Resolve the HU

From `initiative/impact-map.yaml`, find the `user_stories` entry for `hu`. Read
its `spec_ref` (the HU file) and `assets_dir`. If the HU does not exist, return
`status: failed`. If `enrichment.{role}.required` is `false`, proceed anyway but
add a note that this HU was not flagged for `role` (the specialist chose to
enrich it regardless).

### Step 2: Apply the Enrichment (initiative mode only)

Edit the HU file `.../hu/HU-xxx/HU-xxx.md`:

- **role=architecture** -> replace the `## Notas de arquitecto` placeholder with
  the architect's content. Suggested structure:
  ```markdown
  ## Notas de arquitecto
  - **Enfoque técnico:** {resumen del diseño}
  - **Integraciones:** {SIIF / Zoho / etc. y su contrato}
  - **Datos / contratos:** {entidades, campos clave}
  - **Riesgos / decisiones:** {ADR breve}
  - **Referencias:** {enlaces a docs en assets/ o externos}
  ```
- **role=design** -> replace the `## Diseño (UX/UI)` placeholder:
  ```markdown
  ## Diseño (UX/UI)
  - **Figma:** {url del archivo/frame}
  - **Pantallas / flujos:** {descripción breve}
  - **Recursos:** {exports en assets/, enlaces}
  ```

Place any uploaded/exported files under the HU `assets/` folder (the specialist
provides them; do not invent binary content). Record links, not copies of large
external docs.

### Step 3: Update Status Everywhere

Set `enrichment.{role}.status` to `done` (or `in-progress` if the specialist says
it is partial) in THREE places, kept consistent:
1. The HU file header line (`Enriquecimiento: …`).
2. `initiative/impact-map.yaml` -> the HU entry `enrichment.{role}.status`.
3. The Feature `spec.md` TOC row (`Arq.`/`Dis.` column).

Do not change `required`; only `status`.

### Step 4: Persist State (initiative mode only)

Keep `initiative/.status.yaml` `phase` as-is (enrichment does not move the main
phase; it is an out-of-band specialist pass like SPEC-FIX). Set `notes` to
indicate which HU/role was enriched. Append an entry to `.execution-log.md` named
`ENRICH-{ROLE}` with the HU id.

### Step 5: Return Summary

Return the JSON envelope. Report remaining HUs still `pending` for this role so
the orchestrator can tell PMO/specialist what is left.

## Rules

- Only edit the targeted HU file, its `assets/`, the impact-map entry and the TOC
  row. Never touch other HUs.
- Technical detail is allowed in architect notes; UX detail + Figma links in
  design notes. Keep the HU business body unchanged.
- Never seed cl00xx projects.
- Never write outside `initiative/`.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "HU-004 enriched (role=architecture); status done.",
  "detailed_report": "What was added; assets recorded.",
  "artifacts": [
    { "name": "hu", "path": "initiative/specs/{domain}/hu/HU-004/HU-004.md", "type": "markdown" },
    { "name": "impact-map", "path": "initiative/impact-map.yaml", "type": "yaml" }
  ],
  "role": "architecture | design",
  "hu": "HU-004",
  "pending_for_role": ["HU-007"],
  "next_recommended": "ENRICH | DECOMPOSE",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
