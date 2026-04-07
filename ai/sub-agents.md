# Sub-agentes y herramientas

## Modelo general

`nea-flow` asume un orquestador liviano que puede delegar trabajo a
sub-agentes especializados por fase. Cada sub-agente debe:

- leer la skill correcta
- ejecutar una sola fase o una tarea de soporte
- no re-delegar salvo que la herramienta y el prompt lo permitan explicitamente
- devolver un resultado estructurado

## Que hace el orquestador

- decide si usar el flujo
- carga estado del cambio
- elige fase siguiente
- valida respuestas
- resume resultados
- pide aprobacion

## Que no debe hacer el orquestador

- leer muchos archivos para explorar el codebase si puede delegarlo
- implementar una feature multiarchivo inline
- escribir specs, design o tasks fuera de sus fases
- ocultar riesgos de sub-agentes

## Skills de soporte

Ademas de las fases, existen skills auxiliares:

- `judgment-day`: revision dual ciega
- `skill-registry`: indice compacto de skills
- `skill-creator`: bootstrap para nuevas skills

## Diferencias por herramienta

### OpenCode

Es la integracion mas cercana al modelo ideal:

- soporta agente orquestador dedicado
- soporta sub-agentes reales por fase
- permite modelos distintos por fase

### Claude Code

Tambien soporta delegacion real via Agent tool, aunque su integracion se
apoya en `CLAUDE.md` y slash commands del proyecto o del usuario.

### Codex

Puede estructurarse como orquestador con sub-agentes por fase. En este repo,
su ejemplo usa el mismo patron de fases, skill resolution y contexto acotado
que Claude, adaptado al entorno de Codex.

### Gemini CLI

Puede seguir el mismo patron de orquestador y sub-agentes por fase que Codex,
adaptado a las capacidades del entorno Gemini CLI.

### VS Code

Funciona principalmente como capa de instrucciones y contexto. Puede usar modo
agente y herramientas, pero no es la referencia principal para delegacion real
de sub-agentes en este repo.

## Criterio de compatibilidad

Una integracion nueva es aceptable si conserva:

- las fases del flujo
- el contrato de salida por fase
- la persistencia en OpenSpec
- la separacion conceptual entre orquestador y ejecutor

No hace falta que todas las herramientas soporten exactamente la misma
capacidad de delegacion, pero si deben preservar la semantica del flujo.
