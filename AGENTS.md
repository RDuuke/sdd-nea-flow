# AGENTS.md — sdd-nea-flow

Instructions for AI agents working in this repository.
This file explains how the repo is organized, its conventions, and how to contribute correctly.

## What This Repo Is

`sdd-nea-flow` is a skills library for Spec-Driven Development (SDD) built around a sub-agent orchestration pattern. It contains:

- **Phase skills** (`skills/flow-nea-*/SKILL.md`): executable instructions for each flow phase
- **Support skills** (`skills/judgment-day/`, `skills/skill-registry/`, `skills/skill-creator/`)
- **Tool-specific examples** (`examples/*/`): ready-to-use configuration for each editor/CLI
- **Installation scripts** (`scripts/install.sh`, `scripts/install.ps1`)

There is no application code here. The value of the repo lives in the Markdown instructions.

## Repo Structure

```text
sdd-nea-flow/
├── skills/
│   ├── flow-nea-init/SKILL.md
│   ├── flow-nea-explore/SKILL.md
│   ├── flow-nea-propose/SKILL.md
│   ├── flow-nea-spec/SKILL.md
│   ├── flow-nea-design/SKILL.md
│   ├── flow-nea-tasks/SKILL.md
│   ├── flow-nea-apply/SKILL.md
│   ├── flow-nea-verify/SKILL.md
│   ├── flow-nea-archive/SKILL.md
│   ├── flow-nea-continue/SKILL.md
│   ├── judgment-day/SKILL.md
│   ├── skill-registry/SKILL.md
│   ├── skill-creator/SKILL.md
│   └── _shared/
│       └── persistence-contract.md
├── examples/
│   ├── opencode/
│   │   ├── AGENTS.md              <- orchestrator prompt for OpenCode
│   │   ├── opencode.multi.json    <- config with phase-specific models
│   │   └── opencode.single.json   <- config with a single model
│   ├── claude-code/
│   │   ├── CLAUDE.md              <- orchestrator prompt for Claude Code
│   │   └── commands/              <- slash commands (/flow-nea-*.md)
│   ├── amazonq/
│   ├── gemini-cli/
│   ├── codex/
│   └── vscode/
├── scripts/
│   ├── install.sh
│   └── install.ps1
├── README.md
└── AGENTS.md                      <- this file
```

## Critical Conventions

### Language

- **Flow artifacts**: ALWAYS in Spanish (`proposal.md`, specs, `design.md`, `tasks.md`, `verify-report.md`)
- **File names and paths**: ALWAYS in English
- **Source code and code comments**: follow the destination project's language
- **AI-facing instructions in this repo** (`SKILL.md`, orchestrator prompts, agent instruction files): English
- **Human-facing documentation** (`README.md` and explanatory docs): Spanish unless there is a strong reason not to

### Skill Format

Each `SKILL.md` contains:

1. **YAML frontmatter** with `name`, `description`, `trigger`, `license`, `metadata`
2. **## Purpose** — what the skill does in one sentence
3. **## What You Receive** — input parameters
4. **## Execution and Persistence Contract** — read `skills/_shared/persistence-contract.md`
5. **## What to Do** — numbered steps (`Step 1`, `Step 2`, ...)
6. **## Rules** — restrictions and limits
7. **## Output Contract (JSON)** — exact return envelope

### Output Contract (Standard Envelope)

All skills return this JSON:

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "brief summary for the orchestrator",
  "detailed_report": "optional analysis when complexity requires it",
  "artifacts": [
    {
      "name": "artifact-name",
      "path": "relative/path/to/artifact",
      "type": "markdown | yaml | directory"
    }
  ],
  "next_recommended": "NEXT_PHASE_NAME",
  "risks": ["list of risks or blockers"],
  "skill_resolution": "injected | fallback-registry | fallback-path | none"
}
```

`skill_resolution` indicates whether the skill instructions reached the sub-agent correctly:
- `injected`: the orchestrator injected the compact rules successfully
- `fallback-registry`: the sub-agent used `.atl/skill-registry.md` as fallback
- `fallback-path`: the sub-agent read `SKILL.md` directly
- `none`: the sub-agent did not find the instructions

### Size Budgets (Do Not Exceed)

| Artifact | Limit |
|----------|-------|
| tasks.md | 530 words |
| design.md | 800 words |
| proposal.md | 500 words |
| specs/ (per domain) | 650 words |

### Flow Dependency Graph

```text
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```

SPEC and DESIGN are independent (both read PROPOSE). TASKS requires both.

## How To Add a New Skill

1. Create `skills/{name}/SKILL.md` following the required frontmatter and section structure
2. If the skill is a flow phase, add it to the dependency graph in:
   - `examples/claude-code/CLAUDE.md`
   - `examples/opencode/AGENTS.md`
   - `examples/opencode/opencode.multi.json` and `opencode.single.json`
3. If installation changes are needed, update `scripts/install.sh` and `scripts/install.ps1`
4. Update `README.md`: repo structure and any additional skills section if applicable

## How To Modify an Existing Skill

1. Read the entire `SKILL.md` before editing
2. Preserve the output contract; do not remove fields from the JSON envelope
3. If you change a size budget, update the budget table in this file
4. Mentally test the change against at least one example before opening a PR

## How To Modify the Installation Scripts

The scripts use idempotent markers: `<!-- BEGIN:flow-nea -->` / `<!-- END:flow-nea -->`.

- The skill list to install lives in `install_skills()` (bash) and `Install-Skills` (PowerShell)
- The OpenCode functions (`install_opencode_config` / `Install-OpenCodeConfig`) use `jq` for intelligent merges
- Always verify idempotency: running the script twice must not duplicate content

## What Not To Do

- Do not create extra documentation files (`.md`) outside the existing directories without justification
- Do not add application logic or executable code beyond installation shell scripts
- Do not modify `openspec/` — that folder is generated by the flow inside target projects, not this repo
- Do not hardcode specific model names inside skills; use placeholders or let the orchestrator resolve them
- Do not write flow artifact contents in English; that would violate the language rule

## Skills

A skill is a set of local instructions stored in a `SKILL.md` file. Below is the list of skills that can be used. Each entry includes a name, description, and file path so you can open the source for full instructions when using a specific skill.

### Available Skills

- find-skills: Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill. (file: C:/Users/juandg/.agents/skills/find-skills/SKILL.md)
- skill-creator: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Codex's capabilities with specialized knowledge, workflows, or tool integrations. (file: C:/Users/juandg/.codex/skills/.system/skill-creator/SKILL.md)
- skill-installer: Install Codex skills into `$CODEX_HOME/skills` from a curated list or a GitHub repo path. Use when a user asks to list installable skills, install a curated skill, or install a skill from another repo (including private repos). (file: C:/Users/juandg/.codex/skills/.system/skill-installer/SKILL.md)

### How To Use Skills

- Discovery: The list above is the set of skills available in this session. Skill bodies live on disk at the listed paths.
- Trigger rules: If the user names a skill (with `$SkillName` or plain text) or the task clearly matches a listed skill description, you must use that skill for that turn. Multiple mentions mean use them all. Do not carry skills across turns unless they are mentioned again.
- Missing or blocked: If a named skill is not in the list or its path cannot be read, say so briefly and continue with the best fallback.
- How to use a skill (progressive disclosure):
  1. After deciding to use a skill, open its `SKILL.md`. Read only enough to follow the workflow.
  2. When `SKILL.md` references relative paths (for example `scripts/foo.py`), resolve them relative to the skill directory first.
  3. If `SKILL.md` points to extra folders such as `references/`, load only the specific files needed for the request.
  4. If `scripts/` exist, prefer running or patching them instead of retyping large code blocks.
  5. If `assets/` or templates exist, reuse them instead of recreating from scratch.
- Coordination and sequencing:
  - If multiple skills apply, choose the minimal set that covers the request and state the order you will use them.
  - Announce which skill(s) you are using and why in one short line.
  - If you skip an obvious skill, say why.
- Context hygiene:
  - Keep context small: summarize long sections instead of pasting them.
  - Avoid deep reference chasing: prefer files directly linked from `SKILL.md` unless blocked.
  - When variants exist (frameworks, providers, domains), pick only the relevant reference files and note that choice.
- Safety and fallback: If a skill cannot be applied cleanly (missing files, unclear instructions), state the issue, choose the next-best approach, and continue.
