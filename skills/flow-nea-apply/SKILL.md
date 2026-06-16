---
name: flow-nea-apply
description: >
  Implement tasks from the change, writing actual code following specs and design.
trigger: >
  When the orchestrator launches you to implement one or more tasks from a change.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Related Skills (optional, load if available)

- **typescript-general** - Type safety and code organization (load for .ts files)
- **testing** - Test structure and TDD patterns (load for *.test.ts files)
- **form-controls** - Form component patterns (load for form/input components)
- **scss** - Styling tokens and patterns (load for .scss files)

If a related skill file does not exist at the expected path, skip it silently
and continue with implementation using your general knowledge. Do NOT fail or
block because an optional coding skill is missing. Report any missing skills as
a warning in the output envelope `risks` field.

## Purpose

Implement assigned work, update execution state, and report progress.

## What You Receive

- Change name
- Specific tasks to implement, or a quick blueprint to execute
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Read Context

Check `openspec/config.yaml` for `experimental.neabrain: true`.
If enabled, consult the Neabrain index for paths and relationships before reading files.
Otherwise, use direct relative paths from the project root.
Read file bodies only when needed:
- `tasks.md`, `design.md`, and `specs/` for the normal flow
- `quick.md` for quick mode
- relevant code and conventions

### Step 2: Detect TDD Mode

Detect TDD from (priority order):
1) openspec/config.yaml -> gates.apply.tdd (canonical)
2) openspec/config.yaml -> rules.apply.tdd (legacy fallback, deprecated)
3) skills/testing/SKILL.md (if present, TDD patterns apply)
4) Existing test patterns
Default: `false` (standard mode).

Recognized values:
- `false` -> standard mode, no gate.
- `true` or `"strict"` -> strict TDD gate active (see Step 4).

### Step 2.1: Strict TDD Gate (only if active)

When the strict gate is active, EACH task in the batch must walk a four-step
cycle. Production code MUST NOT be written before a failing test exists.

For each task:

1. **RED** — write the test, run it, confirm it fails.
2. **GREEN** — write the minimum code that makes the test pass.
3. **TRIANGULATE** (optional) — add a second test covering an edge case.
4. **REFACTOR** — clean up; all tests stay green.

Record evidence in `openspec/changes/{change-name}/apply-progress.md` using
this exact format (append per task):

```markdown
## Tarea {id} — {titulo corto}

- **RED:** test `{archivo}::{nombre}` falla con: `{mensaje corto}`
- **GREEN:** implementacion en `{archivos}`; test pasa.
- **TRIANGULATE:** test `{archivo}::{nombre}` cubre `{caso}`. (omitir si no aplica)
- **REFACTOR:** `{notas}` (omitir si no aplica)
```

If the gate is active and you cannot honor it for a task (e.g., test
infrastructure missing), STOP that task, mark `status: warning`, and report
the obstacle in `risks`. Do not silently fall back to standard mode.

### Step 2.5: Load Coding Skills (autonomous)

Based on files to be modified, attempt to load the corresponding skill before implementing.
Do not wait for the orchestrator to specify them — this is the sub-agent's responsibility:
- .ts files -> read skills/typescript-general/SKILL.md
- *.test.ts files -> read skills/testing/SKILL.md
- Form/input components -> read skills/form-controls/SKILL.md
- .scss files -> read skills/scss/SKILL.md

If a skill file does not exist, skip it and proceed with general knowledge.
Add `"Missing optional skill: {skill-name}"` to the `risks` field in your output.

### Step 3: Detect Execution Mode

Normal mode:
- `openspec/changes/{change-name}/tasks.md` exists

Quick mode:
- `openspec/changes/{change-name}/quick.md` exists and `tasks.md` does not exist, or
- `.status.yaml` indicates `phase: QUICK`

If quick mode is detected:
- read `quick.md` as the single source of implementation scope
- do not require `design.md` or `specs/`
- implement only the blueprint described in `quick.md`

### Step 4: Implement Work

- Implement only assigned tasks
- Follow existing code patterns
- Keep batch small

In quick mode:

- implement only the bounded fix defined in `quick.md`
- do not invent additional work beyond the blueprint

### Step 4.5: Review Budget Check

Read `openspec/config.yaml -> gates.apply.review_budget` (falling back to
the legacy path `rules.apply.review_budget` if present). Defaults:

```yaml
review_budget:
  max_diff_lines: 0          # 0 = gate disabled
  sensitive_paths: []        # empty = gate disabled
```

If `max_diff_lines > 0`:

1. Run `git diff --numstat HEAD` to compute total added + removed lines for
   the current working tree (or the commits made in this batch).
2. If total > `max_diff_lines`, the gate trips.

If `sensitive_paths` is non-empty:

1. List the files modified in this batch.
2. If any file matches any glob in `sensitive_paths`, the gate trips.

When the gate trips:

- Set output `status: warning`.
- Add risk: `"Review budget exceeded: {n} lines (limit {limit}); sensitive paths touched: [...]. Manual review recommended before PR."`
- Set `awaiting_approval: true` in `.status.yaml` and add `notes: "review_budget"`.
- Do NOT advance phase. `next_recommended` stays `APPLY` until user confirms,
  unless all tasks are complete in which case it becomes `VERIFY`.

If git is not available or the repo is not a git working tree, skip this
check silently and add a single risk: `"Review budget skipped: git unavailable"`.

### Step 5: Persist Progress

- If openspec mode and normal mode, update `openspec/changes/{change-name}/tasks.md`
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: APPLY
  change: "{change-name}"
  awaiting_approval: false   # true if review_budget gate tripped
  completed: false
  pending_tasks: ["list of unchecked task ids"]
  modified_artifacts: []
  notes: ""                  # "quick" | "review_budget" | "tdd_strict" as applicable
  ```

In quick mode, `pending_tasks` stays empty and `notes` should mention `quick`.
If the review budget gate tripped, `notes` MUST include `review_budget`.

### Step 6: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Load coding skills autonomously based on files to be modified; do not wait for the orchestrator to specify them.
- Always follow design decisions when `design.md` exists.
- Use OpenSpec as the source of truth; do not copy code unless needed.
- If blocked, stop and report.
- In strict TDD mode, always write the failing test first AND record evidence
  in `apply-progress.md` for every completed task. Missing evidence = the task
  is NOT done.
- When the review budget gate trips, set `awaiting_approval: true` and stop;
  do not auto-advance.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Implemented tasks X.Y through Z.W.",
  "detailed_report": "Technical summary and notes.",
  "tasks_completed": ["1.1", "1.2"],
  "tasks_pending": ["1.3"],
  "tdd_evidence": {
    "mode": "off | strict",
    "tasks": [
      { "id": "1.1", "red": true, "green": true, "triangulate": false, "refactor": false }
    ]
  },
  "review_budget": {
    "checked": true,
    "tripped": false,
    "diff_lines": 137,
    "limit": 400,
    "sensitive_paths_touched": []
  },
  "artifacts": [
    {
      "name": "tasks_or_quick_blueprint",
      "path": "openspec/changes/{change-name}/tasks.md | openspec/changes/{change-name}/quick.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "APPLY | VERIFY",
  "risks": ["list of risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```

Omit `tdd_evidence` when the strict gate is off, and `review_budget` when the
gate is disabled. Both fields are additive; consumers that ignore them MUST
keep working.
