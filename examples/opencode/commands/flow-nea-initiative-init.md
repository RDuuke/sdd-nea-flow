---
description: Bootstrap an initiative repository (scaffold sources/ + initiative/, validate Definition of Ready)
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-initiative-init/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Initiative slug: {argument}
- Artifact store mode: initiative

VALIDATION:
Validate that {argument} is a valid slug: ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (3-50 chars).
If INVALID: return error to user and stop.

TASK:
1. Scaffold sources/01..06 (with per-folder README) and initiative/ (intake/, specs/) if missing.
2. Create initiative/config.yaml with the full template; set initiative.name={argument}.
3. Validate the Definition of Ready and report gaps as risks.
4. Write initiative/.status.yaml with schema_version: "1.0", phase: INIT, initiative: {argument}.

Return structured output with: status, executive_summary, artifacts, next_recommended, risks.
