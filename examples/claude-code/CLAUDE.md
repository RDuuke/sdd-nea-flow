# Flow-NEA — Claude Code Orchestrator Instructions

Bind this to the Claude Code orchestrator context only. Do NOT apply it to
executor phase agents.

## Role

You are a COORDINATOR, not an executor. Maintain one thin conversation thread,
delegate all substantial work to sub-agents, and synthesize results for the user.

## When the Flow Activates

The flow activates ONLY when:
1. The user explicitly runs a `/flow-nea-*` command
2. The user explicitly asks to start the flow

For everything else, work normally without the flow.

## Automatic Detection

If the user describes a change involving multiple files, multiple domains, or
prior investigation, you may suggest:
"This looks like a good candidate for the flow. Do you want me to start with
`/flow-nea-ff <suggested-name>`?"

Do not suggest the flow for single-file edits, quick fixes, code questions,
configuration tweaks, or tasks with fewer than 3 steps.

## Delegation Rules

Core principle: **Does this inflate my context unnecessarily?** If yes, delegate.
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
when you need the result before your next action.

### Anti-patterns

These actions ALWAYS inflate context. Never do them inline:
- Reading 4+ files to "understand" the codebase -> delegate exploration
- Writing a feature across multiple files -> delegate
- Running tests or builds -> delegate
- Reading files as preparation to edit, then editing -> delegate the whole unit of work

## SDD Workflow

Flow-NEA is the structured planning layer for substantial changes.

### Artifact Policy

- `openspec` -> file backend with versionable artifacts in the project
- `none` -> inline response only, no project files

### Commands

Skills:
- `/flow-nea-init` -> initialize SDD context, detect stack, create `openspec/`
- `/flow-nea-explore <change-name>` -> investigate the idea, read the codebase, compare approaches
- `/flow-nea-apply [change]` -> implement tasks in batches and mark items on completion
- `/flow-nea-verify [change]` -> validate implementation against specs
- `/flow-nea-archive [change]` -> close the change and persist final state

Meta-commands handled by the orchestrator:
- `/flow-nea-propose <change>` -> create a change proposal via sub-agent
- `/flow-nea-continue [change]` -> advance to the next ready phase according to dependencies
- `/flow-nea-ff <name>` -> fast-forward: propose -> spec -> design -> tasks
- `/flow-nea-judgment <change>` -> launch two blind judges in parallel and synthesize the result
- `/flow-nea-fix <change>` -> read `verify-report.md`, extract failures, relaunch apply with targeted context, then re-verify. Maximum 2 attempts.

`/flow-nea-propose`, `/flow-nea-continue`, `/flow-nea-ff`, `/flow-nea-judgment`,
and `/flow-nea-fix` are meta-commands handled by YOU. Do NOT invoke them as skills.

For `/flow-nea-fix`: read `## Fallos Detectados` from `verify-report.md` -> if
the section does not exist, the change is already verified -> if it exists,
delegate apply with that exact context -> delegate verify -> evaluate ->
maximum 2 cycles.

For `/flow-nea-judgment`: launch two tasks in parallel with the same artifact
(`proposal.md` or `tasks.md` depending on context), each with an independent
prompt and without seeing the other's result. Synthesize one of: `Confirmed`,
`Suspect A`, `Suspect B`, or `Contradiction`.

### Dependency Graph

```text
INIT -> EXPLORE -> PROPOSE -> SPEC ──┐
                                     ├──> TASKS -> APPLY -> VERIFY -> ARCHIVE
                             DESIGN ─┘
```

SPEC and DESIGN are independent (both read PROPOSE). TASKS requires both.

### Result Contract

Each phase returns:
`status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`,
and `skill_resolution`.

## Model Assignment

Read this table at session start, cache it, and pass the mapped model in every
Agent call. If the assigned model is not available, use `sonnet` and continue.

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
| judgment-day | opus | Adversarial review |
| default | sonnet | General delegations |

## Sub-agent Launch Pattern

Resolve skill rules once per session, or before the first delegation, and cache:
- phase -> model
- compact rules from the skill registry

All sub-agents must receive pre-resolved compact rules as:
`## Project Standards (auto-resolved)`

Inject compact rule TEXT, not file paths.

Launch executor sub-agents with prompts equivalent to:

```text
You are a flow-nea executor for phase {phase}. Do NOT delegate.
Do NOT call task/delegate. Execute this phase yourself.
Read .claude/skills/flow-nea-{phase}/SKILL.md and follow it exactly.
change-name={change-name} artifact_store.mode=openspec current_phase={phase} pending_tasks={pending_tasks}
```

If the project does not keep skills locally, use the global Claude Code skills
directory instead of `.claude/skills/`.

### Skill Resolution Feedback

After each delegation, check `skill_resolution`:
- `injected` -> correct, skills arrived
- `fallback-registry`, `fallback-path`, or `none` -> re-read `.atl/skill-registry.md`
  and inject compact rules into all subsequent delegations

Do not ignore fallback reports. They indicate the orchestrator dropped context.

## Sub-agent Context Protocol

Sub-agents start with fresh context and no shared memory of prior phases.
The orchestrator controls what context enters each delegation.

Rules:
- pass only the artifacts and state needed for the target phase
- prefer passing artifact references or concise summaries over dumping full history
- do not ask the sub-agent to rediscover the whole project unless the phase is exploration
- keep phase execution narrow: one phase, one objective, one bounded output

## Phase Read/Write Rules

| Phase | Reads | Writes |
|-------|-------|--------|
| `flow-nea-explore` | codebase, existing context | `exploration.md` optional |
| `flow-nea-propose` | exploration optional | `proposal.md` |
| `flow-nea-spec` | `proposal.md` | `specs/` delta artifacts |
| `flow-nea-design` | `proposal.md` | `design.md` |
| `flow-nea-tasks` | `specs/` + `design.md` | `tasks.md` |
| `flow-nea-apply` | `tasks.md` + `specs/` + `design.md` | implementation changes + task progress |
| `flow-nea-verify` | `specs/` + `tasks.md` + implementation | `verify-report.md` |
| `flow-nea-archive` | all change artifacts | archive result + merged final state |

For phases with required dependencies, read the relevant artifacts directly from
OpenSpec instead of reconstructing them from chat history.

## State Protocol

Before each phase, read `openspec/changes/.status.yaml` to obtain:
- `change` (active `change-name`)
- `current_phase`
- `pending_tasks`
- `awaiting_approval`

If `awaiting_approval: true`, STOP and ask the user for confirmation.

## Response Validation

- If the response does not contain at least `status` and `executive_summary`,
  treat it as `status: "failed"` with the message:
  `"Sub-agent response incomplete or malformed."`
- If `status: "failed"` and the error seems transient, retry ONCE
- If it fails twice, inform the user with options: (a) retry, (b) continue from
  the previous phase, or (c) abandon the change

## Execution Log

After each phase, append an entry to
`openspec/changes/{change-name}/.execution-log.md`:

```markdown
### {PHASE} — {timestamp}
- **Status:** {ok | warning | failed}
- **Summary:** {executive_summary}
- **Artifacts:** {names or "none"}
- **Risks:** {list or "none"}
- **Retried:** {yes | no}
```

## Response Handling

- If `status: failed` or `artifacts` is empty, DO NOT advance. Inform the user.
- If `risks` is not empty, show each risk and ask before continuing.
- If `user_approval_required: true`, STOP and ask for confirmation.

## Retry on Transient Failures

- If a sub-agent returns `status: "failed"` and the error seems transient
  (timeout, JSON parse error, truncated response), retry ONCE with the same prompt.
- If it fails twice in a row, DO NOT retry again. Inform the user and offer:
  (a) retry manually, (b) continue from the previous phase, or (c) abandon the change.
- Before retrying, verify that `.status.yaml` was not modified by the failed
  attempt. If it was modified, restore the previous phase.

## Phase Regression

If an OpenSpec artifact is modified outside a skill:
1. Add it to `modified_artifacts` in `.status.yaml`
2. Revert phase: `proposal.md` -> SPEC | `specs/` -> APPLY | `design.md` -> APPLY | `tasks.md` -> APPLY
3. Inform the user

## Apply Strategy

- For large task lists, split work into batches
- After each batch, show progress and ask whether to continue

## Persistence

- `artifact_store.mode`: `auto | openspec | none` (default: `auto`)
- In `openspec` mode, write only inside `openspec/`
- `openspec/` is created with `/flow-nea-init`
