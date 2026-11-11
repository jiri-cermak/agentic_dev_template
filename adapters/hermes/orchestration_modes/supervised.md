# Supervised Orchestration Mode

## Overview

Active monitoring with checkpoint reviews. The subagent reports progress at defined checkpoints, and the Architect reviews and approves before the subagent continues. More overhead than fire-and-forget, but catches errors early.

## When to Use

**Use when:**
- Task is high-risk or complex
- You need to catch errors early
- You want to guide the approach
- Failure would be costly
- Task has natural checkpoints

**Don't use when:**
- Task is simple (use fire-and-forget)
- You want maximum speed
- Task is low-risk
- Requirements are crystal clear

## How It Works

```
Architect                          Subagent
   |                                   |
   |--- Delegate task ---------------->|
   |    with checkpoints               |
   |                                   |--- Execute phase 1
   |<-- Checkpoint 1 ------------------|
   |                                   |
   |--- Review checkpoint 1            |
   |    - Approve direction            |
   |    - Provide corrections          |
   |                                   |
   |--- Continue --------------------->|
   |                                   |--- Execute phase 2
   |<-- Checkpoint 2 ------------------|
   |                                   |
   |--- Review checkpoint 2            |
   |    - Approve direction            |
   |    - Provide corrections          |
   |                                   |
   |--- Continue --------------------->|
   |                                   |--- Execute phase 3
   |<-- Final result ------------------|
   |                                   |
   |--- Verify result                  |
   |    - Final gate                   |
```

## Implementation

### Checkpoint Definition

Define checkpoints in the relay context:

```markdown
## Checkpoints

### Checkpoint 1: Initial Setup
**When:** After setting up files and dependencies
**Report:**
- Files created/modified
- Dependencies installed
- Initial structure

### Checkpoint 2: Core Implementation
**When:** After implementing main functionality
**Report:**
- Core logic implemented
- Tests passing (if any)
- Progress percentage

### Checkpoint 3: Final Review
**When:** Before final commit
**Report:**
- All tests passing
- All files modified
- Ready for final verification
```

### Checkpoint Report Format

Subagent reports at each checkpoint:

```markdown
## Checkpoint {N} Report

**Progress:** {percentage}%

**Completed:**
- {Task 1}
- {Task 2}

**Current Status:**
- {What's being worked on}

**Issues Encountered:**
- {Issue 1}: {Resolution}
- {Issue 2}: {Resolution}

**Next Steps:**
- {Step 1}
- {Step 2}

**Files Modified:**
- `{FILE_PATH_1}` - {changes}
- `{FILE_PATH_2}` - {changes}

**Requesting:**
- [ ] Approval to continue
- [ ] Guidance on {specific question}
- [ ] Decision on {specific choice}
```

### Architect Review Checklist

At each checkpoint, Architect reviews:

- [ ] Progress is on track
- [ ] Approach is correct
- [ ] No unexpected file changes
- [ ] Issues are handled appropriately
- [ ] Next steps are reasonable

**Decision:**
- ✅ Approve: "Continue as planned"
- 🔄 Correct: "Change X to Y, then continue"
- ⏸️ Pause: "Wait, I need to investigate Z"
- ❌ Stop: "This approach is wrong, let's reconsider"

## Examples

### Example 1: Database Migration

**Checkpoint 1: Backup and Schema Design**
```markdown
## Checkpoint 1 Report

**Progress:** 20%

**Completed:**
- Database backed up to backup_2026_08_19.sql
- New schema designed
- Migration script skeleton created

**Current Status:**
- Reviewing schema changes

**Issues Encountered:**
- None

**Next Steps:**
- Implement migration logic
- Test on copy of database

**Requesting:**
- [x] Approval to continue
- [ ] Review schema design (see attached)
```

**Architect Response:**
```markdown
✅ Approved. Schema looks good. Continue with migration logic.
```

**Checkpoint 2: Migration Implementation**
```markdown
## Checkpoint 2 Report

**Progress:** 60%

**Completed:**
- Migration script implemented
- Tested on database copy
- All data migrated successfully

**Current Status:**
- Running final validation

**Issues Encountered:**
- Foreign key constraint on table 'orders' required disabling temporarily
- Re-enabled after migration

**Requesting:**
- [x] Approval to continue
- [ ] Confirm FK handling is acceptable
```

**Architect Response:**
```markdown
✅ Approved. FK handling is acceptable. Continue to final checkpoint.
```

**Checkpoint 3: Final Validation**
```markdown
## Checkpoint 3 Report

**Progress:** 100%

**Completed:**
- Migration complete
- All validation tests passing
- Data integrity verified

**Ready for:**
- Final commit and deployment
```

**Architect Response:**
```markdown
✅ Approved. Ready for final verification.
```

### Example 2: Security-Critical Code

**Checkpoint 1: Authentication Flow**
```markdown
## Checkpoint 1 Report

**Progress:** 30%

**Completed:**
- Password hashing implemented (bcrypt)
- Session management skeleton
- Login endpoint created

**Current Status:**
- Implementing token validation

**Requesting:**
- [x] Approval to continue
- [ ] Confirm bcrypt cost factor (using 12)
```

**Architect Response:**
```markdown
✅ Approved. Bcrypt cost 12 is appropriate. Continue.
```

**Checkpoint 2: Authorization**
```markdown
## Checkpoint 2 Report

**Progress:** 70%

**Completed:**
- Token validation implemented
- Role-based access control
- Protected endpoints

**Issues Encountered:**
- None

**Requesting:**
- [x] Approval to continue
```

**Architect Response:**
```markdown
✅ Approved. Continue to final checkpoint.
```

## Best Practices

1. **Define clear checkpoints**: Each checkpoint should have a clear purpose and deliverable.

2. **Keep checkpoints frequent enough**: For high-risk tasks, checkpoint every 20-30% of progress.

3. **Be specific in reviews**: Don't just say "looks good". Say what you checked and why it's acceptable.

4. **Document decisions**: Record why you approved or corrected at each checkpoint.

5. **Don't micromanage**: Trust the subagent within the checkpoint boundaries.

## When to Switch Modes

**Switch to Fire-and-Forget if:**
- Task becomes routine after a few supervised runs
- You've established trust with the subagent
- Risk level decreases

**Switch to Iterative if:**
- Checkpoints reveal fundamental issues
- Approach needs significant rethinking
- You need more back-and-forth

**Switch to Collaborative if:**
- Checkpoints reveal you need to work together
- Task requires domain expertise
- You're making fundamental design decisions

## Anti-Patterns

❌ **Too many checkpoints**: If you're checkpointing every 5%, you're micromanaging. Use fire-and-forget.

❌ **Too few checkpoints**: If you only checkpoint at 50% and 100%, you're not catching errors early enough.

❌ **Rubber-stamping**: Don't just approve everything. Actually review the checkpoint.

❌ **Blocking on minor issues**: If a checkpoint reveals a minor issue, note it but don't block progress.

## Performance Characteristics

- **Overhead**: High (checkpoint reviews)
- **Parallelism**: Low (sequential with reviews)
- **Safety**: High (catches errors early)
- **Best for**: High-risk, complex, or critical tasks

## Metrics to Track

- Number of checkpoints per task
- Time spent in reviews
- Correction rate at checkpoints
- Escalation rate

If correction rate is > 30%, your task definitions may be unclear. If it's < 5%, you may be over-supervising.
