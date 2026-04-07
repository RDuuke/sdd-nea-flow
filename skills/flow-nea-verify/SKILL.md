---
name: flow-nea-verify
description: >
  Validate that implementation matches the declared change artifacts using real execution.
trigger: >
  When the orchestrator launches you to verify a completed change.
license: MIT
metadata:
  author: juan-duque
  version: "2.0"
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
Act as a quality gate: code alone is never sufficient — every scenario requires a passing test as proof.

## Compliance Levels

Use these status labels consistently throughout the report:

| Status | Symbol | Meaning |
|--------|--------|---------|
| COMPLIANT | ✅ | Test exists AND passes. Only acceptable state to advance to ARCHIVE. |
| FAILING | ❌ | Test exists but fails. |
| UNTESTED | ❌ | Scenario has no associated test. Equivalent to FAILING. |
| PARTIAL | ⚠️ | Test covers part of the scenario but not all cases. |

## Issue Severity

Clasificar cada problema encontrado con uno de estos niveles:

- **CRITICAL**: blocks progress. Failing tests, broken build, uncovered scenarios in core features.
- **WARNING**: risk but not blocking. Partial coverage, edge scenarios without tests.
- **SUGGESTION**: optional improvement. Refactor, readability, additional tests recommended.

## What You Receive

- Change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Check Completeness

- Normal mode: read `tasks.md` and list incomplete tasks
- Quick mode: if `quick.md` exists and `tasks.md` does not, skip incomplete task checks

Quick mode detection:

- `openspec/changes/{change-name}/quick.md` exists and `tasks.md` does not exist, or
- `.status.yaml` indicates the quick path and no normal planning artifacts were created

### Step 2: Behavioral Validation Matrix

Normal mode:

For each spec domain in `openspec/changes/{change-name}/specs/`:
1. Read each requirement and its scenarios
2. Search for a corresponding test (by name, description, or assertion)
3. Assign a compliance status per scenario: COMPLIANT ✅ / FAILING ❌ / UNTESTED ❌ / PARTIAL ⚠️

Quick mode:

1. Read `quick.md`
2. Use `## Verificacion` as the expected validation checklist
3. Search for corresponding tests, assertions, build signals, or direct checks
4. Build the same compliance matrix using each verification item as a row

Build a matrix in the report:

```markdown
## Matriz de Validacion

| Dominio | Escenario | Estado | Test asociado | Severidad |
|---------|-----------|--------|---------------|-----------|
| auth    | Login con credenciales validas | ✅ COMPLIANT | auth.test.ts:22 | — |
| auth    | Login fallido muestra error | ❌ FAILING | auth.test.ts:41 | CRITICAL |
| export  | Exportar CSV vacio | ❌ UNTESTED | — | CRITICAL |
| export  | Exportar con headers | ⚠️ PARTIAL | export.test.ts:15 | WARNING |
```

**Key rule**: UNTESTED equals FAILING. Code that works but has no test = NOT COMPLIANT.

### Step 3: Check Design Coherence

If `design.md` exists, verify design decisions were followed. For each decision:
- Mark as ✅ implemented, ⚠️ partial, or ❌ missing
- Flag any deviation as WARNING or CRITICAL depending on impact

If running in quick mode and no `design.md` exists, skip this step silently.

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

### Step 6: Final Compliance Summary

Aggregate the matrix from Step 2 with test results from Step 4:
- Count COMPLIANT / FAILING / UNTESTED / PARTIAL per domain
- Determine overall status:
  - Any CRITICAL issue → `status: failed`
  - Only WARNINGs → `status: warning`
  - All COMPLIANT → `status: ok`

Remember: a scenario is only COMPLIANT if a test EXISTS and PASSES.
Code that implements the feature without a passing test is UNTESTED = FAILING.

### Step 7: Persist Report

- If openspec mode, write openspec/changes/{change-name}/verify-report.md

  The report MUST include a `## Fallos Detectados` section when tests or build fail,
  with this exact structure for machine consumption by flow-nea-fix:

  ```markdown
  ## Fallos Detectados

  ### Tests fallidos
  - `test name or file`: error message (1 line max)

  ### Errores de build
  - `file:line`: error message (1 line max)

  ### Tareas incompletas
  - task id / description
  ```

  If all tests pass and build succeeds, omit the `## Fallos Detectados` section entirely.

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
- In quick mode, verification may come from `quick.md` plus real execution; do not invent missing specs.
- Code that works but has no test = UNTESTED = FAILING. No exceptions.
- Classify every issue as CRITICAL / WARNING / SUGGESTION.
- If any CRITICAL issue exists: `status: failed`. Do not advance to ARCHIVE.
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
  "risks": ["list of risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
