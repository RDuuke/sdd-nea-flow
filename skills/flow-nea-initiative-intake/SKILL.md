---
name: flow-nea-initiative-intake
description: >
  Read the initiative sources/ subfolders, extract per domain, and consolidate
  them into a single intake digest plus an auditable source index.
trigger: >
  When the orchestrator launches you to ingest an initiative's sources after init.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Read the heterogeneous documents under `sources/01..06`, extract the relevant
signal per subfolder, and consolidate everything into `initiative/intake/intake.md`.
Record every file seen in `initiative/intake/source-index.md`, including files
that could not be read (graceful degradation). This digest is the single input
for the SPEC phase.

You extract and consolidate. You do NOT write specs or design.

## What You Receive

- Initiative slug
- Artifact store mode (`initiative` | `none`)

## Execution and Persistence Contract

Read and follow: skills/_shared/initiative-persistence-contract.md

## What to Do

### Step 1: Inventory Sources

Walk `sources/01..06`. For every file, record one row in
`initiative/intake/source-index.md`:

```markdown
# Índice de fuentes — {YYYY-MM-DD HH:MM}

| Archivo | Subcarpeta | Formato | Legible | Estado | Nota |
|---|---|---|---|---|---|
| plan-2026.pdf | 01-negocio | pdf | sí | parsed | — |
| mockups.fig | 05-ux-ui | fig | no | needs-conversion | exportar a PNG/PDF |
```

### Step 2: Read With Graceful Degradation

Per file format:

- `md`, `txt`, `yaml`, `json`, `csv` -> read directly.
- `pdf` -> read (page ranges if large). If extraction yields no usable text ->
  degrade.
- `docx`, `pptx`, `xlsx` -> attempt; if not readable -> degrade.
- images (`png`, `jpg`, etc.) -> read visually and describe relevant content; if
  purely decorative -> mark as such.
- anything else / unreadable -> degrade.

**Degrade** = record the file in `source-index.md` with
`Estado: needs-conversion` and a `Nota` recommending an action (e.g. "exportar a
.md/.txt y re-ejecutar intake"). NEVER fail the phase because a file is
unreadable. Unreadable files -> add to `risks` and set `status: warning`.

### Step 3: Extract Per Subfolder

| Subcarpeta | Extract | intake.md section |
|---|---|---|
| 01-negocio | objetivos, KPIs, restricciones, stakeholders | `## Negocio` |
| 02-producto | features, capacidades, prioridades | `## Producto` |
| 03-reuniones | decisiones, acuerdos, pendientes (con fecha) | `## Decisiones` |
| 04-referencias | benchmarks, links, estándares | `## Referencias` |
| 05-ux-ui | flujos, pantallas, lineamientos | `## UX/UI` |
| 06-docs-tecnicos | restricciones técnicas, integraciones | `## Restricciones técnicas` |

Cite the source file and section for each extracted point (e.g.
`(01-negocio/objetivos.md)`). Do NOT dump full source contents; summarize.

### Step 4: Write the Digest (initiative mode only)

Write `initiative/intake/intake.md`:

```markdown
# Intake — {Iniciativa}

## Resumen ejecutivo
{3-6 líneas: de qué trata la iniciativa, según las fuentes}

## Negocio
- {objetivo / restricción}  (fuente)

## Producto
- {feature / capacidad}  (fuente)

## Decisiones
- {fecha} {decisión}  (fuente)

## Referencias
- {referencia}  (fuente)

## UX/UI
- {flujo / lineamiento}  (fuente)

## Restricciones técnicas
- {restricción / integración}  (fuente)

## Vacíos detectados
- {insumo faltante para poder escribir specs}
```

`## Vacíos detectados` is mandatory: list missing inputs SPEC would need
(empty subfolders, unreadable critical docs, undefined scope, no target
projects).

### Step 5: Persist State (initiative mode only)

Update `initiative/.status.yaml`:

```yaml
phase: INTAKE
initiative: "{slug}"
awaiting_approval: true     # gates.intake.require_human_review default
completed: false
notes: "Intake listo; requiere revisión humana antes de SPEC."
```

If `gates.intake.require_human_review` is `false` in config, set
`awaiting_approval: false`. Append an INTAKE entry to `.execution-log.md`.

### Step 6: Return Summary

Return the JSON envelope. Always surface unreadable files and detected gaps so
the orchestrator can stop at the human-review gate.

## Rules

- NEVER fail the phase due to an unreadable file; degrade and warn.
- Cite sources; do not dump full documents.
- Do not invent content not present in `sources/`.
- Never write outside `initiative/`.
- All artifact content MUST be written in Spanish.
- Size budget: keep `intake.md` focused; prefer bullet points over prose.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Intake consolidated from N sources; M unreadable.",
  "detailed_report": "Per-subfolder counts and gaps.",
  "artifacts": [
    { "name": "intake", "path": "initiative/intake/intake.md", "type": "markdown" },
    { "name": "source-index", "path": "initiative/intake/source-index.md", "type": "markdown" }
  ],
  "awaiting_approval": true,
  "next_recommended": "SPEC",
  "risks": ["unreadable files (needs-conversion), detected gaps"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
