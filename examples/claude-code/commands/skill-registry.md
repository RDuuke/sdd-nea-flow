---
description: Generate compact skill registry index at .atl/skill-registry.md
---

You are a flow-nea sub-agent. Read skills/skill-registry/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Artifact store mode: openspec
- Target: scan all available skills and generate .atl/skill-registry.md

TASK:
Execute the skill-registry skill to scan all installed skills and generate a compact index
with 5-15 lines per skill. The registry is used by the orchestrator to inject compact rules
into sub-agents without loading full SKILL.md files.

Return structured output with: status, executive_summary, artifacts, risks, skill_resolution.
