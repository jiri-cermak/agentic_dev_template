# Fire-and-Forget Orchestration Mode

## Overview

Maximum delegation, minimum oversight. The Architect delegates a task and waits for the result. No mid-flight monitoring or intervention.

## When to Use

**Use when:**
- Task is simple and well-defined
- Risk of failure is low
- You trust the subagent to execute correctly
- You want maximum parallelism
- Task is self-contained with clear success criteria

**Don't use when:**
- Task is complex or ambiguous
- Failure would be costly
- You need to guide the approach
- Task requires human judgment

## How It Works

```
Architect                          Subagent
   |                                   |
   |--- Delegate task ---------------->|
   |                                   |--- Execute
   |                                   |--- Write handover
   |                                   |--- Commit
   |<-- Completion signal -------------|
   |                                   |
   |--- Verify result                  |
   |    - Check handover               |
   |    - Run tests                    |
   |    - Review diff                  |
   |                                   |
   |--- Gate decision                  |
   |    - Pass → Done                  |
   |    - Fail → Retry or escalate     |
```

## Implementation

### Relay Context Template

```markdown
**Task ID:** {TASK_ID}
**Orchestration Mode:** fire_and_forget

## Task
{Clear, self-contained task description}

## Target Files
- `{FILE_PATH_1}` - {action: create/modify}
- `{FILE_PATH_2}` - {action: create/modify}

## Constraints
- {Constraint 1}
- {Constraint 2}

## Tests
```bash
{TEST_COMMAND_1}
{TEST_COMMAND_2}
```

## Stop Conditions
- STOP if {condition}

## Handover
Write to `handovers/done/completion-{TASK_ID}.md` with:
1. Summary
2. Files Changed
3. Tests Run
4. Evidence
5. Learnings
```

### Verification Checklist

After subagent completes:

- [ ] Read handover file
- [ ] Verify all target files were modified
- [ ] Run all tests (must pass)
- [ ] Review git diff (no unexpected changes)
- [ ] Check for hallucination patterns
- [ ] Verify commit message is appropriate

### Gate Decision

**Pass if:**
- All tests pass
- No unexpected file changes
- No hallucination patterns detected
- Handover is complete

**Fail if:**
- Tests fail
- Unexpected file changes
- Hallucination detected
- Handover incomplete

**On failure:**
- If clear fix: retry with corrected relay
- If ambiguous: escalate to human
- If hallucination: escalate immediately

## Examples

### Example 1: Code Formatting

```markdown
**Task ID:** FORMAT-001
**Orchestration Mode:** fire_and_forget

## Task
Format all Python files in src/ using black with line-length 88.

## Target Files
- `src/**/*.py` - modify

## Constraints
- Use black version 23.0 or later
- Line length 88
- Don't modify comments

## Tests
```bash
black --check src/
```

## Handover
Write to `handovers/done/completion-FORMAT-001.md`
```

### Example 2: Add Documentation

```markdown
**Task ID:** DOC-001
**Orchestration Mode:** fire_and_forget

## Task
Add docstrings to all public functions in src/api.py.

## Target Files
- `src/api.py` - modify

## Constraints
- Use Google-style docstrings
- Include Args, Returns, Raises sections
- Don't change function signatures

## Tests
```bash
python -m doctest src/api.py
```

## Handover
Write to `handovers/done/completion-DOC-001.md`
```

### Example 3: Write Tests

```markdown
**Task ID:** TEST-001
**Orchestration Mode:** fire_and_forget

## Task
Write unit tests for the Calculator class in src/calculator.py.

## Target Files
- `tests/test_calculator.py` - create

## Constraints
- Use pytest
- Cover all public methods
- Include edge cases
- Minimum 80% coverage

## Tests
```bash
pytest tests/test_calculator.py -v --cov=src/calculator
```

## Handover
Write to `handovers/done/completion-TEST-001.md`
```

## Best Practices

1. **Clear task definition**: The task must be unambiguous. Fire-and-forget doesn't work when the subagent has to guess what you want.

2. **Explicit success criteria**: Define what "done" looks like. Include specific tests that must pass.

3. **Minimal constraints**: Don't over-constrain. Let the subagent choose the best approach within the boundaries.

4. **Trust but verify**: Trust the subagent to execute, but always verify the result.

5. **Fast feedback**: If it fails, provide quick feedback and retry. Don't let failures accumulate.

## When to Switch Modes

**Switch to Iterative if:**
- Subagent fails 2+ times
- Task is more complex than expected
- Requirements are unclear

**Switch to Supervised if:**
- Task involves critical systems
- You need to catch errors early
- Failure would be very costly

**Switch to Collaborative if:**
- Task requires domain expertise
- You need to make design decisions together
- You're exploring the problem space

## Anti-Patterns

❌ **Using fire-and-forget for complex tasks**: Complex tasks need supervision or iteration.

❌ **Skipping verification**: Always verify the result, even if you trust the subagent.

❌ **Retrying without fixing**: If it fails, understand why before retrying.

❌ **Parallelizing dependent tasks**: Fire-and-forget works best for independent tasks.

## Performance Characteristics

- **Overhead**: Minimal (just delegation and verification)
- **Parallelism**: High (can run many tasks in parallel)
- **Safety**: Low (no mid-flight correction)
- **Best for**: High-volume, low-risk tasks

## Metrics to Track

- Success rate (should be > 90%)
- Average time to completion
- Retry rate (should be < 10%)
- Hallucination rate (should be < 1%)

If success rate drops below 80%, consider switching to a more supervised mode.
