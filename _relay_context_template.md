# Relay Context Template

Copy this template into the relay dispatch. Replace every `{...}` placeholder before delegation. Read `CORE_PROTOCOL.md` first — it defines the lifecycle and gates.

**Skill isolation:** Keep the project adapter as a dotfile in every project. The harness scans a fixed set of project-convention files (concrete filenames defined in the adapter) for auto-discovery. A dotfile is invisible to progressive subdirectory discovery, preventing the harness from injecting it as a virtual skill. The relay context is the subagent's sole source of rules.

```markdown
**Project:** {PROJECT_NAME}
**Project root:** {PROJECT_ROOT}
**Task ID:** {TASK_ID}
**Tier:** {full|lite}
**max_attempts:** {3}
**escalation_policy:** {human_retry | skip_on_fail | block_and_continue}
**Execution profile:** thinking_type: {disabled|enabled}; reasoning_effort: {null|low|medium|high}
**Model/provider:** record actual delegated model/provider

## Location pre-flight
The first command must be:
`cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel`
Do not rely on workdir metadata. Use absolute paths for all target files.

## Task
{SELF_CONTAINED_TASK_DESCRIPTION}

## Target files
- `{ABSOLUTE_PATH}` — create | modify

## Out of scope
- `.agents.md`, `CORE_PROTOCOL.md`, `.internal_master_plan.md`, `devlog.md`
- `handovers/`, `learnings/`, `.git/`
- {PROJECT_SPECIFIC_PROTECTED_FILES}
- Any file not listed above

## Study
- `{REFERENCE_FILE}` when the task depends on prior work or a specification

## Adapter boundaries
- Allowed: {ALLOWED_TOOLS}
- No: {UNAVAILABLE_TOOLS}
- {ADDITIONAL_CONSTRAINTS}
- No `git add -A` or `git add .`

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

## Testing methodology
Run these commands verbatim and preserve complete output:

1. Structural assertion:
   `{STRUCTURAL_TEST_COMMAND}`
2. Negative assertion:
   `{NEGATIVE_TEST_COMMAND}`
3. Runtime assertion, if applicable:
   Start `{SERVER_COMMAND}` with the terminal background-process tool, then:
   `{RUNTIME_TEST_COMMAND}`
4. Browser/DOM assertion for HTML/CSS/JS changes:
   Use the browser/DOM assertion tool(s) provided by the adapter to check zero JS errors, required DOM/CSS properties, image loading, and relevant state transitions. If the visual tool is unavailable, use DOM/property checks and record the fallback.

## Success criteria
Machine-checkable pass conditions — the gate passes only when all hold:

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

## Stop conditions
- STOP if the repository root or target boundary is ambiguous.
- STOP if a required environment capability is missing.
- STOP on a repeated error signature.
- STOP if a test failure indicates missing or contradictory specification.
- STOP if the staged file list contains anything outside target files.
- On exhausting `max_attempts`, write `handovers/{TASK_ID}/failure_postmortem.md` (see Failure escalation in `CORE_PROTOCOL.md`).

## Lite relay
Select `tier: lite` only when all hold: touches ≤2 files, no new dependency, existing test coverage, reversible (no schema/state change). A lite relay uses a one-paragraph task spec and a two-heading handover:

## Summary
{ONE_PARAGRAPH_RESULT}

## Diff
{DIFF_OF_CHANGES}

The Architect spot-checks the diff rather than re-running every test. `success_criteria:` still apply.

## Handover
Write to `{HANDOVER_PATH}` using exactly these headings:

## Raw Test Output
Complete, unabridged output for every declared test, including browser/DOM evidence when applicable.

## Git Evidence
Post-commit output for `git log --oneline -1`, `git diff HEAD~1 --stat`, `git diff --cached --name-only` (captured before commit), and `git status --short`.

## Files Changed
| File Path | Action | Lines Added | Lines Deleted |
|---|---|---|---|

## Surprises Checklist
- [ ] Every command succeeded on first attempt.
- [ ] Nothing outside this context was read.
- [ ] No test needed adjustment.
- [ ] No file outside target files was modified.
- [ ] No undeclared dependency was added.
- [ ] No untracked asset was staged unintentionally.

Describe any checked surprise below the checklist.

## Contract Enforcement
State where the structural and negative assertions appear in raw output. Include runtime/browser evidence when applicable. State model/provider, thinking mode, and whether steps were parallelized.

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

The Architect independently re-runs the declared tests before accepting the step.
