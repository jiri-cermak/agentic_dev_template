# Verification Strategies

Plugin-based verification strategies for different project types and risk profiles.

## Philosophy

Different projects need different verification. A web app needs visual regression testing. A reservation system needs SQL migration safety. An async game needs state consistency checks.

Instead of one-size-fits-all verification, we provide composable strategies that can be:
- Mixed and matched based on project needs
- Enabled/disabled per task
- Extended with custom strategies

## Available Strategies

### 1. Hallucination Guard (`hallucination_guard.md`)

**Focus:** Protect from LLM hallucinations (fabricated evidence, invented data, false confidence)

**Use when:** All tasks (cross-cutting concern)

**Checks:**
- Raw output verification (no summaries)
- Claimed file existence (stat the file)
- Claimed test results (run the test)
- Claimed API responses (verify format)
- Confidence calibration (does the agent sound certain?)

### 2. Visual Regression (`visual_regression.md`)

**Focus:** Visual testing for web apps

**Use when:** Web apps, mobile-first web, UI changes

**Checks:**
- Screenshot comparison (before/after)
- DOM structure validation
- CSS property verification
- Responsive design checks (mobile/tablet/desktop)
- Accessibility compliance (WCAG 2.1 AA)

### 3. SQL Migration (`sql_migration.md`)

**Focus:** Database migration safety

**Use when:** Reservation systems, data model changes, schema evolution

**Checks:**
- Migration script validation (syntax, rollback capability)
- Data integrity checks (row counts, foreign keys)
- Performance impact analysis (query plans, indexes)
- Backward compatibility (old clients still work)
- Rollback testing (can we revert if needed?)

### 4. State Consistency (`state_consistency.md`)

**Focus:** State transitions in async systems

**Use when:** Async online games, stateful applications, distributed systems

**Checks:**
- State machine validation (only valid transitions)
- Race condition detection (concurrent access)
- Idempotency checks (same operation, same result)
- State recovery (can we recover from failure?)
- Consistency guarantees (ACID, eventual consistency)

### 5. Security Scan (`security_scan.md`)

**Focus:** Security vulnerabilities

**Use when:** All projects (especially user-facing, authentication, data handling)

**Checks:**
- Dependency vulnerabilities (known CVEs)
- Code injection risks (SQL injection, XSS, command injection)
- Authentication/authorization flaws
- Secrets management (no hardcoded secrets)
- Input validation (sanitize all inputs)

### 6. Knowledge Integrity (`knowledge_integrity.md`)

**Focus:** Knowledge base verification

**Use when:** OKF, LLM wiki, hybrid wiki+DB knowledge systems

**Checks:**
- Content accuracy (facts verified against sources)
- Link integrity (no broken links)
- Cross-reference validation (references are consistent)
- Semantic consistency (no contradictions)
- Retrieval testing (can we find what we stored?)

## How to Use

### Step 1: Select Strategies

In your `.agents.md`, specify which strategies to use:

```markdown
## Verification Strategies

**Active strategies:**
- hallucination_guard (all tasks)
- visual_regression (web app tasks)
- security_scan (all tasks)

**Inactive strategies:**
- sql_migration (not a database project)
- state_consistency (not an async system)
- knowledge_integrity (not a knowledge base)
```

### Step 2: Reference in Relay Context

In your relay context, specify:

```markdown
**Verification strategies:** hallucination_guard, visual_regression, security_scan
```

### Step 3: Execute Verification

The Architect will run all active strategies during the verification phase (Step 6 of Standard mode).

Each strategy produces a verification report:

```markdown
## Verification Report: {TASK_ID}

### Hallucination Guard
- ✅ Raw output verified
- ✅ File existence confirmed
- ✅ Test results reproduced
- ✅ API responses validated
- ✅ Confidence calibration: appropriate

### Visual Regression
- ✅ Screenshot comparison: no unexpected changes
- ✅ DOM structure: valid
- ✅ CSS properties: match design spec
- ✅ Responsive design: mobile/tablet/desktop pass
- ✅ Accessibility: WCAG 2.1 AA compliant

### Security Scan
- ✅ Dependencies: no known CVEs
- ✅ Code injection: no risks found
- ✅ Authentication: properly implemented
- ✅ Secrets: no hardcoded secrets
- ✅ Input validation: all inputs sanitized
```

### Step 4: Gate Decision

If all strategies pass → ✅ Validation cleared

If any strategy fails → Gate matrix applies:
- Hallucination detected → Fabrication gate (stop, escalate)
- Visual regression failed → Contract failure gate (retry)
- Security vulnerability found → Environment blocker gate (stop, fix first)

## Combining Strategies

Strategies are composable. You can combine them based on project needs:

**Example 1: Web app with database**
```markdown
**Active strategies:**
- hallucination_guard
- visual_regression
- sql_migration
- security_scan
```

**Example 2: Async game with knowledge base**
```markdown
**Active strategies:**
- hallucination_guard
- state_consistency
- knowledge_integrity
- security_scan
```

**Example 3: Simple API**
```markdown
**Active strategies:**
- hallucination_guard
- security_scan
```

## Extending Strategies

To create a custom verification strategy:

1. Copy an existing strategy as a template:
   ```bash
   cp verification_strategies/hallucination_guard.md verification_strategies/custom.md
   ```

2. Modify to fit your needs:
   - Change the focus
   - Add/remove checks
   - Adjust the verification report format

3. Reference in `.agents.md`:
   ```markdown
   ## Verification Strategies
   
   **Active strategies:**
   - hallucination_guard
   - custom (my custom strategy)
   ```

## Best Practices

### 1. Always Include Hallucination Guard

This is a cross-cutting concern. LLMs hallucinate. Always verify raw output, file existence, test results, and API responses.

### 2. Match Strategies to Project Type

- **Web app:** hallucination_guard + visual_regression + security_scan
- **Database project:** hallucination_guard + sql_migration + security_scan
- **Async system:** hallucination_guard + state_consistency + security_scan
- **Knowledge base:** hallucination_guard + knowledge_integrity

### 3. Don't Over-Verify

If a strategy doesn't apply, don't enable it. Over-verification wastes time and creates noise.

### 4. Review Verification Reports

After each task, review the verification report. If you see patterns:
- Same check failing repeatedly → Fix the root cause
- Check always passing → Consider removing it (low value)
- Check sometimes failing → Investigate why

### 5. Evolve Strategies Over Time

As you learn what works:
- Add new checks to existing strategies
- Remove checks that don't provide value
- Create new strategies for new project types

## Comparison with Standard Verification

Standard mode includes basic verification (run tests, check git diff, verify files). Verification strategies extend this with:

| Aspect | Standard Verification | Verification Strategies |
|---|---|---|
| Scope | Generic (tests, diff, files) | Specialized (visual, SQL, state, security, knowledge) |
| Checks | 3-5 basic checks | 10-20 specialized checks per strategy |
| Customization | None | Composable, extensible |
| Use case | All tasks | Tasks that need specialized verification |

## When to Use Strategies

✅ Your project has specialized verification needs
✅ Standard verification is not enough
✅ You want to catch specific types of errors (hallucinations, visual regressions, security issues)
✅ You're working on a high-risk project (database, async, security-critical)

❌ Your project is simple (use Standard verification)
❌ You don't know what you need (start with Standard, then add strategies)

## Future Work

- Add more strategies (performance testing, load testing, chaos testing)
- Create strategy templates for common project types
- Build a strategy recommendation engine (suggest strategies based on project metadata)
- Integrate with CI/CD pipelines (run strategies as part of deployment)
