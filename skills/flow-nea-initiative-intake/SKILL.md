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

Walk `sources/` only (the 6 convention subfolders if present; map whatever
exists). **IGNORE `resources/` and any directory other than `sources/` and
`initiative/`** — `resources/` is general-repo data, NOT an initiative input; do
not inventory or read it. For every file UNDER `sources/`, record one row in
`initiative/intake/source-index.md`:

```markdown
# Índice de fuentes — {YYYY-MM-DD HH:MM}

| Archivo | Subcarpeta | Formato | Legible | Estado | Nota |
|---|---|---|---|---|---|
| plan-2026.md | 01-negocio | md | sí | parsed | — |
| catalogo.xlsx | 06-docs-tecnicos | xlsx | no | unsupported-format | exportar a CSV/MD |
| notas.txt | 03-reuniones | txt | no | encoding | guardar como UTF-8 |
```

`Estado` ∈ `parsed | encoding | unsupported-format | empty`.

### Step 2: Read With Graceful Degradation + Encoding Triage

Per file format:

- `md`, `txt`, `yaml`, `json`, `csv` -> read directly.
- `pdf` -> read (page ranges if large). If extraction yields no usable text ->
  degrade (`unsupported-format`).
- `docx`, `pptx`, `xlsx` -> attempt; if not readable -> degrade (`unsupported-format`).
- images (`png`, `jpg`, etc.) -> read visually and describe relevant content; if
  purely decorative -> mark as such.
- empty file (0 bytes / only whitespace) -> `empty`.
- anything else / unreadable -> degrade.

**Encoding (UTF-8) triage — important.** The MURIC run hit a UTF-8 read error and
the files had to be re-encoded by hand. When reading a text file FAILS due to
encoding (not valid UTF-8, mojibake / replacement chars), do NOT abort the phase:
catch it, classify the file as `encoding`, and continue with the rest. Suggested
action: "guardar/convertir el archivo a UTF-8 y re-ejecutar intake".

**Classify every non-processable file by motive** and record it in BOTH:
1. `source-index.md` — `Estado` column = `parsed | encoding | unsupported-format | empty`.
2. `initiative/intake/needs-review.md` — a single, clear human-facing checklist:

```markdown
# Archivos a revisar — {YYYY-MM-DD HH:MM}

| Archivo | Subcarpeta | Motivo | Acción sugerida |
|---|---|---|---|
| catalogo.xlsx | 06-docs-tecnicos | unsupported-format | exportar a CSV/MD y re-ejecutar |
| notas.txt | 03-reuniones | encoding | guardar como UTF-8 y re-ejecutar |
```

NEVER fail the phase because a file is unreadable or mis-encoded. Add the count to
`risks` and set `status: warning`. If `needs-review.md` has zero rows, write it
with an explicit "Sin archivos pendientes de revisión."

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

**Anti-invención (regla dura):** toda afirmación DEBE rastrear a una fuente. No
inventes cifras, umbrales, nombres de personas/sistemas, ni expansiones de siglas
que no estén en las fuentes. Lo desconocido se marca `[sin confirmar]` o va a
`## Vacíos detectados` — nunca se rellena con suposiciones.

### Step 3.5: Build the External Glossary

Extract a glossary of domain terms and acronyms used across the sources and write
it to **`initiative/glossary.md`** (external file, NOT inline in intake.md). One
section per term so it has a stable anchor:

```markdown
# Glosario — {Iniciativa}

## SFC
- **Nombre completo:** [sin confirmar]
- **Definición:** {si la fuente la define, si no "[sin confirmar]"}
- **Fuente:** (06-docs-tecnicos/...)

## CUIF
- **Nombre completo:** {...}
...
```

For each acronym, give its **full name SOLO si aparece en las fuentes**; if the
sources never expand it, write `[sin confirmar]` — do NOT guess. The heading
`## SFC` yields the anchor `#sfc` that SPEC/HU link to
(`initiative/glossary.md#sfc`). In `intake.md`, keep only a one-line pointer:
`> Glosario: ver initiative/glossary.md`. These canonical names are reused
downstream.

### Step 4: Write the Digest (initiative mode only)

Write `initiative/intake/intake.md`:

```markdown
# Intake — {Iniciativa}

## Resumen ejecutivo
{3-6 líneas: de qué trata la iniciativa, según las fuentes}

> Glosario: ver [initiative/glossary.md](../glossary.md)

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
- [CRITICAL] {gap que BLOQUEA HUs — incluir acción y, si se conoce, stakeholder}
- {gap normal: insumo faltante para specs}
```

The external `initiative/glossary.md` is mandatory (aunque tenga pocas entradas).
`## Vacíos detectados` is
mandatory: prefix con `[CRITICAL]` los gaps que bloquean historias (ej. una
query/insumo no documentado), con su acción de resolución; el resto son gaps
normales (subcarpetas vacías, docs ilegibles, scope indefinido, sin
target_projects reales).

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

- Read ONLY under `sources/`. Ignore `resources/` and any other repo directory.
- NEVER fail the phase due to an unreadable file; degrade and warn.
- Cite sources; do not dump full documents.
- **Anti-invención:** do not invent content, figures, thresholds, names, or
  acronym expansions absent from `sources/`. Unknown -> `[sin confirmar]` or a gap.
- Glossary acronyms: full name only if the sources define it; else `[sin confirmar]`.
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
    { "name": "glossary", "path": "initiative/glossary.md", "type": "markdown" },
    { "name": "source-index", "path": "initiative/intake/source-index.md", "type": "markdown" },
    { "name": "needs-review", "path": "initiative/intake/needs-review.md", "type": "markdown" }
  ],
  "awaiting_approval": true,
  "next_recommended": "SPEC",
  "risks": ["files needing review (encoding/unsupported-format), detected gaps"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
