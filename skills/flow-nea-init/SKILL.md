---
name: flow-nea-init
description: >
  Initialize flow-nea context in a project. Detects stack and bootstraps the
  active persistence backend (OpenSpec).
trigger: >
  When user wants to initialize flow-nea or says "flow-nea init".
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

You initialize the flow-nea context, detect stack and conventions, and bootstrap
the selected persistence backend.

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Detect Project Context

- Tech stack (package.json, go.mod, pyproject.toml, etc.)
- Conventions (linters, test frameworks, CI)
- Architecture patterns

### Step 2: Initialize Persistence Backend

If mode is openspec, ensure this structure exists:

openspec/
  config.yaml
  specs/
  changes/
    archive/

If mode is none, do not create project files.

### Step 3: Generate Config (openspec mode only)

If openspec/config.yaml is missing, create it with agnostic placeholders, then
fill the context with the detected values in the same run.

Base template:

schema: flow-nea

context: |
  Tech stack: not assessed
  Architecture: not assessed
  Testing: not assessed
  Style: not assessed

rules:
  proposal:
    - Include rollback plan for risky changes
    - Identify affected modules/packages
  specs:
    - Use Given/When/Then format for scenarios
    - Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY)
  design:
    - Document architecture decisions with rationale
  tasks:
    - Group tasks by phase
    - Use hierarchical numbering (1.1, 1.2, etc.)
  apply:
    - Follow existing code patterns and conventions
  verify:
    - Run tests if test infrastructure exists
  archive:
    - Warn before destructive merges

experimental:
  neabrain: false

### Step 4: Persist Context (openspec mode only)

- Save detected context into openspec/config.yaml.
- Write openspec/changes/.status.yaml:
  ```yaml
  phase: INIT
  change: null
  awaiting_approval: false
  completed: false
  ```

### Step 5: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Never create placeholder specs.
- Always detect real stack, do not guess.
- If openspec/ already exists, report what exists before writing config.
- If config.yaml exists, update only the context block; preserve rules.
- Keep config.yaml context concise (no more than 10 lines).
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

{
  "status": "ok | warning | failed",
  "executive_summary": "Initialization summary and persistence mode.",
  "detailed_report": "Optional notes.",
  "artifacts": [
    {
      "name": "config",
      "path": "openspec/config.yaml",
      "type": "yaml"
    }
  ],
  "next_recommended": "EXPLORE",
  "risks": ["list of risks or blockers"]
}
