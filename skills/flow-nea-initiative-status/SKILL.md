---
name: flow-nea-initiative-status
description: >
  Read-only status engine for the initiative layer. Produces a normalized
  envelope with the active initiative, its phase, gaps, gate state and the next
  recommended phase.
trigger: >
  When the orchestrator needs the current initiative-layer state without
  re-implementing detection logic.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Single source of truth for initiative-layer state. Mirrors `flow-nea-status` but
for the upstream initiative flow (`INIT -> INTAKE -> SPEC`).

This skill is strictly read-only. It MUST NOT modify any file.

## What You Receive

- Initiative slug (optional; derive from `.status.yaml` if absent)
- Artifact store mode (`initiative` | `none`)

## Execution and Persistence Contract

Read and follow: skills/_shared/initiative-persistence-contract.md

This skill never writes.

## What to Do

### Step 1: Resolve Active Initiative

1. If a slug was passed, use it.
2. Otherwise read `initiative/.status.yaml` and use its `initiative` field.
3. If neither is available, report `status: warning` and
   `action_context.blocked: true` with reason `"No active initiative resolved"`.

### Step 2: Detect Current Phase

Priority order:

1. `initiative/.status.yaml` -> `phase` field (canonical).
2. If `.status.yaml` is missing, infer from artifacts (first match wins):

   | Condition | Phase |
   |---|---|
   | `impact-map.yaml` exists | HU |
   | `specs/` non-empty (no `impact-map.yaml`) | SPEC |
   | `intake/intake.md` exists | INTAKE |
   | `config.yaml` exists | INIT |
   | nothing | INIT |

### Step 3: Check Dependencies and DoR

| Phase | Required artifacts |
|-------|--------------------|
| INTAKE | `config.yaml` + non-empty `sources/` |
| SPEC | `intake/intake.md` |
| HU | `specs/` (non-empty, with `CAP-xxx`) |

If the current phase's predecessor is missing, list it under
`missing_dependencies`. Also surface DoR gaps recorded by init/intake (empty
`01-negocio`/`02-producto`, placeholder `target_projects`, unreadable critical
sources) under `risks`.

### Step 3.5: Validate impact-map (read-only lint, if present)

If `initiative/impact-map.yaml` exists, run these checks WITHOUT modifying it.
Report `impact_map_valid` (boolean) and `validation_errors` (list of strings):

1. **Coverage:** every `CAP-xxx` in `initiative/specs/**/spec.md` is referenced by
   a `user_stories[].capability` OR appears in `unmapped_scope`.
2. **HU sync:** every `HU-xxx` heading in the specs has exactly one
   `user_stories` entry, and every entry's `spec_ref` resolves to an existing
   file + matching anchor.
3. **Project validity:** every `target_project.id` exists in
   `config.yaml` `target_projects`.
4. **Slug rules:** every `proposed_change_name` is a valid slug
   (`^[a-z0-9][a-z0-9-]*[a-z0-9]$`) and unique within its `target_project`.
5. **ID uniqueness:** `FEAT-*`, `CAP-*` (per Feature), `HU-*` (initiative-wide)
   are unique.

If the map is absent, set `impact_map_valid: null`. Any failure -> add a clear
message to `validation_errors` and set `impact_map_valid: false`; also surface a
short summary under `risks`. This step never writes.

### Step 4: Determine Next Phase

Dependency graph:

```text
INIT -> INTAKE -> [human-review gate] -> SPEC -> HU -> (DECOMPOSE futuro)
```

Special cases:
- If `awaiting_approval: true`, `next_phase` equals `current_phase` and
  `action_context.blocked: true` with reason `"awaiting_approval"`.
- After SPEC, `next_phase` is `HU`.
- After HU, `next_phase` is `DECOMPOSE` (out of scope; report it but do not
  attempt to run it).

### Step 5: Action Context

Populate `action_context`:
- `blocked`: `true` when phase cannot advance (awaiting review, missing
  dependency, no initiative resolved).
- `reason`: short string (max 80 chars).
- `requires_user_input`: `true` if the orchestrator must ask the user.

## Rules

- This skill never writes. If status files are corrupted, report and stop.
- Do not invoke other skills.
- Do not summarize artifact contents; only count and classify.
- All artifact content read in Spanish; report keys stay in English.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Initiative X is at INTAKE awaiting human review.",
  "initiative": "compra-de-cartera",
  "current_phase": "INTAKE",
  "next_phase": "SPEC",
  "awaiting_approval": true,
  "artifacts_present": ["config.yaml", "intake/intake.md", "source-index.md"],
  "missing_dependencies": [],
  "action_context": {
    "blocked": true,
    "reason": "awaiting_approval",
    "requires_user_input": true
  },
  "next_recommended": "SPEC",
  "risks": ["DoR gaps, unreadable sources"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
