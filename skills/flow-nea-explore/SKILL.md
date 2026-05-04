---
name: flow-nea-explore
description: >
  Explore and investigate ideas before committing to a change.
trigger: >
  When the orchestrator launches you to think through a feature or investigate the codebase.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

You investigate the codebase, compare approaches, and return a structured analysis.
By default you research, report back, and persist the analysis when a change name is provided.

## What You Receive

- Topic or feature to explore (always provided)
- Optional change name (if provided and valid, use for artifact persistence)
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Understand the Request

- Is it a new feature, bug fix, or refactor?
- What domain does it touch?

### Step 1.5: NeaBrain Enrichment (if enabled)

Check `openspec/config.yaml` for `experimental.neabrain: true`.
If enabled and NeaBrain MCP available (see persistence-contract.md availability check):
- Call `nbn_search` with query = `"{topic} {change-name}"` and the active project name.
- If results found, inject as context under heading `## Conocimiento previo relevante`.
- Prior observations enrich analysis only — never override what real code says.
If disabled or unavailable, skip silently.

### Step 2: Investigate the Codebase

Use direct relative paths from the project root.
Read relevant code only when needed to understand:
- Current architecture and patterns
- Files/modules affected
- Existing behavior related to the request
- Constraints or risks

### Step 3: Analyze Options

Compare multiple approaches if relevant.

### Step 4: Save Exploration (openspec mode)

If a valid change-name is provided (see Change Name Validation in
persistence-contract.md), write:
- openspec/changes/{change-name}/exploration.md
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: EXPLORE
  change: "{change-name}"
  awaiting_approval: false
  completed: false
  pending_tasks: []
  modified_artifacts: []
  notes: ""
  ```

If no change-name is provided or is invalid, return analysis inline only (no
artifact). The topic itself is NOT used as a change-name for persistence
purposes.

### Step 4.5: NeaBrain Capture (if enabled)

If `experimental.neabrain: true` and change-name valid and NeaBrain available:
- Call `nbn_capture_passive` with:
  - `content`: `"[EXPLORE] [{change-name}]: {titulo}\n\n{hallazgos clave}\n\nArchivos afectados: {lista}"`
  - `project`: active project name
  - `topic`: `"explore"`
  - `tags`: [change-name, "explore"]
If unavailable, skip silently.

### Step 5: Return Structured Analysis

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Do not modify code.
- Always read real code, do not guess.
- Keep analysis concise.
- If request is too vague, ask for clarification.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "High-level summary for the orchestrator.",
  "detailed_report": "Full technical breakdown.",
  "artifacts": [
    {
      "name": "explore",
      "path": "openspec/changes/{change-name}/exploration.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "PROPOSE",
  "risks": ["list of technical risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
