# Persistence Contract (development changes)

## Mode and boundaries

The orchestrator supplies artifact_store.mode: openspec | none. For missing/auto,
use openspec when available, otherwise none. Unknown mode is unresolved none.
In none mode use supplied context and never write project files. In openspec
mode artifacts live under openspec/; APPLY may change authorized source/tests.
STATUS never writes, including recovery and legacy migration.

## Shared operative references

Read these relative to this installed _shared directory:

- [state-contract.md](state-contract.md): selector, local state, dependencies,
  approvals, invalidation and targeted legacy recovery.
- [validation-contract.md](validation-contract.md): capabilities, proportional
  checks, mandatory gates, evidence reuse and archive readiness.
- [audit-contract.md](audit-contract.md): versioned operational YAML records,
  compact handoff and legacy report compatibility.
- [execution-contract.md](execution-contract.md): phase routing, exact skill
  loading, bounded context and coordinator/worker responsibilities.

Load [research-contract.md](research-contract.md) for relevant optional research
and [delivery-contract.md](delivery-contract.md) for requested delivery only.

These govern development changes only. Initiative uses its separate contract.
Do not duplicate state inference or audit templates inside orchestrator prompts.

## OpenSpec locations

```text
openspec/
  config.yaml
  specs/{domain}/spec.md             # consolidated current behavior
  changes/
    .status.yaml                    # selector only
    {change-name}/
      .status.yaml                  # canonical change state
      exploration.md
      proposal.md                   # or quick.md
      specs/{domain}/spec.md        # deltas for this change
      design.md
      tasks.md
      validation-plan.yaml
      apply-progress.yaml
      verify-report.yaml
      fix-report.yaml
      archive-report.yaml
      .execution-log.yaml
    archive/YYYY-MM-DD-{change-name}/
```

## Names and file access

Change/domain names: ^[a-z0-9][a-z0-9-]*[a-z0-9]$, length 3..50,
no path separators, dots or spaces. Invalid names fail before any file write;
suggest a sanitized alternative. Existing legacy domain refs may be read as-is
after checking they resolve within openspec; do not rename history implicitly.

Use deterministic project-root paths. Enumerate only immediate change/domain or
archive directories when resolving selection, affected domains or archived slugs.
No recursive glob to locate openspec or silently substitute another project.
Check existence before reading and resolved containment before writing/moving.
Artifacts contain Spanish prose, English keys/paths. Preserve existing legacy
files; no bulk migration or deletion. Operational Markdown is read-only fallback.

## Execution and response

Each phase uses the standard JSON envelope in audit-contract.md. The orchestrator
records a unique execution event after each attempted phase in .execution-log.yaml,
including failure/retry events. Informational warnings do not imply approval.
Only valid completed outputs advance dependencies. Final ARCHIVE logs are written
at the archived location. STATE is canonical; logs never determine state.

Read existing content before updating; merge progress and preserve unknown fields
and conflicting versions. Validate prepared writes, serialize mutations, then
read the persisted result back before claiming success or advancing. Verify
identities, hashes and relevant refs, not existence alone. If readback fails,
reconcile actual bytes/state before retrying, preserving earlier versions.
Mode none returns inline work without claiming persistence. No Engram or task
memory mirror is used.

## Experimental Features

Optional features controlled via `openspec/config.yaml` under the `experimental` key.
If the key is absent or false, the feature is disabled.

```yaml
experimental:
  neabrain: false  # Set to true to enable NeaBrain transversal memory integration
```

### NeaBrain Integration Protocol

When `experimental.neabrain: true`, skills call NeaBrain MCP tools at specific
moments. OpenSpec remains the source of truth for flow artifacts. NeaBrain adds
cross-change persistent memory.

#### Availability check

Before every NeaBrain operation, verify MCP tool is reachable (call `nbn_config_show`).
If unavailable (MCP not configured, binary not found, call fails): skip silently,
continue with OpenSpec only. Never fail a phase because NeaBrain is unavailable.

#### Project naming

1. Use `project` field from `openspec/config.yaml` if present.
2. Otherwise use repository root folder name.
3. Fallback: `"nea-flow"`.

#### Capture per phase

| Phase | Moment | Tool | topic | tags |
|-------|--------|------|-------|------|
| EXPLORE | before investigate | `nbn_search` | — | — |
| EXPLORE | after save | `nbn_capture_passive` | `explore` | [change-name, "explore"] |
| DESIGN | after persist | `nbn_capture_passive` | `architecture-decisions` | [change-name, "adr"] |
| VERIFY | after persist | `nbn_capture_passive` | `verify` | [change-name, "verify", status] |
| ARCHIVE | after persist | `nbn_capture_passive` | `completed-changes` | [change-name, "archive"] |

#### Enrichment vs. capture

- **Enrichment** (EXPLORE pre-query): call `nbn_search` with topic + change-name.
  Inject found observations as context. Prior observations must not override what real code says.
- **Capture** (post-phase): call `nbn_capture_passive` (no user confirmation).
  Content always in Spanish.

#### Observation content format

```text
[PHASE] [{change-name}]: {titulo}

{un párrafo con hallazgo, decisión o resultado}

Archivos afectados: {lista separada por comas}
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

- If mode is none, do not create or modify project files; return artifacts and proposed work inline.
- In openspec mode persist flow artifacts under openspec/; APPLY may modify the authorized project source and tests.
- When falling back to none, recommend enabling openspec for persistence.
- Always verify path existence before reading or writing.
- All artifact content must be written in espanol. Keep filenames and paths in English.
