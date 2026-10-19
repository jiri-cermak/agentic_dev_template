# Relay Context Template

Copy this template into the relay dispatch. Replace every `{...}` placeholder before delegation. Read `CORE_PROTOCOL.md` first — it defines the lifecycle and gates.

**Skill isolation:** Keep the project adapter as a dotfile in every project. The harness scans a fixed set of project-convention files (concrete filenames defined in the adapter) for auto-discovery. A dotfile is invisible to progressive subdirectory discovery, preventing the harness from injecting it as a virtual skill. The relay context is the subagent's sole source of rules.

```markdown
**Project:** {PROJECT_NAME}
**Project root:** {PROJECT_ROOT}
**Task ID:** {TASK_ID}
**Tier:** {minimal|standard|full}
**max_attempts:** {3}
**escalation_policy:** {human_retry | skip_on_fail | block_and_continue}
**progress_interval:** {5}
**max_depth:** {1}
**Execution profile:** thinking_type: {disabled|enabled}; reasoning_effort: {null|low|medium|high}
**Model/provider:** record actual delegated model/provider

## Location pre-flight
The first command must be:
`cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel`
Do not rely on workdir metadata. Use absolute paths for all target files.

## Task
{SELF_CONTAINED_TASK_DESCRIPTION}

At `max_depth` > 1, the subagent may spawn children with a reduced-scope relay context (each inherits the parent's `success_criteria` and adds its own).

## Target files
- `{ABSOLUTE_PATH}` — create | modify

## Out of scope
- `.agents.md`, `CORE_PROTOCOL.md`, `SOUL.md`, `.internal_master_plan.md`, `devlog.md`
- `.git/`
- `learnings/promoted.md`
- other tasks' `handovers/{TASK_ID}/`
- {PROJECT_SPECIFIC_PROTECTED_FILES}
- Any file not listed above

Writable exceptions: the subagent's own `handovers/{TASK_ID}/` and append-only `learnings/pending.md`.

## Study
- `{REFERENCE_FILE}` when the task depends on prior work or a specification

## Adapter boundaries
- Allowed: {ALLOWED_TOOLS}
- No: {UNAVAILABLE_TOOLS}
- {ADDITIONAL_CONSTRAINTS}
- No `git add -A` or `git add .`

## Tool restriction (deny-list — a gate failure, not a warning)
Do NOT invoke these tools, even if they are present in your toolset:
- `{DENIED_TOOL_1}` — test runner
- `{DENIED_TOOL_2}` — container / remote-shell / daemon access
- `{DENIED_TOOL_3}` — package manager / network

Invoking a denied tool is a **gate failure** (contract category). The Architect audits the
execution record for these exact tools. If you believe a denied tool is required, STOP and
write the failure postmortem — do not invoke it.

## Capability needs
Declare only the capabilities this relay depends on; the adapter maps each to `available | degraded | not_available`. The Architect must check the adapter README for available capabilities before declaring a need.

capability_needs:
  - capability: live_steering
    fallback: kill_and_respawn
  - capability: cross_session_memory
    fallback: file_based_learnings
  - capability: gateway_notification
    fallback: devlog_only
  - capability: compression_safety
    fallback: manual_context_checkpoints

## Shape contract (Standard and Full tiers)
Exact data shapes, API signatures, decorators, model fields. No pseudocode.

- `{FIELD_NAME}`: {TYPE} — {DESCRIPTION}
- `{API_SIGNATURE}`: {EXPECTED_BEHAVIOR}
- `{DECORATOR_NAME}`: {PURPOSE}

The testing methodology must include at least one shape assertion validating a declared field type, response structure, signature, or decorator.

## Testing methodology
Run these commands verbatim and preserve complete output:

1. Structural assertion:
   `{STRUCTURAL_TEST_COMMAND}`
2. Negative assertion (asserts something should NOT happen):
   `{NEGATIVE_TEST_COMMAND}`
3. Shape assertion (when a shape contract is present):
   `{SHAPE_ASSERTION_COMMAND}`
4. Runtime assertion, if applicable:
   Start `{SERVER_COMMAND}` with the terminal background-process tool, then:
   `{RUNTIME_TEST_COMMAND}`
5. Browser/DOM assertion for HTML/CSS/JS changes:
   Use the browser/DOM assertion tool(s) provided by the adapter to check zero JS errors, required DOM/CSS properties, image loading, and relevant state transitions. If the visual tool is unavailable, use DOM/property checks and record the fallback.
6. Impeccable design gates (when UI/CSS/JS changes):
   Run the adapter-declared commands:
   `{DETECT_COMMAND}` — anti-pattern scanner; zero findings required
   `{AUDIT_COMMAND}` — a11y/perf/responsive audit; no critical findings
   `{CRITIQUE_COMMAND}` — UX heuristic scoring; must pass adapter threshold

## Success criteria
Machine-checkable pass conditions — the gate passes only when all hold. **Required at every tier; a reduced handover never removes these.**

success_criteria:
  - type: test_id
    value: {TEST_ID}
  - type: diff_check
    file: {ABSOLUTE_PATH}
    contains: "{EXPECTED_LITERAL}"
  - type: exit_code
    command: {ADAPTER_COMMAND}
    expected: {EXIT_CODE}

Also supported: `type: checksum` (a file plus its expected hash).

## Pre-flight command (Full tier)
Before starting work, run this command and paste the raw output:
`{PRE_FLIGHT_COMMAND}`

## Shared resource contract (Full tier)
What this task CREATES and USES:

| Resource | Type | Created/Used |
|---|---|---|
| {RESOURCE_NAME} | {filter|URL|module|model|template} | {created|used|none} |

Even if "none", state it explicitly.

## Stop conditions
- ⚠️ STOP if the repository root or target boundary is ambiguous. Run `cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel`. Paste raw output. Do NOT describe.
- ⚠️ STOP if a required environment capability is missing and the adapter does not authorize remediation. Run `{PRE_FLIGHT_COMMAND}`. Paste raw output. Do NOT describe.
- STOP on a repeated error signature.
- STOP if a test failure indicates missing or contradictory specification.
- STOP if the staged file list contains anything outside target files.
- On exhausting `max_attempts`, write `handovers/{TASK_ID}/failure_postmortem.md` (see Failure escalation in `CORE_PROTOCOL.md`).
- Write `handovers/{TASK_ID}/progress.md` every `progress_interval` steps; check for `handovers/{TASK_ID}/abort.md` between steps and, if present, stop cleanly with a partial handover.

## Reduced handover (any tier)
A relay whose change is small and reversible may use a reduced handover: a one-paragraph task spec and a two-heading handover:

## Summary
{ONE_PARAGRAPH_RESULT}

## Diff
{DIFF_OF_CHANGES}

Qualify only when all hold: touches ≤2 files, no new dependency, existing test coverage, reversible (no schema/state change). The reduced handover changes format and context only — `success_criteria:` still applies and the full gate matrix is unchanged.

## Handover
Write to `handovers/{TASK_ID}/completion.md` using exactly these headings:

## Raw Test Output
Complete, unabridged output for every declared test. Never summarize. Never "all tests passed."

## Git Evidence
Post-commit output for `git log --oneline -1`, `git diff HEAD~1 --stat`, `git diff --cached --name-only` (captured before commit), and `git status --short`.

## Files Changed
| File Path | Action | Size (bytes) | First Line |
|---|---|---|---|

## Surprises Checklist
- [ ] Every command succeeded on first attempt.
- [ ] Nothing outside this context was read.
- [ ] No test needed adjustment.
- [ ] No file outside target files was modified.
- [ ] No undeclared dependency was added.
- [ ] No untracked asset was staged unintentionally.

If ANY box is checked → describe exactly what happened below.

## Contract Enforcement
State where the structural, negative, and shape assertions appear in raw output. Include runtime/browser evidence when applicable. State model/provider, thinking mode, and whether steps were parallelized.

## Execution Record
Write `handovers/{TASK_ID}/execution_record.jsonl` during execution — one JSON line per tool call. Schema: `timestamp` (ISO 8601), `tool_name` (string), `tool_args_hash` (SHA-256 of canonicalized args), `denied_flag` (boolean — `true` if the tool is on this relay's deny-list). The Architect parses this file during the verification gate; any `denied_flag: true` is a **gate failure** (contract category). Do not store raw arguments — only their hash.

## Commit
Before committing:
`git diff --cached --name-only`
Verify that every staged path is an explicit target and no other path is staged. Then:

```bash
git commit -F - << 'EOF'
{TASK_ID}: short description
EOF
```

Never use `git add -A` or `git add .`.
```

The Architect independently re-runs the declared tests before accepting the step. Verify the subagent's commit is the latest (`git log -1`) before re-execution.
