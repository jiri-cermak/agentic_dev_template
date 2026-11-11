# Iterative Orchestration Mode

## Overview

Cyclical refinement through feedback loops. The Architect delegates, reviews the result, provides feedback, and the subagent iterates. Typically 2-3 cycles until the result is satisfactory.

## When to Use

**Use when:**
- Task has unclear requirements
- You expect to refine the approach
- You want to explore multiple solutions
- You're learning about the problem space
- Quality matters more than speed

**Don't use when:**
- Task is simple and well-defined (use fire-and-forget)
- You need maximum speed
- Requirements are crystal clear
- Task is low-risk

## How It Works

```
Architect                          Subagent
   |                                   |
   |--- Delegate task ---------------->|
   |                                   |--- Execute
   |                                   |--- Write handover
   |<-- Completion signal -------------|
   |                                   |
   |--- Review result                  |
   |    - Check quality                |
   |    - Identify issues              |
   |    - Formulate feedback           |
   |                                   |
   |--- Provide feedback ------------->|
   |                                   |--- Refine
   |                                   |--- Write handover
   |<-- Completion signal -------------|
   |                                   |
   |--- Review again                   |
   |    - Satisfactory? YES → Done     |
   |    - Satisfactory? NO → Repeat    |
```

Typically 2-3 iterations. If it takes more than 3, something is wrong.

## Implementation

### Relay Context Template

```markdown
**Task ID:** {TASK_ID}
**Orchestration Mode:** iterative
**Max Iterations:** 3

## Task
{Task description with room for refinement}

## Initial Approach
{Suggested starting point, but open to alternatives}

## Target Files
- `{FILE_PATH}` - {action}

## Success Criteria
- {Criterion 1}
- {Criterion 2}
- {Criterion 3}

## Tests
```bash
{TEST_COMMAND}
```

## Feedback Protocol
After each iteration, Architect will provide:
- What works well
- What needs improvement
- Specific suggestions for next iteration

## Handover
Write to `handovers/done/completion-{TASK_ID}-iter{N}.md`
Include iteration number and changes from previous iteration.
```

### Iteration Tracking

Track iterations in handover files:

```
handovers/
└── done/
    ├── completion-TASK-001-iter1.md
    ├── completion-TASK-001-iter2.md
    └── completion-TASK-001-iter3.md  # Final
```

### Feedback Template

After each iteration, Architect provides:

```markdown
## Iteration {N} Feedback

### What Works
- {Positive aspect 1}
- {Positive aspect 2}

### What Needs Improvement
- {Issue 1}: {Specific suggestion}
- {Issue 2}: {Specific suggestion}

### Priority for Next Iteration
1. {Most important fix}
2. {Second priority}
3. {Nice to have}

### Decision
- Continue iterating (if not satisfactory)
- Accept result (if satisfactory)
- Escalate (if stuck after 3 iterations)
```

## Examples

### Example 1: Algorithm Design

**Iteration 1:**
```markdown
**Task:** Implement a search algorithm for the product catalog

**Initial Approach:** Start with a simple linear search

**Result:** Linear search implemented, works but slow for 10k products

**Feedback:**
- ✅ Works correctly
- ❌ Too slow (500ms for 10k products)
- 🔄 Try binary search or indexing
```

**Iteration 2:**
```markdown
**Refinement:** Implement binary search with pre-sorted index

**Result:** Binary search implemented, 50ms for 10k products

**Feedback:**
- ✅ Much faster
- ✅ Still correct
- 🔄 Add caching for frequently searched terms
```

**Iteration 3:**
```markdown
**Refinement:** Add LRU cache for search results

**Result:** Cache implemented, 5ms for cached queries

**Feedback:**
- ✅ Excellent performance
- ✅ Correct
- ✅ Accept result
```

### Example 2: API Design

**Iteration 1:**
```markdown
**Task:** Design REST API for user management

**Initial Approach:** Standard CRUD endpoints

**Result:** 
- POST /users
- GET /users/{id}
- PUT /users/{id}
- DELETE /users/{id}

**Feedback:**
- ✅ Basic CRUD works
- ❌ No pagination for GET /users
- ❌ No filtering or sorting
- 🔄 Add query parameters
```

**Iteration 2:**
```markdown
**Refinement:** Add pagination, filtering, sorting

**Result:**
- GET /users?page=1&limit=20&sort=name&filter=active

**Feedback:**
- ✅ Good pagination
- ✅ Filtering works
- ❌ No bulk operations
- 🔄 Add bulk delete and bulk update
```

**Iteration 3:**
```markdown
**Refinement:** Add bulk operations

**Result:**
- POST /users/bulk-delete
- POST /users/bulk-update

**Feedback:**
- ✅ Complete API
- ✅ All requirements met
- ✅ Accept result
```

## Best Practices

1. **Start broad, then refine**: First iteration explores the space, subsequent iterations focus on quality.

2. **Specific feedback**: Don't say "needs improvement". Say "the search is too slow, try indexing".

3. **Limit iterations**: If it takes more than 3 iterations, something is fundamentally wrong. Escalate.

4. **Track progress**: Each iteration should clearly show what improved.

5. **Know when to stop**: Perfect is the enemy of good. Accept "good enough" after 2-3 iterations.

## When to Switch Modes

**Switch to Fire-and-Forget if:**
- Task becomes simple and well-defined
- Requirements are now clear
- You've learned enough to delegate directly

**Switch to Supervised if:**
- Iterations aren't converging
- Task is more complex than expected
- You need tighter control

**Switch to Collaborative if:**
- You're stuck after 3 iterations
- Task requires domain expertise you don't have
- You need to make fundamental design decisions

## Anti-Patterns

❌ **Endless iteration**: If it takes more than 3 iterations, stop and reassess.

❌ **Vague feedback**: "This isn't good enough" doesn't help. Be specific.

❌ **Changing requirements mid-iteration**: Stick to the plan for each iteration. Save new requirements for the next cycle.

❌ **Skipping review**: Always review the result before providing feedback.

## Performance Characteristics

- **Overhead**: Medium (review + feedback loops)
- **Parallelism**: Low (sequential iterations)
- **Safety**: Medium (catches issues early)
- **Best for**: Exploratory tasks, quality-critical work

## Metrics to Track

- Number of iterations per task (should be 2-3)
- Time per iteration
- Quality improvement per iteration
- Escalation rate (should be < 5%)

If you're consistently hitting 3+ iterations, your initial task definitions may be too vague.
