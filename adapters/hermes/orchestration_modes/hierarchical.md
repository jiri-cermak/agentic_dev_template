# Hierarchical Orchestration Mode

## Overview

Multi-level delegation where the Architect delegates to a Lead Subagent, who then coordinates Worker Subagents. Results flow up through the hierarchy. For very large, complex tasks with natural decomposition.

## When to Use

**Use when:**
- Task is very large and complex
- Natural decomposition into sub-tasks exists
- You need multiple levels of oversight
- Work can be parallelized at multiple levels

**Don't use when:**
- Task is small or medium (overkill)
- No natural hierarchy exists
- You can manage subagents directly
- Task doesn't benefit from multi-level oversight

## How It Works

```
Architect
   |
   |--- Delegate to Lead Subagent
   |    |
   |    v
   | Lead Subagent
   |    |
   |    |--- Decompose into worker tasks
   |    |    |                    |                    |
   |    |    v                    v                    v
   |    | Worker A            Worker B            Worker C
   |    |    |                    |                    |
   |    |    |--- Execute         |--- Execute         |--- Execute
   |    |    |                    |                    |
   |    |<-- Result A -----------|<-- Result B -------|<-- Result C ---
   |    |
   |    |--- Merge worker results
   |    |--- Verify integration
   |    |
   |<-- Final result -------------
   |
   |--- Final verification
   |--- Done
```

## Implementation

### Architect to Lead Delegation

```markdown
**Task ID:** {TASK_ID}
**Orchestration Mode:** hierarchical
**Role:** Lead Subagent

## Your Responsibility
You are the Lead Subagent. You will:
1. Decompose the task into worker sub-tasks
2. Delegate to worker subagents
3. Merge their results
4. Verify integration
5. Report back to Architect

## Overall Task
{Large task description}

## Success Criteria
- {Criterion 1}
- {Criterion 2}
- {Criterion 3}

## Constraints
- Worker subagents should work on independent parts
- You must verify integration before reporting back
- Report progress at checkpoints

## Checkpoints
1. After decomposition (show your plan)
2. After workers complete (show merged result)
3. Final verification (ready for Architect)

## Handover
Write to `handovers/done/completion-{TASK_ID}-lead.md`
Include:
- Decomposition plan
- Worker assignments
- Merge report
- Integration test results
```

### Lead to Worker Delegation

Lead Subagent decomposes and delegates:

```markdown
## Decomposition Plan

### Worker A: {Task Name}
- **Scope:** {What this worker does}
- **Files:** {Files to modify}
- **Dependencies:** None
- **Estimated effort:** {Time}

### Worker B: {Task Name}
- **Scope:** {What this worker does}
- **Files:** {Files to modify}
- **Dependencies:** None
- **Estimated effort:** {Time}

### Worker C: {Task Name}
- **Scope:** {What this worker does}
- **Files:** {Files to modify}
- **Dependencies:** None
- **Estimated effort:** {Time}

### Conflict Check
- No conflicts detected ✅
```

Each worker gets a relay context:

```markdown
**Task ID:** {TASK_ID}-worker{A/B/C}
**Orchestration Mode:** fire_and_forget (or supervised)
**Assigned by:** Lead Subagent

## Your Task
{Specific task description}

## Target Files
- `{FILE_PATH}` - {action}

## Tests
```bash
{TEST_COMMAND}
```

## Handover
Write to `handovers/done/completion-{TASK_ID}-worker{A/B/C}.md`
```

### Lead Merge and Verification

Lead Subagent merges worker results:

```markdown
## Merge Report

### Worker Results
- Worker A: ✅ Complete
- Worker B: ✅ Complete
- Worker C: ✅ Complete

### Integration Check
- No conflicts ✅
- All tests passing ✅

### Issues Resolved
- {Issue 1}: {Resolution}

### Ready for Architect
- All workers complete
- Integration verified
- Ready for final review
```

### Architect Final Verification

Architect verifies the Lead's work:

```markdown
## Final Verification

### Lead Report
- Decomposition: ✅ Sound
- Worker coordination: ✅ Effective
- Integration: ✅ Verified

### Final Tests
```bash
# Run full test suite
pytest tests/ -v
```
- All tests passing ✅

### Final Commit
- Merged all work
- Single commit
- Commit message: "feat: {large task}"
```

## Examples

### Example 1: Enterprise System Migration

**Architect delegates to Lead:**
```markdown
## Overall Task
Migrate the entire authentication system from legacy to modern architecture.

## Scope
- User model migration
- Authentication flow rewrite
- Session management update
- API endpoint updates
- Test suite update
- Documentation update

## Success Criteria
- All users can still log in
- New architecture is more secure
- All tests pass
- Documentation is updated
```

**Lead decomposes:**
```markdown
### Worker A: Database Migration
- Migrate user table schema
- Add new fields
- Migrate existing data
- Files: models.py, migrations/

### Worker B: Authentication Logic
- Rewrite login/logout
- Update password hashing
- Add 2FA support
- Files: auth.py, views.py

### Worker C: Session Management
- Update session handling
- Add token refresh
- Files: sessions.py, middleware.py

### Worker D: API Updates
- Update API endpoints
- Add new endpoints
- Files: api.py, serializers.py

### Worker E: Tests and Docs
- Update test suite
- Update documentation
- Files: tests/, docs/
```

**Lead coordinates workers, merges results, verifies integration, reports to Architect.**

### Example 2: Large Feature Development

**Architect delegates to Lead:**
```markdown
## Overall Task
Implement a complete e-commerce checkout flow.

## Scope
- Shopping cart
- Checkout process
- Payment integration
- Order confirmation
- Email notifications
```

**Lead decomposes:**
```markdown
### Worker A: Shopping Cart
- Cart model
- Add/remove items
- Update quantities
- Files: cart.py, views.py

### Worker B: Checkout Process
- Checkout form
- Address validation
- Order creation
- Files: checkout.py, forms.py

### Worker C: Payment Integration
- Stripe integration
- Payment processing
- Error handling
- Files: payments.py, stripe.py

### Worker D: Order Confirmation
- Confirmation page
- Email notification
- Files: orders.py, emails.py
```

**Lead coordinates, merges, verifies, reports.**

## Best Practices

1. **Clear hierarchy**: Architect → Lead → Workers. Don't skip levels.

2. **Lead has authority**: Let the Lead make decisions about worker coordination. Don't micromanage workers.

3. **Lead verifies integration**: The Lead should verify that worker results integrate correctly before reporting to Architect.

4. **Architect verifies final result**: The Architect should verify the Lead's final result, not just trust the Lead.

5. **Checkpoints at each level**: Lead reports to Architect at checkpoints. Workers report to Lead at checkpoints.

6. **Clear boundaries**: Each level should have clear responsibilities. Don't blur the lines.

## When to Switch Modes

**Switch to Parallel if:**
- Task is large but doesn't need multi-level oversight
- You can manage workers directly
- No natural hierarchy exists

**Switch to Supervised if:**
- Task is complex but not large enough for hierarchy
- You need tight control
- Lead overhead isn't worth it

**Switch to Collaborative if:**
- Task requires deep collaboration
- No natural decomposition exists
- You need to work together at all levels

## Anti-Patterns

❌ **Using hierarchy for small tasks**: If you can manage workers directly, don't add a Lead.

❌ **Micromanaging workers**: Let the Lead coordinate workers. Don't bypass the Lead.

❌ **Skipping integration verification**: The Lead must verify integration before reporting to Architect.

❌ **Unclear hierarchy**: Make sure everyone knows who reports to whom.

## Performance Characteristics

- **Overhead**: High (multi-level coordination)
- **Parallelism**: High (workers in parallel)
- **Safety**: High (multi-level verification)
- **Best for**: Very large, complex tasks with natural hierarchy

## Metrics to Track

- Number of levels in hierarchy
- Number of workers per Lead
- Time spent in coordination
- Integration issue rate

If coordination overhead is > 30% of total time, the hierarchy may be too deep. If integration issues are > 10%, worker coordination is poor.
