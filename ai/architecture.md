# Arquitectura de nea-flow

`nea-flow` implementa un patron de Spec-Driven Development con un
orquestador liviano y sub-agentes especializados por fase.

La idea central es separar coordinacion de ejecucion:

- el orquestador mantiene estado, resume y pide aprobacion
- los sub-agentes ejecutan trabajo puntual con contexto fresco
- OpenSpec persiste los artefactos del cambio

## Capas del sistema

### 1. Orquestador

El agente principal decide si una accion va inline o delegada. Su contexto debe
mantenerse pequeno y estable. No debe leer de mas ni implementar fases
completas por si mismo salvo tareas triviales.

Responsabilidades:

- detectar cuando conviene usar el flujo
- leer estado actual de `openspec/changes/.status.yaml`
- lanzar la fase correcta
- validar respuestas de sub-agentes
- mostrar resumenes y riesgos
- pedir aprobacion cuando corresponde

### 2. Skills de fase

Cada fase vive en `skills/flow-nea-*/SKILL.md`. Las skills describen:

- entradas esperadas
- pasos a ejecutar
- reglas y limites
- contrato de salida JSON

Las skills son la unidad ejecutable del sistema.

### 3. Ejemplos por herramienta

`examples/` adapta el mismo patron a distintas herramientas:

- OpenCode y Claude Code pueden delegar sub-agentes reales
- Codex, Gemini CLI y VS Code ejecutan mas trabajo inline

Los ejemplos no definen el patron; lo transportan a cada entorno.

### 4. Persistencia OpenSpec

OpenSpec guarda el estado del cambio y sus artefactos en el proyecto destino.
No pertenece a este repo; este repo solo define como usarlo.

## Principio operativo

La pregunta clave del orquestador es:

**"Esto infla mi contexto sin necesidad?"**

Si la respuesta es si, debe delegar. Este principio reduce:

- compresion de contexto
- perdida de decisiones intermedias
- mezcla entre planeacion e implementacion
- respuestas largas pero poco confiables

## Por que el patron no es agnostico de arquitectura

El repo es agnostico de herramienta, pero no de modelo mental. Todas las
integraciones deben preservar estas propiedades:

- flujo por fases
- artefactos persistidos
- separacion entre coordinacion y ejecucion
- validacion estructurada por fase
- posibilidad de retomar o retroceder estado

Si una integracion no puede delegar sub-agentes reales, aun debe emular el
comportamiento leyendo la skill correcta y ejecutando la fase de forma aislada.

## Mapa de componentes

```text
Usuario
  -> Orquestador
     -> Skills de fase
     -> Examples por herramienta
     -> OpenSpec en el proyecto destino
```

## Limites del repo

Este repo no contiene:

- codigo de aplicacion
- logica de negocio de proyectos destino
- una implementacion propia de OpenSpec
- una UI del flujo

Su funcion es empaquetar instrucciones, convenciones y configuraciones para que
otros agentes ejecuten el patron correctamente.
