# Authoring guide para maintainers

## Cuando crear una nueva skill

Crea una nueva skill cuando el comportamiento:

- tiene pasos reutilizables
- necesita reglas estables
- requiere contrato de salida propio
- no encaja bien en una fase existente

## Como agregar una skill

1. Crear `skills/{name}/SKILL.md`
2. Seguir el formato de frontmatter y secciones ya usado
3. Definir entradas, pasos, reglas y output contract
4. Integrarla en prompts o ejemplos si aplica
5. Actualizar `README.md` y `ai/` si cambia el mapa del flujo
6. Si agrega un slash command, actualizar tambien los wrappers en `examples/`

## Como modificar una skill existente

1. Leer el archivo completo antes de editar
2. Confirmar que no cambie accidentalmente el contrato de salida
3. Revisar si impacta examples, README o `AGENTS.md`
4. Verificar consistencia con budgets y reglas de idioma

## Donde poner cada tipo de contenido

- Cambio ejecutable por agente -> `skills/`
- Prompt o config por herramienta -> `examples/`
- Regla global de contribucion del repo -> `AGENTS.md`
- Onboarding, uso e instalacion -> `README.md`
- Arquitectura o referencia tecnica para maintainers -> `ai/`

## Reglas de idioma editoriales

- prompts y archivos AI-facing -> ingles
- artefactos OpenSpec -> espanol
- docs humanas del repo -> espanol

## Checklist de cambio

Antes de abrir un PR:

- confirmar que las rutas nuevas son coherentes con el repo
- revisar enlaces internos
- evitar duplicacion larga entre `README.md` y `ai/`
- confirmar que ejemplos por herramienta no contradicen a las skills
- validar que la documentacion humana no cambie reglas runtime sin tocar la fuente operativa
- si la skill introduce un artefacto OpenSpec nuevo, documentarlo en `ai/persistence.md` o `ai/flow.md`

## Anti-patrones

- usar `README.md` como deposito de toda la arquitectura
- duplicar la misma regla en cinco prompts sin documentar la fuente de verdad
- mezclar docs humanas y prompts AI-facing en el mismo archivo sin motivo
- introducir conceptos no soportados por el flujo real
