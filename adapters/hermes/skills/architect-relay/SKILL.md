---
name: architect-relay
version: 1.0.0
description: Architect orchestration for Tiered Relay Architecture on Hermes — plan, stash, pre-flight, delegate via delegate_task, verify, gate, post-mortem, stabilize.
triggers:
  - when: acting as the Architect in a Hermes Agent session
  - when: before any delegation
  - when: constructing a relay context
  - when: performing post-mortem and learning classification
---

# Architect Relay Skill (Hermes)

## Trigger

Use when: acting as the Architect in a Hermes Agent session, before any delegation.

## Load core files

Before delegating, read (in order):
1. `SOUL.md` — Hermes Architect identity
2. `CORE_PROTOCOL.md` — agnostic orchestration rules
3. `CORE_PROTOCOL_hermes_overlay.md` — Hermes extensions
4. `.agents.md` — project adapter

## Obligations

1. **Classify requirement tier** (Minimal/Standard/Full)
2. **Pre-delegation stash** — commit/stash state files
3. **Pre-flight** — verify location, clean working tree
4. **Construct relay context** — tier-appropriate fields
5. **Delegate** via `delegate_task` with filled relay context as `goal`
6. **Wait for completion** — do not read handover until subagent finishes
7. **Verify** — audit handover, verify all files, re-run tests
8. **Gate** — apply matrix (fabrication → stagnation → environment → spec → execution → contract → cleared)
9. **Post-mortem** — classify learnings, persist to Mnemosyne
10. **Stabilize** — clean working tree before next step

## Hermes-specific advantages (use them)

- **Live steering:** if subagent drifts, `delegate_task(action='steer', subagent_id='...', message='...')`
- **Memory recall:** before relay, `session_search(query='similar task')` to learn from past
- **Gateway notification:** on critical failures, notify user via configured channel
- **Profile isolation:** switch profiles for separate projects

## Anti-hallucination measures

- Raw output paste (Completion File Contract)
- Surprises checklist (agent must disclose deviations)
- Shape contracts (exact data shapes, not pseudocode)
- Negative tests (assert something should NOT happen)
- Files verification (Architect independently checks file size and first line)
- State-aware re-execution (confirm agent's commit before re-running tests)
- Pre-delegation stash (prevent state-file pollution)

Add measures only when you hit the corresponding failure. See CORE_PROTOCOL.md §Failure → Measure ROI.

## Pitfalls

- Do NOT accept summarized test output — demand raw paste
- Do NOT trust agent's self-report — independently re-run tests
- Do NOT proceed with dirty working tree — stash or commit first
- Do NOT skip verification — every file in handover must be checked
- Do NOT silently continue on delegation failure — retry once, then escalate
