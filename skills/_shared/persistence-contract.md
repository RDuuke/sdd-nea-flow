# Persistence Contract (shared across all flow-nea skills)

## Mode Resolution

The orchestrator passes artifact_store.mode with one of:
- openspec
- none

If mode is missing or set to auto:
1) If OpenSpec is available -> use openspec
2) Otherwise -> use none

If mode is unknown, treat it as none and report it as unresolved.

## Behavior Per Mode

| Mode | Read from | Write to | Project files |
|------|-----------|----------|---------------|
| openspec | openspec/ | openspec/ | Only inside openspec/ |
| none | Orchestrator prompt context | Nowhere | Never |

## OpenSpec Structure

openspec/
  config.yaml
  specs/
  changes/
    archive/

Change folders live at:
openspec/changes/{change-name}/

## Change Name Validation

Before creating any folder or file under `openspec/changes/`, validate the
change-name:

- MUST match the pattern `^[a-z0-9][a-z0-9-]*[a-z0-9]$` (lowercase
  alphanumeric and hyphens only, cannot start or end with a hyphen).
- Length MUST be between 3 and 50 characters.
- MUST NOT contain path separators (`/`, `\`), dots (`..`), or spaces.

If the change-name is invalid:
1. Do NOT create any folders or files.
2. Return `status: "failed"` with a clear message explaining the validation
   rule that was violated.
3. Suggest a sanitized alternative (e.g., `"my feature!"` → `"my-feature"`).

## Status File

Path: openspec/changes/.status.yaml

Template:

```yaml
schema_version: "1.3"
phase: INIT
change: null
awaiting_approval: false
completed: false
pending_tasks: []
modified_artifacts: []
notes: ""
```

Rules:
- If .status.yaml is missing, infer phase from existing artifacts (see flow-nea-continue rules) and create the file before proceeding.
- If legacy .status.json exists, read it, migrate values to .status.yaml, and delete the .json file.
- Never block a phase solely because .status.yaml is missing; always recover by inference.
- If any field is absent (older schema), treat it as its default value: `pending_tasks: []`, `modified_artifacts: []`, `notes: ""`, `schema_version: "1.0"`.
- Do not fail or block due to missing fields; fill defaults silently.

## Out-of-Flow Artifact Modification

When an OpenSpec artifact is modified outside a phase skill (by the orchestrator inline or a general sub-agent), the orchestrator MUST:
1. Add the artifact to `modified_artifacts` in `.status.yaml`.
2. Regress `phase` according to this table:

| Modified artifact | Regress phase to |
|---|---|
| `proposal.md` | SPEC |
| `specs/` | APPLY |
| `design.md` | APPLY |
| `tasks.md` | APPLY |

3. Set `notes` with a brief description of what changed and why.
4. Inform the user that the phase was regressed and which tasks need to be re-run.

## Execution Log

Path: `openspec/changes/{change-name}/.execution-log.md`

The orchestrator MUST append an entry to this file after each sub-agent
completes a phase. Format:

```markdown
### {PHASE} — {YYYY-MM-DD HH:MM}

- **Status:** {ok | warning | failed}
- **Summary:** {executive_summary from sub-agent response}
- **Artifacts:** {comma-separated list of artifact names, or "none"}
- **Risks:** {comma-separated list, or "none"}
- **Retried:** {yes | no}
```

Rules:
- Create the file on first entry (do not fail if it does not exist yet).
- Always append; never overwrite previous entries.
- If mode is `none`, skip logging (no file persistence available).
- The log is informational only — never use it to determine flow state
  (use `.status.yaml` for that).

## File Access Rules

- Always use direct relative paths from the project root (e.g. `openspec/changes/{change-name}/design.md`).
- Never use glob patterns to locate OpenSpec files; paths are deterministic and known.
- Never search for `openspec/` using recursive glob; assume it lives at the project root.
- If a file does not exist at the expected path, report it as missing — do not search elsewhere.

## Experimental Features

Optional features controlled via `openspec/config.yaml` under the `experimental` key.
If the key is absent or false, the feature is disabled.

```yaml
experimental:
  neabrain: false  # Set to true to enable Neabrain index for path/relationship lookup
```

## Security Guidelines

Sub-agents generate code and execute commands. Follow these rules to minimize
risk:

- **No hardcoded secrets.** Sub-agents MUST NOT write API keys, passwords,
  tokens, or credentials directly in code. Use environment variables or
  configuration files excluded from version control.
- **No destructive commands without confirmation.** The APPLY and VERIFY phases
  MUST NOT execute destructive commands (e.g., `rm -rf`, `DROP TABLE`,
  `git push --force`) without explicit user approval from the orchestrator.
- **Scope enforcement.** Sub-agents MUST NOT modify files outside of:
  (a) the project source code (for APPLY), or (b) the `openspec/` directory
  (for artifact persistence). Any attempt to write outside these boundaries
  should be reported as `status: "failed"`.
- **Sanitize generated file names.** When creating files based on user input
  (e.g., spec domain names), apply the same validation rules as change-name
  (see Change Name Validation above).

## Common Rules

- If mode is none, do not create or modify any project files.
- If mode is openspec, write files ONLY under openspec/.
- When falling back to none, recommend enabling openspec for persistence.
- Always verify path existence before reading or writing.
- All artifact content must be written in espanol. Keep filenames and paths in English.
