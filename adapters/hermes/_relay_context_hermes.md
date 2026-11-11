# Hermes Relay Context Template

Copy this context into `delegate_task`. Replace every `{...}` placeholder before delegation.

**Project:** {PROJECT_NAME}
**Project root:** {PROJECT_ROOT}
**Task ID:** {TASK_ID}
**Tier:** {minimal|standard|full}
**Max depth:** {1|2|3}
**Max attempts:** {3}
**Escalation policy:** {human_retry|skip_on_fail|block_and_continue}

## Capability needs

```
capability_needs:
  - capability: live_steering
    available: true  # Hermes provides this
  - capability: cross_session_memory
    available: true  # Mnemosyne
  - capability: gateway_notification
    available: {true|false}  # depends on config
  - capability: compression_safety
    available: true  # Hermes provides this
```

## Pre-flight

```bash
cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel
```

## Target files

- {FILE_1}
- {FILE_2}

## Tests

```bash
{TEST_COMMAND_1}
{TEST_COMMAND_2}
```

## Tool restriction (deny-list — a gate failure, not a warning)

Do NOT invoke these tools, even if they are present in your toolset:
- `mcp__opencode__tests` — test runner (the Architect runs the suite)
- `mcp__opencode__run_cli` — container/VPS bridge (the Architect or human runs it)
- `execute_code` — author-only relay: use `patch`/`write_file` instead

Invoking a denied tool is a **gate failure**. The Architect audits your session transcript
for these tools — a handover claim is not proof.

## Success criteria (machine-checkable)

```
success_criteria:
  - type: test_id
    value: {TEST_ID}
  - type: diff_check
    file: {FILE}
    contains: "{STRING}"
  - type: exit_code
    command: {COMMAND}
    expected: 0
```

## Stop conditions

- {STOP_CONDITION_1}
- {STOP_CONDITION_2}

## Handover contract

Write to `handovers/done/completion-{TASK_ID}.md`:

**For full tier (5 headings):**
1. Summary
2. Files changed
3. Tests run
4. Evidence
5. Learnings

**For lite tier (2 headings):**
1. Summary
2. Diff

## Delegation

Copy this context into `delegate_task`. Replace every `{...}` placeholder before delegation.

Subagent: use the filled context as the `goal` parameter.

## Mnemosyne persistence

After completion, Architect promotes critical learnings to Mnemosyne:
- Working memory: task state, ephemeral context
- Episodic memory: patterns ("X failed because Y")
- Persona memory: stable project facts

## Abort mechanism

Subagent writes `handovers/{TASK_ID}/progress.md` every {progress_interval} steps.
Architect can write `handovers/{TASK_ID}/abort.md` to abort. Subagent checks for abort.md between steps and stops cleanly.
