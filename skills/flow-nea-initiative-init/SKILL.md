---
name: flow-nea-initiative-init
description: >
  Bootstrap an initiative repository: scaffold the sources/ + initiative/
  structure, write config and status, and validate the Definition of Ready.
trigger: >
  When the user wants to start a new initiative or says "initiative init".
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

You initialize an **initiative repository** (one repo per initiative, e.g.
`compra-de-cartera`). You scaffold the directory structure, write
`initiative/config.yaml` and `initiative/.status.yaml`, and validate a
Definition of Ready (DoR) so downstream INTAKE and SPEC have real inputs.

This is the upstream layer of flow-nea. A general spec maps conceptually to an
Azure DevOps **Feature**, and a change candidate to a **User Story (HU)**. No
Azure API is used in this phase; only metadata is recorded.

## What You Receive

- Initiative slug (the `$ARGUMENTS`), e.g. `compra-de-cartera`
- Artifact store mode (`initiative` | `none`)

## Execution and Persistence Contract

Read and follow: skills/_shared/initiative-persistence-contract.md

## What to Do

### Step 1: Validate the Slug

Validate the initiative slug against the rule in the contract
(`^[a-z0-9][a-z0-9-]*[a-z0-9]$`, 3-50 chars). If invalid, do NOT create
anything; return `status: failed` with a sanitized suggestion.

### Step 2: Scaffold Structure (initiative mode only)

If the directories do not exist, create them:

```text
sources/01-negocio/  sources/02-producto/  sources/03-reuniones/
sources/04-referencias/  sources/05-ux-ui/  sources/06-docs-tecnicos/
initiative/  initiative/intake/  initiative/specs/
```

In each `sources/NN-*/` write a short `README.md` (Spanish) explaining what
goes there (see the ingest mapping in `flow-nea-initiative-intake`). Do NOT
create placeholder specs or fake source documents.

If `initiative/` already exists, report what exists before writing; preserve
existing `config.yaml` content and only fill the `context` block.

### Step 3: Generate Config (initiative mode only)

If `initiative/config.yaml` is missing, create it with this full template.
ALL top-level blocks are REQUIRED (`initiative`, `azure`, `context`,
`sources_root`, `target_projects`, `gates`). Do not omit blocks.

```yaml
schema: flow-nea-initiative

initiative:
  name: ""                 # slug ^[a-z0-9][a-z0-9-]*[a-z0-9]$
  description: ""          # one line
  epic: ""                 # reserved Azure Epic id/url, optional

azure:
  organization: ""
  project: ""
  area_path: ""
  iteration_path: ""
  feature_work_item_type: "Feature"
  story_work_item_type: "User Story"

context: |
  Negocio: not assessed
  Producto: not assessed

sources_root: sources

target_projects:           # MANUAL registry of external cl00xx projects
  - id: cl0000
    path: ../cl0000

gates:
  intake:
    require_human_review: true   # set false for unattended/PMO-absent runs (auto-approve intake)
  spec:
    require_impact_map: true
```

Fill `initiative.name` with the validated slug. Leave `target_projects` with a
single placeholder entry for the user to edit.

### Step 4: Validate Definition of Ready (DoR)

Check these and REPORT each as ready/missing. Do NOT fail the phase for missing
DoR items — they are warnings that gate quality, not blockers for init:

1. `initiative.description` present in config.
2. `sources/01-negocio` non-empty (objective + scope).
3. `sources/02-producto` non-empty (minimum features).
4. Success metrics / initiative-level acceptance criteria present in `01-negocio`.
5. At least one real entry in `target_projects` (placeholder `cl0000` counts as missing).
6. Business glossary / domains hinted in `02-producto` (used later to name Features).
7. Azure mapping filled (`azure.organization`, `azure.project`, `azure.area_path`).

Each missing item -> add to `risks` and set `status: warning`. All present ->
`status: ok`.

### Step 5: Persist State (initiative mode only)

Write `initiative/.status.yaml`:

```yaml
schema_version: "1.0"
phase: INIT
initiative: "{slug}"
awaiting_approval: false
completed: false
notes: ""
```

Append an INIT entry to `initiative/.execution-log.md` (date AND time).

### Step 6: Return Summary

Return the JSON envelope. List DoR gaps explicitly so the user knows what to
fill in `sources/` before running INTAKE.

## Rules

- Never create placeholder specs or fake source documents.
- Never write outside `initiative/` (the `sources/NN-*/README.md` files are the
  only exception, written once during scaffold).
- If `config.yaml` exists, update only `context`; preserve the rest.
- Keep `context` concise (max 10 lines).
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Initiative scaffolded; DoR status summary.",
  "detailed_report": "Optional notes and DoR gaps.",
  "artifacts": [
    { "name": "config", "path": "initiative/config.yaml", "type": "yaml" },
    { "name": "status", "path": "initiative/.status.yaml", "type": "yaml" }
  ],
  "next_recommended": "INTAKE",
  "risks": ["DoR gaps or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
