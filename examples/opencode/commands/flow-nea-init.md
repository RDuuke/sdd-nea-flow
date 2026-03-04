---
description: Initialize flow-nea context in the current project
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-init/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Artifact store mode: openspec

TASK:
1. Detect the project stack by reading: package.json, go.mod, pyproject.toml, Cargo.toml, pom.xml (whichever exists)
2. Detect conventions: linters, test frameworks, CI config files
3. If openspec/ does not exist, create the full structure:
   openspec/config.yaml, openspec/specs/, openspec/changes/, openspec/changes/archive/
4. If openspec/config.yaml does not exist, create it with detected stack values
5. Write openspec/changes/.status.yaml with schema_version: "1.3", phase: INIT, change: null

Return structured output with: status, executive_summary, artifacts, next_recommended.
