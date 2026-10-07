# Development Planning Examples

Load only the example for the phase being authored. Adapt section headings and
artifact prose to Spanish; paths/keys and protocol markers such as
ADDED/MODIFIED/REMOVED remain English. These are guides, not
fixed stages or size gates. Never omit criteria, identities or unaffected
scenarios to shorten an artifact.


## PROPOSE

Format:

# Proposal: {Change Title}

## Intent
{Problem and why}

## Scope
### In Scope
- ...

### Out of Scope
- ...

## Approach
{High-level technical approach}

## Affected Areas
| Area | Impact | Description |
|------|--------|-------------|
| src/path/to/file.ts | New/Modified/Removed | descripcion concreta |

> Use concrete file paths, not vague descriptions like "auth module".

## Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| ... | Low/Med/High | ... |

## Rollback Plan
> MANDATORY. Describe how to revert this change if it fails in production.
> Minimum: which files to restore, which migrations to revert, whether feature flags are involved.

{Como revertir}

## Dependencies
- ...

## Success Criteria
> MANDATORY. List of verifiable conditions that must be met to consider this change successful.
> Each criterion must be checkable (test, metric, observable behavior).

- [ ] ...


## SPEC

Delta format:

# Delta for {Domain}

## ADDED Requirements

### Requirement: {Name}
The system MUST/SHALL/SHOULD/MAY ...

#### Scenario: {Happy path}
- GIVEN ...
- WHEN ...
- THEN ...

#### Scenario: {Edge case}
- GIVEN ...
- WHEN ...
- THEN ...

## MODIFIED Requirements
...

## REMOVED Requirements
...


## DESIGN

Format:

# Design: {Change Title}

## Technical Approach
{Overall strategy}

## Architecture Decisions
### Decision: {Title}
Choice: ...
Alternatives: ...
Rationale: ...

## Data Flow
{ASCII diagram if helpful}

## File Changes
| File | Action | Description |
|------|--------|-------------|
| path/to/file | Create/Modify/Delete | ... |

## Interfaces / Contracts
{New interfaces, APIs, types}

## Validation Strategy
Summarize impact, checks and mandatory gates; reference validation-plan.yaml.
Do not assume unit/integration/E2E, build or coverage are available.

## Migration / Rollout
{Plan or "No migration required"}

## Open Questions
- [ ] ...


## QUICK

- Use this structure:

```markdown
# Quick Fix: {titulo breve}

## Objetivo

## Archivos afectados

## Blueprint

## Riesgos

## Verificacion
```

Content rules:

- `## Objetivo`: explain the user-visible or behavior-level outcome
- `## Archivos afectados`: list probable files, folders, or modules to touch
- `## Blueprint`: concrete implementation steps, concise but actionable
- `## Riesgos`: short list of risks, assumptions, or fallback triggers
- `## Verificacion`: specific checks, commands, or expected outcomes
