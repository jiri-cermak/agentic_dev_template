# State Consistency Verification Strategy

## Focus
State transitions in async systems, stateful applications, distributed systems.

## Trigger
Use when: Async online games, stateful applications, distributed systems, event-driven architectures.

## Checks

### 1. State Machine Validation
**What to check:** Only valid state transitions should occur.

**How to verify:**
```bash
# Extract state transition log
grep "STATE_TRANSITION" application.log > transitions.log

# Validate transitions against state machine definition
python3 << 'EOF'
import json

# Define valid state machine
valid_transitions = {
    'idle': ['processing'],
    'processing': ['completed', 'failed', 'cancelled'],
    'completed': [],  # terminal state
    'failed': ['retrying'],
    'retrying': ['processing', 'failed'],
    'cancelled': []   # terminal state
}

with open('transitions.log') as f:
    lines = f.readlines()

errors = []
current_state = None

for i, line in enumerate(lines):
    # Parse: "STATE_TRANSITION from=idle to=processing"
    if 'from=' in line and 'to=' in line:
        from_state = line.split('from=')[1].split()[0]
        to_state = line.split('to=')[1].split()[0]
        
        # Validate transition
        if from_state not in valid_transitions:
            errors.append(f"Line {i+1}: Unknown state '{from_state}'")
        elif to_state not in valid_transitions[from_state]:
            errors.append(f"Line {i+1}: Invalid transition {from_state} → {to_state}")
        
        current_state = to_state

if errors:
    print(f"FAIL: {len(errors)} invalid state transitions")
    for error in errors:
        print(f"  {error}")
    exit(1)

print(f"PASS: All {len(lines)} state transitions valid")
EOF
```

**Gate:** If invalid transition found → Fabrication gate (stop, investigate)

### 2. Race Condition Detection
**What to check:** Concurrent access should not cause data corruption.

**How to verify:**
```bash
# Run concurrent stress test
python3 << 'EOF'
import threading
import time
import json

# Shared state
state = {'counter': 0, 'errors': []}
lock = threading.Lock()

def worker(worker_id):
    for i in range(100):
        # Simulate concurrent access
        with lock:
            current = state['counter']
            time.sleep(0.001)  # Simulate work
            state['counter'] = current + 1
            
            # Check for corruption
            if state['counter'] != current + 1:
                state['errors'].append(f"Worker {worker_id}: corruption detected")

# Run 10 concurrent workers
threads = []
for i in range(10):
    t = threading.Thread(target=worker, args=(i,))
    threads.append(t)
    t.start()

for t in threads:
    t.join()

# Verify final state
expected = 1000  # 10 workers * 100 iterations
actual = state['counter']

print(f"Expected counter: {expected}")
print(f"Actual counter: {actual}")

if actual != expected:
    print(f"FAIL: Race condition detected (lost {expected - actual} updates)")
    exit(1)

if state['errors']:
    print(f"FAIL: {len(state['errors'])} corruption errors")
    for error in state['errors']:
        print(f"  {error}")
    exit(1)

print("PASS: No race conditions detected")
EOF
```

**Gate:** If race condition found → Environment blocker gate (stop, add locking)

### 3. Idempotency Checks
**What to check:** Same operation should produce same result, even when repeated.

**How to verify:**
```bash
# Test operation first time
python3 << 'EOF'
import requests
import json

# Create a resource
response1 = requests.post('http://localhost:8000/api/resources', 
                         json={'name': 'test', 'value': 42})
result1 = response1.json()

print(f"First call: {result1}")
EOF

# Test operation second time (should be idempotent)
python3 << 'EOF'
import requests
import json

# Same operation again
response2 = requests.post('http://localhost:8000/api/resources', 
                         json={'name': 'test', 'value': 42})
result2 = response2.json()

print(f"Second call: {result2}")

# Compare results
if result1 == result2:
    print("PASS: Operation is idempotent")
else:
    print("FAIL: Operation is not idempotent")
    print(f"  First:  {result1}")
    print(f"  Second: {result2}")
    exit(1)
EOF

# Test with duplicate requests
python3 << 'EOF'
import requests

# Send 5 identical requests
results = []
for i in range(5):
    response = requests.post('http://localhost:8000/api/resources', 
                            json={'name': 'test', 'value': 42})
    results.append(response.json())

# All results should be identical
if len(set(json.dumps(r, sort_keys=True) for r in results)) == 1:
    print("PASS: All 5 requests produced identical results")
else:
    print("FAIL: Requests produced different results")
    for i, r in enumerate(results):
        print(f"  Request {i+1}: {r}")
    exit(1)
EOF
```

**Gate:** If not idempotent → Contract failure gate (fix idempotency, retry)

### 4. State Recovery
**What to check:** System should recover from failures without data loss.

**How to verify:**
```bash
# Create initial state
python3 << 'EOF'
import requests

# Create resources
for i in range(10):
    requests.post('http://localhost:8000/api/resources', 
                 json={'name': f'resource_{i}', 'value': i})

# Get current state
response = requests.get('http://localhost:8000/api/resources')
state_before = response.json()

print(f"Created {len(state_before)} resources")
with open('state_before.json', 'w') as f:
    import json
    json.dump(state_before, f)
EOF

# Simulate failure (kill process)
pkill -f "python application.py" || true
sleep 2

# Restart application
python application.py &
sleep 5

# Verify state recovered
python3 << 'EOF'
import requests
import json

response = requests.get('http://localhost:8000/api/resources')
state_after = response.json()

with open('state_before.json') as f:
    state_before = json.load(f)

# Compare
if len(state_after) != len(state_before):
    print(f"FAIL: Data loss detected ({len(state_before)} → {len(state_after)})")
    exit(1)

# Check each resource
for before in state_before:
    matching = [a for a in state_after if a['id'] == before['id']]
    if not matching:
        print(f"FAIL: Resource {before['id']} lost")
        exit(1)
    if matching[0] != before:
        print(f"FAIL: Resource {before['id']} corrupted")
        exit(1)

print(f"PASS: State recovered successfully ({len(state_after)} resources)")
EOF
```

**Gate:** If data loss or corruption → Environment blocker gate (stop, investigate persistence)

### 5. Consistency Guarantees
**What to check:** System should maintain consistency (ACID or eventual).

**How to verify:**
```bash
# Test ACID properties (for transactional systems)
python3 << 'EOF'
import sqlite3
import json

conn = sqlite3.connect('database.db', isolation_level=None)
cursor = conn.cursor()

# Test Atomicity: all or nothing
try:
    cursor.execute("BEGIN TRANSACTION")
    cursor.execute("INSERT INTO accounts (id, balance) VALUES (1, 100)")
    cursor.execute("INSERT INTO accounts (id, balance) VALUES (2, 200)")
    
    # Simulate error
    raise Exception("Simulated error")
    
    cursor.execute("COMMIT")
except:
    cursor.execute("ROLLBACK")

# Verify rollback worked
cursor.execute("SELECT COUNT(*) FROM accounts WHERE id IN (1, 2)")
count = cursor.fetchone()[0]

if count != 0:
    print("FAIL: Atomicity violated (partial commit)")
    exit(1)

print("PASS: Atomicity maintained")

# Test Consistency: constraints enforced
try:
    cursor.execute("INSERT INTO accounts (id, balance) VALUES (3, -100)")
    print("FAIL: Consistency violated (negative balance allowed)")
    exit(1)
except sqlite3.IntegrityError:
    print("PASS: Consistency maintained (constraints enforced)")

# Test Isolation: concurrent transactions don't interfere
cursor.execute("BEGIN TRANSACTION")
cursor.execute("UPDATE accounts SET balance = balance + 50 WHERE id = 1")

# Start another connection
conn2 = sqlite3.connect('database.db', isolation_level=None)
cursor2 = conn2.cursor()
cursor2.execute("SELECT balance FROM accounts WHERE id = 1")
balance = cursor2.fetchone()[0]

# Should see original balance (isolation)
if balance != 100:
    print(f"FAIL: Isolation violated (saw balance {balance})")
    exit(1)

cursor.execute("COMMIT")
conn2.close()
print("PASS: Isolation maintained")

# Test Durability: committed data survives restart
cursor.execute("INSERT INTO accounts (id, balance) VALUES (4, 400)")
cursor.execute("COMMIT")

conn.close()

# Reopen connection
conn = sqlite3.connect('database.db')
cursor = conn.cursor()
cursor.execute("SELECT balance FROM accounts WHERE id = 4")
balance = cursor.fetchone()[0]

if balance != 400:
    print("FAIL: Durability violated (data lost after reconnect)")
    exit(1)

print("PASS: Durability maintained")
conn.close()
EOF
```

**Gate:** If ACID violated → Environment blocker gate (stop, fix transaction handling)

## Verification Report Format

```markdown
### State Consistency

- ✅ State machine: all transitions valid
- ✅ Race conditions: no concurrent access issues
- ✅ Idempotency: repeated operations produce same result
- ✅ State recovery: system recovers from failures without data loss
- ✅ Consistency: ACID properties maintained (or eventual consistency documented)
```

## Pitfalls

1. **Don't assume state machines are obvious.** Explicitly define valid transitions. Ambiguity leads to invalid states.

2. **Don't ignore race conditions.** They're hard to reproduce but critical in production. Use stress tests with concurrent access.

3. **Don't skip idempotency testing.** Network retries, duplicate requests, and message redelivery are common. Operations must be idempotent.

4. **Don't assume persistence works.** Test state recovery by killing and restarting the process. Verify no data loss.

5. **Don't over-promise consistency.** If you can't guarantee ACID, document the consistency model (eventual, causal, etc.).

## Integration with Other Strategies

State Consistency works best with:
- **Hallucination Guard:** Verify state logs are real, not fabricated
- **Security Scan:** Check for race condition vulnerabilities
- **Standard Verification:** Run unit tests, check git diff

## When to Escalate

Escalate to the user when:
- Invalid state transitions found
- Race conditions detected
- Data loss after failure
- ACID properties violated
- Idempotency broken

Do not escalate when:
- State machine has many valid transitions (complex but not broken)
- Minor timing variations (expected in async systems)
- Eventual consistency documented (not a bug)

## Tools Required

- `sqlite3`: Database testing
- `requests`: API testing
- `threading`: Concurrency testing

No additional installation needed (Python stdlib).
