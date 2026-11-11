# Parallel Orchestration Mode

## Overview

Multiple subagents work on independent parts of a task simultaneously. The Architect decomposes the task, assigns parts to subagents, and merges the results. Maximizes throughput for tasks with natural parallelism.

## When to Use

**Use when:**
- Task can be decomposed into independent parts
- You want to maximize throughput
- Parts don't have dependencies
- You have multiple subagents available

**Don't use when:**
- Parts have dependencies (must be sequential)
- Task is small (overhead not worth it)
- Parts conflict (modify same files)
- You don't have multiple subagents

## How It Works

```
Architect
   |
   |--- Decompose task
   |    - Part A (independent)
   |    - Part B (independent)
   |    - Part C (independent)
   |
   |--- Delegate to Subagents
   |    |                    |                    |
   |    v                    v                    v
   | Subagent A          Subagent B          Subagent C
   |    |                    |                    |
   |    |--- Execute A       |--- Execute B       |--- Execute C
   |    |                    |                    |
   |<-- Result A -----------|<-- Result B -------|<-- Result C ---
   |
   |--- Merge results
   |    - Check for conflicts
   |    - Resolve if needed
   |    - Final verification
   |
   |--- Done
```

## Implementation

### Task Decomposition

Architect decomposes the task:

```markdown
## Task Decomposition

### Original Task
{Large task description}

### Decomposed Parts

#### Part A: {Name}
- **Scope:** {What this part covers}
- **Files:** {Files this part modifies}
- **Dependencies:** None (or list of other parts)
- **Estimated effort:** {Time}

#### Part B: {Name}
- **Scope:** {What this part covers}
- **Files:** {Files this part modifies}
- **Dependencies:** None (or list of other parts)
- **Estimated effort:** {Time}

#### Part C: {Name}
- **Scope:** {What this part covers}
- **Files:** {Files this part modifies}
- **Dependencies:** None (or list of other parts)
- **Estimated effort:** {Time}

### Conflict Check
- Part A modifies: file1.py, file2.py
- Part B modifies: file3.py, file4.py
- Part C modifies: file5.py
- **No conflicts detected** ✅

### Merge Strategy
- Sequential merge (A → B → C)
- No integration needed (parts are independent)
```

### Parallel Relay Context

Each subagent gets a relay context for its part:

```markdown
**Task ID:** {TASK_ID}-part{A/B/C}
**Orchestration Mode:** parallel
**Part:** {A/B/C} of {N}

## Your Part
{Specific description of this part}

## Target Files
- `{FILE_PATH_1}` - {action}

## Constraints
- Do NOT modify files outside your scope
- Follow the same coding standards as other parts

## Tests
```bash
{TEST_COMMAND_FOR_THIS_PART}
```

## Handover
Write to `handovers/done/completion-{TASK_ID}-part{A/B/C}.md`
```

### Merge Process

After all subagents complete, Architect merges:

```markdown
## Merge Report

### Results Received
- Part A: ✅ Complete (2 files modified)
- Part B: ✅ Complete (2 files modified)
- Part C: ✅ Complete (1 file modified)

### Conflict Check
- Part A: file1.py, file2.py
- Part B: file3.py, file4.py
- Part C: file5.py
- **No conflicts** ✅

### Integration Tests
```bash
# Run all tests together
pytest tests/ -v
```
- All tests passing ✅

### Final Commit
- Merged all parts
- Single commit with all changes
- Commit message: "feat: implement {large task}"
```

## Examples

### Example 1: Multi-File Refactoring

**Task:** Refactor authentication module across 5 files

**Decomposition:**
```markdown
#### Part A: Update models.py
- Add new fields to User model
- Files: models.py

#### Part B: Update views.py
- Update login/logout views
- Files: views.py

#### Part C: Update forms.py
- Update authentication forms
- Files: forms.py

#### Part D: Update tests
- Update test_models.py, test_views.py, test_forms.py
- Files: tests/test_models.py, tests/test_views.py, tests/test_forms.py

#### Part E: Update documentation
- Update API docs
- Files: docs/api.md

**No conflicts** - each part modifies different files
```

**Execution:**
- 5 subagents work in parallel
- Each modifies its assigned files
- Architect merges results
- Runs full test suite
- Single commit

### Example 2: Batch Processing

**Task:** Process 100 images (resize, compress, upload)

**Decomposition:**
```markdown
#### Part A: Process images 1-20
- Resize to 800x600
- Compress to 80% quality
- Upload to S3
- Files: images/001-020.jpg

#### Part B: Process images 21-40
- Same as Part A
- Files: images/021-040.jpg

#### Part C: Process images 41-60
- Same as Part A
- Files: images/041-060.jpg

#### Part D: Process images 61-80
- Same as Part A
- Files: images/061-080.jpg

#### Part E: Process images 81-100
- Same as Part A
- Files: images/081-100.jpg

**No conflicts** - each part processes different images
```

**Execution:**
- 5 subagents work in parallel
- Each processes its batch
- Architect verifies all uploads
- Generates summary report

## Conflict Resolution

If parts modify the same files, Architect must resolve conflicts:

```markdown
## Conflict Detected

### Conflicting Files
- file1.py modified by Part A and Part B

### Resolution Strategy
1. **Sequential merge:** Apply Part A first, then Part B
2. **Manual merge:** Architect manually merges changes
3. **Re-decompose:** Split the conflicting file into separate parts

### Chosen Strategy
Manual merge - Architect will merge Part A and Part B changes to file1.py
```

## Best Practices

1. **Decompose carefully**: Make sure parts are truly independent. Hidden dependencies will cause problems.

2. **Check for conflicts**: Before starting, verify no two parts modify the same files.

3. **Define clear boundaries**: Each part should have a clear scope and file list.

4. **Test individually and together**: Each part should pass its own tests, and the merged result should pass integration tests.

5. **Have a merge strategy**: Know how you'll merge before you start. Sequential? Manual? Automated?

6. **Monitor progress**: Keep track of which parts are done and which are still running.

## When to Switch Modes

**Switch to Fire-and-Forget if:**
- Task is small (not worth decomposition overhead)
- Parts have dependencies (can't parallelize)

**Switch to Supervised if:**
- Parts are high-risk
- You need tight control over each part
- Conflicts are likely

**Switch to Hierarchical if:**
- Task is very large
- Natural hierarchy exists
- You need multiple levels of oversight

## Anti-Patterns

❌ **Parallelizing dependent tasks**: If Part B depends on Part A, they can't run in parallel.

❌ **Ignoring conflicts**: If two parts modify the same file, you'll have merge conflicts. Plan for this.

❌ **Over-decomposition**: Don't decompose into 20 tiny parts. The overhead will kill you.

❌ **No merge strategy**: If you don't know how you'll merge, you'll have a bad time.

## Performance Characteristics

- **Overhead**: Medium (decomposition + merge)
- **Parallelism**: High (multiple subagents)
- **Safety**: Medium (conflict resolution needed)
- **Best for**: Large tasks with natural parallelism

## Metrics to Track

- Number of parts per task
- Time saved vs sequential execution
- Conflict rate (should be < 5%)
- Merge time

If conflict rate is high, your decomposition is poor. If time saved is < 30%, the overhead isn't worth it.
