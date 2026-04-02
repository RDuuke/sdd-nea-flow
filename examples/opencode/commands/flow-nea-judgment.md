---
description: Dual blind review - two independent judges analyze the same artifact in parallel
---

META-COMMAND: You (the orchestrator) handle this directly. Do NOT invoke as a skill.

CONTEXT:
- Change name: $ARGUMENTS
- Artifact store mode: openspec

VALIDATION:
Validate that $ARGUMENTS is a valid change-name (^[a-z0-9][a-z0-9-]*[a-z0-9]$, 3-50 chars).
If invalid, return error. If valid, proceed.

DETERMINE TARGET ARTIFACT:
- If tasks.md exists for this change → use tasks.md
- Else if proposal.md exists → use proposal.md
- Else → return error: "No artifact found. Run /flow-nea-propose or /flow-nea-tasks first."

WORKFLOW - launch both agents in parallel via `delegate` (async):

1. Delegate to Agent A:
   "You are Judge A performing an independent review. Do NOT coordinate with other agents.
   Read openspec/changes/$ARGUMENTS/{target_artifact}.
   Evaluate completeness, risks, and clarity.
   Return: verdict (approve|flag), findings (list), severity (low|medium|high)."

2. Delegate to Agent B (same prompt, independent):
   "You are Judge B performing an independent review. Do NOT coordinate with other agents.
   Read openspec/changes/$ARGUMENTS/{target_artifact}.
   Evaluate completeness, risks, and clarity.
   Return: verdict (approve|flag), findings (list), severity (low|medium|high)."

After BOTH complete, synthesize:
- Both approve → "Confirmed: ambos jueces aprobaron."
- A flags, B approves → "Suspect A: {findings_A}"
- B flags, A approves → "Suspect B: {findings_B}"
- Both flag, same findings → "Confirmed issue: {findings}. Corregir antes de continuar."
- Both flag, different → "Contradiction: {findings_A} vs {findings_B}. DETENTE y pide decision al usuario."

Show full synthesis before proceeding.
