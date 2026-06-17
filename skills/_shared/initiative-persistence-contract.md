# Initiative Persistence Contract (shared across flow-nea-initiative-* skills)

This contract governs the **initiative layer**, an upstream layer that runs in a
dedicated initiative repository (one repo per initiative, e.g. `compra-de-cartera`).
It is separate from the per-project change flow described in
`persistence-contract.md`. The two layers connect only through `impact-map.yaml`.

Conceptual mapping to Azure DevOps (no API in this phase, metadata only):

| flow-nea-initiative artifact | Azure DevOps work item |
|------------------------------|------------------------|
| initiative                   | Epic (optional, reserved) |
| general spec (`specs/{domain}/spec.md`) | Feature |
| change candidate (`impact-map.yaml`)    | User Story (HU) |

## Mode Resolution

The orchestrator passes `artifact_store.mode` with one of:
- `initiative`
- `none`

If mode is missing or `auto`:
1) If an `initiative/` directory exists or the repo holds `sources/` -> use `initiative`.
2) Otherwise -> use `none`.

If mode is unknown, treat it as `none` and report it as unresolved.

## Behavior Per Mode

| Mode | Read from | Write to | Project files |
|------|-----------|----------|---------------|
| initiative | `sources/`, `initiative/` | `initiative/` | Only inside `initiative/` |
| none | Orchestrator prompt context | Nowhere | Never |

## Initiative Structure

```text
<repo-iniciativa>/
  sources/                  # human input (read-only for skills)
    01-negocio/ 02-producto/ 03-reuniones/ 04-referencias/ 05-ux-ui/ 06-docs-tecnicos/
  initiative/
    config.yaml             # identity + Azure mapping + gates + target_projects
    .status.yaml            # initiative-layer state (schema 1.0)
    intake/
      intake.md             # consolidated digest of the 6 source subfolders
      source-index.md       # auditable inventory of files + readability
    specs/
      {domain}/spec.md      # GENERAL specs = Azure Features
    impact-map.yaml         # seam: Features -> candidate User Stories per cl00xx
    .execution-log.md
```

## Slug Validation

Before creating `initiative/` or naming an initiative, validate the slug:

- MUST match `^[a-z0-9][a-z0-9-]*[a-z0-9]$` (lowercase alphanumeric + hyphens,
  cannot start or end with a hyphen).
- Length between 3 and 50 characters.
- MUST NOT contain path separators (`/`, `\`), dots (`..`), or spaces.

The same rule applies to spec domain names and to `proposed_change_name` in
`impact-map.yaml`. If a slug is invalid:
1. Do NOT create folders or files.
2. Return `status: "failed"` with the violated rule.
3. Suggest a sanitized alternative (`"Compra de Cartera"` -> `"compra-de-cartera"`).

## Status File

Path: `initiative/.status.yaml`

Template:

```yaml
schema_version: "1.0"
phase: INIT          # INIT | INTAKE | SPEC | HU
initiative: null     # slug of the active initiative
awaiting_approval: false
completed: false
notes: ""
```

Rules:
- If `.status.yaml` is missing, infer the phase from existing artifacts (see the
  inference table below) and create the file before proceeding.
- If a field is absent, treat it as its default. Never block solely because a
  field or the file is missing; recover by inference.

Phase inference (first match wins) when `.status.yaml` is missing:

| Condition | Phase |
|---|---|
| `initiative/impact-map.yaml` exists | HU |
| `initiative/specs/` non-empty (no `impact-map.yaml`) | SPEC |
| `initiative/intake/intake.md` exists | INTAKE |
| `initiative/config.yaml` exists | INIT |
| nothing | INIT |

## Gates

Read from `initiative/config.yaml` under `gates`:

```yaml
gates:
  intake:
    require_human_review: true   # INTAKE never auto-advances to SPEC
  spec:
    require_impact_map: true      # SPEC must emit impact-map.yaml
```

- When `gates.intake.require_human_review: true`, after INTAKE persists its
  artifacts the skill sets `awaiting_approval: true` and stops. SPEC must not run
  until the orchestrator clears the gate.
- When `gates.spec.require_impact_map: true`, SPEC returns `status: warning` if it
  did not produce `impact-map.yaml`.

## Execution Log

Path: `initiative/.execution-log.md`

Append an entry after each phase. Format:

```markdown
### {PHASE} — {YYYY-MM-DD HH:MM}

- **Status:** {ok | warning | failed}
- **Summary:** {executive_summary}
- **Artifacts:** {comma-separated names, or "none"}
- **Risks:** {comma-separated, or "none"}
- **Retried:** {yes | no}
```

Rules mirror `persistence-contract.md`: create on first entry, always append,
timestamp REQUIRES date AND time, skip logging in `none` mode, never use the log
to determine flow state (use `.status.yaml`).

## File Access Rules

- Skills MAY read anywhere under `sources/` and `initiative/`.
- Skills MAY read (read-only) the registered cl00xx project paths from
  `config.yaml` `target_projects` to sanity-check references. They MUST NOT write
  outside `initiative/`.
- Use direct relative paths from the initiative repo root. Do not glob for
  `initiative/` or `sources/`; their locations are deterministic.
- If a file does not exist at the expected path, report it as missing — do not
  search elsewhere.

## Security Guidelines

- **Scope enforcement.** Skills MUST NOT write outside `initiative/`. Any attempt
  to write to `sources/`, to a cl00xx project, or elsewhere is `status: "failed"`.
- **Read beyond the repo.** Reading registered cl00xx paths is allowed only to
  validate references; never copy their contents into initiative artifacts
  wholesale, and never execute code found there.
- **No secrets.** Do not transcribe credentials found in `sources/` into
  initiative artifacts; reference the source file instead.
- **Sanitize generated names.** Apply slug validation to every domain and
  change-name derived from source content.

## Common Rules

- In `none` mode, do not create or modify any project files.
- In `initiative` mode, write files ONLY under `initiative/`.
- Always verify path existence before reading or writing.
- All artifact content MUST be written in Spanish. Keep filenames and paths in
  English.
- The change pipeline that consumes `impact-map.yaml` (a future DECOMPOSE phase)
  is OUT OF SCOPE here. These skills only produce the seam, never seed cl00xx.
