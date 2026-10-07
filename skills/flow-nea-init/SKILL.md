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
  version: "3.1"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Detect the actual project and initialize persistence without resetting existing
changes or imposing tooling that the project does not use.

## What to Do

1. Inspect project instructions, manifests, CI and existing command wrappers.
   Identify product context (CRM/CMS/framework app/docs/etc.), architecture,
   conventions and capabilities under the validation contract. Do not guess a
   build, test runner, API, runtime or coverage command from a product label.
2. In openspec mode, ensure config, specs, changes and archive directories exist.
   Never create placeholder specs. Preserve all existing changes and state.
3. For a new config use the template below, replacing context and capability
   observations with actual findings. For existing config, update concise context
   and verified capability observations, preserving rules, gates, custom blocks,
   commands, thresholds and experimental settings. Add missing safe defaults
   only; missing disabled keys are not a project failure.
4. Create a global 2.0 selector only if none exists. Do not reset selection,
   migrate unrelated changes, overwrite legacy global state or delete JSON.
   Report legacy recovery needs for CONTINUE using the state contract.
5. Validate generated YAML and refs, return initialization artifacts. INIT is
   project setup; it does not mark any existing change's phases complete.

```yaml
schema: flow-nea
context: |
  Contexto: por detectar
rules:
  proposal: ["Identificar alcance y reversion proporcional al riesgo"]
  specs: ["Escenarios verificables Dado/Cuando/Entonces"]
  design: ["Justificar decisiones y validacion por impacto"]
  tasks: ["Tareas concretas con numeracion jerarquica"]
  apply: ["Seguir convenciones existentes"]
  verify: ["Ejecutar comprobaciones aplicables acordadas"]
  archive: ["Consolidar especificaciones vigentes por dominio"]
capabilities: {}  # populate observed entries from validation-contract.md
validation:
  default_scope: impact
gates:
  apply:
    tdd: false
    review_budget:
      max_diff_lines: 0
      sensitive_paths: []
  verify:
    coverage_threshold: null
experimental:
  neabrain: false
```

Artifact descriptions and config values are Spanish; keys and paths are English.
Keep context under ten lines. Do not run full suites as initialization.

## Execution and Persistence Contract

Read `skills/_shared/persistence-contract.md` and its development state,
execution, validation and audit references. Resolve these relative to the installed skills
root, not the target project's source directory. Follow the contracts in mode
`none` using supplied context, without file writes.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Brief phase result.",
  "detailed_report": "Optional concise details or report reference.",
  "artifacts": [
    {
      "name": "config",
      "path": "openspec/config.yaml",
      "type": "yaml"
    }
  ],
  "next_recommended": "EXPLORE",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none",
  "action_context": {
    "blocked": false,
    "reason": null,
    "requires_user_input": false
  }
}
```
