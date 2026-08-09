# Relay Context Template — v6

Copy this context into `delegate_task`. Replace every `{...}` placeholder before delegation.

```markdown
**Project:** {PROJECT_NAME}
**Project root:** {PROJECT_ROOT}
**Task ID:** {TASK_ID}
**Execution profile:** thinking_type: {disabled|enabled}; reasoning_effort: {null|high}

## Location pre-flight
The first command must be:
`cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel`
Do not rely on workdir metadata. Use absolute paths for all target files.

## Task
{SELF_CONTAINED_TASK_DESCRIPTION}

## Target files
- `{ABSOLUTE_TARGET_PATH}` — create | modify

## Out of scope
- `{ABSOLUTE_OR_RELATIVE_PATH_NOT_TO_TOUCH}`

## Constraints
**Study:**
- `{REFERENCE_FILE}`

**Adapter boundaries:**
- Allowed tools: {ALLOWED_TOOLS}
- Unavailable tools: {UNAVAILABLE_TOOLS}
- Dependency policy: {DEPENDENCY_POLICY}
- Build/deploy policy: {BUILD_DEPLOY_POLICY}

## Testing methodology
Run these commands verbatim and preserve complete output:

1. Structural assertion:
   `{STRUCTURAL_TEST_COMMAND}`
2. Negative assertion:
   `{NEGATIVE_TEST_COMMAND}`
3. Runtime assertion, if applicable:
   `{RUNTIME_TEST_COMMAND_OR_NOT_APPLICABLE}`
4. Browser/DOM assertion, if UI or client-side behavior changes:
   `{BROWSER_TEST_COMMAND_OR_NOT_APPLICABLE}`

Use the project's adapter rules. Do not substitute tools or weaken assertions without recording the change as a surprise.

## Stop conditions
- STOP if the repository root or target boundary is ambiguous.
- STOP if a required environment capability is missing and the adapter does not authorize remediation.
- STOP on a repeated error signature; do not consume further retries.
- STOP if a test failure indicates a missing or contradictory specification rather than attempting unrelated fixes.

## Handover
Write to `{PROJECT_ROOT}/handovers/done/completion-{TASK_ID}.md` using exactly these headings:

## Raw Test Output
Complete, unabridged output for every declared test.

## Git Evidence
Post-commit output for `git log --oneline -1`, `git diff HEAD~1 --stat`, and `git status --short`.

## Files Changed
| File Path | Action | Lines Added | Lines Deleted |
|---|---|---:|---:|

## Surprises Checklist
- [ ] Every command succeeded on first attempt.
- [ ] Nothing outside this context was read.
- [ ] No test needed adjustment.
- [ ] No file outside target files was modified.
- [ ] No undeclared dependency was added.

Describe any checked surprise below the checklist.

## Contract Enforcement
State where the structural and negative assertions appear in the raw output. Include runtime/browser evidence when applicable.

## Commit
Before committing, run:
`git diff --cached --name-only`
Stage only the explicit target files. Never use `git add -A` or `git add .`.
Commit with:

```bash
git commit -F - << 'EOF'
{TASK_ID}: short description
EOF
```
```

The Architect independently reruns the declared tests before accepting the step.
