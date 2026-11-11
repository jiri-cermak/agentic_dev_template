# Primitives Protocol Mode

The most minimal protocol. Just the essentials.

## Philosophy

From Pi: "Primitives, not features." Ship minimal, let users build via extensions.

This mode strips away all ceremony. No master plan, no pre-delegation stash, no clean-state checks, no post-mortem. Just:
1. Delegate the task
2. Verify the result
3. Record learnings (if any)

## When to Use

✅ You know exactly what you're doing
✅ Task is trivial (README tweak, config change, small bug fix)
✅ You want maximum speed, minimum overhead
✅ You trust the subagent implicitly
✅ The task is self-contained (no dependencies, no multi-file changes)

❌ Multi-file changes
❌ Complex features
❌ You need verification rigor
❌ You're learning a new codebase
❌ The task has high risk of failure

## The Protocol

### Step 1: Delegate

Write a minimal relay context:

```markdown
**Task ID:** {TASK_ID}
**Task:** {ONE_SENTENCE_DESCRIPTION}

## Target files
- `{FILE_PATH}` — modify

## Tests
```bash
{TEST_COMMAND}
```

## Handover
Write to `handovers/done/completion-{TASK_ID}.md`:
1. Raw test output
2. Git diff
```

Delegate via `delegate_task`. No pre-delegation stash. No master plan. No tier selection.

### Step 2: Verify

When the subagent completes:

1. Read the handover file
2. Run the tests yourself
3. Check the git diff
4. If tests pass and diff looks good → ✅ pass
5. If tests fail or diff is wrong → ❌ fail, retry with better context

**No gate matrix.** No fabrication/stagnation/spec-drift classification. Just: did it work?

### Step 3: Record Learnings (Optional)

If you learned something worth remembering:

```python
memory(action='add', target='episodic', content='What you learned')
```

If not, skip this step.

## What's Missing

Compared to Standard mode, Primitives mode lacks:

- **Pre-delegation stash** — Architect's uncommitted changes may pollute agent's commit
- **Clean-state checks** — Stale files from previous steps may cause issues
- **Master plan** — No tracking of multi-step work
- **Post-mortem** — No systematic learning capture
- **Tier selection** — No Minimal/Standard/Full distinction
- **Gate matrix** — No classification of failure types
- **Anti-hallucination measures** — No surprises checklist, no shape contracts, no negative tests
- **Files verification** — No `wc -c` + `head -1` checks

## Risk Mitigation

If Primitives mode fails:
1. Retry once with clearer context
2. If it fails again, switch to Standard mode
3. If Standard mode fails, escalate to user

## Example

**Task:** Add a "Contributing" section to README.md

**Relay context:**
```markdown
**Task ID:** README-001
**Task:** Add a "Contributing" section to README.md

## Target files
- `/path/to/README.md` — modify

## Tests
```bash
grep -q "## Contributing" /path/to/README.md
```

## Handover
Write to `handovers/done/completion-README-001.md`:
1. Raw test output
2. Git diff
```

**Verification:**
```bash
# Run the test
grep -q "## Contributing" /path/to/README.md && echo "PASS" || echo "FAIL"

# Check the diff
cd /path/to/project && git diff README.md
```

**Result:** If PASS and diff looks good → ✅ done. If FAIL → retry.

## Comparison with Standard Mode

| Aspect | Primitives | Standard |
|---|---|---|
| Steps | 3 (delegate, verify, learn) | 9 (plan → stash → pre-flight → relay → delegate → verify → gate → post-mortem → stabilize) |
| Ceremony | Minimal | High |
| Speed | Fast | Slower |
| Risk | Higher (less verification) | Lower (more verification) |
| Use case | Trivial tasks | Normal development |
| Anti-hallucination | None | Full suite |

## When to Upgrade to Standard

If you find yourself:
- Retrying the same task 2+ times
- Discovering the subagent made unexpected changes
- Needing to track multi-step work
- Learning the same lesson repeatedly

→ Switch to Standard mode.
