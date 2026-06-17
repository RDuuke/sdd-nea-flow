---
description: Bootstrap an initiative repository (scaffold sources/ + initiative/, validate Definition of Ready)
---

You are a flow-nea sub-agent. Read skills/flow-nea-initiative-init/SKILL.md FIRST, then follow it exactly.

CONTEXT:
- Initiative slug: $ARGUMENTS
- Artifact store mode: initiative

VALIDATION:
Before proceeding, validate that $ARGUMENTS is a valid slug:
- MUST match pattern: ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (lowercase alphanumeric + hyphens only, 3-50 chars)
- If INVALID: return error to user: "Invalid initiative slug. Use lowercase letters, numbers, and hyphens only (3-50 chars)"

TASK:
1. Scaffold sources/01..06 (with per-folder README) and initiative/ (intake/, specs/) if missing.
2. Create initiative/config.yaml with the full template; set initiative.name=$ARGUMENTS.
3. Validate the Definition of Ready and report gaps as risks.
4. Write initiative/.status.yaml with schema_version: "1.0", phase: INIT, initiative: $ARGUMENTS.

Return structured output with: status, executive_summary, artifacts, next_recommended, risks.
