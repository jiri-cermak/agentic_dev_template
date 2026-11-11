# Standard Protocol Mode

The full v6.1 protocol with all anti-hallucination measures. This is the default mode for normal development work.

## Philosophy

Verification over assumption. Every claim must be independently verified. Every step must be reproducible.

## When to Use

✅ Normal development tasks
✅ Multi-file changes
✅ Complex features
✅ You need verification rigor
✅ The task has dependencies or risks
✅ You're learning a new codebase

❌ Trivial tasks (use Primitives mode)
❌ You want maximum speed at the cost of safety

## The Protocol

### Step 1: Plan

Create or update the master plan:

```markdown
# Master Plan

## Task: {FEATURE_NAME}

### Steps
1. {STEP_1} - tier: minimal - status: pending
2. {STEP_2} - tier: standard - status: pending
3. {STEP_3} - tier: full - status: pending
```

**Tier selection:**
- **Minimal**: Trivial, well-defined, low-risk (README tweak, config change)
- **Standard**: Normal complexity, moderate risk (bug fix, small feature)
- **Full**: High complexity, high risk (multi-file refactor, new architecture)

### Step 2: Pre-Delegation Stash

Before delegating, ensure your working directory is clean:

```bash
# Check for uncommitted changes
git status

# If dirty, stash them
git stash

# Verify clean
git status  # Should show "nothing to commit"
```

**Why?** The subagent may run `git add -A`, which would pick up your uncommitted changes.

### Step 3: Pre-Flight Check

Verify the environment is ready:

```bash
# Location check
pwd

# Git check
git rev-parse --show-toplevel

# Dependency check (if applicable)
python -c "import {DEPENDENCY}" || echo "Missing dependency: {DEPENDENCY}"
```

If any check fails, fix it before proceeding.

### Step 4: Relay

Write a detailed relay context:

```markdown
**Task ID:** {TASK_ID}
**Tier:** {minimal|standard|full}
**Task:** {DETAILED_DESCRIPTION}

## Target files
- `{FILE_PATH_1}` — modify
- `{FILE_PATH_2}` — create

## Out of scope
- `{FILE_PATH_3}` — do not touch

## Constraints
- Must use {SPECIFIC_LIBRARY}
- Must follow {CODING_STANDARD}
- No new dependencies without approval

## Shape contract (Standard/Full only)
```json
{
  "expected_output": {
    "field1": "string",
    "field2": "number"
  }
}
```

## Tests
```bash
# Structural assertion
python -c "assert {CONDITION}"

# Negative assertion (Standard/Full only)
python -c "assert not {FORBIDDEN_CONDITION}"

# Shape assertion (Standard/Full only)
python -c "assert {SHAPE_CONDITION}"
```

## Stop conditions
- If {CONDITION_1}, stop and ask for clarification
- If {CONDITION_2}, stop and report error

## Handover
Write to `handovers/done/completion-{TASK_ID}.md`:
1. Raw test output
2. Git evidence (commit hash, diff stat)
3. Files changed (with line counts)
4. Surprises checklist
5. Contract enforcement statement
```

### Step 5: Delegate

Delegate via `delegate_task`:

```python
delegate_task(
    goal="Execute the task described in the relay context",
    context="... relay context ..."
)
```

Wait for completion. The subagent will:
1. Read the relay context
2. Execute the task
3. Run tests
4. Write handover file
5. Commit changes

### Step 6: Verify

When the subagent completes:

1. **Read the handover file**
   ```bash
   cat handovers/done/completion-{TASK_ID}.md
   ```

2. **Run the tests yourself**
   ```bash
   # Copy the exact test commands from the relay
   python -c "assert {CONDITION}"
   ```

3. **Check the git diff**
   ```bash
   git diff HEAD~1
   ```

4. **Verify files changed**
   ```bash
   # For each file in the handover
   wc -l {FILE_PATH}  # Should match handover
   head -5 {FILE_PATH}  # Should look reasonable
   ```

5. **Check for surprises**
   - Did the subagent modify files outside the target list?
   - Did they add unexpected dependencies?
   - Did they deviate from the constraints?

### Step 7: Gate

Apply the gate matrix:

| Precedence | Gate | Condition | Action |
|---|---|---|---|
| 1 (highest) | Fabrication | Claimed evidence contradicts workspace | Stop, escalate immediately |
| 2 | Stagnation | Same error recurs after correction | Stop, record signature, escalate |
| 3 | Environment blocker | Missing capability cannot be fixed in scope | Stop, don't burn retries |
| 4 | Spec drift | Test/path wrong because relay underspecified | Revise relay, retry |
| 5 | Execution error | Agent didn't follow spec | Retry with correction (2 consecutive → escalate) |
| 6 | Contract failure | Handover incomplete | Metadata-only retry |
| 7 (lowest) | Validation cleared | Evidence matches scope and contract | Mark complete |

**Maximum 3 attempts per task ID.** Repeated error signature is hard stop.

### Step 8: Post-Mortem

If the task succeeded:

1. **Classify learnings**
   ```python
   # What worked well?
   memory(action='add', target='episodic', content='Pattern: {SUCCESSFUL_APPROACH}')
   
   # What was the project context?
   memory(action='add', target='persona', content='Fact: {PROJECT_FACT}')
   ```

2. **Update master plan**
   ```markdown
   ### Steps
   1. {STEP_1} - tier: minimal - status: completed ✅
   ```

3. **Archive the relay**
   ```bash
   mv handovers/relay-{TASK_ID}.md handovers/archive/
   ```

If the task failed:

1. **Document the failure**
   ```markdown
   ## Failure: {TASK_ID}
   
   **Error signature:** {ERROR_PATTERN}
   **Attempts:** 3
   **Root cause:** {ANALYSIS}
   **Learning:** {WHAT_WE_LEARNED}
   ```

2. **Persist the learning**
   ```python
   memory(action='add', target='episodic', content='Anti-pattern: {FAILURE_PATTERN}')
   ```

3. **Escalate if needed**
   - If 3 attempts failed → escalate to user
   - If environment blocker → ask user to fix
   - If spec drift → revise and retry

### Step 9: Stabilize

Ensure the workspace is clean before the next step:

```bash
# Check for uncommitted changes
git status

# If dirty, commit or stash
git add -A
git commit -m "chore: stabilize after {TASK_ID}"

# Verify clean
git status  # Should show "nothing to commit"
```

## Anti-Hallucination Measures

Standard mode includes:

- **Raw output paste** — Agent must paste complete terminal output, never summaries
- **Surprises checklist** — Agent must disclose every deviation
- **Shape contracts** — Exact data shapes, not pseudocode
- **Negative tests** — Assert something should NOT happen
- **Files verification** — Architect independently checks file size and first line
- **State-aware re-execution** — Confirm agent's commit before re-running tests
- **Pre-delegation stash** — Prevent state-file pollution
- **Gate matrix** — Classify failures (fabrication, stagnation, spec drift, etc.)
- **Max 3 attempts** — Prevent infinite retry loops

## What's Missing

Compared to Primitives mode, Standard mode adds:

- Master plan
- Pre-delegation stash
- Clean-state checks
- Tier selection
- Post-mortem
- Gate matrix
- Anti-hallucination measures

Compared to Custom mode, Standard mode is:

- Predefined (no customization)
- Well-tested (proven in practice)
- Comprehensive (covers most cases)

## When to Switch Modes

**Switch to Primitives if:**
- You're doing trivial tasks
- You want maximum speed
- You trust the subagent implicitly

**Switch to Custom if:**
- You have a specialized workflow
- Standard mode is too much or too little
- You want to experiment

## Example

**Task:** Add user authentication to a Flask app

**Master plan:**
```markdown
# Master Plan

## Task: User Authentication

### Steps
1. Create User model - tier: standard - status: pending
2. Create auth routes - tier: standard - status: pending
3. Create login template - tier: minimal - status: pending
4. Add tests - tier: full - status: pending
```

**Relay context (Step 1):**
```markdown
**Task ID:** AUTH-001
**Tier:** standard
**Task:** Create a User model with username, email, and password_hash fields

## Target files
- `models.py` — modify

## Out of scope
- `app.py` — do not touch yet
- `templates/` — do not touch yet

## Constraints
- Use Flask-SQLAlchemy
- Password must be hashed with werkzeug.security
- No new dependencies without approval

## Shape contract
```json
{
  "User": {
    "id": "int",
    "username": "string",
    "email": "string",
    "password_hash": "string"
  }
}
```

## Tests
```bash
# Structural assertion
python -c "from models import User; u = User(username='test', email='test@example.com'); assert u.username == 'test'"

# Negative assertion
python -c "from models import User; u = User(); assert not hasattr(u, 'plaintext_password')"

# Shape assertion
python -c "from models import User; u = User(); assert all(hasattr(u, f) for f in ['id', 'username', 'email', 'password_hash'])"
```

## Stop conditions
- If Flask-SQLAlchemy is not installed, stop and ask user to install
- If database migration fails, stop and report error

## Handover
Write to `handovers/done/completion-AUTH-001.md`:
1. Raw test output
2. Git evidence (commit hash, diff stat)
3. Files changed (with line counts)
4. Surprises checklist
5. Contract enforcement statement
```

**Verification:**
```bash
# Run tests
python -c "from models import User; u = User(username='test', email='test@example.com'); assert u.username == 'test'"

# Check diff
git diff HEAD~1 models.py

# Verify file
wc -l models.py
head -10 models.py
```

**Gate:** Validation cleared ✅

**Post-mortem:**
```python
memory(action='add', target='episodic', content='Pattern: Flask-SQLAlchemy User model with werkzeug password hashing')
memory(action='add', target='persona', content='Fact: Project uses Flask-SQLAlchemy for ORM')
```

**Stabilize:**
```bash
git status  # Clean ✅
```
