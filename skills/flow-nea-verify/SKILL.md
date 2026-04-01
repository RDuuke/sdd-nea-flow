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

## Related Skills (optional, load if available)

- **testing** - Test execution and structure validation

If the testing skill file does not exist at the expected path, skip it silently
and continue with verification using your general knowledge. Do NOT fail or
block because the optional testing skill is missing. Report any missing skills
as a warning in the output envelope `risks` field.

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

### Step 5.5: Code Coverage (optional)

Detect coverage command from:
1) openspec/config.yaml -> rules.verify.coverage_command
2) package.json scripts.coverage or scripts["test:coverage"]
3) pytest --cov (if pytest is detected)
If not found, skip this step (do not report as warning).

If a coverage command is found:
- Run it and capture the overall coverage percentage.
- Include the coverage percentage in verify-report.md under a
  `## Cobertura de Codigo` section.
- If coverage is below the threshold configured in
  `openspec/config.yaml -> rules.verify.coverage_threshold` (default: 80%),
  set status to `warning` and add a risk: "Cobertura por debajo del umbral:
  {actual}% < {threshold}%".
- If no threshold is configured and no coverage command is found, skip silently.

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

```json
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
```
