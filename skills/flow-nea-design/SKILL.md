---
name: flow-nea-design
description: >
  Create technical design document with architecture decisions and approach.
trigger: >
  When the orchestrator launches you to write or update technical design for a change.
license: MIT
metadata:
  author: juan-duque
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Produce design.md describing how the change will be implemented.

## What You Receive

- Change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read skills/_shared/persistence-contract.md and its state, execution, validation and audit references. Resolve them from the installed skills root.

## What to Do

Read approved proposal and selected change state first. DESIGN does not require SPEC to exist.

### Step 1: Read the Codebase

Use direct relative paths from the project root.
Read file bodies only when needed.
Identify patterns, entry points, and dependencies relevant to the change.

### Step 2: Write design.md (openspec mode)

openspec/changes/{change-name}/design.md

Read the relevant DESIGN example in
[planning-examples.md](../_shared/planning-examples.md) when useful.
Retain the agreed scope, criteria, risks and applicable rollback/validation
details; adapt structure to the change.

### Step 3: Persist (openspec mode)

- Save design to openspec/changes/{change-name}/design.md
- Write validation-plan.yaml under the audit and validation contracts, with criteria, methods, required checks, commands and expected evidence. Preserve existing project gates and record approved local exceptions.
- Merge `openspec/changes/{change-name}/.status.yaml` under state-contract.md;
  record DESIGN completion only for valid complete output, update input
  hashes and preserve independent completed phases, approvals and pending work.

### Step 3.5: NeaBrain Capture (if enabled)

If `experimental.neabrain: true` and NeaBrain available:
- For each entry in `## Architecture Decisions`, call `nbn_capture_passive` with:
  - `content`: `"[ADR] [{change-name}]: {decision title}\n\nChoice: {choice}\nRationale: {rationale}\n\nArchivos afectados: {lista}"`
  - `project`: active project name
  - `topic`: `"architecture-decisions"`
  - `tags`: [change-name, "adr"]
- One observation per decision, not one per design.md.
If unavailable, skip silently.

### Step 4: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Always read real code before designing.
- Use OpenSpec as the source of truth; do not copy code unless needed.
- Every decision must include rationale.
- Use concrete file paths.
- Follow existing patterns unless the change is about refactoring them.
- **If you don't know how to solve something, write it in Open Questions — never guess or invent a solution.** An honest open question is better than an incorrect architecture decision. If there are blocking questions without answers, report as `status: warning`.
- All artifact content MUST be written in Spanish.
- Keep design concise; use tables or snippets only when they clarify decisions. No fixed word-count gate. Load research-contract.md for useful unresolved external questions.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Design complete. X decisions documented.",
  "detailed_report": "Design notes or persistence info.",
  "artifacts": [
    {
      "name": "design",
      "path": "openspec/changes/{change-name}/design.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "SPEC | TASKS",
  "risks": [
    "list of risks or blockers"
  ],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  }
}
```

Return a single next_recommended phase from the state contract, not the literal
union shown in examples. Set action_context.blocked=true for unresolved required
inputs, material decisions or scope approval; optional warnings stay unblocked.
