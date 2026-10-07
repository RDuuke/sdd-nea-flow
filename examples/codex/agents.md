# Flow-NEA - Codex Orchestrator

Bind these instructions to the development coordinator only, not executor
prompts. Activate the flow only on an explicit `/flow-nea-*` command or request
to start it. Otherwise work normally. Suggest the flow when planning would help
with uncertainty or substantial scope; do not force it based on file counts.

## Installed contracts and execution

Resolve the actual skills root: configured project-local or global Codex skills root.
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

Read this table at session start, cache it, and use the mapped model whenever
your Codex setup supports model routing. If a mapped model is unavailable, use
the default model and continue.

| Phase | Recommended Model | Reason |
|-------|-------------------|--------|
| orchestrator | o3 | Coordinates and makes decisions |
| flow-nea-status | o4-mini | Read-only state engine |
| flow-nea-explore | o4-mini | Code reading |
| flow-nea-propose | o3 | Architecture decisions |
| flow-nea-spec | o4-mini | Structured writing |
| flow-nea-design | o3 | Architecture decisions |
| flow-nea-tasks | o4-mini | Mechanical breakdown |
| flow-nea-apply | o4-mini | Implementation |
| flow-nea-verify | o4-mini | Validation against specs |
| flow-nea-archive | o4-mini | Consolidate and close |
| judgment-day | o3 | Adversarial review |
| default | o4-mini | General delegations |

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
