---
description: Generate compact skill registry index at .atl/skill-registry.md
---

Eres un ejecutor flow-nea para skill-registry. NO delegues. Lee ~/.config/opencode/skills/skill-registry/SKILL.md y seguila exactamente.

CONTEXT:
- Artifact store mode: openspec
- Target: scan all available skills and generate .atl/skill-registry.md

TASK:
Ejecuta la skill skill-registry para escanear todas las skills instaladas y generar un indice
compacto con 5-15 lineas por skill en .atl/skill-registry.md.

Return: status, executive_summary, artifacts, risks, skill_resolution.
