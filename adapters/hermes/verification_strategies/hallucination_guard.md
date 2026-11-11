# Hallucination Guard Verification Strategy

## Focus
Protect from LLM hallucinations (fabricated evidence, invented data, false confidence).

## Trigger
Use when: All tasks (cross-cutting concern).

## Checks

### 1. Raw Output Verification
**What to check:** Agent must provide complete, unedited terminal output, not summaries or paraphrases.

**How to verify:**
```bash
# Check that output contains expected markers
grep -q "expected_command_output" handover.md

# Check that output is not summarized
! grep -q "output omitted" handover.md
! grep -q "results truncated" handover.md

# Check output length (should be substantial, not just a few lines)
wc -l handover.md | awk '{if ($1 < 10) exit 1}'
```

**Gate:** If output is summarized or missing → Fabrication gate (stop, escalate)

### 2. File Existence Verification
**What to check:** Agent must actually create/modify files, not just claim to.

**How to verify:**
```bash
# Check each claimed file exists
for file in file1.py file2.js config.yaml; do
  if [ ! -f "$file" ]; then
    echo "ERROR: $file does not exist"
    exit 1
  fi
done

# Check file is not empty
for file in file1.py file2.js config.yaml; do
  if [ ! -s "$file" ]; then
    echo "ERROR: $file is empty"
    exit 1
  fi
done
```

**Gate:** If file doesn't exist or is empty → Fabrication gate (stop, escalate)

### 3. Test Results Reproduction
**What to check:** Agent's claimed test results must be reproducible.

**How to verify:**
```bash
# Run the exact tests the agent claimed to run
pytest tests/ -v > actual_test_output.txt

# Compare with agent's claimed output
diff actual_test_output.txt claimed_test_output.txt

# Check exit code matches
[ $? -eq 0 ] && echo "PASS: Test results match" || echo "FAIL: Test results diverge"
```

**Gate:** If results don't match → Fabrication gate (stop, escalate)

### 4. API Response Validation
**What to check:** If agent claims to call an API, verify the response format is correct.

**How to verify:**
```bash
# Check response is valid JSON (if JSON API)
python3 -c "import json; json.load(open('api_response.json'))"

# Check response has expected structure
python3 << 'EOF'
import json
response = json.load(open('api_response.json'))
assert 'status' in response, "Missing 'status' field"
assert 'data' in response, "Missing 'data' field"
assert response['status'] in ['success', 'error'], "Invalid status value"
EOF

# Check response is not fabricated (has realistic timestamps, IDs, etc.)
python3 << 'EOF'
import json
from datetime import datetime
response = json.load(open('api_response.json'))
timestamp = datetime.fromisoformat(response['timestamp'])
# Timestamp should be recent (within last hour)
assert (datetime.now() - timestamp).total_seconds() < 3600, "Timestamp too old"
EOF
```

**Gate:** If response format is invalid or unrealistic → Fabrication gate (stop, escalate)

### 5. Confidence Calibration
**What to check:** Agent's confidence should match the evidence quality.

**How to verify:**
```bash
# Look for overconfident language without evidence
grep -E "(definitely|certainly|obviously|clearly)" handover.md | \
  grep -v -E "(tests? show|evidence|result)" && \
  echo "WARNING: Overconfident language without evidence"

# Look for hedging language with strong evidence
grep -E "(maybe|perhaps|might|could)" handover.md | \
  grep -E "(tests? show|evidence|result)" && \
  echo "WARNING: Hedging despite strong evidence"

# Check agent acknowledges uncertainty when appropriate
grep -q "uncertain\|unclear\|unknown" handover.md && \
  echo "PASS: Agent acknowledges uncertainty" || \
  echo "INFO: No uncertainty acknowledged (may be overconfident)"
```

**Gate:** No automatic gate, but flag for review if confidence is misaligned with evidence.

## Verification Report Format

```markdown
### Hallucination Guard

- ✅ Raw output verified (complete, not summarized)
- ✅ File existence confirmed (all claimed files exist and are non-empty)
- ✅ Test results reproduced (actual output matches claimed output)
- ✅ API responses validated (format correct, realistic values)
- ✅ Confidence calibration: appropriate (confidence matches evidence)
```

## Pitfalls

1. **Don't over-verify trivial outputs.** For simple file creation, just check the file exists. Don't demand 1000 lines of output for a 10-line config file.

2. **Allow legitimate summarization.** If the agent says "tests passed (47/47)", that's OK if they also provide the full output elsewhere. The key is that the full output must be available somewhere.

3. **Be skeptical of perfect results.** If everything works on the first try with no issues, that's suspicious. Real development has friction. Ask the agent what went wrong.

4. **Check timestamps and IDs.** Fabricated data often has unrealistic timestamps (e.g., 1970-01-01) or sequential IDs (1, 2, 3, 4). Real data has variation.

5. **Verify negative results.** If the agent says "no errors found", verify that they actually looked for errors. Check the command they ran and its output.

## Integration with Other Strategies

Hallucination Guard should always be active, regardless of project type. It's the foundation that other strategies build on:

- Visual Regression assumes screenshots are real (Hallucination Guard verifies this)
- SQL Migration assumes query results are accurate (Hallucination Guard verifies this)
- State Consistency assumes state transitions are real (Hallucination Guard verifies this)
- Security Scan assumes vulnerability scans are real (Hallucination Guard verifies this)
- Knowledge Integrity assumes retrieved knowledge is real (Hallucination Guard verifies this)

## When to Escalate

Escalate to the user when:
- Agent fabricates file existence (claims file exists but it doesn't)
- Agent fabricates test results (claims tests pass but they fail)
- Agent fabricates API responses (response format is impossible)
- Agent is consistently overconfident without evidence

Do not escalate when:
- Agent provides complete output but it's verbose (this is good, not bad)
- Agent acknowledges uncertainty (this is appropriate, not a failure)
- Agent's confidence is slightly misaligned (flag for review, don't escalate)
