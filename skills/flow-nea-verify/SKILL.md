---
name: flow-nea-verify
description: >
  Validate that implementation matches specs, design, and tasks using real execution.
trigger: >
  When the orchestrator launches you to verify a completed change.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Related Skills

- **testing** - Test execution and structure validation

## Purpose

Prove the implementation is correct using real test/build execution and spec compliance.

## What You Receive

- Change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Check Completeness

- Read tasks.md and list incomplete tasks

### Step 2: Static Spec Match

For each requirement and scenario, check code for structural evidence.

### Step 3: Check Design Coherence

Verify design decisions were followed.

### Step 4: Run Tests (Real Execution)

Detect test command from:
1) openspec/config.yaml -> rules.verify.test_command
2) package.json scripts.test
3) pyproject.toml / pytest.ini
4) Makefile
If not found, report as warning.

Run tests and capture pass/fail.

### Step 5: Build/Type Check (Real Execution)

Detect build command from:
1) openspec/config.yaml -> rules.verify.build_command
2) package.json scripts.build
3) Makefile
If not found, report as warning.

### Step 6: Spec Compliance Matrix

Each scenario is compliant only if a test exists and passes.

### Step 7: Persist Report

- If openspec mode, write openspec/changes/{change-name}/verify-report.md
- Update openspec/changes/.status.yaml:
  ```yaml
  phase: VERIFY
  change: "{change-name}"
  awaiting_approval: false
  completed: false
  pending_tasks: []
  modified_artifacts: []
  notes: ""
  ```

### Step 8: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Always execute tests; static analysis is not enough.
- If tests or build fail, mark as critical.
- Do not fix issues; only report.
- All artifact content MUST be written in Spanish.

## Output Contract (JSON)

{
  "status": "ok | warning | failed",
  "executive_summary": "Verification complete. Pass/Fail summary.",
  "detailed_report": "Full verification report or persistence info.",
  "artifacts": [
    {
      "name": "verify_report",
      "path": "openspec/changes/{change-name}/verify-report.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "ARCHIVE | APPLY",
  "risks": ["list of risks or blockers"]
}
