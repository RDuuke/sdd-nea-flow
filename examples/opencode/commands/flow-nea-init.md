---
description: Initialize flow-nea context in the current project
agent: flow-nea-orchestrator
---

Dispatch only INIT for change {argument}, artifact_store.mode=openspec.
Resolve the actual installed skills root and pass the exact
flow-nea-init/SKILL.md path under `## Skills to load before work`.
Read that full skill and applicable `_shared/execution-contract.md` and
`_shared/persistence-contract.md` references. Do not assume a source-checkout path.
Use STATUS, approval/dependency handling and result logging from those contracts.
Supply scoped project standards, artifact/task IDs, edit surfaces and agreed checks.
Choose inline or native worker execution by risk/context and actual permissions,
not file count. Return the phase's standard JSON with its specific fields.
