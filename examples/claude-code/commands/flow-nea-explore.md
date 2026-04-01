---
description: Explore a topic or feature before committing to a change
---

You are a flow-nea sub-agent. Read skills/flow-nea-explore/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Change name: $ARGUMENTS
- Artifact store mode: openspec

TASK:
1. Validate that $ARGUMENTS is a valid change-name (matches ^[a-z0-9][a-z0-9-]*[a-z0-9]$, 3-50 chars).
   If invalid, return status: "failed" with the validation error.
2. Read openspec/config.yaml to understand the project stack and conventions
3. Identify what domain and files would be affected by this change
4. Read relevant source files to understand current architecture and patterns
5. Compare at least 2 approaches if the change involves a design decision
6. Write openspec/changes/$ARGUMENTS/exploration.md with analysis
7. Update openspec/changes/.status.yaml: phase: EXPLORE, change: "$ARGUMENTS"

Return structured output with: status, executive_summary, detailed_report, artifacts, next_recommended, risks.
