---
name: skill-creator
description: >
  Creates new AI agent skills following the flow-nea skill spec.
  Trigger: When user asks to create a new skill, add agent instructions, or document patterns for AI.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Create a Skill

Create when:
- A pattern is used repeatedly and the AI needs guidance
- Project conventions differ from generic best practices
- Complex workflows need step-by-step instructions
- Decision trees help the AI choose the right approach

**Do NOT create when:**
- Documentation already exists (create a reference instead)
- The pattern is trivial or self-explanatory
- It is a one-off task

---

## Skill Structure

```
skills/{skill-name}/
├── SKILL.md              # Required — main file
├── assets/               # Optional — templates, schemas, examples
│   ├── template.ext
│   └── schema.json
└── references/           # Optional — links to local docs
    └── docs.md
```

---

## SKILL.md Template

```markdown
---
name: {skill-name}
description: >
  {One-line description of what this skill does}.
  Trigger: {When the AI should load this skill}.
license: MIT
metadata:
  author: {author}
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

{Concise purpose}

## What You Receive

- {Input 1}
- {Input 2}

## What to Do

### Step 1: {First step}

{Instructions}

### Step 2: {Second step}

{Instructions}

## Rules

- {Critical rule 1}
- {Critical rule 2}

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "...",
  "artifacts": [],
  "next_recommended": "...",
  "risks": [],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
```

---

## Naming Conventions

| Type | Pattern | Examples |
|------|---------|----------|
| Generic skill | `{technology}` | `pytest`, `playwright` |
| Project-specific | `{project}-{component}` | `myapp-api`, `myapp-ui` |
| Workflow | `{action}-{target}` | `skill-creator`, `judgment-day` |

---

## Rule: assets/ vs references/

```
Need code templates?       → assets/
Need JSON schemas?         → assets/
Need config examples?      → assets/
Link to existing docs?     → references/ (LOCAL paths, not web URLs)
```

---

## Required Frontmatter

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Identifier (lowercase, hyphens) |
| `description` | Yes | What it does + Trigger in one block |
| `license` | Yes | MIT |
| `metadata.author` | Yes | Author |
| `metadata.version` | Yes | Semantic version as string |

---

## Pre-creation Checklist

- [ ] Skill does not already exist (check `skills/`)
- [ ] Pattern is reusable (not a one-off)
- [ ] Name follows conventions
- [ ] Frontmatter is complete (description includes trigger keywords)
- [ ] Critical patterns are clear
- [ ] Code examples are minimal
- [ ] Output Contract includes `skill_resolution`
- [ ] Register in `checksums.sha256` if applicable

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
