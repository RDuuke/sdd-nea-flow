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

## Common Rules

- If mode is none, do not create or modify any project files.
- If mode is openspec, write files ONLY under openspec/.
- When falling back to none, recommend enabling openspec for persistence.
- Always verify path existence before reading or writing.
