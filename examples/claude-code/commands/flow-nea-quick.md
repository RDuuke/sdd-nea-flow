---
description: Create a minimal quick blueprint for a small, low-risk fix
---

You are a flow-nea sub-agent. Read skills/flow-nea-quick/SKILL.md FIRST, then follow its instructions exactly.

CONTEXT:
- Change name: $ARGUMENTS
- Artifact store mode: openspec

TASK:
1. Validate that $ARGUMENTS is a valid change-name:
   - MUST match pattern: ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (lowercase alphanumeric + hyphens only, 3-50 chars)
   - If invalid: return error to user: "Invalid change name. Use lowercase letters, numbers, and hyphens only (3-50 chars)"
2. Inspect only the minimum context needed to decide whether this qualifies for quick mode
3. If the change qualifies, write openspec/changes/$ARGUMENTS/quick.md in Spanish
4. Update openspec/changes/.status.yaml to phase QUICK with awaiting_approval: true
5. If the change does not qualify, return warning status and recommend the normal flow

After the quick blueprint is created, ask:
"Quick blueprint ready for $ARGUMENTS. Review openspec/changes/$ARGUMENTS/quick.md and then run /flow-nea-apply $ARGUMENTS"
