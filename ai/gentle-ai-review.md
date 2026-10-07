# Revision de Gentle AI para el flujo de desarrollo

Esta revision compara catorce fuentes de Gentle AI con el flujo de desarrollo de
NEA. No cambia el flujo de iniciativas. Las integraciones del primer lote ya se
aplicaron, con contratos compartidos y sin Engram. El segundo lote tambien esta
integrado, como se detalla mas abajo. Los cambios y la revision estan en
`feat/development-flow-improvements`, preparados para la entrega v2.4.0.

Las fuentes se consultaron en el commit
`631cf9295f1393f857ce2f0f7088a30dd08b70f0`. Los enlaces fijan esa version para
evitar que una actualizacion de `main` cambie el fundamento de la comparacion.

## Decision recomendada

Conservar el flujo SDD explicito y adoptar mejoras puntuales de ejecucion y
entrega. Gentle AI usa Organic Driven Development (ODD), con contratos de
investigacion, memoria y revision propios. Sustituir nuestro flujo por ese
modelo perderia las decisiones ya tomadas sobre OpenSpec, evidencia
proporcional y specs consolidadas.

La simplificacion debe eliminar duplicacion e imposiciones universales, sin
eliminar evidencia, recuperacion ni las politicas obligatorias del proyecto.

## Comparacion de las nueve fuentes

| Fuente | Integrar o adaptar | Mantener fuera del nucleo |
| --- | --- | --- |
| [Orquestador Codex](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/codex/orchestrator.md) | Cargar las skills por rutas exactas; acotar contexto, objetivo y superficies de escritura; delegar por riesgo o independencia; observar la terminacion de los workers. | ODD siempre activo, comandos propietarios de revision y placeholders que requieren su renderizador. NEA se activa por instruccion explicita. |
| [Secciones compartidas ODD](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/_shared/odd-orchestrator-sections.md) | Una fuente comun para reglas transversales; normalizacion antes de verificar; cambios posteriores invalidan evidencia afectada; distinguir defectos introducidos y fallos del baseline. | Revision independiente para todo cambio, heuristicas por modelo y bloques adicionales de texto que romperian nuestro resultado JSON. No duplicar el contador de FIX. |
| [Persistencia](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/_shared/persistence-contract.md) | Leer de vuelta las escrituras antes de declarar exito; leer, combinar y guardar sin perder progreso; conservar versiones en conflicto y cerrar con un handoff completo. | Engram obligatorio, espejo completo de tareas y una segunda estructura `odd/tasks/`. OpenSpec sigue siendo la fuente de verdad; una casilla completada no prueba validacion. |
| [Investigacion](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/_shared/research-lifecycle.md) | Investigar preguntas concretas, citar fuentes primarias y separar hechos, supuestos, vigencia y vacios. Continuar trabajo independiente cuando falte evidencia opcional. | Nueva fase obligatoria, cuestionarios fijos y ceremonias de persistencia. EXPLORE puede cubrir esta necesidad y respetar los artefactos autorizados. |
| [Branch y PR](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/branch-pr/SKILL.md) | Resolver destino y rama base reales; usar la plantilla del repositorio; informar checks ejecutados y pendientes; atribuir fallos al baseline solo con reproduccion comparable aislada. | Issue con `status:approved`, etiqueta `type:*`, limite fijo de 400 lineas y comandos Go como requisitos generales. Son politicas de Gentle AI. |
| [PRs encadenados](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/chained-pr/SKILL.md) | Dividir cambios grandes por unidades coherentes cuando facilite revision y rollback; explicar dependencias y conservar las decisiones de entrega del usuario. | Encadenar PRs automaticamente o reducir claridad para cumplir un numero de lineas. Este trabajo permanece en la rama elegida. |
| [Creacion de issues](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/issue-creation/SKILL.md) | Leer formularios y politicas del destino; comprobar duplicados; verificar el resultado de una escritura remota y detener reintentos si su resultado es desconocido. | Issue obligatoria para desarrollar; taxonomia y gates de aprobacion de Gentle AI. Solo activar una adaptacion de entrega cuando se solicite esa operacion. |
| [Creacion de skills](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/skill-creator/SKILL.md) | Skills concisas, triggers claros y referencias para detalles reutilizables. Crear una skill cuando exista una necesidad repetida, no para cada procedimiento. | Copiar su frontmatter, licencia o limites de palabras como contrato propio. Las referencias nuevas deben ser instalables. |
| [Commits por unidad de trabajo](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/work-unit-commits/SKILL.md) | Agrupar comportamiento, pruebas y documentacion relacionadas; identificar validacion y efecto de revertir cada unidad. | Commit automatico por fase o tarea, separacion por tipo de archivo y presupuesto universal de lineas. La entrega debe respetar la autorizacion del usuario. |

## Que simplificar de NEA

1. **Duplicacion entre orquestadores.** Extraer las reglas comunes que aun se
   repiten en los cinco ejemplos a un contrato compartido instalable. Cada
   ejemplo conserva activacion, herramientas y limites propios de su entorno.
   Los wrappers conservan solo el despacho y sus parametros.
2. **Delegacion por cantidad de archivos.** Reemplazar umbrales mecanicos por
   riesgo, independencia, incertidumbre y volumen real de contexto. Una edicion
   mecanica de varios archivos no exige otro agente; una revision sensible
   puede necesitarlo aunque afecte un archivo. Respetar las capacidades y
   permisos del entorno, con ejecucion secuencial cuando corresponda.
3. **Resumenes como sustituto de una skill.** Mantener reglas compactas del
   proyecto, pero entregar tambien la ruta exacta de la skill ejecutora y exigir
   su lectura. Conservar los valores actuales de `skill_resolution` para no
   romper consumidores.
4. **Limites rigidos de longitud y listas de tareas fijas.** Convertir objetivos
   de brevedad en guia, evitando truncar requisitos o imponer trabajo que no
   aplica. Conservar dependencias y criterios de aceptacion verificables.
5. **Plantillas extensas repetidas en las skills.** Mover ejemplos y esquemas
   comunes a referencias compartidas. Antes de usar subcarpetas de referencias
   por skill, ampliar los instaladores: actualmente copian `SKILL.md` y los
   Markdown compartidos, no todos los recursos locales de cada skill.

Estas simplificaciones ya se aplicaron: contrato comun de ejecucion, rutas exactas,
delegacion por riesgo, tareas por unidades coherentes y ejemplos compartidos.
Los recursos nuevos son `_shared/*.md`, compatibles con ambos instaladores; no
fue necesario ampliar la copia de recursos por skill. Los contratos JSON y la
capa de iniciativa se conservaron.

## Que conservar de los cambios ya implementados

- Estado por change, selector global y recuperacion sin destruir datos previos.
- Logs y reportes operativos YAML, con referencias a evidencia; documentos de
  propuesta, specs, diseno y tareas en Markdown.
- Validacion segun capacidades observadas del proyecto. Ser un CRM o usar un
  framework no prueba que existan tests, navegador, APIs o infraestructura.
- Reejecucion de pruebas fallidas y areas afectadas. Una falla no obliga a
  repetir toda la suite; ampliar solo por impacto o un gate vigente que lo
  exija. La evidencia reutilizada debe seguir siendo compatible y declararse.
- Gates obligatorios existentes y excepciones autorizadas con alcance concreto.
- ARCHIVE que combina deltas en una spec vigente por dominio, conserva lo no
  afectado y puede recuperarse de una interrupcion. No copiar cada change como
  una spec independiente ni acumular bloques delta.
- Autorizaciones vigentes sin nuevas confirmaciones por cada lote. ARCHIVE no
  implica commit, push, publicacion de PR o despliegue.

## Integracion aplicada

| Tanda | Cambio operativo | Comprobacion necesaria |
| --- | --- | --- |
| 1 | Contrato comun de ejecucion: rutas exactas de skills, contexto acotado, escrituras verificadas y delegacion por riesgo. Actualizar los cinco ejemplos y wrappers afectados. | Rutas instaladas validas, contratos JSON intactos y coherencia entre herramientas; caso de edicion mecanica sin delegacion forzada. |
| 2 | Normalizacion antes de VERIFY y atribucion de baseline con evidencia; reutilizar invalidacion y FIX existentes. | Una modificacion posterior invalida solo evidencia dependiente; falla focal no provoca suite completa; baseline sin reproduccion queda sin confirmar. |
| 3 | Entrega opcional por unidades revisables: commits y PR con destino, plantilla, evidencia y dependencias del proyecto. | Preparar una entrega sin publicar; no inventar issues, etiquetas, checks ni autorizaciones. No cambiar la estrategia de rama elegida. |
| 4 | Reducir cuerpos y plantillas duplicadas; ampliar instaladores solo si se agregan recursos por skill. | Instalacion en directorio temporal y comprobacion de todas las referencias; checksums actualizados para skills modificadas. |

No se recomienda importar las nueve skills completas ni agregar nueve gates al
flujo. Las mejoras transversales pertenecen a contratos compartidos; la entrega
puede ser una capacidad opcional, fuera del grafo SDD obligatorio.

Fuentes operativas:
[ejecucion](../skills/_shared/execution-contract.md),
[investigacion](../skills/_shared/research-contract.md),
[entrega](../skills/_shared/delivery-contract.md),
[validacion](../skills/_shared/validation-contract.md),
[ejemplos de planeacion](../skills/_shared/planning-examples.md) y
[autoria](../skills/_shared/skill-authoring.md).

## Validacion de esta integracion

El validador documental comprobo 43 frontmatters, 14 ejemplos JSON, 12 YAML y
64 enlaces locales sin errores. Se verificaron 24 checksums y la instalacion
PowerShell en un directorio aislado, con las nuevas referencias compartidas.
Ambas configuraciones OpenCode conservan las definiciones de iniciativa y sus
secciones de prompt permanecen iguales al baseline.

Una revision independiente ejercito siete escenarios de instrucciones: edicion
mecanica sin agentes, FIX focal con PASS reutilizable, fallo obligatorio previo,
PR preparado sin publicar, normalizacion posterior a VERIFY, fallo de readback y
revision dual sin capacidad independiente. Esto comprueba decisiones del flujo,
no ejecuciones ni pruebas de producto. No se publico PR ni se cambio la
instalacion global durante la comprobacion.

El segundo lote paso 23 pruebas del validador y la comprobacion documental de
43 frontmatters, 14 ejemplos JSON, 12 YAML, 88 enlaces y 27 checksums. La
instalacion aislada distribuyo 21 skills y 14 referencias compartidas; los 35
archivos coincidieron con sus fuentes y 39 enlaces de desarrollo instalados
fueron validos. La revision independiente ejercito nueve escenarios de triage y
continuidad de hallazgos. Detecto una regla de validacion segura de comandos que
se incorporo al contrato que carga VERIFY. Son comprobaciones de instrucciones
y distribucion, no pruebas de aplicaciones destino.

## Segundo lote: triage, delegacion, documentos y revision

Estas cinco fuentes se revisaron en el mismo commit fijado arriba. Esta seccion
documenta la adaptacion aplicada en contratos compartidos y fases existentes.
No se instalaron skills externas ni motores propietarios.

| Fuente | Aporte revisado | Adaptacion aplicada |
| --- | --- | --- |
| [Systemic issue triage](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/systemic-issue-triage/SKILL.md) | Agrupa sintomas por causa raiz, exige reproducir el problema y cuestiona soluciones que agregan complejidad. NEA incorpora agrupacion condicionada a evidencia en EXPLORE/APPLY/FIX. | Reproduccion y agrupacion en EXPLORE/FIX cuando la evidencia lo justifique. Validar todos los sintomas asociados; usar pruebas o evidencia directa identificada. No exigir cluster para un bug aislado, reduccion de lineas, nuevas gates o cierre remoto automatico. |
| [Hermes ephemeral delegation](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/hermes-ephemeral-delegation/SKILL.md) | Misiones autosuficientes, motivos concretos de delegacion, independencia y comprobacion de resultados. Gran parte ya vive en execution-contract.md. | Evidencia comprobable en el handoff y contexto acotado. No importar delegate_task, perfiles de agente Hermes, TDD universal o una suite obligatoria por tarea; comprobar evidencia no significa repetir todas las pruebas. |
| [Cognitive doc design](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/cognitive-doc-design/SKILL.md) | Resultado primero, detalle progresivo y una ruta de lectura para reviewers. Ya usamos referencias bajo demanda; la guia compartida explicita el recorrido de revision. | Guia compartida para autoria y entrega: que cambio, donde revisar primero y que evidencia lo respalda. Adaptar estructura a cada documento, sin imponer todas sus secciones ni convertir los registros YAML en documentos narrativos. |
| [Review ledger general](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/_shared/review-ledger-contract.md) | Vincula revision al candidato exacto, separa revision de entrega y evita tratar acceso fallido como revision terminada. NEA ya tiene hashes, categorias, evidencia y autorizacion de entrega separada. | Conservar identidad y resolucion de hallazgos en los reportes existentes. No importar el motor Go, autoridades opacas, lineages, acknowledgements ni revision automatica de cuatro lentes. |
| [Review ledger Pi](https://github.com/Gentleman-Programming/gentle-ai/blob/631cf9295f1393f857ce2f0f7088a30dd08b70f0/internal/assets/skills/_shared/review-ledger-contract-pi.md) | Adapta el ciclo anterior a herramientas gentle-pi, con inspect/start/status/capture y bindings del proveedor. No es un formato de log reutilizable por si solo. | Mantener solo principios generales: resultado observado, candidato identificado y cierre no inferido. No integrar el adaptador Pi ni inventar sus herramientas en entornos sin ellas. |

### Mejoras aplicadas del segundo lote

1. **Triage causal acotado.** Tratar la causa propuesta por un reporte como
   hipotesis. Reproducir el sintoma antes de corregir; agrupar fallos solo con
   evidencia de una causa compartida. Si varias paginas fallan por el mismo
   plugin/configuracion, una correccion puede cubrirlas, pero hay que comprobar
   cada criterio afectado. No asumir una causa comun porque todos usan WordPress.
2. **Resolucion de hallazgos sin un segundo ledger.** Se extendieron findings de
   verify-report.yaml con identidad preservada entre ejecuciones, resolucion y
   referencias a evidencia de reparacion/validacion. FIX conserva finding_ids y
   su presupuesto actual. Un hallazgo no desaparece por reemplazar el informe:
   indicar resuelto, pendiente, descartado con evidencia o sustituido por otro.
   Esto no crea otra autoridad ni permite archivo con obligaciones pendientes.
3. **Ruta de revision en documentos humanos.** Guiar al reviewer hacia los
   contratos cambiados y evidencia relevante. Mantener resumen corto y detalle
   enlazado; no repetir una narrativa por fase ni una plantilla completa en todos
   los documentos. Preservar las plantillas reales del proyecto destino.

La revision independiente no sustituye verificacion funcional y no autoriza
commit/push/PR. Un error conocido del baseline no exime un check obligatorio.
El protocolo de Gentle AI permite una correccion nativa; no se debe superponer
a nuestros dos ciclos FIX ni agregar otro contador.

Fuentes operativas nuevas:
[triage](../skills/_shared/triage-contract.md),
[continuidad de hallazgos](../skills/_shared/findings-contract.md) y
[documentacion](../skills/_shared/documentation-contract.md).
EXPLORE, APPLY, VERIFY y los wrappers FIX consumen estas reglas. Ejecucion,
entrega y autoria enlazan los contratos pertinentes, sin nuevas fases ni gates.

### Relacion con plugins CMS/CRM

NEA Flow sigue siendo agnostico a herramientas. El soporte especifico para
WordPress/Joomla/Drupal u otros CMS/CRM pertenece a un plugin opcional; no se
introduce deteccion ni activacion de ese plugin en esta integracion. El plugin
podra aportar capacidades y entradas observadas de entorno, contenido y
configuracion para seleccionar comprobaciones pertinentes.

Para triage CMS, separar sintoma, entorno/datos y causa corroborada. Para
trazabilidad, la identidad del candidato incluye entradas externas pertinentes,
no solo el commit del codigo. Un inventario nuevo o un informe mas largo no
justifica repetir toda la suite; aplicar compatibilidad e invalidacion por impacto.
