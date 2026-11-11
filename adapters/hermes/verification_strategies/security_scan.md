# Security Scan Verification Strategy

## Focus
Security vulnerabilities: dependency CVEs, code injection, authentication flaws, secrets management, input validation.

## Trigger
Use when: All projects (especially user-facing, authentication, data handling, API endpoints).

## Checks

### 1. Dependency Vulnerabilities (Known CVEs)
**What to check:** Dependencies should not have known security vulnerabilities.

**How to verify:**
```bash
# For Python projects
pip-audit 2>&1 | tee pip_audit.log

python3 << 'EOF'
with open('pip_audit.log') as f:
    content = f.read()

# Check for vulnerabilities
if 'No known vulnerabilities' in content:
    print("PASS: No known vulnerabilities in Python dependencies")
elif 'CRITICAL' in content or 'HIGH' in content:
    print("FAIL: Critical or high severity vulnerabilities found")
    print(content)
    exit(1)
else:
    print("WARNING: Low or medium severity vulnerabilities found")
    print(content)
EOF

# For Node.js projects
npm audit 2>&1 | tee npm_audit.log

python3 << 'EOF'
import json

try:
    with open('npm_audit.log') as f:
        # npm audit outputs JSON with --json flag
        # For plain text, just check for vulnerability count
        content = f.read()
        
    if 'found 0 vulnerabilities' in content:
        print("PASS: No known vulnerabilities in Node.js dependencies")
    elif 'high severity' in content.lower() or 'critical severity' in content.lower():
        print("FAIL: High or critical severity vulnerabilities found")
        print(content)
        exit(1)
    else:
        print("WARNING: Low or moderate severity vulnerabilities found")
        print(content)
except FileNotFoundError:
    print("INFO: npm audit not available (not a Node.js project)")
EOF
```

**Gate:** If critical/high CVE found → Environment blocker gate (stop, update dependencies)

### 2. Code Injection Risks
**What to check:** No SQL injection, XSS, command injection, or path traversal vulnerabilities.

**How to verify:**
```bash
# Check for SQL injection patterns
grep -r "execute.*%s\|execute.*format\|execute.*+" --include="*.py" src/ > sql_injection.log 2>&1

python3 << 'EOF'
with open('sql_injection.log') as f:
    lines = f.readlines()

if lines:
    print("FAIL: Potential SQL injection found")
    for line in lines:
        print(f"  {line.strip()}")
    exit(1)

print("PASS: No SQL injection patterns found")
EOF

# Check for XSS patterns (web apps)
grep -r "innerHTML\|document.write\|eval(" --include="*.js" --include="*.html" src/ > xss.log 2>&1

python3 << 'EOF'
with open('xss.log') as f:
    lines = f.readlines()

if lines:
    print("WARNING: Potential XSS patterns found")
    for line in lines:
        print(f"  {line.strip()}")
    # Not a hard fail, but flag for review
else:
    print("PASS: No XSS patterns found")
EOF

# Check for command injection patterns
grep -r "os.system\|subprocess.call.*shell=True\|subprocess.Popen.*shell=True" --include="*.py" src/ > cmd_injection.log 2>&1

python3 << 'EOF'
with open('cmd_injection.log') as f:
    lines = f.readlines()

if lines:
    print("FAIL: Potential command injection found")
    for line in lines:
        print(f"  {line.strip()}")
    exit(1)

print("PASS: No command injection patterns found")
EOF

# Check for path traversal patterns
grep -r "\.\./" --include="*.py" --include="*.js" src/ > path_traversal.log 2>&1

python3 << 'EOF'
with open('path_traversal.log') as f:
    lines = f.readlines()

if lines:
    print("WARNING: Potential path traversal patterns found")
    for line in lines:
        print(f"  {line.strip()}")
    # Not a hard fail, but flag for review
else:
    print("PASS: No path traversal patterns found")
EOF
```

**Gate:** If SQL injection or command injection found → Fabrication gate (stop, fix immediately)

### 3. Authentication/Authorization Flaws
**What to check:** Authentication should be properly implemented, authorization should be enforced.

**How to verify:**
```bash
# Check for hardcoded credentials
grep -r "password.*=.*['\"].*['\"]" --include="*.py" --include="*.js" src/ > hardcoded_creds.log 2>&1

python3 << 'EOF'
with open('hardcoded_creds.log') as f:
    lines = f.readlines()

if lines:
    print("FAIL: Hardcoded credentials found")
    for line in lines:
        print(f"  {line.strip()}")
    exit(1)

print("PASS: No hardcoded credentials found")
EOF

# Check for missing authentication on endpoints
grep -r "@app.route\|@router\|@api_view" --include="*.py" src/ > endpoints.log 2>&1

python3 << 'EOF'
with open('endpoints.log') as f:
    content = f.read()

# Check that endpoints have authentication decorators
import re

endpoints = re.findall(r'@(app\.route|router|api_view).*', content)
auth_decorators = re.findall(r'@login_required|@requires_auth|@auth', content)

print(f"Found {len(endpoints)} endpoints")
print(f"Found {len(auth_decorators)} authentication decorators")

# This is a heuristic, not a hard check
if len(auth_decorators) == 0 and len(endpoints) > 0:
    print("WARNING: Endpoints found but no authentication decorators")
    print("  Review endpoints manually to ensure proper authentication")
else:
    print("PASS: Authentication decorators present")
EOF

# Check for proper password hashing
grep -r "hashlib.md5\|hashlib.sha1\|plaintext" --include="*.py" src/ > weak_hashing.log 2>&1

python3 << 'EOF'
with open('weak_hashing.log') as f:
    lines = f.readlines()

if lines:
    print("FAIL: Weak password hashing found")
    for line in lines:
        print(f"  {line.strip()}")
    exit(1)

print("PASS: No weak password hashing found")
EOF

# Check for proper session management
grep -r "session.permanent.*=.*True\|session\[.*\].*=.*" --include="*.py" src/ > session.log 2>&1

python3 << 'EOF'
with open('session.log') as f:
    lines = f.readlines()

if lines:
    print("INFO: Session management patterns found")
    print("  Review manually to ensure proper session security")
else:
    print("INFO: No session management patterns found")
EOF
```

**Gate:** If hardcoded credentials or weak hashing found → Environment blocker gate (stop, fix immediately)

### 4. Secrets Management
**What to check:** No hardcoded secrets, API keys, or tokens in code.

**How to verify:**
```bash
# Check for API keys
grep -r "api_key.*=.*['\"].*[a-zA-Z0-9]\{20,\}['\"]" --include="*.py" --include="*.js" src/ > api_keys.log 2>&1

python3 << 'EOF'
with open('api_keys.log') as f:
    lines = f.readlines()

if lines:
    print("FAIL: Hardcoded API keys found")
    for line in lines:
        print(f"  {line.strip()}")
    exit(1)

print("PASS: No hardcoded API keys found")
EOF

# Check for tokens
grep -r "token.*=.*['\"].*[a-zA-Z0-9]\{20,\}['\"]" --include="*.py" --include="*.js" src/ > tokens.log 2>&1

python3 << 'EOF'
with open('tokens.log') as f:
    lines = f.readlines()

if lines:
    print("FAIL: Hardcoded tokens found")
    for line in lines:
        print(f"  {line.strip()}")
    exit(1)

print("PASS: No hardcoded tokens found")
EOF

# Check for environment variable usage (good practice)
grep -r "os.environ\|process.env" --include="*.py" --include="*.js" src/ > env_vars.log 2>&1

python3 << 'EOF'
with open('env_vars.log') as f:
    lines = f.readlines()

if lines:
    print("PASS: Environment variables used for configuration")
    print(f"  Found {len(lines)} environment variable usages")
else:
    print("WARNING: No environment variable usage found")
    print("  Consider using environment variables for sensitive configuration")
EOF

# Check .gitignore for sensitive files
if [ -f .gitignore ]; then
  grep -q "\.env\|secrets\|credentials" .gitignore && \
    echo "PASS: .gitignore excludes sensitive files" || \
    echo "WARNING: .gitignore may not exclude sensitive files"
else
  echo "WARNING: No .gitignore found"
fi
```

**Gate:** If hardcoded secrets found → Fabrication gate (stop, remove secrets immediately)

### 5. Input Validation
**What to check:** All user inputs should be validated and sanitized.

**How to verify:**
```bash
# Check for input validation patterns
grep -r "request.form\|request.json\|request.args" --include="*.py" src/ > inputs.log 2>&1

python3 << 'EOF'
with open('inputs.log') as f:
    lines = f.readlines()

if not lines:
    print("INFO: No input handling found (may not be a web app)")
    exit(0)

print(f"Found {len(lines)} input handling locations")

# Check for validation
validation_patterns = [
    'validate', 'sanitize', 'clean', 'check', 'verify',
    'is_valid', 'isinstance', 'try:', 'except', 'ValueError', 'TypeError'
]

validated = 0
for line in lines:
    with open(line.split(':')[0]) as f:
        content = f.read()
        if any(pattern in content for pattern in validation_patterns):
            validated += 1

print(f"Found {validated} locations with validation")

if validated == 0:
    print("WARNING: No input validation found")
    print("  Review input handling manually to ensure proper validation")
elif validated < len(lines):
    print("WARNING: Some inputs may not be validated")
    print(f"  {len(lines) - validated} locations without obvious validation")
else:
    print("PASS: All inputs appear to be validated")
EOF

# Check for type conversion (common source of bugs)
grep -r "int(\|float(\|str(" --include="*.py" src/ > type_conversion.log 2>&1

python3 << 'EOF'
with open('type_conversion.log') as f:
    lines = f.readlines()

if lines:
    print("INFO: Type conversion found")
    print("  Ensure type conversions are wrapped in try/except blocks")
else:
    print("INFO: No explicit type conversion found")
EOF
```

**Gate:** No automatic gate, but flag for review if no validation found.

## Verification Report Format

```markdown
### Security Scan

- ✅ Dependencies: no known CVEs (pip-audit: 0 vulnerabilities)
- ✅ Code injection: no SQL injection, XSS, or command injection patterns
- ✅ Authentication: properly implemented, no hardcoded credentials
- ✅ Secrets: no hardcoded API keys or tokens, environment variables used
- ✅ Input validation: all user inputs validated and sanitized
```

## Pitfalls

1. **Don't rely on grep alone.** Grep can miss obfuscated code or complex patterns. Use it as a first pass, then review manually.

2. **Don't ignore warnings.** "WARNING" in this strategy often means "review manually." Take the time to review.

3. **Don't skip dependency audits.** Dependencies are a common attack vector. Run `pip-audit` and `npm audit` regularly.

4. **Don't assume authentication is correct.** Just because you see `@login_required` doesn't mean it's implemented correctly. Review the implementation.

5. **Don't forget environment-specific secrets.** Check `.env` files, config files, and deployment scripts for hardcoded secrets.

## Integration with Other Strategies

Security Scan works best with:
- **Hallucination Guard:** Verify security scan results are real, not fabricated
- **Visual Regression:** Check for XSS in dynamic content
- **Standard Verification:** Run unit tests, check git diff

## When to Escalate

Escalate to the user when:
- Critical or high severity CVE found
- SQL injection or command injection found
- Hardcoded credentials or secrets found
- Weak password hashing found

Do not escalate when:
- Low or medium severity CVE found (flag for future fix)
- XSS or path traversal patterns found (review manually)
- No input validation found (flag for review)

## Tools Required

- `pip-audit`: Python dependency vulnerability scanner
- `npm`: Node.js package manager (for `npm audit`)
- `grep`: Pattern matching

Install:
```bash
pip install pip-audit
```
