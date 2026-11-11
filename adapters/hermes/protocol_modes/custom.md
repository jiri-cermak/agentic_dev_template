# Custom Protocol Mode

Define your own orchestration protocol. For specialized workflows or experimentation.

## Philosophy

Standard mode is comprehensive, but not every workflow fits the mold. Custom mode lets you:
- Define your own steps
- Skip ceremony you don't need
- Add ceremony you do need
- Experiment with new approaches

## When to Use

✅ You have a specialized workflow (e.g., data pipeline, API integration)
✅ Standard mode is too much ceremony for your needs
✅ Standard mode is too little ceremony for your needs
✅ You want to experiment with new approaches
✅ You're adapting the protocol to a specific project or team

❌ You're new to the system (start with Standard)
❌ You don't know what ceremony you need (start with Standard, then customize)

## How to Create a Custom Protocol

### Step 1: Copy a Starting Point

```bash
# Copy Standard as your base
cp protocol_modes/standard.md protocol_modes/custom.md

# Or copy Primitives if you want minimal ceremony
cp protocol_modes/primitives.md protocol_modes/custom.md
```

### Step 2: Modify to Fit Your Needs

Edit `custom.md` to:
- Add steps you need
- Remove steps you don't need
- Change the order
- Add project-specific checks
- Add custom verification criteria

### Step 3: Reference in Relay Context

In your relay context, specify:

```markdown
**Protocol mode:** custom
**Custom protocol:** .agents.md
```

Then define your custom protocol in `.agents.md`:

```markdown
## Custom Protocol

### Step 1: {YOUR_STEP_1}
{DESCRIPTION}

### Step 2: {YOUR_STEP_2}
{DESCRIPTION}

...
```

### Step 4: Use in Practice

The Architect will follow your custom protocol instead of Standard.

## Example: Data Pipeline Protocol

**Scenario:** You're building a data pipeline that extracts data from an API, transforms it, and loads it into a database.

**Custom protocol:**

```markdown
## Custom Protocol: Data Pipeline

### Step 1: Extract
1. Query the API endpoint
2. Save raw response to `data/raw/`
3. Verify response structure matches schema

### Step 2: Transform
1. Load raw data
2. Apply transformations (clean, normalize, aggregate)
3. Save transformed data to `data/transformed/`
4. Verify transformation logic with unit tests

### Step 3: Load
1. Connect to database
2. Create/update table schema
3. Insert transformed data
4. Verify row counts match expectations

### Step 4: Validate
1. Run data quality checks (nulls, duplicates, outliers)
2. Generate validation report
3. If issues found, stop and report

### Step 5: Document
1. Update pipeline documentation
2. Log data lineage
3. Archive raw data
```

**Relay context:**

```markdown
**Task ID:** PIPELINE-001
**Protocol mode:** custom
**Custom protocol:** .agents.md
**Task:** Extract user data from API, transform to analytics format, load into database

## Target files
- `pipelines/extract.py` — create
- `pipelines/transform.py` — create
- `pipelines/load.py` — create
- `data/raw/users.json` — create
- `data/transformed/users_analytics.parquet` — create

## Stop conditions
- If API returns 401/403, stop and ask for credentials
- If database connection fails, stop and report error
- If data quality checks fail, stop and report issues

## Handover
Write to `handovers/done/completion-PIPELINE-001.md`:
1. Extraction log (row counts, timestamps)
2. Transformation log (operations applied, row counts before/after)
3. Load log (rows inserted, schema changes)
4. Validation report (quality checks passed/failed)
5. Data lineage diagram
```

## Example: API Integration Protocol

**Scenario:** You're integrating with a third-party API that has rate limits, authentication requirements, and specific error handling needs.

**Custom protocol:**

```markdown
## Custom Protocol: API Integration

### Step 1: Setup
1. Verify API credentials are available
2. Check rate limit headers
3. Test authentication with a simple request

### Step 2: Design
1. Define request/response schemas
2. Map API endpoints to internal models
3. Define error handling strategy

### Step 3: Implement
1. Create API client class
2. Implement authentication (OAuth, API key, etc.)
3. Implement rate limiting (sleep, retry, backoff)
4. Implement error handling (network errors, API errors, timeouts)

### Step 4: Test
1. Write unit tests with mocked responses
2. Write integration tests with real API (if possible)
3. Test error scenarios (401, 403, 429, 500)

### Step 5: Document
1. Document API client usage
2. Document rate limit strategy
3. Document error handling approach
```

## Best Practices

### 1. Start with Standard, Then Customize

Don't start from scratch. Copy Standard mode, then:
- Remove steps you don't need
- Add steps you do need
- This ensures you don't miss critical ceremony

### 2. Keep It Simple

Custom protocols should be:
- Clear and easy to follow
- Not much longer than Standard (if longer, you're probably over-engineering)
- Focused on the specific workflow

### 3. Test Your Protocol

Before using a custom protocol in production:
- Run it on a simple task
- Verify all steps work as expected
- Check that the handover format is useful
- Iterate based on feedback

### 4. Document Your Protocol

Make sure your custom protocol is:
- Well-documented (explain why each step exists)
- Version-controlled (track changes)
- Shared with the team (if applicable)

### 5. Reuse When Possible

If you find yourself creating similar custom protocols:
- Extract common patterns into a shared protocol
- Create a library of custom protocols for different use cases
- Consider contributing back to Standard mode if the pattern is general

## Comparison with Other Modes

| Aspect | Primitives | Standard | Custom |
|---|---|---|---|
| Steps | 3 | 9 | Variable |
| Ceremony | Minimal | High | Variable |
| Flexibility | Low | Low | High |
| Risk | Higher | Lower | Variable |
| Use case | Trivial tasks | Normal development | Specialized workflows |

## When to Promote to Standard

If you find yourself:
- Using the same custom protocol for multiple projects
- Finding the pattern is general enough for others to use
- Getting questions from others about your approach

→ Consider promoting your custom protocol to Standard mode.

## When to Fall Back to Standard

If you find your custom protocol:
- Is missing critical steps (verification, post-mortem)
- Is causing more problems than it solves
- Is too complex to maintain

→ Fall back to Standard mode.
