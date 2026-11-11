# Security Scan Verification Strategy

## Purpose
Comprehensive security scanning to identify vulnerabilities in code, dependencies, and configuration.

## When to Use
- Before deploying to production
- After adding new dependencies
- When security is a concern
- As part of CI/CD pipeline

## What to Check

### 1. Dependency Vulnerabilities
**Check for known CVEs in dependencies:**

```bash
# Python
pip-audit

# Node.js
npm audit

# Go
govulncheck ./...
```

**Gate:** 
- Critical/High severity → FAIL
- Medium severity → WARNING
- Low severity → INFO

### 2. Code Security Issues
**Check for common security vulnerabilities:**

```bash
# Python (bandit)
bandit -r src/

# JavaScript (eslint with security plugin)
npx eslint --plugin security src/

# General patterns
grep -r "password\s*=" src/  # Hardcoded passwords
grep -r "eval(" src/          # Dangerous eval usage
grep -r "exec(" src/          # Command injection risk
```

**Common issues to check:**
- SQL injection
- XSS (Cross-Site Scripting)
- Command injection
- Path traversal
- Insecure deserialization
- Hardcoded credentials
- Insecure randomness
- Missing input validation

**Gate:**
- Critical issues → FAIL
- Warnings → WARNING
- Info → INFO

### 3. Configuration Security
**Check for insecure configuration:**

```bash
# Check for debug mode in production
grep -r "DEBUG\s*=\s*True" config/

# Check for permissive CORS
grep -r "Access-Control-Allow-Origin: \*" config/

# Check for weak cryptography
grep -r "md5\|sha1" src/  # Weak hashing
```

**Gate:**
- Production debug mode → FAIL
- Permissive CORS → WARNING
- Weak crypto → WARNING

### 4. Authentication & Authorization
**Check for proper auth implementation:**

```bash
# Check for proper password hashing
grep -r "bcrypt\|argon2\|pbkdf2" src/

# Check for proper session management
grep -r "session\|cookie" src/

# Check for proper authorization
grep -r "permission\|role\|auth" src/
```

**Gate:**
- Missing password hashing → FAIL
- Missing authorization → FAIL
- Insecure session management → WARNING

## Verification Process

1. **Run dependency scan**
   - Identify vulnerable dependencies
   - Check severity levels
   - Document findings

2. **Run code scan**
   - Use static analysis tools
   - Check for common patterns
   - Review findings manually

3. **Check configuration**
   - Review config files
   - Check for insecure defaults
   - Verify production settings

4. **Review auth implementation**
   - Check password handling
   - Verify session management
   - Review authorization logic

5. **Generate report**
   - List all findings
   - Categorize by severity
   - Provide remediation steps

## Output Format

```markdown
# Security Scan Report

## Summary
- Dependencies scanned: {count}
- Files scanned: {count}
- Critical issues: {count}
- Warnings: {count}
- Info: {count}

## Dependency Vulnerabilities
### {package_name} {version}
- **CVE:** {cve_id}
- **Severity:** {severity}
- **Description:** {description}
- **Remediation:** Upgrade to {version}

## Code Security Issues
### {issue_type}
- **File:** {file_path}
- **Line:** {line_number}
- **Severity:** {severity}
- **Description:** {description}
- **Remediation:** {recommendation}

## Configuration Issues
...

## Overall Assessment
{security_posture_assessment}

## Recommendations
1. {priority_1}
2. {priority_2}
3. {priority_3}
```

## Integration

This strategy integrates with:
- `code-review` skill for deeper analysis
- `supervised` orchestration mode for guided remediation
- `iterative` protocol mode for progressive fixes

## Configuration

Configurable via `plugin.yaml`:
- `scan_dependencies`: Enable dependency scanning (default: true)
- `scan_code`: Enable code scanning (default: true)
- `scan_configuration`: Enable config scanning (default: true)
- `severity_threshold`: Minimum severity to report (default: medium)
- `ignore_dev_dependencies`: Ignore dev dependencies (default: false)

## Best Practices

1. **Run regularly**: Security scanning should be part of CI/CD
2. **Fix critical issues first**: Prioritize by severity
3. **Keep dependencies updated**: Regular updates reduce vulnerabilities
4. **Use multiple tools**: Different tools catch different issues
5. **Manual review**: Automated tools miss context-specific issues
