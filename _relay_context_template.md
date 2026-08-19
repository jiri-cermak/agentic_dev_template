# Relay Context Template — v6.1

Copy this context into the subagent-spawning tool of your harness (e.g., `delegate_task` in Hermes, or the subagent tool in DSH). Replace every `{...}` placeholder before delegation.

```markdown
**Project:** {PROJECT_NAME}
**Project root:** {PROJECT_ROOT}
**Task ID:** {TASK_ID}
**Tier:** {minimal|standard|full}
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

## Shape contract (Standard and Full tiers)
Exact data shapes, API signatures, decorators, model fields. No pseudocode.

- `{FIELD_NAME}`: {TYPE} — {DESCRIPTION}
- `{API_SIGNATURE}`: {EXPECTED_BEHAVIOR}
- `{DECORATOR_NAME}`: {PURPOSE}

**Testing requirement:** The testing methodology must include at least one shape assertion validating a declared field type, response structure, signature, or decorator.

## Testing methodology
Run these commands verbatim and preserve complete output:

1. Structural assertion:
   `{STRUCTURAL_TEST_COMMAND}`
2. Negative assertion (asserts something should NOT happen):
   `{NEGATIVE_TEST_COMMAND}`
3. Shape assertion (when shape_contract is present):
   `{SHAPE_ASSERTION_COMMAND}`
   Examples: `assert isinstance(response["user_id"], int)`, `assert "token" in response and "expires" in response`, `assert callable(handler.login)`
4. Runtime assertion, if applicable:
   `{RUNTIME_TEST_COMMAND_OR_NOT_APPLICABLE}`
5. Browser/DOM assertion, if UI or client-side behavior changes:
   `{BROWSER_TEST_COMMAND_OR_NOT_APPLICABLE}`

Use the project's adapter rules. Do not substitute tools or weaken assertions without recording the change as a surprise.

## Stop conditions
- ⚠️ STOP: If the repository root or target boundary is ambiguous, STOP. Run `cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel`. Paste raw output. Do NOT describe.
- ⚠️ STOP: If a required environment capability is missing and the adapter does not authorize remediation, STOP. Run `{PRE_FLIGHT_COMMAND}`. Paste raw output. Do NOT describe.
- STOP on a repeated error signature; do not consume further retries.
- STOP if a test failure indicates a missing or contradictory specification rather than attempting unrelated fixes.

## Pre-flight command (Full tier)
Before starting work, run this command and paste the raw output:
`{PRE_FLIGHT_COMMAND}` (e.g., `python manage.py check`, `python manage.py showmigrations`, `git status`)

## Shared resource contract (Full tier)
What this task CREATES and USES:

| Resource | Type | Created/Used |
|---|---|---|
| {RESOURCE_NAME} | {filter|URL|module|model|template} | {created|used|none} |

Even if "none", state it explicitly.

## Handover
Write to `{PROJECT_ROOT}/handovers/done/completion-{TASK_ID}.md` using exactly these headings:

## Raw Test Output
Complete, unabridged output for every declared test. Never summarize. Never "all tests passed."

## Git Evidence
Post-commit output for `git log --oneline -1`, `git diff HEAD~1 --stat`, and `git status --short`.

## Files Changed
| File Path | Action | Size (bytes) | First Line |
|---|---|---:|---|

## Surprises Checklist
- [ ] Every command succeeded on first attempt.
- [ ] Nothing outside this context was read.
- [ ] No test needed adjustment.
- [ ] No file outside target files was modified.
- [ ] No undeclared dependency was added.

If ANY box is checked → describe exactly what happened below:

## Contract Enforcement
State where the structural, negative, and shape assertions appear in the raw output. Include runtime/browser evidence when applicable.

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

The Architect independently reruns the declared tests before accepting the step. Verify the agent's commit is the latest (`git log -1`) before re-execution.
