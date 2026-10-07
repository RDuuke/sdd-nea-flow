# Development Audit Examples

Illustrative documents, not evidence of actual execution. Read the audit contract
for required fields. Refs below are relative to the report's target directory;
the examples do not create these files. Use actual observations/times/hashes in
real records. Each fenced YAML block is one independent file.

## .execution-log.yaml

```yaml
schema_version: "1.0"
kind: execution_log
change: example-change
updated_at: "2026-10-06T15:43:00-05:00"
status: ok
summary: "Verificacion focal completada."
artifact_refs: [verify-report.yaml]
events:
  - id: verify-001
    phase: VERIFY
    started_at: "2026-10-06T15:42:00-05:00"
    finished_at: "2026-10-06T15:43:00-05:00"
    status: ok
    summary: "Comprobacion directa aprobada."
    artifact_refs: [verify-report.yaml]
    risks: []
    attempt: 1
    retried: false
```

## apply-progress.yaml

```yaml
schema_version: "1.0"
kind: apply_progress
change: example-change
updated_at: "2026-10-06T15:41:00-05:00"
status: ok
summary: "Paso quick completado."
artifact_refs: [quick.md]
tasks:
  - id: q1
    status: complete
    summary: "Enlace actualizado."
    evidence_refs: [evidence/browser-check.txt]
    tdd:
      applicability: not_applicable
      reason: "Ajuste declarativo sin logica nueva; comprobacion directa acordada."
```

## validation-plan.yaml

```yaml
schema_version: "1.0"
kind: validation_plan
change: example-change
updated_at: "2026-10-06T15:30:00-05:00"
status: ok
summary: "Validacion directa del enlace afectado."
artifact_refs: [quick.md]
impact:
  areas: [navigation]
  shared_dependencies: []
  risk: low
  reason: "Cambio local de destino, sin modificar header compartido."
checks:
  - id: nav-link
    criteria: [quick-link-target]
    method: browser
    required: true
    scope: "Enlace y destino del menu afectado."
    expected: "El enlace abre el destino aprobado."
    capability: browser
    reason: "La comprobacion directa cubre el comportamiento sin build aplicable."
exceptions: []
```

## verify-report.yaml

```yaml
schema_version: "1.0"
kind: verify_report
change: example-change
updated_at: "2026-10-06T15:43:00-05:00"
status: ok
summary: "Destino aprobado y tareas completas."
artifact_refs: [quick.md, validation-plan.yaml, apply-progress.yaml]
archive_ready: true
input_hashes:
  quick.md: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  navigation.html: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
criteria:
  - id: quick-link-target
    source_ref: quick.md#verificacion
    status: COMPLIANT
    check_ids: [nav-link]
    evidence_ids: [browser-001]
checks:
  - id: nav-link
    required: true
    result: passed
    reason: "Destino coincide con el alcance aprobado."
    evidence_ids: [browser-001]
evidence:
  - id: browser-001
    method: browser
    steps: ["Abrir menu", "Activar enlace", "Comprobar destino"]
    observed: "Destino esperado abierto."
    started_at: "2026-10-06T15:42:00-05:00"
    finished_at: "2026-10-06T15:43:00-05:00"
    refs: [evidence/browser-check.txt]
    input_hashes:
      navigation.html: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
    environment:
      browser: "Version registrada en evidencia separada."
    reused_from: null
findings:
  - id: nav-destination-001
    category: product
    severity: critical
    blocking: false
    summary: "Destino corregido; se conserva el fallo anterior."
    criterion_ids: [quick-link-target]
    artifact_refs: [evidence/browser-before.txt, evidence/browser-check.txt]
    resolution: resolved
    resolution_reason: "La comprobacion actual cubre el sintoma reportado."
    resolution_at: "2026-10-06T15:43:00-05:00"
    resolution_evidence_ids: [browser-001]
    resolution_input_hashes:
      navigation.html: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
    history:
      - at: "2026-10-06T15:40:00-05:00"
        resolution: open
        blocking: true
        summary: "El enlace abria un destino distinto al aprobado."
        evidence_refs: [evidence/browser-before.txt]
        input_hashes:
          navigation.html: cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      - at: "2026-10-06T15:43:00-05:00"
        resolution: resolved
        blocking: false
        summary: "Destino aprobado en la ejecucion actual."
        evidence_refs: [evidence/browser-check.txt]
        input_hashes:
          navigation.html: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
incomplete_tasks: []
```

## fix-report.yaml

```yaml
schema_version: "1.0"
kind: fix_report
change: example-change
updated_at: "2026-10-06T15:43:00-05:00"
status: ok
summary: "Sin ciclos FIX necesarios."
artifact_refs: [verify-report.yaml]
attempts: []
```

## archive-report.yaml

```yaml
schema_version: "1.0"
kind: archive_report
change: example-change
updated_at: "2026-10-06T15:45:00-05:00"
status: ok
summary: "Cambio archivado sin delta contractual."
artifact_refs: [verify-report.yaml]
archive_path: openspec/changes/archive/2026-10-06-example-change/
verification_ref: verify-report.yaml
domains: []
```

When contracts change, domains lists the actual added/modified/removed requirement
IDs and before/after hashes. Domain operation records also describe unchanged
requirements. Transaction backup refs stay with the archived change. No domains
are invented for an implementation-only fix with unchanged behavior.
