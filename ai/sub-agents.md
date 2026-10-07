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

## Cuando delegar

Decidir por riesgo, incertidumbre, independencia y presion de contexto, no por
numero de archivos. Una edicion mecanica de varios archivos puede ejecutarse
inline; una revision sensible puede justificar otro agente aunque afecte uno.
Sin delegacion permitida, ejecutar unidades de fase secuenciales conservando
contratos. No simular independencia cuando se solicita revision dual.

El coordinador entrega rutas exactas de skills, reglas pertinentes del proyecto,
artefactos necesarios, superficies de escritura y checks acordados. El ejecutor
lee la skill completa; un resumen del registro no la sustituye. Se observa su
resultado terminal antes de avanzar y se serializan escrituras compartidas.
No escribir specs, diseno o tareas fuera de sus fases ni ocultar riesgos.

Contrato canonico: [execution-contract.md](../skills/_shared/execution-contract.md).

## Skills de soporte

Ademas de las fases, existen skills auxiliares:

- `flow-nea-status`: motor de estado read-only. Devuelve fase actual,
  progreso de tareas, dependencias faltantes y `action_context`. El
  orquestador y `flow-nea-continue` lo consumen en vez de releer
  `.status.yaml` a mano.
- `judgment-day`: revision dual ciega
- `skill-registry`: indice compacto de skills
- `skill-creator`: bootstrap para nuevas skills

## Gates configurables (opt-in)

Dos compuertas viven en `openspec/config.yaml -> gates.apply`:

- `tdd`: cuando es `true` o `"strict"`, `flow-nea-apply` recorre
  RED -> GREEN -> TRIANGULATE -> REFACTOR por tarea de comportamiento aplicable y registra evidencia en
  `apply-progress.yaml`. `flow-nea-verify` audita esa evidencia.
- `review_budget`: limita el tamano del diff (`max_diff_lines`) y/o
  bloquea rutas sensibles (`sensitive_paths`). Si se excede, `apply` deja
  `awaiting_approval: true` y el orquestador pregunta antes de avanzar.

Ambos gates estan desactivados por defecto. La cobertura tampoco recibe umbral por defecto en nuevos proyectos. Gates existentes se preservan. Cambios existentes siguen
funcionando sin tocar nada.

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
