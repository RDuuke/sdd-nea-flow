---
name: judgment-day
description: >
  Dual blind adversarial review system. Two independent judges review the same target simultaneously.
  Trigger: When user says "judgment day", "dual review", "revision dual", or "juzgar".
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Desplegar dos jueces independientes y ciegos simultaneamente para evaluar el mismo objetivo, luego sintetizar sus hallazgos. Maximiza confianza en issues criticos.

## Que recibe

- Change name (obligatorio)
- Artifact store mode (openspec | none)
- Criterios de evaluacion (opcional — por defecto: spec compliance, design adherence, code quality)

## Flujo de ejecucion

### Paso 1: Resolver skills del proyecto

Leer `.atl/skill-registry.md` para obtener compact rules relevantes al codebase. Inyectar en ambos jueces.

### Paso 2: Lanzar jueces en paralelo (async)

Lanzar Juez A y Juez B simultaneamente con:
- Acceso identico a: specs, design, tasks, codigo implementado
- Criterios identicos de evaluacion
- **SIN conocimiento del otro juez** (contextos separados)

Prompt para cada juez:
```
Eres un revisor de codigo independiente. Revisa la implementacion del cambio '{change-name}'.
Lee: openspec/changes/{change-name}/specs/, design.md, tasks.md y el codigo afectado.
Evalua: cumplimiento de specs, coherencia con design, calidad de codigo, tests.
Categoriza cada hallazgo como: CRITICO | ADVERTENCIA | SUGERENCIA
Retorna lista de hallazgos con: categoria, archivo:linea, descripcion, evidencia.
```

### Paso 3: Sintetizar veredictos

Comparar resultados de ambos jueces:

| Estado | Condicion | Accion |
|--------|-----------|--------|
| **Confirmado** | Encontrado por ambos jueces | Aplicar fix |
| **Sospechoso A** | Solo Juez A | Revisar manualmente |
| **Sospechoso B** | Solo Juez B | Revisar manualmente |
| **Contradiccion** | Jueces en desacuerdo sobre el mismo issue | Escalar al usuario |

### Paso 4: Mostrar veredicto al usuario

Tabla de veredicto:
```
| Severidad | Hallazgo | Fuente | Estado |
|-----------|----------|--------|--------|
| CRITICO   | ...      | Ambos  | Confirmado |
| ADVERTENCIA | ...   | Juez A | Sospechoso A |
```

Preguntar: "¿Aplicamos los fixes confirmados?"

### Paso 5: Aplicar fixes (si el usuario confirma)

Delegar a un Fix Agent separado (NUNCA un juez hace fixes).
Despues de aplicar, re-lanzar ambos jueces (maximo 2 ciclos).

### Paso 6: Escalar si no converge

Si despues de 2 ciclos siguen issues criticos confirmados: reportar al usuario con historial completo. No seguir loopeando.

## Rules

- El orquestador NUNCA revisa codigo directamente — solo lanza jueces, lee resultados y sintetiza
- Los jueces trabajan ciegos entre si — ningun cross-contamination
- El Fix Agent es una delegacion separada — nunca un juez hace fixes
- Maximo 2 ciclos de fix+re-judge antes de escalar
- Issues CRITICOS confirmados bloquean ARCHIVE

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Judgment Day complete. N confirmed issues, M suspects.",
  "detailed_report": "Verdict table with all findings.",
  "artifacts": [],
  "confirmed_issues": ["list of confirmed issues"],
  "suspect_issues": ["list of single-judge issues"],
  "contradictions": ["list of contradictions"],
  "next_recommended": "ARCHIVE | APPLY",
  "risks": ["list of blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
