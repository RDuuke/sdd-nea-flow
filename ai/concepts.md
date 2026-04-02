# Conceptos y convenciones

## Vocabulario base

### Orquestador

Agente principal que coordina el flujo. Mantiene contexto minimo, delega trabajo
pesado y nunca deberia implementar fases complejas directamente.

### Sub-agente

Agente especializado que ejecuta una fase puntual con contexto fresco y devuelve
un resultado estructurado.

### Skill

Paquete de instrucciones locales definido en un `SKILL.md`. Contiene pasos,
reglas, contrato de salida y referencias compartidas.

### Prompt

Instruccion AI-facing que configura el comportamiento del orquestador o de una
integracion concreta. Ejemplos: `examples/opencode/AGENTS.md`,
`examples/claude-code/CLAUDE.md`.

### OpenSpec

Backend documental donde se persisten specs base, cambios activos, estado y
artefactos de verificacion.

### Delta spec

Especificacion de cambio que describe solo la diferencia contra las specs base,
usando bloques como `ADDED`, `MODIFIED` y `REMOVED`.

### Artifact store

Modo de persistencia configurado para una fase. En la practica, `nea-flow`
privilegia `openspec`.

### Execution log

Registro por fase que permite auditar que ejecuto cada sub-agente, con que
resultado y con que riesgos.

### Phase

Unidad de trabajo del flujo. Ejemplos: `PROPOSE`, `SPEC`, `APPLY`.

### Meta-command

Comando manejado por el orquestador que compone varias fases o aplica logica
especial. Ejemplos: `/flow-nea-ff`, `/flow-nea-continue`, `/flow-nea-fix`.

## Convenciones de idioma

- Artefactos del flujo: siempre en espanol
- Nombres de archivos y rutas: siempre en ingles
- Prompts, configuraciones AI-facing y `SKILL.md`: ingles
- Documentacion humana para maintainers: espanol

## Convenciones de nombres

- Skills de fase: `flow-nea-{phase}`
- Carpeta de cambios en OpenSpec: `openspec/changes/{change-name}`
- Artefactos canonicos: `proposal.md`, `design.md`, `tasks.md`, `verify-report.md`
- Estado compartido: `.status.yaml`

## Regla editorial

Ubicacion correcta por tipo de contenido:

- `README.md`: onboarding, instalacion, uso, overview
- `ai/`: arquitectura y referencia tecnica para maintainers
- `AGENTS.md`: reglas de contribucion y convenciones del repo
- `skills/`: instrucciones ejecutables
- `examples/`: prompts y configuracion por herramienta

## Regla de duplicacion

Se permite una version corta de un concepto en `README.md`, pero la explicacion
profunda debe vivir en `ai/`. No se debe mantener la misma seccion larga en dos
lugares.
