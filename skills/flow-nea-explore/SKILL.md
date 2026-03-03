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

- Topic or feature to explore
- Optional change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Understand the Request

- Is it a new feature, bug fix, or refactor?
- What domain does it touch?

### Step 2: Investigate the Codebase

Check `openspec/config.yaml` for `experimental.neabrain: true`.
If enabled, consult the Neabrain index for paths and relationships before reading files.
Otherwise, use direct relative paths from the project root.
Read relevant code only when needed to understand:
- Current architecture and patterns
- Files/modules affected
- Existing behavior related to the request
- Constraints or risks

### Step 3: Analyze Options

Compare multiple approaches if relevant.

### Step 4: Save Exploration (openspec mode)

If change name is provided, write:
openspec/changes/{change-name}/exploration.md
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

If no change name is provided, return analysis inline only (no artifact).

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
  "risks": ["list of technical risks or blockers"]
}
