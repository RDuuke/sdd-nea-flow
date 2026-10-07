# Flow-NEA - Claude Code Orchestrator

Bind these instructions to the development coordinator only, not executor
prompts. Activate the flow only on an explicit `/flow-nea-*` command or request
to start it. Otherwise work normally. Suggest the flow when planning would help
with uncertainty or substantial scope; do not force it based on file counts.

## Installed contracts and execution

Resolve the actual skills root: project .claude/skills or configured global Claude skills root.
Check paths before reading; do not assume source-checkout paths exist in a
target project. Read `_shared/execution-contract.md` and
`_shared/persistence-contract.md` from that root, following their applicable
state, validation and audit references. These are the canonical development
rules for routing, approvals, recovery, logging and phase handoffs.

Deliver resolved exact phase/related skill paths under `## Skills to load before
work`; the executor reads their full bodies. Include compact project rules
under `## Project Standards (auto-resolved)`, bounded artifact/task context,
authorized edit surfaces and agreed checks. Summaries do not replace a skill.

Delegate by risk, independence and context pressure when actual permitted tools
support it; otherwise execute sequential bounded phase units inline. Mechanical
multi-file work does not force delegation. Use the native supported worker tool
with the configured model; observe terminal results before advancing. Serialize
shared writes. Do not assume generic `task`/`delegate` commands exist on every
platform. Explicit dual review requires independent reviewers; disclose if
unavailable. The separate initiative layer, where present, keeps its own rules.

## Model Assignment

Read this table at session start, cache it, and pass the mapped model in every
Agent call. If the assigned model is not available, use `sonnet` and continue.

| Phase | Model | Reason |
|-------|-------|--------|
| orchestrator | opus | Coordinates and makes decisions |
| flow-nea-status | haiku | Read-only state engine |
| flow-nea-initiative-init | haiku | Scaffold + Definition of Ready |
| flow-nea-initiative-intake | sonnet | Read/extract initiative sources |
| flow-nea-initiative-spec | opus | Detailed Features + capabilities |
| flow-nea-initiative-hu | sonnet | Decompose Features into User Stories + impact-map |
| flow-nea-initiative-enrich | opus | Architect/designer enrichment of a HU |
| flow-nea-initiative-status | haiku | Read-only initiative state engine |
| flow-nea-explore | sonnet | Reads code, structural analysis |
| flow-nea-propose | opus | Architecture decisions |
| flow-nea-spec | sonnet | Structured writing |
| flow-nea-design | opus | Architecture decisions |
| flow-nea-tasks | sonnet | Mechanical breakdown |
| flow-nea-apply | sonnet | Implementation |
| flow-nea-verify | sonnet | Validation against specs |
| flow-nea-archive | haiku | Consolidate and close |
| judgment-day | opus | Adversarial review |
| default | sonnet | General delegations |

## Commands

Phase commands run the corresponding exact SKILL.md: INIT, EXPLORE, PROPOSE,
SPEC, DESIGN, TASKS, APPLY, VERIFY and ARCHIVE (`/flow-nea-{phase}`).
Slash shortcuts are coordinator-owned, not additional executor phases:

- `/flow-nea-ff <change>`: PROPOSE, scope approval once, then missing SPEC/DESIGN
  independently and TASKS. Finish planning; no implicit implementation.
- `/flow-nea-quick <change>`: QUICK skill creates blueprint/validation plan;
  approved scope then APPLY -> VERIFY -> ARCHIVE when archive_ready is current.
- `/flow-nea-continue [change]`: read the exact continue skill as a bounded
  recovery procedure in the coordinator, then execute the next ready phase.
- `/flow-nea-fix <change>`: structured product findings from verify-report.yaml;
  targeted APPLY -> VERIFY, at most two persisted cycles. Legacy fallback only
  if YAML is absent. Infrastructure/evidence blockers need recovery, not edits.
- `/flow-nea-judgment <change>`: load judgment-day and run independent dual review
  with the same target and blind prompts. Preserve its output/synthesis contract.

```text
INIT -> EXPLORE -> approved PROPOSE -> SPEC ---+
                                     DESIGN -+-> TASKS -> APPLY -> VERIFY -> ARCHIVE
INIT/EXPLORE -> approved QUICK -> APPLY -> VERIFY -> ARCHIVE
```

Direct PROPOSE can use sufficient supplied context without EXPLORE. PROPOSE is
coordinator-dispatched through its skill even where exposed as a slash shortcut.
All phase outputs keep the standard JSON contract and phase-specific fields.

## Optional research and delivery

Load `_shared/research-contract.md` for useful external investigation within
EXPLORE/design. It is not a mandatory phase. Load `_shared/delivery-contract.md`
when asked to prepare commits, an issue or a PR. Preserve the chosen branch,
destination policy and authorization. Delivery does not follow ARCHIVE
automatically. No Engram or memory mirror is required or used by this workflow.

## Initiative Layer (upstream)

A separate UPSTREAM layer runs in a dedicated **initiative repository** (one repo
per initiative, e.g. `compra-de-cartera`). It ingests business/product source
documents and produces general specs, leaving a seam for a future change
pipeline. It is distinct from the per-project change flow above.

Conceptual mapping to Azure DevOps (metadata only, NO API in this phase):

| Initiative artifact | Azure work item |
|---|---|
| initiative | Epic (optional, reserved) |
| general spec (`initiative/specs/{domain}/spec.md`) | Feature |
| change candidate (`initiative/impact-map.yaml`) | User Story (HU) |

### Dependency Sub-graph (runs in the initiative repo)

```text
INITIATIVE-INIT -> INTAKE -> [human-review gate] -> SPEC (Features) -> HU (User Stories) -> (ENRICH opcional) -> (DECOMPOSE futuro) ⤳ seed de HU en cl00xx
```

SPEC writes the detailed Features (capabilities `CAP-xxx`). HU decomposes each
Feature into User Stories — **one folder per HU** (`specs/{domain}/hu/HU-xxx/`
with `HU-xxx.md` + `assets/`) — keeps a table of contents in the Feature spec,
flags HUs needing an architect and/or designer, and emits the lean
`initiative/impact-map.yaml`. HU is orchestrator-driven, batchable per Feature.

This flow is run by **PMO**. After HU, the orchestrator surfaces the flagged HUs
(`architecture_candidates`, `design_candidates`) and asks PMO to confirm. A
specialist then enters out-of-band:
- architect -> `/flow-nea-initiative-arch <slug> HU-xxx` (fills `## Notas de arquitecto`)
- designer -> `/flow-nea-initiative-design <slug> HU-xxx` (fills `## Diseño (UX/UI)`, Figma links, assets)
ENRICH updates the HU's `enrichment.{role}.status` (pending -> done) and never
moves the stored phase (like SPEC-FIX).

The seam between this layer and the per-project flow (`INIT -> ... -> ARCHIVE`
inside each cl00xx) is `initiative/impact-map.yaml`. DECOMPOSE/seed is OUT OF
SCOPE today; the initiative layer only emits the map, never writes into cl00xx.

### Commands

Skills:
- `/flow-nea-initiative-init <slug>` -> scaffold `sources/`+`initiative/`, write config/status, validate Definition of Ready
- `/flow-nea-initiative-intake <slug>` -> ingest `sources/01..06` into `intake.md` + `source-index.md` (graceful degradation for pdf/docx/img)
- `/flow-nea-initiative-spec <slug>` -> write detailed general specs (Features + capabilities)
- `/flow-nea-initiative-hu <slug>` -> decompose Features into User Stories (one folder per HU) + emit `impact-map.yaml`
- `/flow-nea-initiative-arch <slug> HU-xxx` -> architect enriches a HU (`## Notas de arquitecto`)
- `/flow-nea-initiative-design <slug> HU-xxx` -> designer enriches a HU (`## Diseño (UX/UI)`, Figma links, assets)

Meta-commands handled by the orchestrator:
- `/flow-nea-initiative-ff <slug>` -> ATTENDED: run init -> intake, then STOP at the human-review gate before spec
- `/flow-nea-initiative-auto <slug>` -> UNATTENDED: run init -> intake -> spec -> hu end-to-end WITHOUT stopping at the human-review gate (use when PMO is absent). Stops only on failure or empty `01-negocio`/`02-producto`. ENRICH and DECOMPOSE are NOT run.

### Unattended / auto-approval

When PMO is absent, the human-review gate after INTAKE can be auto-approved two ways:
1. Set `gates.intake.require_human_review: false` in `initiative/config.yaml` —
   INTAKE then sets `awaiting_approval: false` and the flow continues to SPEC.
2. Run `/flow-nea-initiative-auto <slug>` — the orchestrator overrides the gate
   for that single run (it does not edit config) and chains SPEC + HU.

In unattended mode the orchestrator accepts the HU skill's enrichment flags
as-is (no PMO confirmation) and reports `architecture_candidates` /
`design_candidates` so specialists can be routed later. It must still STOP and
report if INIT finds empty `01-negocio`/`02-producto` (no real input to ingest)
or any phase returns `status: failed`.

### State Protocol (initiative layer)

- Initiative state lives in `initiative/.status.yaml` (schema 1.0:
  `phase: INIT|INTAKE|SPEC`), NOT in `openspec/changes/.status.yaml`.
- Delegate to `flow-nea-initiative-status` (haiku, read-only) for current phase,
  gaps, and gate state. Do not read `.status.yaml` inline.
- INTAKE sets `awaiting_approval: true` when `gates.intake.require_human_review`
  is true: STOP and ask the user to review `intake.md` before SPEC.
- If init reports Definition-of-Ready gaps (empty `01-negocio`/`02-producto`,
  placeholder `target_projects`), surface them and do not force SPEC.

### Quality rules (initiative layer)

- Sources dir is ALWAYS `sources/`. `resources/` is general-repo data — skills
  ignore it (never read/inventory).
- Anti-invención: every claim traces to a source or is marked `[sin confirmar]`/GAP.
  INTAKE builds a `## Glosario` (acronyms expanded only if the sources define them);
  SPEC/HU reuse those canonical names. Never fabricate figures/thresholds/names.
- SPEC altitude: CAP statements are business outcomes; technical/regulatory facts
  live in `## Decisiones técnicas`. Every CAP needs a testable AC; gating CAPs need
  a measurable threshold.
- INTAKE marks `[CRITICAL]` gaps; HU turns them into `status: blocked` HUs with
  `blockers[]` in the impact-map. `flow-nea-initiative-status` reports
  `blocked_hus`, `enrichment_pending`, and `placeholder_projects`.

### Phase Read/Write Rules (initiative layer)

| Phase | Reads | Writes |
|-------|-------|--------|
| `flow-nea-initiative-init` | repo root, existing `initiative/` | `initiative/config.yaml`, `.status.yaml`, scaffold |
| `flow-nea-initiative-intake` | `sources/01..06` | `initiative/intake/intake.md`, `source-index.md` |
| `flow-nea-initiative-spec` | `initiative/intake/intake.md`, `config.yaml` | `initiative/specs/` (Features + capabilities) |
| `flow-nea-initiative-hu` | `initiative/specs/`, `config.yaml` | HU folders under `initiative/specs/{domain}/hu/`, spec TOC, `initiative/impact-map.yaml` |
| `flow-nea-initiative-enrich` | one HU file + `impact-map.yaml` | that HU file + `assets/`, its `impact-map` entry, spec TOC row |
| `flow-nea-initiative-status` | `initiative/.status.yaml` + tree | — (read-only) |
