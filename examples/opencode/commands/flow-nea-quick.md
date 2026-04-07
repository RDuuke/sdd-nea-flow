---
description: Quick end-to-end shortcut for a small, low-risk fix
agent: flow-nea-orchestrator
---

META-COMMAND: You (the orchestrator) handle this directly.
Do NOT invoke `/flow-nea-quick` as a user-facing phase skill.

CONTEXT:
- Working directory: {workdir}
- Change name: {argument}
- Artifact store mode: openspec

VALIDATION:
1. Validate that {argument} is a valid change-name:
   - MUST match pattern: ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (lowercase alphanumeric + hyphens only, 3-50 chars)
   - If invalid: return error to user: "Invalid change name. Use lowercase letters, numbers, and hyphens only (3-50 chars)"

WORKFLOW:
1. Read `openspec/changes/.status.yaml` if it exists.
2. If `openspec/changes/{argument}/quick.md` does not exist:
   - Launch Task with prompt:
     "You are a flow-nea sub-agent. Read skills/flow-nea-quick/SKILL.md FIRST.
     change-name={argument} artifact_store.mode=openspec workdir={workdir}
     Write openspec/changes/{argument}/quick.md if the change qualifies. Return JSON."
   - If the quick skill returns `warning` or `failed`, stop and show the result.
   - After successful creation, STOP and ask the user to review `openspec/changes/{argument}/quick.md` and approve the shortcut.
3. If `quick.md` already exists and `.status.yaml` says `awaiting_approval: true`, ask the user to confirm the quick blueprint before continuing.
4. When the user explicitly approves:
   - Update `openspec/changes/.status.yaml` to keep `phase: QUICK` and set `awaiting_approval: false`
   - Launch `/flow-nea-apply` logic for `{argument}`
   - If apply succeeds, launch `/flow-nea-verify` logic for `{argument}`
   - If verify returns `status: ok`, launch `/flow-nea-archive` logic for `{argument}`
5. Finalization rules:
   - If verify returns `warning` or `failed`, STOP and show the verification result. Do not archive.
   - If archive succeeds, tell the user the quick flow is complete and archived.

RULES:
- `flow-nea-quick` has a single approval gate on `quick.md`
- After approval, the orchestrator must run `APPLY -> VERIFY -> ARCHIVE`
- Never archive if verify is not `ok`
