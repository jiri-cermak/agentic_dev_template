# Protocol Modes

Protocol modes define the level of ceremony and control in the orchestration loop. Inspired by Pi's "primitives, not features" philosophy.

## Available Modes

### 1. Primitives Mode (`primitives.md`)

Minimal protocol: just delegate work, verify results, record learnings. No ceremony.

**Use when:**
- You know exactly what you're doing
- Task is trivial (README tweak, config change)
- You want maximum speed, minimum overhead
- You trust the subagent implicitly

**What's included:**
- Delegate task
- Verify result (tests pass, no fabrication)
- Record learning (if any)
- Done

**What's NOT included:**
- No pre-delegation stash
- No clean-state checks
- No master plan
- No post-mortem
- No tier selection

### 2. Standard Mode (`standard.md`)

Full v6.1 protocol with all anti-hallucination measures.

**Use when:**
- Normal development tasks
- Multi-file changes
- Complex features
- You need verification rigor

**What's included:**
- 9-step lifecycle (plan → stash → pre-flight → relay → delegate → verify → gate → post-mortem → stabilize)
- 3-tier system (Minimal/Standard/Full)
- All anti-hallucination measures
- Master plan template
- Pre-delegation stash
- Clean-state checks

### 3. Custom Mode (`custom.md`)

User-defined protocol. Specify your own steps.

**Use when:**
- You have a specialized workflow
- Standard mode is too much or too little
- You want to experiment

**How to create:**
- Copy `standard.md` or `primitives.md` as a starting point
- Modify to fit your needs
- Reference in relay context: `protocol_mode: custom`
- Define custom steps in `.agents.md`

## Adaptive Angles (Experimental)

These are variations on primitives that adapt to different use cases:

### Technical-Level Adaptive

Same protocol, different verbosity based on user profile:
- `user_profile: technical` — minimal explanations, focus on code
- `user_profile: intermediate` — moderate explanations, some context
- `user_profile: non_technical` — detailed explanations, step-by-step reasoning

### Visual Iteration

For design/visual work:
1. Take screenshot
2. Review with agent
3. Iterate on changes
4. Take screenshot again
5. Finalize

### Exploration

For research/discovery:
1. Formulate hypothesis
2. Investigate
3. Report findings
4. Make decision
5. Generate spec

### Maintenance

For bug fixes, small patches:
1. Identify issue
2. Diagnose root cause
3. Fix
4. Test
5. Document

### Teaching

For learning:
1. Explain concept
2. Demonstrate
3. Practice
4. Quiz

### Pair

For code review, collaborative work:
1. Review code
2. Discuss trade-offs
3. Refactor together
4. Merge

## How to Use

In your relay context, specify the mode:

```markdown
**Protocol mode:** primitives | standard | custom
```

The Architect skill will load the appropriate protocol definition.

## Future Work

- Implement adaptive angles as separate protocol modes
- Add mode-switching mid-session
- Create protocol evolution skill (auto-suggest mode based on task complexity)
