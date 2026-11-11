# Collaborative Orchestration Mode

## Overview

True partnership between Architect and Subagent. Both contribute to the solution, make decisions together, and work iteratively. More like pair programming than delegation.

## When to Use

**Use when:**
- Task requires human expertise
- You want to work together on design
- You're exploring creative solutions
- You need to make decisions together
- Task requires domain knowledge

**Don't use when:**
- Task is well-defined (use fire-and-forget)
- You want maximum speed
- You don't need to collaborate
- Task is routine

## How It Works

```
Architect                          Subagent
   |                                   |
   |--- Discuss problem -------------->|
   |<-- Brainstorm solutions ----------|
   |                                   |
   |--- Propose approach ------------->|
   |<-- Feedback/alternatives ---------|
   |                                   |
   |--- Agree on direction             |
   |                                   |
   |--- Subagent implements ---------->|
   |                                   |--- Code
   |<-- Share progress ---------------|
   |                                   |
   |--- Review and suggest ------------>|
   |<-- Incorporate feedback ----------|
   |                                   |
   |--- Subagent completes ----------->|
   |                                   |--- Tests
   |                                   |--- Commit
   |<-- Final result ------------------|
   |                                   |
   |--- Joint review                   |
   |    - Both approve                 |
   |    - Both sign off                |
```

## Implementation

### Initial Discussion

Start with a collaborative discussion:

```markdown
## Problem Statement
{Describe the problem you're trying to solve}

## Constraints
- {Constraint 1}
- {Constraint 2}

## What I Know
- {Your domain knowledge}
- {Your experience}

## What I Need Help With
- {Where you need the subagent's expertise}
- {Areas where you want collaboration}

## Open Questions
- {Question 1}
- {Question 2}
```

### Collaborative Handover Format

```markdown
## Collaborative Session: {TASK_ID}

### Problem
{Problem statement}

### Discussion
- **Architect:** {Initial thoughts}
- **Subagent:** {Suggestions}
- **Architect:** {Refinement}
- **Subagent:** {Alternatives}
- **Decision:** {Joint decision}

### Approach
{Agreed-upon approach}

### Implementation
{What was implemented}

### Files Changed
- `{FILE_PATH_1}` - {changes}

### Tests
```bash
{TEST_COMMAND}
```

### Result
{Final outcome}

### Learnings
{What both learned from the collaboration}
```

## Examples

### Example 1: System Design

**Initial Discussion:**
```markdown
## Problem Statement
We need to design a notification system that supports email, SMS, and push notifications.

## Constraints
- Must support 10k users
- Must be reliable (no lost notifications)
- Must be extensible for future channels

## What I Know
- We have a user database with email and phone
- We've used SendGrid for email before
- We need to handle rate limiting

## What I Need Help With
- Best architecture pattern (queue-based? event-driven?)
- How to handle retries and failures
- How to make it extensible

## Open Questions
- Should we use a message queue?
- How do we handle duplicate notifications?
- What's the best way to abstract different channels?
```

**Collaborative Design:**
```markdown
### Discussion
- **Architect:** I'm thinking event-driven with a notification service
- **Subagent:** Agreed. I'd suggest using a message queue for reliability
- **Architect:** Good idea. What queue? Redis? RabbitMQ?
- **Subagent:** Redis is simpler, RabbitMQ is more robust. For 10k users, Redis should work
- **Architect:** Let's go with Redis. How do we handle failures?
- **Subagent:** Dead letter queue + retry logic with exponential backoff
- **Decision:** Event-driven with Redis queue, DLQ for failures, retry with backoff

### Approach
1. NotificationService receives events
2. Events pushed to Redis queue
3. Workers consume from queue
4. Each channel (email, SMS, push) is a separate worker
5. Failures go to DLQ, retried with backoff

### Implementation
[Subagent implements with Architect input at each step]
```

### Example 2: Complex Debugging

**Initial Discussion:**
```markdown
## Problem Statement
Users are reporting intermittent 500 errors on the checkout page.

## What I Know
- Started happening after last deployment
- Affects ~5% of checkouts
- Error logs show database timeout

## What I Need Help With
- How to systematically debug this
- What to look for in the code
- How to reproduce the issue

## Open Questions
- What changed in the last deployment?
- Is it a specific query?
- Could it be a race condition?
```

**Collaborative Debugging:**
```markdown
### Discussion
- **Architect:** Last deployment added a new analytics query
- **Subagent:** Let's check if that query is the culprit
- **Architect:** Good idea. How do we check?
- **Subagent:** Let's look at the query execution time and see if it correlates with errors
- **Architect:** I'll pull the logs, you analyze the pattern
- **Subagent:** Found it. The analytics query runs on every checkout and times out under load

### Solution
- Move analytics query to background job
- Add caching for analytics data
- Add query timeout protection

### Implementation
[Joint implementation with Architect providing context, Subagent writing code]
```

## Best Practices

1. **Start with discussion**: Don't jump straight to implementation. Discuss the problem first.

2. **Share your knowledge**: Tell the subagent what you know. It helps it give better suggestions.

3. **Be open to alternatives**: The subagent might have better ideas. Listen.

4. **Make decisions together**: Don't just accept the subagent's suggestion. Discuss trade-offs.

5. **Document the collaboration**: Record what you discussed and why you made certain decisions.

6. **Learn from each other**: Both Architect and Subagent should learn from the collaboration.

## When to Switch Modes

**Switch to Fire-and-Forget if:**
- Collaboration establishes a clear pattern
- Task becomes routine
- You've learned enough to delegate directly

**Switch to Supervised if:**
- Collaboration reveals high risk
- You need tighter control
- Task is more complex than expected

**Switch to Iterative if:**
- Collaboration isn't converging
- You need more structured feedback loops
- Task is unclear

## Anti-Patterns

❌ **Dominating the conversation**: Don't just tell the subagent what to do. Listen to its suggestions.

❌ **Skipping discussion**: Don't jump straight to implementation. Discuss first.

❌ **Not documenting decisions**: If you don't record why you made certain decisions, you'll forget.

❌ **Over-collaborating**: Not every task needs collaboration. Use it only when you need partnership.

## Performance Characteristics

- **Overhead**: High (discussion + collaboration)
- **Parallelism**: None (sequential collaboration)
- **Safety**: High (joint decision-making)
- **Best for**: Complex design, debugging, learning

## Metrics to Track

- Time spent in discussion vs implementation
- Number of decisions made collaboratively
- Quality of outcomes (fewer bugs, better designs)
- Learning outcomes (what did both learn?)

If you're collaborating on routine tasks, you're over-collaborating. If you're not collaborating on complex tasks, you're under-collaborating.
