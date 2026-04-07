---
name: flow-nea-quick
description: >
  Create a minimal quick blueprint for a small, low-risk fix with a single approval gate.
trigger: >
  When the orchestrator needs a low-bureaucracy path for a trivial or tightly scoped change.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Create a minimal OpenSpec artifact for a small fix that does not justify the full
planning chain. This is a shortcut for low-risk work, not a replacement for the
normal flow.

## What You Receive

- Change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## Eligibility Rules

Quick mode is allowed only when all of these are true:

- the change is a small fix, validation tweak, local rename, null check, tiny UI adjustment, or similarly bounded task
- the likely implementation stays within 1-2 files or one tightly scoped area
- there is no architecture change
- there is no need for a substantial `SPEC` or `DESIGN` discussion
- risk is low and verification is direct

Quick mode must be rejected when any of these are true:

- the change spans multiple domains or subsystems
- the behavior change is ambiguous
- the work affects core flows or broad contracts
- the implementation requires non-trivial design decisions
- the task would still need normal `proposal.md`, `specs/`, `design.md`, or `tasks.md` to be executed safely

## What to Do

### Step 1: Assess Scope

- Read only the minimum context needed to judge size, impact, and verification path
- Decide whether the change qualifies for quick mode

### Step 2: Handle Rejection

If the change does not qualify:

- Do NOT write `quick.md`
- Return `status: warning`
- Explain why the shortcut is unsafe
- Recommend the normal path with `next_recommended: "PROPOSE"`

### Step 3: Write Quick Blueprint

If openspec mode is enabled and the change qualifies:

- Create `openspec/changes/{change-name}/quick.md`
- The file MUST be written in Spanish
- Use this structure:

```markdown
# Quick Fix: {titulo breve}

## Objetivo

## Archivos afectados

## Blueprint

## Riesgos

## Verificacion
```

Content rules:

- `## Objetivo`: explain the user-visible or behavior-level outcome
- `## Archivos afectados`: list probable files, folders, or modules to touch
- `## Blueprint`: concrete implementation steps, concise but actionable
- `## Riesgos`: short list of risks, assumptions, or fallback triggers
- `## Verificacion`: specific checks, commands, or expected outcomes

### Step 4: Persist State

If openspec mode is enabled and the quick blueprint was created, update
`openspec/changes/.status.yaml` with:

```yaml
phase: QUICK
change: "{change-name}"
awaiting_approval: true
completed: false
pending_tasks: []
modified_artifacts: []
notes: "quick"
```

### Step 5: Return Summary

Return the standard envelope with:

- `status`
- `executive_summary`
- `detailed_report` when needed
- `artifacts`
- `next_recommended`
- `risks`

## Rules

- Use quick mode only for genuinely small, low-risk work
- Never create `proposal.md`, `specs/`, `design.md`, or `tasks.md` in this skill
- If the change is not clearly eligible, reject quick mode and recommend the normal flow
- All artifact content MUST be written in Spanish

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Quick blueprint created or rejected with reason.",
  "detailed_report": "Optional explanation of scope, files, and eligibility.",
  "artifacts": [
    {
      "name": "quick_blueprint",
      "path": "openspec/changes/{change-name}/quick.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "APPLY | PROPOSE",
  "risks": ["list of risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
