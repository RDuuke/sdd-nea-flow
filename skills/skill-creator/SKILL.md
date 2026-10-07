---
name: skill-creator
description: >
  Creates new AI agent skills following the flow-nea skill spec.
  Trigger: When user asks to create a new skill, add agent instructions, or document patterns for AI.
license: MIT
metadata:
  author: juan-duque
  version: "1.1"
  scope: [root]
  invoker: flow-nea-orchestrator
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Purpose

Create or update reusable AI instructions when project-specific decisions need
guidance. Do not create a skill for trivial, one-off or already documented work.
Prefer a narrow update or shared reference over another overlapping skill.

## Workflow

1. Resolve the requested location and inspect applicable conventions/nearby skills.
   Read an existing SKILL.md fully before modifying it; preserve its trigger,
   supported metadata and output fields unless the requested change affects them.
2. Read [skill-authoring.md](../_shared/skill-authoring.md) for repository structure,
   frontmatter, language, progressive disclosure and installation constraints.
3. Write a concise entrypoint with real decision rules, boundaries and JSON
   output. Put substantial conditional examples in installed references. No hard
   word ceiling, duplicated tutorial or resource directory without a use.
4. Align affected examples/human docs and checksums. Validate frontmatter, JSON
   and installed reference paths. For complex workflows use realistic scoped
   evaluation when available/authorized; do not mistake syntax for behavior.
5. Return the standard envelope with actual files changed and unresolved gaps.
   Never change deployment, memory or publication policy as an implied side effect.

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Skill {name} created at skills/{name}/SKILL.md",
  "artifacts": [
    {
      "name": "{skill-name}",
      "path": "skills/{skill-name}/SKILL.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "none",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
