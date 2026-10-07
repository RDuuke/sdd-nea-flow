# NEA Skill Authoring Reference

Use for reusable skill creation/updates, not every development phase. Keep the
entrypoint to purpose, trigger, inputs, necessary decisions/actions and output.
Do not repeat generic agent advice. Choose a new skill only for a repeated
nontrivial capability not covered by an existing skill or shared contract.

Names/folders use lowercase hyphenated identities. Preserve supported frontmatter
and output fields. This repository uses MIT and metadata author/version; do not
copy another project's license or taxonomy. Adapt this structure to actual work:

```text
---
name: skill-name
description: Describe the capability and the request that needs it.
license: MIT
metadata:
  author: project-author
  version: "1.0"
  scope: [root]
  invoker: flow-nea-orchestrator
---
## Purpose
## Inputs
## Workflow and decision rules
## References (load when relevant)
## Output Contract (JSON)
```

Preserve `status`, `executive_summary`, optional `detailed_report`, `artifacts`,
`next_recommended`, `risks`, `skill_resolution`, and applicable phase-specific
fields. See [audit-contract.md](audit-contract.md) for the development envelope.
Keep enums/artifact types compatible; do not append unrelated text to strict JSON.

Move substantial examples, schemas and conditional detail to references when
that shortens the entrypoint. Keep rules canonical. Runtime references must be
installed, not only present in the source checkout's `ai/` directory. Current
installers copy `SKILL.md` and `_shared/*.md`; per-skill references/assets require
installer support before depending on them. Do not add empty resource directories.

Be concise without word ceilings that discard obligations. AI instructions are
English; artifact prose is Spanish, keys/paths English. Read existing SKILL.md
fully before editing. Verify references, frontmatter, JSON, integrations and
checksums. For complex workflows use realistic bounded behavioral evaluation
when available/authorized; formatting checks alone do not prove correct routing.

Use [documentation-contract.md](documentation-contract.md) for guides and
review-facing explanations: result first, progressive detail and a concrete
reading/evidence path. Do not impose its examples as a mandatory skeleton or
append human narratives to strict skill JSON.
