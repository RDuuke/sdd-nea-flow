# Persistence Contract (shared across all flow-nea skills)

## Mode Resolution

The orchestrator passes artifact_store.mode with one of:
- openspec
- none

If mode is missing or set to auto:
1) If OpenSpec is available -> use openspec
2) Otherwise -> use none

If mode is unknown, treat it as none and report it as unresolved.

## Behavior Per Mode

| Mode | Read from | Write to | Project files |
|------|-----------|----------|---------------|
| openspec | openspec/ | openspec/ | Only inside openspec/ |
| none | Orchestrator prompt context | Nowhere | Never |

## OpenSpec Structure

openspec/
  config.yaml
  specs/
  changes/
    archive/

Change folders live at:
openspec/changes/{change-name}/

## Status File

Path: openspec/changes/.status.yaml

Template:

```yaml
phase: INIT
change: null
awaiting_approval: false
completed: false
pending_tasks: []
modified_artifacts: []
notes: ""
```

Rules:
- If .status.yaml is missing, infer phase from existing artifacts (see flow-nea-continue rules) and create the file before proceeding.
- If legacy .status.json exists, read it, migrate values to .status.yaml, and delete the .json file.
- Never block a phase solely because .status.yaml is missing; always recover by inference.

## Out-of-Flow Artifact Modification

When an OpenSpec artifact is modified outside a phase skill (by the orchestrator inline or a general sub-agent), the orchestrator MUST:
1. Add the artifact to `modified_artifacts` in `.status.yaml`.
2. Regress `phase` according to this table:

| Modified artifact | Regress phase to |
|---|---|
| `proposal.md` | SPEC |
| `specs/` | APPLY |
| `design.md` | APPLY |
| `tasks.md` | APPLY |

3. Set `notes` with a brief description of what changed and why.
4. Inform the user that the phase was regressed and which tasks need to be re-run.

## File Access Rules

- Always use direct relative paths from the project root (e.g. `openspec/changes/{change-name}/design.md`).
- Never use glob patterns to locate OpenSpec files; paths are deterministic and known.
- Never search for `openspec/` using recursive glob; assume it lives at the project root.
- If a file does not exist at the expected path, report it as missing — do not search elsewhere.

## Experimental Features

Optional features controlled via `openspec/config.yaml` under the `experimental` key.
If the key is absent or false, the feature is disabled.

```yaml
experimental:
  neabrain: false  # Set to true to enable Neabrain index for path/relationship lookup
```

## Common Rules

- If mode is none, do not create or modify any project files.
- If mode is openspec, write files ONLY under openspec/.
- When falling back to none, recommend enabling openspec for persistence.
- Always verify path existence before reading or writing.
- All artifact content must be written in espanol. Keep filenames and paths in English.
