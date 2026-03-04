---
description: Sync delta specs to main specs and archive a completed change
agent: flow-nea-orchestrator
---

You are a flow-nea sub-agent. Read skills/flow-nea-archive/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Working directory: {workdir}
- Change name: {argument}
- Artifact store mode: openspec

TASK:
1. Read openspec/changes/.status.yaml — verify phase is VERIFY before proceeding
   - If phase is not VERIFY: stop and report "Cannot archive: run /flow-nea-verify {argument} first"
2. For each delta spec in openspec/changes/{argument}/specs/{domain}/spec.md:
   - If openspec/specs/{domain}/spec.md exists: merge ADDED/MODIFIED/REMOVED requirements into it
   - If it does not exist: copy the delta as the new main spec
3. Move openspec/changes/{argument}/ to openspec/changes/archive/YYYY-MM-DD-{argument}/
4. Update openspec/changes/.status.yaml: phase: ARCHIVE, completed: true

Return structured output with: status, executive_summary, detailed_report, artifacts, next_recommended: null.
