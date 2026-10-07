# Flow-NEA - OpenCode Orchestrator

Bind these instructions to the development coordinator only, not executor
prompts. Activate the flow only on an explicit `/flow-nea-*` command or request
to start it. Otherwise work normally. Suggest the flow when planning would help
with uncertainty or substantial scope; do not force it based on file counts.

## Installed contracts and execution

Resolve the actual skills root: project .opencode/skills or configured global OpenCode skills root.
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

Read this table at session start, cache it, and pass the model in each sub-agent call. If the model is not available, use the default model and continue.

| Phase | Recommended Model | Reason |
|-------|-------------------|--------|
| orchestrator | claude-opus | Coordinates and makes decisions |
| flow-nea-initiative-init | claude-haiku | Scaffold + Definition of Ready |
| flow-nea-initiative-intake | claude-sonnet | Read/extract initiative sources |
| flow-nea-initiative-spec | claude-opus | Detailed Features + capabilities |
| flow-nea-initiative-hu | claude-sonnet | Decompose Features into User Stories + impact-map |
| flow-nea-initiative-enrich | claude-opus | Architect/designer enrichment of a HU |
| flow-nea-initiative-status | claude-haiku | Read-only initiative state engine |
| flow-nea-explore | claude-sonnet | Code reading |
| flow-nea-propose | claude-opus | Architecture decisions |
| flow-nea-spec | claude-sonnet | Structured writing |
| flow-nea-design | claude-opus | Architecture decisions |
| flow-nea-tasks | claude-sonnet | Mechanical breakdown |
| flow-nea-apply | claude-sonnet | Implementation |
| flow-nea-verify | claude-sonnet | Validation against specs |
| flow-nea-archive | claude-haiku | Consolidate and close |
| judgment-day | claude-opus | Adversarial review |
| default | claude-sonnet | General delegations |

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
per initiative, e.g. `compra-de-cartera`). It ingests business/product sources and
produces general specs, distinct from the per-project change flow above.

Azure DevOps mapping (metadata only, NO API in this phase): initiative ≈ Epic,
general spec (`initiative/specs/{domain}/spec.md`) = Feature, change candidate
(`initiative/impact-map.yaml`) = User Story (HU).

### Sub-graph (runs in the initiative repo)

```text
INITIATIVE-INIT -> INTAKE -> [human-review gate] -> SPEC (Features) -> HU (User Stories) -> (ENRICH opcional) -> (DECOMPOSE futuro) ⤳ seed de HU en cl00xx
```

SPEC writes detailed Features (capabilities `CAP-xxx`). HU decomposes Features into
User Stories — one folder per HU (`specs/{domain}/hu/HU-xxx/` with `HU-xxx.md` +
`assets/`) — keeps a TOC in the Feature spec, flags HUs needing architect/designer,
and emits the lean `initiative/impact-map.yaml`. Run by PMO; batchable per Feature.

ENRICH is an out-of-band specialist pass: architect (`/flow-nea-initiative-arch`)
or designer (`/flow-nea-initiative-design`) fills the HU's notes / Figma links and
flips `enrichment.{role}.status`. It never moves the stored phase.

The seam to the per-project flow is `initiative/impact-map.yaml`. DECOMPOSE/seed is
OUT OF SCOPE; this layer only emits the map, never writes into cl00xx.

### Commands

- `/flow-nea-initiative-init <slug>` -> scaffold `sources/`+`initiative/`, config/status, Definition of Ready
- `/flow-nea-initiative-intake <slug>` -> ingest `sources/01..06` -> `intake.md` + `source-index.md`
- `/flow-nea-initiative-spec <slug>` -> detailed general specs (Features + capabilities)
- `/flow-nea-initiative-hu <slug>` -> decompose Features into User Stories (one folder per HU) + `impact-map.yaml`
- `/flow-nea-initiative-arch <slug> HU-xxx` -> architect enriches a HU
- `/flow-nea-initiative-design <slug> HU-xxx` -> designer enriches a HU (Figma links, assets)
- `/flow-nea-initiative-ff <slug>` -> meta-command (ATTENDED): init -> intake, STOP at human-review gate before spec
- `/flow-nea-initiative-auto <slug>` -> meta-command (UNATTENDED): init -> intake (auto-approved) -> spec -> hu, no stop. For PMO-absent runs. ENRICH/DECOMPOSE not run.

Unattended: set `gates.intake.require_human_review: false` for permanent
auto-approval, or use `/flow-nea-initiative-auto` to override the gate for one
run. In unattended mode accept the HU skill's enrichment flags as-is and report
`architecture_candidates`/`design_candidates` for later routing; still STOP on
`status: failed` or empty `01-negocio`/`02-producto`.

### Quality rules (initiative layer)

- Sources dir is ALWAYS `sources/`; `resources/` is general-repo data (skills ignore it).
- Anti-invención: claims trace to a source or are `[sin confirmar]`/GAP. INTAKE builds
  a `## Glosario` (acronyms expanded only if sources define them); SPEC/HU reuse it.
- SPEC altitude: CAP = business outcome; technical facts -> `## Decisiones técnicas`.
  Every CAP needs a testable AC; gating CAPs need a measurable threshold.
- `[CRITICAL]` intake gaps -> HU `status: blocked` + `blockers[]`. The status skill
  reports `blocked_hus`, `enrichment_pending`, `placeholder_projects`.

### State Protocol (initiative layer)

- State lives in `initiative/.status.yaml` (schema 1.0: `phase: INIT|INTAKE|SPEC|HU`),
  NOT in `openspec/changes/.status.yaml`.
- Delegate to `flow-nea-initiative-status` (haiku, read-only) for phase/gaps/gate.
- INTAKE sets `awaiting_approval: true` when `gates.intake.require_human_review`:
  STOP and ask the user to review `intake.md` before SPEC.
- Surface Definition-of-Ready gaps from init; do not force SPEC.
