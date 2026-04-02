---
description: Dual blind review - two independent judges analyze the same artifact in parallel
---

META-COMMAND: You (the orchestrator) handle this directly. Do NOT invoke as a skill.

CONTEXT:
- Change name: $ARGUMENTS
- Artifact store mode: openspec

VALIDATION:
Before proceeding, validate that $ARGUMENTS is a valid change-name:
- MUST match pattern: ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (lowercase alphanumeric + hyphens only, 3-50 chars)
- If INVALID: return error to user with the format requirements
- If VALID: proceed to WORKFLOW below

DETERMINE TARGET ARTIFACT:
- If tasks.md exists for this change → use tasks.md as the review target
- Else if proposal.md exists → use proposal.md
- Else → return error: "No artifact found to review. Run /flow-nea-propose or /flow-nea-tasks first."

WORKFLOW - launch both agents in parallel (do NOT show intermediate results):

1. Launch Agent A with prompt:
   "You are Judge A performing an independent review. Do NOT coordinate with other agents.
   Read openspec/changes/$ARGUMENTS/{target_artifact} carefully.
   Evaluate: (1) completeness — are there missing requirements or tasks?
   (2) risks — what could go wrong during implementation?
   (3) clarity — are specs/tasks unambiguous and actionable?
   Return a structured verdict with: verdict (approve|flag), findings (list), severity (low|medium|high)."

2. Launch Agent B with prompt:
   "You are Judge B performing an independent review. Do NOT coordinate with other agents.
   Read openspec/changes/$ARGUMENTS/{target_artifact} carefully.
   Evaluate: (1) completeness — are there missing requirements or tasks?
   (2) risks — what could go wrong during implementation?
   (3) clarity — are specs/tasks unambiguous and actionable?
   Return a structured verdict with: verdict (approve|flag), findings (list), severity (low|medium|high)."

After BOTH agents complete, synthesize:
- Both approve → "Confirmed: ambos jueces aprobaron. Puedes continuar."
- A flags, B approves → "Suspect A: el Juez A detecto problemas. Revisar: {findings_A}"
- B flags, A approves → "Suspect B: el Juez B detecto problemas. Revisar: {findings_B}"
- Both flag → evaluate overlap:
  - Same findings → "Confirmed issue: {findings}. Corregir antes de continuar."
  - Different findings → "Contradiction: los jueces no coinciden. Detente y decide: {findings_A} vs {findings_B}"

Always show the full synthesis to the user before proceeding to the next phase.
