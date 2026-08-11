# Relay Context Template

Copy this template into `delegate_task`. Replace every `{...}` placeholder before delegation. Read `CORE_PROTOCOL.md` first — it defines the lifecycle and gates.

**Workdir:** Always set `workdir` to a directory outside the project root (e.g., `workdir="/opt/data"`). This prevents the runtime from auto-detecting `AGENTS.md` in the project root and injecting it as a virtual skill. The relay context is the subagent's sole source of rules — every absolute path, constraint, and test is already self-contained here.

```markdown
**Project:** {PROJECT_NAME}
**Project root:** {PROJECT_ROOT}
**Task ID:** {TASK_ID}
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
- `AGENTS.md`, `CORE_PROTOCOL.md`, `.internal_master_plan.md`, `devlog.md`
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
   Use `browser_navigate` and `browser_console` to check zero JS errors, required DOM/CSS properties, image loading, and relevant state transitions. If `browser_vision` fails, use DOM/property checks and record the fallback.

## Stop conditions
- STOP if the repository root or target boundary is ambiguous.
- STOP if a required environment capability is missing.
- STOP on a repeated error signature.
- STOP if a test failure indicates missing or contradictory specification.
- STOP if the staged file list contains anything outside target files.

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
