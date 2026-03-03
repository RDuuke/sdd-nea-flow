---
name: flow-nea-spec
description: >
  Write specifications with requirements and scenarios (delta specs for changes).
trigger: >
  When the orchestrator launches you to write or update specs after a proposal is approved.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Write delta specs describing what is added, modified, or removed.

## What You Receive

- Change name
- Proposal content
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Identify Affected Domains

From proposal "Affected Areas", group by domain (auth, payments, ui, etc.).

### Step 2: Read Existing Specs

- If openspec mode and openspec/specs/{domain}/spec.md exists, read it.

### Step 3: Write Delta Specs (openspec mode)

openspec/changes/{change-name}/specs/{domain}/spec.md

Delta format:

# Delta for {Domain}

## ADDED Requirements

### Requirement: {Name}
The system MUST/SHALL/SHOULD/MAY ...

#### Scenario: {Happy path}
- GIVEN ...
- WHEN ...
- THEN ...

#### Scenario: {Edge case}
- GIVEN ...
- WHEN ...
- THEN ...

## MODIFIED Requirements
...

## REMOVED Requirements
...

If no existing spec exists, write a FULL spec instead of delta.

### Step 4: Persist (openspec mode)

- Save delta specs under openspec/changes/{change-name}/specs/{domain}/spec.md
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: SPEC
  change: "{change-name}"
  awaiting_approval: false
  completed: false
  pending_tasks: []
  modified_artifacts: []
  notes: ""
  ```

### Step 5: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Use Given/When/Then format for scenarios.
- Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY).
- Every requirement must have at least one scenario.
- Include both happy path and edge case scenarios.
- Do not include implementation details.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

{
  "status": "ok | warning | failed",
  "executive_summary": "Specs written and persisted.",
  "detailed_report": "Notes or persistence info.",
  "artifacts": [
    {
      "name": "spec",
      "path": "openspec/changes/{change-name}/specs/{domain}/spec.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "DESIGN",
  "risks": ["list of risks or blockers"]
}
