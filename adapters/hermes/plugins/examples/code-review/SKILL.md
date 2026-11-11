---
name: code-review
version: 1.0.0
triggers:
  - when: user asks for code review
  - when: user says "review this code"
  - when: file is modified and user asks for review
---

# Code Review Skill

Comprehensive code review focusing on security, performance, and best practices.

## Steps

### 1. Analyze the Code
- Read the source file(s) to review
- Identify the programming language and framework
- Understand the code's purpose and context

### 2. Security Check
- Look for common security vulnerabilities:
  - SQL injection
  - XSS (Cross-Site Scripting)
  - Command injection
  - Path traversal
  - Insecure deserialization
  - Hardcoded credentials
  - Insecure randomness
- Check for proper input validation
- Verify authentication and authorization

### 3. Performance Check
- Identify performance bottlenecks:
  - N+1 queries
  - Inefficient loops
  - Unnecessary computations
  - Missing indexes
  - Memory leaks
- Check for proper caching
- Verify resource cleanup

### 4. Best Practices Check
- Code style and formatting
- Naming conventions
- Function/method length
- Comment quality
- Error handling
- Test coverage

### 5. Generate Report
Create a structured report with:
- Critical issues (must fix)
- Warnings (should fix)
- Informational notes (nice to have)
- Specific recommendations with code examples

## Output Format

```markdown
# Code Review Report

## Summary
- Files reviewed: {count}
- Critical issues: {count}
- Warnings: {count}
- Info: {count}

## Critical Issues
### Issue 1: {title}
- **File:** {file_path}
- **Line:** {line_number}
- **Description:** {description}
- **Recommendation:** {recommendation}
- **Example:**
  ```{language}
  // Bad
  {bad_code}
  
  // Good
  {good_code}
  ```

## Warnings
...

## Informational Notes
...

## Overall Assessment
{overall_quality_assessment}
```

## Integration

This skill integrates with:
- `security-scan` verification strategy for deeper security analysis
- `iterative` protocol mode for progressive improvement
- `supervised` orchestration mode for guided review

## Configuration

The skill can be configured via `plugin.yaml`:
- `strict_mode`: Enable stricter checks (default: false)
- `check_security`: Enable security checks (default: true)
- `check_performance`: Enable performance checks (default: true)
- `check_style`: Enable style checks (default: true)
- `output_format`: Report format (default: markdown)
