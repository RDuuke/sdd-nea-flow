# Flow-NEA: Spec-Driven Development

This project uses flow-nea for complex changes. The `/flow-nea-*` commands
activate a structured phase flow with sub-agents.

## When the Flow Activates

The flow activates ONLY when:
1. The user explicitly runs a `/flow-nea-*` command
2. The user explicitly asks to start the flow

For everything else (fixes, questions, edits, simple refactors), work
normally without the flow.

## Automatic Detection (Suggest Only, Never Force)

If the user describes a change involving multiple files, multiple
domains, or requiring prior investigation, you may suggest:
"This looks like a good candidate for the flow. Do you want me to start with
/flow-nea-ff <suggested-name>?"

Do not suggest the flow for single-file edits, quick fixes, questions
about the code, configuration, or tasks with fewer than 3 steps.

## Orchestrator Rules (Apply Only Within the Flow)

When the user invokes a `/flow-nea-*` command:

### Model Assignment

Read this table at the start of the session, or before the first delegation,
cache it, and pass the model in each Agent call. If the assigned model is not
available, use `sonnet` and continue.

| Phase | Model | Reason |
|-------|-------|--------|
| orchestrator | opus | Coordinates and makes decisions |
| flow-nea-explore | sonnet | Reads code, structural analysis |
| flow-nea-propose | opus | Architecture decisions |
| flow-nea-spec | sonnet | Structured writing |
| flow-nea-design | opus | Architecture decisions |
| flow-nea-tasks | sonnet | Mechanical breakdown |
| flow-nea-apply | sonnet | Implementation |
| flow-nea-verify | sonnet | Validation against specs |
| flow-nea-archive | haiku | Copy and close |
| default | sonnet | General delegations |

### Delegation

Principle: **Does this inflate my context unnecessarily?** If yes, delegate.
If no, do it inline.

| Action | Inline | Delegate |
|--------|--------|----------|
| Read to decide or verify (1-3 files) | ✅ | — |
| Read to explore or understand (4+ files) | — | ✅ |
| Read as preparation for writing | — | ✅ together with the write |
| Atomic write (one file, mechanical, already understood) | ✅ | — |
| Write with analysis (multiple files, new logic) | — | ✅ |
| Bash for state (`git`, `gh`) | ✅ | — |
| Bash for execution (test, build, install) | — | ✅ |

`delegate (async)` is the default for delegated work. Use `task (sync)` only
when you need the result before the next action.

- Use the Agent tool to launch sub-agents with fresh context.
- Each sub-agent receives pre-resolved compact rules from the skill registry as
  `## Project Standards (auto-resolved)`.
- Do not execute phase work directly except for trivial inline tasks.

### Anti-patterns

These actions ALWAYS inflate context unnecessarily. Never do them inline:
- Reading 4+ files to "understand" the codebase -> delegate exploration
- Writing a feature across multiple files -> delegate
- Running tests or builds -> delegate
- Reading files as preparation to edit, then editing -> delegate the whole unit of work

### State

- Before each phase, read `openspec/changes/.status.yaml`
- Build the Agent prompt including: `change-name`, `artifact_store.mode`,
  `current_phase`, and `pending_tasks`

### Response Validation

- If the sub-agent response does not contain at least `status` and
  `executive_summary`, treat it as `status: "failed"` with the message:
  `"Sub-agent response incomplete or malformed."`
- After each delegation, check `skill_resolution`:
  - `injected` -> correct, skills reached the sub-agent
  - `fallback-registry`, `fallback-path`, or `none` -> the skill cache was lost
    (likely due to compaction). Re-read `.atl/skill-registry.md` and inject
    compact rules into all subsequent delegations.

### Execution Log

After EACH sub-agent completes a phase, APPEND an entry to
`openspec/changes/{change-name}/.execution-log.md` with this format:

```markdown
### {PHASE} — {timestamp}
- **Status:** {ok | warning | failed}
- **Summary:** {executive_summary}
- **Artifacts:** {names or "none"}
- **Risks:** {list or "none"}
- **Retried:** {yes | no}
```

This provides an audit trail for diagnosis.

### Response Handling

- If `status` is `failed` or `artifacts` is empty: DO NOT advance. Inform the user.
- If `risks` is not empty: show each risk and ask before continuing.
- If `user_approval_required` is true: STOP and ask for confirmation.

### Retry on Transient Failures

- If a sub-agent returns `status: "failed"` and the error seems transient
  (timeout, JSON parse error, truncated response), retry ONCE with the same prompt.
- If it fails twice in a row: DO NOT retry. Inform the user and offer options:
  (a) retry manually, (b) continue from the previous phase, or (c) abandon the change.
- Before retrying, verify that `.status.yaml` was not modified by the failed
  attempt. If it was modified, restore the previous phase.

### State Update Outside the Flow

If an OpenSpec artifact is modified outside a skill:
1. Add it to `modified_artifacts` in `.status.yaml`
2. Revert the phase:
   `proposal.md` -> SPEC | `specs/` -> APPLY | `design.md` -> APPLY | `tasks.md` -> APPLY
3. Inform the user

### Apply Strategy

- For large task lists, split work into batches
- After each batch, show progress and ask whether to continue

### Meta-commands

These commands are handled directly by the orchestrator. Do NOT invoke them as skills.

- `/flow-nea-ff <change-name>`: launches propose -> spec -> design -> tasks in sequence. Show a combined summary only at the end.
- `/flow-nea-continue <change-name>`: reads `.status.yaml`, determines the next pending phase according to the dependency graph, and launches it.
- `/flow-nea-judgment <change-name>`: launches two sub-agents in parallel with the same artifact (`proposal.md` or `tasks.md` depending on context), each without seeing the other's result. Synthesize one of: `Confirmed`, `Suspect A`, `Suspect B`, or `Contradiction`.
- `/flow-nea-fix <change-name>`: reads `verify-report.md`, extracts the `## Fallos Detectados` section, launches apply with that exact context, then re-runs verify. Maximum 2 attempts.

## Phase Flow

```text
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```

SPEC and DESIGN are independent (both read PROPOSE). TASKS requires both.

## Persistence

- `artifact_store.mode`: `auto | openspec | none` (default: `auto`)
- In `openspec` mode, write only inside `openspec/`
- `openspec/` is created with `/flow-nea-init`
