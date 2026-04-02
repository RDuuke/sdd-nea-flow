# Economia de tokens de nea-flow

Este documento no es una medicion instrumentada. Es un estimado operativo
basado en la arquitectura del patron y en la comparacion contra un enfoque de
chat lineal donde un solo agente acumula todo el contexto.

## Idea central

`nea-flow` intenta reducir costo y degradacion por contexto con tres mecanismos:

- orquestador con contexto pequeno
- sub-agentes por fase con contexto fresco
- artefactos persistidos en archivos en lugar de arrastrar todo en el chat

El ahorro no viene de usar menos texto en terminos absolutos, sino de evitar
reenviar repetidamente el mismo contexto completo en cada turno.

## Modelo comparativo

### Enfoque lineal

Un solo agente conversa durante toda la tarea y arrastra:

- requerimiento inicial
- exploracion previa
- decisiones de arquitectura
- borradores de specs
- tareas
- implementacion
- verificacion

En cambios medianos o grandes, el costo crece por reenvio acumulado y por
resumenes de contexto cada vez mas largos.

### Enfoque nea-flow

Cada fase recibe solo lo necesario:

- instrucciones del sistema o prompt
- skill de la fase
- artefactos previos relevantes
- objetivo puntual de esa fase

El hilo principal conserva principalmente:

- estado
- resumen ejecutivo
- riesgos
- proxima accion

## Estimado por tamano de cambio

Estos rangos son una aproximacion razonable para explicar el patron:

| Tipo de cambio | Chat lineal | `nea-flow` | Diferencia estimada |
| --- | --- | --- | --- |
| Pequeno | 1.0x | 0.9x a 1.1x | casi neutro |
| Mediano | 1.0x | 0.65x a 0.85x | ahorro de 15% a 35% |
| Grande | 1.0x | 0.45x a 0.70x | ahorro de 30% a 55% |

Interpretacion:

- en cambios pequenos, el overhead del flujo puede neutralizar parte del ahorro
- en cambios medianos, la separacion por fases ya empieza a pagar
- en cambios grandes, el beneficio principal es evitar recircular contexto

## Donde aparece el ahorro

### 1. Menos relectura global

El sub-agente de `SPEC` no necesita cargar todo lo que uso `APPLY`.
El de `VERIFY` no necesita todo el historial de exploracion, solo los
artefactos y el estado necesarios.

### 2. Menos compresion del hilo principal

El orquestador puede sostener una conversacion larga con menos costo porque no
arrastra el detalle completo de todas las fases.

### 3. Persistencia en archivos

Cuando una decision vive en `proposal.md` o `design.md`, la siguiente fase lee
ese archivo en lugar de reconstruir la decision desde el historial del chat.

## Costos que agrega el patron

`nea-flow` no es gratis. Introduce overhead en:

- prompt del orquestador
- prompt o skill de la fase
- lectura y escritura de artefactos
- validacion estructurada

Por eso no conviene forzarlo para tareas triviales.

## Regla practica

Usar `nea-flow` cuando hay:

- multiples archivos
- multiples dominios
- necesidad de exploracion previa
- riesgo de iteraciones largas
- valor en conservar proposal, spec, design y tasks

No usarlo por defecto en:

- fixes rapidos
- cambios de un solo archivo
- preguntas puntuales
- tareas de menos de tres pasos

## Estimado operativo para maintainers

Como argumento de producto o arquitectura, una afirmacion prudente seria:

> En cambios medianos y grandes, `nea-flow` puede reducir aproximadamente entre
> 15% y 55% del costo de contexto efectivo frente a un flujo lineal, ademas de
> mejorar estabilidad y auditabilidad.

La parte mas importante de esa frase no es el porcentaje exacto, sino el tradeoff:

- menos costo por recirculacion de contexto
- mas costo fijo por estructura
- mejor confiabilidad en cambios complejos

## Como medirlo de verdad despues

Si luego quieres convertir este estimado en benchmark real, deberias medir:

1. tokens de entrada y salida por fase
2. tokens acumulados del hilo principal
3. numero de archivos leidos por fase
4. porcentaje de relectura de contexto
5. tasa de retries o correcciones por perdida de contexto

La comparacion correcta seria:

- mismo cambio
- mismo modelo o familia de modelos
- flujo lineal vs `nea-flow`
- mismas restricciones de calidad
