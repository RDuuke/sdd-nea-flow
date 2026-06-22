# Handoff — nea-flow (capa de iniciativa) → fork

Documento de entrega para equipos que harán un **fork** de nea-flow y continuarán
el trabajo (p. ej. Iris, que usa Azure DevOps). Versión de referencia: **v2.3.0**.

## Qué es nea-flow

Framework de Spec-Driven Development, cero dependencias, solo Markdown:

- **Core per-proyecto (OpenSpec):** orquesta un `change` dentro de un proyecto
  (`INIT → EXPLORE → PROPOSE → SPEC → DESIGN → TASKS → APPLY → VERIFY → ARCHIVE`).
  Estado en `openspec/`.
- **Capa de iniciativa (upstream, esta entrega):** corre en un repo dedicado por
  iniciativa. Ingiere documentos de negocio/producto y produce specs generales y
  Historias de Usuario, dejando una interfaz para el pipeline de cambios.

  ```text
  INITIATIVE-INIT → INTAKE → [gate revisión humana] → SPEC (Features)
                  → HU (Historias) → (ENRICH opcional) → (DECOMPOSE futuro)
  ```

  Mapeo conceptual a Azure DevOps (solo metadata, sin API): iniciativa ≈ Epic,
  spec general = Feature, HU = User Story.

## Cómo forkear y usar

1. Fork en GitHub de `RDuuke/sdd-nea-flow` desde el tag **`v2.3.0`**.
2. Instalar las skills/comandos en el repo de iniciativa o de proyecto:
   - Windows: `./scripts/install.ps1 -Agent claude-code -Scope local`
   - Unix: `./scripts/install.sh --agent claude-code --scope local`
   - El glob `flow-nea-*` instala también las skills `flow-nea-initiative-*`.
3. Comandos de la capa de iniciativa:
   - `/flow-nea-initiative-init <slug>` — scaffold + Definition of Ready
   - `/flow-nea-initiative-intake <slug>` — ingiere `sources/01..06`
   - `/flow-nea-initiative-spec <slug>` — Features + capacidades (CAP-xxx)
   - `/flow-nea-initiative-hu <slug>` — Historias (carpeta por HU) + `impact-map.yaml`
   - `/flow-nea-initiative-arch|design <slug> HU-xxx` — enriquecimiento por especialista
   - `/flow-nea-initiative-ff <slug>` — init→intake (gate); `/flow-nea-initiative-auto` — desatendido

## Mapa de artefactos (repo de iniciativa)

```text
sources/01..06/                 # input humano (SIEMPRE `sources/`; `resources/` se ignora)
initiative/
  config.yaml                   # identidad + mapeo Azure + gates + target_projects
  glossary.md                   # glosario externo; specs/HU enlazan términos por ancla
  .status.yaml                  # estado (INIT | INTAKE | SPEC | HU)
  intake/intake.md              # digest + enlace al glosario
  intake/source-index.md        # inventario (parsed | encoding | unsupported-format | empty)
  intake/needs-review.md        # archivos a revisar (encoding UTF-8 / formato)
  specs/{domain}/spec.md        # Feature + CAP-xxx + TOC de HU + Dependencias y orden + Historial
  specs/{domain}/hu/HU-xxx/HU-xxx.md   # cuerpo de la HU (+ assets/.gitkeep)
  impact-map.yaml               # interfaz de integración (schema 2.3)
  .execution-log.md
```

**`impact-map.yaml` es la interfaz de integración.** Es un índice liviano de
routing (una entrada por HU: id, spec_ref, capability, target_project, order,
depends_on, enrichment, status, blockers, revision). Cada consumidor decide cómo
proyectarlo a su gestor. El cuerpo rico vive en los `.md`; el YAML no lo duplica.

Comportamientos clave ya implementados: anti-invención (todo rastrea a fuente o
queda `[sin confirmar]`); altitud de negocio en specs; triaje de encoding/formato
sin romper el intake; HU con estados (`proposed|blocked|seeded|closed|rejected`);
HUs `seeded`/`closed` son inmutables → re-run crea sucesora (`supersedes`); orden
y dependencias con detección de ciclos; historial por artefacto.

## Roadmap (pendientes y dueños)

| Tema | Dueño | Notas |
|---|---|---|
| **`board` (Azure)** | fork (Iris) | `config.yaml` lleva catálogo `boards:` + `initiative.board` (elegido en init); `impact-map.yaml` lleva el `board` resuelto (top-level). Board por iniciativa (uno). Es metadata de Azure. |
| **Desacople de Azure** | **nea-flow upstream** | nea-flow es agnóstico al gestor: el core se neutraliza (vocabulario neutral; Azure pasa a ser un *perfil de integración* opcional; `impact-map` neutral + `external_refs`). Iris consume el perfil Azure. |
| **DECOMPOSE** | por definir | Fase que consume `impact-map.yaml` y siembra el seed de cada HU en `openspec/changes/` del proyecto cl00xx destino. Cierra el ciclo iniciativa→proyecto. |
| **Reinstalar tras updates** | consumidores | Tras actualizar skills, re-correr el instalador en cada proyecto consumidor. |

## Versionado y seguimiento

- Releases con tags `vX.Y.Z`. Esta entrega = **`v2.3.0`** (capa de iniciativa GA).
- El fork debe **trackear upstream** (`git remote add upstream …`) para traer el
  desacople de Azure y mejoras del core cuando se publiquen.
