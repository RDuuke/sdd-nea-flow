# Validacion proporcional del desarrollo

## Capacidades y obligaciones

Un CRM o CMS puede ofrecer navegador/API sin build; una aplicacion con framework
puede tener pruebas solo en CI; una plantilla documental puede no tener runtime.
INIT registra lo observado, con fuente y disponibilidad, sin deducir herramientas
del tipo de producto. EXPLORE actualiza las capacidades pertinentes al cambio.

DESIGN/QUICK crea validation-plan.yaml con impacto, checks, criterios y evidencia.
La falta de una herramienta opcional es distinta de no poder ejecutar un check
obligatorio. Si no hay automatizacion, un check directo o manual repetible puede
validar comportamiento; una lectura del codigo no sustituye esa ejecucion.

## Politica y resultados

Prioridad: obligaciones explicitas del proyecto y CI, configuracion canonica,
fallback estructurado legacy, y defaults proporcionales. Gates existentes se
conservan. Nuevos proyectos no reciben cobertura minima ni TDD obligatorio.
Excepciones aprobadas son locales al cambio y no rebajan la configuracion global.

| Resultado | Interpretacion |
| --- | --- |
| passed | Evidencia ejecutada demuestra el resultado esperado |
| failed | Comprobacion ejecutada no cumple |
| blocked | Falta entorno, evidencia o decision obligatoria |
| not_run | Comprobacion aun no ejecutada |
| not_applicable | No corresponde al proyecto/cambio, con razon |

COMPLIANT significa criterio respaldado, con automatizacion o comprobacion directa.
No tener test automatizado no equivale a FAILING. Un criterio obligatorio sin
evidencia sigue UNVERIFIED; no se oculta como no aplicable para permitir archivo.

## Reutilizacion y reparacion

Conservar PASS si fuentes, tests/config, entorno y alcance siguen compatibles.
Registrar ejecucion original, hashes y compatibilidad actual; el commit no basta
si el working tree contiene cambios. Evidencia cancelada u omitida no es PASS.

Al reparar una prueba fallida, repetir esa prueba y checks de regresion afectados.
Si cambia setup, fixtures compartidos o configuracion global puede ampliarse el
alcance. Explicar por que; no repetir todas las suites por defecto. Un gate que
exige una ejecucion completa fresca sigue siendo obligatorio salvo excepcion
explicita. Resultados combinados no se presentan como una suite recien ejecutada.

## Casos de aceptacion para revisar instrucciones

VERIFY conserva la identidad e historia de los hallazgos entre informes. Solo
evidencia vigente permite resolverlos: inspeccionar codigo no prueba una
reparacion runtime y un grupo requiere comprobar todos sus criterios. Evidencia
afectada por nuevas entradas se reevalua; historial cerrado compatible no bloquea
archivo por si solo. Sustituir un hallazgo transfiere las obligaciones pendientes,
sin eliminarlas. Contrato: [findings-contract.md](../skills/_shared/findings-contract.md).

La normalizacion que modifica fuentes precede a la verificacion final. Cambios
posteriores invalidan comprobaciones dependientes. VERIFY usa check-only.
Para atribuir un fallo al baseline, reproducirlo con comando/entorno comparables
en una base aislada sin perturbar cambios del usuario. Aun reproducido, un check
obligatorio fallido necesita resolucion o excepcion explicita; no se declara PASS.

Estas trazas ejercitan decisiones del contrato; no son ejecuciones de producto.
BalonManoAnt aporta antecedentes, no defaults universales.

| Entrada/caso | Decision requerida |
| --- | --- |
| Selector en B; solicitud explicita A pausada | Leer A; preservar B; no heredar ARCHIVE de B |
| SPEC lista, DESIGN ausente | Ejecutar DESIGN antes de TASKS |
| DESIGN lista, SPEC ausente | Ejecutar SPEC; conservar DESIGN |
| APPLY con checkbox pendiente y cache vacia | Continuar APPLY; no VERIFY |
| VERIFY failed existente | Recuperar entorno o FIX de producto; no ARCHIVE |
| Estado ausente con aprobacion desconocida | Recuperar artefactos y pedir solo esa decision |
| Estado local corrupto | Detener recuperacion; no usar log como estado |
| Presupuesto excedido aprobado para diff vigente | Continuar; no volver a pedir propuesta |
| Cambio material despues de aprobacion | Invalidar dependencias y renovar aprobacion afectada |
| CMS sin build ni tests, browser disponible | Plan directo ejecutable; no warning por build ausente |
| Framework con tests en CI obligatorios | Esperar evidencia CI; no afirmar ausencia de infraestructura |
| Una prueba falla y otras pasan | Reparar/rerun fallo y afectadas; conservar PASS compatibles |
| Reparacion cambia fixture global | Ampliar checks con razon; aplicar gates existentes |
| Solo documentacion con TDD estricto | Registrar no aplicable razonado; no fabricar RED |
| Entorno caido | Bloqueo de infraestructura; no editar producto por especulacion |
| Dos FIX consumidos, nueva sesion | No FIX3 automatico; informar intervencion manual |
| Reusar PASS sin hashes/entorno | Reejecutar check afectado o pedir evidencia |
| Delta alta/modificacion/baja | Base vigente sin delta headers ni duplicados; conservar ajenos |
| Nombre de requisito ambiguo o base divergente | Resolver conflicto antes de escribir |
| Merge parcial tras interrupcion | Comparar hashes journal y reanudar sin duplicar |
| Archivo movido antes del cierre final | Recuperar en archive; no recrear carpeta activa |
| Log entregado dos veces con mismo ID | Un evento; conflicto de payload bloquea |
| Edicion mecanica aprobada en siete archivos, sin agentes permitidos | Ejecucion inline acotada; no delegacion por conteo |
| Formatter cambia fuentes despues de VERIFY | Invalidar evidencia dependiente y verificar entradas actuales antes de archivo |
| Check obligatorio falla tambien en baseline aislado | Registrar origen; no archivo sin resolver obligacion/excepcion |
| Escritura devuelve exito pero falla readback | Reconciliar contenido real; no declarar persistencia ni avanzar |
| Preparar PR para publicar despues, sin issue relevante | Borrador local en rama vigente; no issue inventada ni publicacion |
| Dos fallos similares sin causa corroborada | Conservar sintomas separados; causa propuesta sigue siendo hipotesis |
| Reparacion runtime con inspeccion solamente | Hallazgo abierto; falta evidencia ejecutada |
| Grupo con criterios A/B y solo A probado | Conservar B pendiente; no declarar todo el grupo resuelto |
| Hallazgo resuelto con entradas pertinentes cambiadas | Reevaluar evidencia afectada; reabrir si falta prueba compatible |
| Hallazgo sustituido por reemplazo abierto | Seguir obligaciones del reemplazo; no inferir reparacion |
| Historial antiguo bloqueante con cierre probado vigente | Conservar historial; evaluar bloqueo actual y obligaciones |

Validacion de sintaxis, contratos de respuesta y refs:
`py scripts/validate-development-contracts.py` (PyYAML solo para QA documental).
Casos del validador: `py -m unittest discover -s tests -p test_development_contracts.py`.
No es dependencia runtime del flujo. Los contratos fuente estan en
[state-contract.md](../skills/_shared/state-contract.md),
[validation-contract.md](../skills/_shared/validation-contract.md) y
[audit-contract.md](../skills/_shared/audit-contract.md).
