# SQL Migration Verification Strategy

## Focus
Database migration safety for reservation systems, data model changes, schema evolution.

## Trigger
Use when: Reservation systems, database schema changes, data migrations, model updates.

## Checks

### 1. Migration Script Validation
**What to check:** Migration script should be syntactically correct and have rollback capability.

**How to verify:**
```bash
# Check migration script syntax
python3 << 'EOF'
import sqlparse

with open('migration.sql') as f:
    sql = f.read()

try:
    parsed = sqlparse.parse(sql)
    if not parsed:
        print("FAIL: No valid SQL statements found")
        exit(1)
    
    # Check for required components
    has_create = any('CREATE TABLE' in str(stmt).upper() for stmt in parsed)
    has_alter = any('ALTER TABLE' in str(stmt).upper() for stmt in parsed)
    has_drop = any('DROP TABLE' in str(stmt).upper() for stmt in parsed)
    
    # Migration should have at least one of these
    if not (has_create or has_alter or has_drop):
        print("FAIL: Migration has no schema changes")
        exit(1)
    
    print("PASS: Migration script is syntactically valid")
except Exception as e:
    print(f"FAIL: SQL syntax error: {e}")
    exit(1)
EOF

# Check for rollback script
if [ ! -f "rollback.sql" ]; then
  echo "FAIL: No rollback script found"
  exit 1
fi

echo "PASS: Rollback script exists"
```

**Gate:** If syntax error or no rollback → Environment blocker gate (stop, fix first)

### 2. Data Integrity Checks
**What to check:** Row counts, foreign keys, constraints should be maintained.

**How to verify:**
```bash
# Count rows before migration
python3 << 'EOF'
import sqlite3
import json

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# Get all tables
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = [row[0] for row in cursor.fetchall()]

# Count rows in each table
counts_before = {}
for table in tables:
    cursor.execute(f"SELECT COUNT(*) FROM {table}")
    counts_before[table] = cursor.fetchone()[0]

# Save counts
with open('counts_before.json', 'w') as f:
    json.dump(counts_before, f)

print(f"Counted {len(tables)} tables before migration")
conn.close()
EOF

# Apply migration
sqlite3 database.db < migration.sql

# Count rows after migration
python3 << 'EOF'
import sqlite3
import json

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# Get counts after
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = [row[0] for row in cursor.fetchall()]

counts_after = {}
for table in tables:
    cursor.execute(f"SELECT COUNT(*) FROM {table}")
    counts_after[table] = cursor.fetchone()[0]

# Load counts before
with open('counts_before.json') as f:
    counts_before = json.load(f)

# Compare
print("Row count changes:")
for table in set(counts_before.keys()) | set(counts_after.keys()):
    before = counts_before.get(table, 0)
    after = counts_after.get(table, 0)
    diff = after - before
    
    if diff != 0:
        print(f"  {table}: {before} → {after} ({diff:+d})")
    
    # Check for data loss (rows deleted unexpectedly)
    if diff < -10:
        print(f"FAIL: Significant data loss in {table}")
        exit(1)

print("PASS: Data integrity maintained")
conn.close()
EOF

# Check foreign key constraints
python3 << 'EOF'
import sqlite3

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# Enable foreign key checking
cursor.execute("PRAGMA foreign_key_check")
violations = cursor.fetchall()

if violations:
    print(f"FAIL: {len(violations)} foreign key violations found")
    for v in violations:
        print(f"  {v}")
    exit(1)

print("PASS: No foreign key violations")
conn.close()
EOF
```

**Gate:** If data loss or FK violations → Environment blocker gate (stop, rollback)

### 3. Performance Impact Analysis
**What to check:** Migration should not significantly degrade query performance.

**How to verify:**
```bash
# Capture query plans before migration
python3 << 'EOF'
import sqlite3
import json

queries = [
    "SELECT * FROM reservations WHERE user_id = 1",
    "SELECT * FROM rooms WHERE available = 1",
    "SELECT COUNT(*) FROM reservations WHERE date > '2025-01-01'"
]

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

plans_before = {}
for query in queries:
    cursor.execute(f"EXPLAIN QUERY PLAN {query}")
    plans_before[query] = cursor.fetchall()

with open('plans_before.json', 'w') as f:
    json.dump(plans_before, f, indent=2)

conn.close()
print(f"Captured {len(queries)} query plans before migration")
EOF

# Apply migration
sqlite3 database.db < migration.sql

# Capture query plans after migration
python3 << 'EOF'
import sqlite3
import json

queries = [
    "SELECT * FROM reservations WHERE user_id = 1",
    "SELECT * FROM rooms WHERE available = 1",
    "SELECT COUNT(*) FROM reservations WHERE date > '2025-01-01'"
]

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

plans_after = {}
for query in queries:
    cursor.execute(f"EXPLAIN QUERY PLAN {query}")
    plans_after[query] = cursor.fetchall()

# Load plans before
with open('plans_before.json') as f:
    plans_before = json.load(f)

# Compare
print("Query plan changes:")
for query in queries:
    before = plans_before[query]
    after = plans_after[query]
    
    # Check for full table scans (performance regression)
    before_has_scan = any('SCAN TABLE' in str(plan) for plan in before)
    after_has_scan = any('SCAN TABLE' in str(plan) for plan in after)
    
    if not before_has_scan and after_has_scan:
        print(f"FAIL: Query now uses full table scan: {query}")
        exit(1)
    
    if before != after:
        print(f"  Query plan changed: {query[:50]}...")

print("PASS: No performance regressions detected")
conn.close()
EOF

# Check index usage
python3 << 'EOF'
import sqlite3

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# List indexes
cursor.execute("SELECT name, tbl_name FROM sqlite_master WHERE type='index'")
indexes = cursor.fetchall()

print(f"Database has {len(indexes)} indexes")

# Check for missing indexes on foreign keys
cursor.execute("PRAGMA table_info(reservations)")
columns = cursor.fetchall()

fk_columns = [col[1] for col in columns if 'id' in col[1].lower()]
print(f"Foreign key columns: {fk_columns}")

for col in fk_columns:
    cursor.execute(f"SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='reservations' AND sql LIKE '%{col}%'")
    if not cursor.fetchone():
        print(f"WARNING: No index on reservations.{col}")

conn.close()
EOF
```

**Gate:** If full table scan introduced → Contract failure gate (add index, retry)

### 4. Backward Compatibility
**What to check:** Old clients should still work after migration.

**How to verify:**
```bash
# Test old API queries still work
python3 << 'EOF'
import sqlite3

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# Old API queries (from v1 API)
old_queries = [
    "SELECT * FROM reservations",
    "SELECT * FROM users WHERE id = 1",
    "SELECT * FROM rooms"
]

for query in old_queries:
    try:
        cursor.execute(query)
        results = cursor.fetchall()
        print(f"PASS: Old query works: {query[:50]}...")
    except Exception as e:
        print(f"FAIL: Old query broken: {query}")
        print(f"  Error: {e}")
        exit(1)

conn.close()
EOF
```

**Gate:** If old queries broken → Contract failure gate (maintain backward compat, retry)

### 5. Rollback Testing
**What to check:** Rollback script should actually work and restore previous state.

**How to verify:**
```bash
# Create backup
cp database.db database_backup.db

# Apply migration
sqlite3 database.db < migration.sql

# Verify migration applied
python3 << 'EOF'
import sqlite3

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# Check new schema elements exist
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='new_table'")
if not cursor.fetchone():
    print("FAIL: Migration not applied")
    exit(1)

print("PASS: Migration applied")
conn.close()
EOF

# Apply rollback
sqlite3 database.db < rollback.sql

# Verify rollback worked
python3 << 'EOF'
import sqlite3

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# Check new schema elements are gone
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='new_table'")
if cursor.fetchone():
    print("FAIL: Rollback did not remove new_table")
    exit(1)

print("PASS: Rollback successful")
conn.close()
EOF

# Restore backup for further testing
cp database_backup.db database.db
```

**Gate:** If rollback fails → Environment blocker gate (stop, fix rollback script)

## Verification Report Format

```markdown
### SQL Migration

- ✅ Migration script: syntactically valid, rollback script exists
- ✅ Data integrity: row counts maintained, no FK violations
- ✅ Performance: no full table scans introduced, indexes present
- ✅ Backward compatibility: old API queries still work
- ✅ Rollback: tested and successful
```

## Pitfalls

1. **Don't skip rollback testing.** Always test the rollback script. A migration without a working rollback is a liability.

2. **Don't ignore data loss.** If row counts drop significantly, investigate. Data loss is usually a bug.

3. **Don't forget indexes.** Foreign keys should have indexes. Missing indexes cause performance regressions.

4. **Don't break backward compatibility.** If old clients depend on the schema, maintain compatibility or version the API.

5. **Don't apply migrations without backup.** Always backup the database before applying migrations.

## Integration with Other Strategies

SQL Migration works best with:
- **Hallucination Guard:** Verify migration scripts are real, not fabricated
- **Security Scan:** Check for SQL injection vulnerabilities
- **Standard Verification:** Run unit tests, check git diff

## When to Escalate

Escalate to the user when:
- Migration has no rollback script
- Data loss > 10 rows
- Foreign key violations found
- Rollback script fails
- Old API queries broken

Do not escalate when:
- Minor row count changes (expected for new tables)
- Query plan changes (as long as no full table scans)
- Missing indexes (flag as warning, not blocker)

## Tools Required

- `sqlite3`: Database CLI
- `sqlparse` (Python): SQL parsing and validation

Install:
```bash
pip install sqlparse
```
