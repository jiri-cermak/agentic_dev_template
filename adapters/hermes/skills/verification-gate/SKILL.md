---
name: verification-gate
version: 1.0.0
description: Independent verification for Tiered Relay Architecture on Hermes — audit handover, verify files, re-run tests, apply gate matrix with machine-checkable criteria.
triggers:
  - when: Architect performing independent verification after subagent completion
  - when: auditing a handover file
  - when: applying the gate matrix
  - when: verifying machine-checkable success criteria
---

# Verification Gate Skill (Hermes)

## Trigger

Use when: Architect performing independent verification after subagent completion.

## Obligations

1. **Read handover file** — verify all required sections present
2. **Verify all files** — for every file in Files Changed table:
   ```bash
   wc -c <file>    # Size must match
   head -1 <file>  # First line must match
   ```
3. **Confirm agent's commit** — `git log -1` shows agent's commit is latest
4. **Re-run tests** — execute testing_methodology verbatim, compare output to agent's claim
5. **Apply gate matrix** — fabrication → stagnation → environment → spec → execution → contract → cleared

## Gate matrix (apply top-down, first match wins)

| Precedence | Gate | Condition | Action |
|---|---|---|---|
| 1 (highest) | Fabrication | Claimed evidence contradicts workspace | Stop, escalate immediately |
| 2 | Stagnation | Same error recurs after correction | Stop, record signature, escalate |
| 3 | Environment blocker | Missing capability cannot be fixed in scope | Stop, don't burn retries |
| 4 | Spec drift | Test/path wrong because relay underspecified | Revise relay, retry |
| 5 | Execution error | Agent didn't follow spec | Retry with correction (2 consecutive → escalate) |
| 6 | Contract failure | Handover incomplete | Metadata-only retry |
| 7 (lowest) | Validation cleared | Evidence matches scope and contract | Mark complete |

**Max 3 attempts per task ID.** Repeated error signature is hard stop.

## Machine-verifiable success criteria

If relay context includes `success_criteria`, verify each:
- `test_id` — test must pass
- `diff_check` — file must contain string
- `exit_code` — command must exit with expected code

Gate passes only if ALL machine checks pass. Architect reads report, not raw output.

## Pitfalls

- Do NOT trust agent's self-report — independently verify
- Do NOT skip file verification — check size and first line for every file
- Do NOT proceed with dirty working tree — stash or commit first
- Do NOT accept summarized test output — demand raw paste
- Do NOT rubber-stamp — if something looks wrong, escalate
