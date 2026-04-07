---
name: skill-registry
description: >
  Scan and catalog all available skills in a project into a compact registry.
  Trigger: When user requests skill registry update, after installing/removing a skill, or on first sdd-init.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---

## Purpose

Generates a skill registry (`.atl/skill-registry.md`) that catalogs all available skills and compacts them into rules for injection into sub-agent prompts.

## Key Concept

**Sub-agents do NOT read the registry or individual SKILL.md files.** Instead, they receive compact rule summaries pre-resolved in their launch prompt. This optimizes context per agent and per session.

## What It Does

### Step 1: Scan Directories

Traverse in order:
- User-level: `~/.claude/skills/`
- Project-level: `skills/` (at the project root)

### Step 2: Exclude SDD/NEA Workflow Skills

Do not catalog:
- `flow-nea-explore`, `flow-nea-propose`, `flow-nea-spec`, `flow-nea-design`
- `flow-nea-tasks`, `flow-nea-apply`, `flow-nea-verify`, `flow-nea-archive`
- `flow-nea-init`, `flow-nea-quick`, `_shared`
- The `skill-registry` skill itself

These are reserved for orchestrator coordination.

### Step 3: Extract Compact Rules

For each skill found, extract:
- Purpose (one line from `description`)
- 2-5 critical patterns or restrictions from the content
- Trigger/usage context

Compact rule format (5-15 lines):
```
## {Skill Name}

- {Critical pattern 1}
- {Critical pattern 2}
- {Critical pattern 3}
- Use when: {trigger context}
```

### Step 4: Write `.atl/skill-registry.md`

Structure:

```markdown
# Skill Registry

Generated: {timestamp}

## Compact Rules

{Compact rule blocks per skill}

## Metadata

- Total skills: {N}
- Scanned: skills/, ~/.claude/skills/
- Updated: {timestamp}
```

Create the `.atl/` directory if it does not exist. Add `.atl/` to `.gitignore` if not already there.

### Step 5: Return Summary

Return an envelope with: status, executive_summary, artifacts, risks.

## Rules

- NEVER include implementation code in compact rules
- Compact rules MUST be concise (5-15 lines each)
- Do not re-scan on every invocation if the registry exists and is recent (< 1 hour)
- If no skills are found, return an empty registry with metadata

## Output Contract (JSON)

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "Registry updated. N skills cataloged.",
  "artifacts": [
    {
      "name": "skill_registry",
      "path": ".atl/skill-registry.md",
      "type": "markdown"
    }
  ],
  "next_recommended": "none",
  "risks": ["list of risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```
