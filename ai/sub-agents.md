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

Ejecuta las skills inline. No replica sub-agentes reales, pero puede seguir el
patron si lee la skill correcta y mantiene separacion entre fases.

### Gemini CLI

Misma limitacion general que Codex: mas ejecucion inline, menos aislamiento
real de contexto.

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
