# AI docs

Esta carpeta concentra la documentacion tecnica para maintainers de `nea-flow`.
No reemplaza `README.md`, no reemplaza `skills/` y no es una capa runtime.

Usa esta carpeta cuando necesites entender o extender el patron de orquestacion,
la estructura de persistencia o las reglas que conectan prompts, skills y
artefactos.

## Como se relaciona con el repo

- `README.md`: entrada principal, instalacion, uso y overview corto
- `AGENTS.md`: reglas de contribucion para agentes IA que editan este repo
- `skills/`: instrucciones ejecutables por fase
- `examples/`: prompts y configuraciones especificas por herramienta
- `ai/`: referencia tecnica humana para maintainers

## Indice

| Documento | Proposito | Cuando leerlo |
| --- | --- | --- |
| `architecture.md` | Explica la arquitectura general del sistema | Cuando necesitas entender el patron completo |
| `concepts.md` | Define el vocabulario y las convenciones del repo | Cuando hay dudas de terminos o reglas |
| `flow.md` | Documenta fases, dependencias y reglas de avance | Cuando cambias el flujo o sus comandos |
| `persistence.md` | Explica OpenSpec, artefactos y regresion de fase | Cuando tocas persistencia o contratos |
| `sub-agents.md` | Describe el modelo de sub-agentes y diferencias por herramienta | Cuando actualizas ejemplos o capacidades |
| `token-economics.md` | Estima el impacto de contexto y costo del patron | Cuando necesitas argumentar eficiencia o escalabilidad |
| `authoring.md` | Guia para crear o modificar skills y prompts | Cuando contribuyes o extiendes `nea-flow` |

## Alcance

Esta carpeta es deliberadamente documental:

- no contiene prompts operativos
- no contiene `SKILL.md`
- no cambia rutas usadas por instaladores
- no debe duplicar entero el `README.md`

Si una decision afecta runtime, la fuente de verdad sigue estando en
`skills/`, `examples/`, `scripts/` y `AGENTS.md`.
