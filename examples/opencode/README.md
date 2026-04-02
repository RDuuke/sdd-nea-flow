# OpenCode — Configuracion nativa multi-agente

Este directorio contiene la configuracion lista para usar con OpenCode.

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `opencode.multi.json` | 12 agentes con modelos diferenciados por fase (recomendado) |
| `opencode.single.json` | Misma estructura, un solo modelo para todas las fases |
| `AGENTS.md` | Prompt del orquestador (referenciado via `{file:./AGENTS.md}`) |
| `commands/` | Slash commands para todos los comandos del flujo |

## Instalacion rapida

```bash
./scripts/install.sh  # Opcion 1: OpenCode
```

El instalador te pregunta si quieres la variante multi-modelo o single-modelo,
copia las skills a `~/.config/opencode/skills/` y fusiona los agentes en tu
`~/.config/opencode/config.json` sin tocar tus agentes existentes.

## Instalacion manual

1. Copia las skills:

```bash
mkdir -p ~/.config/opencode/skills
cp -r skills/flow-nea-* ~/.config/opencode/skills/
cp -r skills/judgment-day ~/.config/opencode/skills/
cp -r skills/skill-registry ~/.config/opencode/skills/
cp -r skills/skill-creator ~/.config/opencode/skills/
cp -r skills/_shared ~/.config/opencode/skills/
```

2. Copia `AGENTS.md` al directorio de OpenCode:

```bash
cp examples/opencode/AGENTS.md ~/.config/opencode/AGENTS.md
```

3. Elige una variante y fusiona el bloque `agent` en `~/.config/opencode/config.json`:

```bash
# Multi-modelo (recomendado)
jq -s '.[0] * {agent: (.[0].agent + .[1].agent)}' \
  ~/.config/opencode/config.json \
  examples/opencode/opencode.multi.json > /tmp/oc.json && mv /tmp/oc.json ~/.config/opencode/config.json

# Single-modelo
jq -s '.[0] * {agent: (.[0].agent + .[1].agent)}' \
  ~/.config/opencode/config.json \
  examples/opencode/opencode.single.json > /tmp/oc.json && mv /tmp/oc.json ~/.config/opencode/config.json
```

4. Edita el archivo resultante y reemplaza los placeholders de modelo:
   - `<your-provider/your-model-opus>` → tu modelo de mayor capacidad
   - `<your-provider/your-model-sonnet>` → tu modelo de uso general
   - `<your-provider/your-model-haiku>` → tu modelo mas rapido/economico
   - (single: `<your-provider/your-model>` → un solo modelo para todo)

## Verificar

Abre OpenCode y ejecuta `/flow-nea-init`.
