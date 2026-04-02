# AGENTS.md

Agent instructions for `sdd-nea-flow`.

This repository contains AI-facing prompts, skills, and example integrations for
the `nea-flow` orchestration pattern. There is no application code here. Most
changes affect Markdown instructions, installation scripts, or example configs.

## Read first

- `@ai/README.md` - maintainer-facing technical map
- `@README.md` - human onboarding, installation, and tool usage
- `@skills/_shared/persistence-contract.md` - shared persistence contract

## Project structure

```text
skills/      phase skills and support skills
examples/    prompts and configs per tool
scripts/     installation scripts
ai/          maintainer technical docs
README.md    human entry point
AGENTS.md    root instructions for coding agents
```

## Source of truth

- Runtime behavior lives in `skills/` and `examples/`
- Human technical rationale lives in `ai/`
- Installation behavior lives in `scripts/`
- `README.md` should stay focused on onboarding and usage

Do not change architecture or flow behavior only in `README.md` or `ai/`. If the
behavior changes, update the operative source too.

## Language rules

- Flow artifacts such as `proposal.md`, `design.md`, `tasks.md`, and
  `verify-report.md` must be in Spanish
- File names and paths must be in English
- AI-facing instructions in this repo must be in English
- Human-facing documentation in this repo should be in Spanish by default

## Working rules

- Read the full file before editing any `SKILL.md`
- Preserve the standard JSON output contract for every skill
- Keep prompts and examples aligned across tools when changing shared behavior
- Prefer adding maintainer documentation to `ai/` rather than growing
  `README.md` indefinitely
- Do not add application logic to this repo
- Do not create or maintain `openspec/` in this repo; it belongs to target
  projects
- Do not hardcode provider-specific model names inside skills unless the file is
  explicitly a tool-specific example config

## Editing guidance

### When changing skills

- Update the relevant `skills/flow-nea-*/SKILL.md`
- Check whether prompts in `examples/` must reflect the same rule
- Update `ai/` if the change affects architecture, flow, or maintainer guidance

### When changing prompts or examples

- Keep AI-facing prompt content in English
- Preserve the behavior of the flow across supported tools where possible
- Document tool-specific limitations rather than hiding them

### When changing documentation

- Keep `README.md` concise and user-oriented
- Put deep architecture, persistence, and authoring guidance in `ai/`
- Avoid duplicating the same long explanation in multiple places

## Key contracts

Every phase skill must keep this output shape:

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "brief summary for the orchestrator",
  "detailed_report": "optional analysis when needed",
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

## Validation

Before finishing a change:

- check for consistency between `skills/`, `examples/`, `README.md`, and `ai/`
- verify links and referenced paths still exist
- keep new docs and Markdown ASCII unless the file already uses other characters
- do not leave partial flow rules documented in one place only
