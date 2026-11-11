# Orchestration Modes

Orchestration modes define how the Architect coordinates with Subagents and monitors their work. Different tasks require different levels of oversight and interaction.

## Available Modes

### 1. Fire-and-Forget (`fire_and_forget.md`)

**Use when:**
- Task is simple and well-defined
- Risk of failure is low
- You trust the subagent to execute correctly
- You want maximum parallelism

**How it works:**
- Architect delegates task to subagent
- Subagent executes without supervision
- Architect verifies result when complete
- No mid-flight monitoring

**Best for:**
- Code formatting
- Simple refactoring
- Documentation updates
- Test writing

### 2. Iterative (`iterative.md`)

**Use when:**
- Task has unclear requirements
- You expect to refine the approach
- You want to explore multiple solutions
- You're learning about the problem space

**How it works:**
- Architect delegates task to subagent
- Subagent executes and returns result
- Architect reviews and provides feedback
- Cycle repeats until satisfactory
- Typically 2-3 iterations

**Best for:**
- Complex algorithms
- API design
- Architecture decisions
- Research tasks

### 3. Supervised (`supervised.md`)

**Use when:**
- Task is high-risk or complex
- You need to catch errors early
- You want to guide the approach
- Failure would be costly

**How it works:**
- Architect delegates task to subagent
- Subagent reports progress at checkpoints
- Architect reviews and approves direction
- Subagent continues with corrections if needed
- More overhead but safer

**Best for:**
- Database migrations
- Security-critical code
- Performance optimizations
- Breaking changes

### 4. Collaborative (`collaborative.md`)

**Use when:**
- Task requires human expertise
- You want to work together on design
- You're exploring creative solutions
- You need to make decisions together

**How it works:**
- Architect and subagent work together
- Both contribute to the solution
- Decisions made collaboratively
- More like pair programming than delegation

**Best for:**
- System design
- Complex debugging
- Code review
- Learning new domains

### 5. Parallel (`parallel.md`)

**Use when:**
- Task can be decomposed into independent parts
- You want to maximize throughput
- Parts don't have dependencies
- You have multiple subagents available

**How it works:**
- Architect breaks task into independent parts
- Multiple subagents work in parallel
- Architect merges results
- Requires conflict resolution strategy

**Best for:**
- Multi-file refactoring
- Batch processing
- Independent feature development
- Test suite generation

### 6. Hierarchical (`hierarchical.md`)

**Use when:**
- Task is very large and complex
- Natural decomposition into sub-tasks exists
- You need multiple levels of oversight
- Work can be parallelized at multiple levels

**How it works:**
- Architect delegates to lead subagent
- Lead subagent coordinates worker subagents
- Results flow up through hierarchy
- Architect verifies final result

**Best for:**
- Large system migrations
- Multi-component features
- Enterprise-scale refactoring
- Complex integrations

## Choosing a Mode

**Decision tree:**

```
Is the task simple and low-risk?
  YES → Fire-and-Forget
  
Is the task unclear or exploratory?
  YES → Iterative
  
Is the task high-risk or complex?
  YES → Supervised
  
Does the task require human expertise?
  YES → Collaborative
  
Can the task be split into independent parts?
  YES → Parallel
  
Is the task very large with natural decomposition?
  YES → Hierarchical
  
Default → Fire-and-Forget
```

## Mode Configuration

In `.agents.md`:

```yaml
orchestration:
  default_mode: fire_and_forget
  override_rules:
    - pattern: "*.sql"
      mode: supervised
    - pattern: "src/security/**"
      mode: supervised
    - pattern: "docs/**"
      mode: fire_and_forget
    - pattern: "tests/**"
      mode: fire_and_forget
```

## Combining Modes

You can combine modes for different aspects:

- **Protocol Mode**: primitives / standard / custom
- **Orchestration Mode**: fire_and_forget / iterative / supervised / collaborative / parallel / hierarchical
- **Verification Strategy**: hallucination_guard / visual_regression / etc.

Example: Use "standard protocol + supervised orchestration + visual_regression verification" for a high-risk UI change.
