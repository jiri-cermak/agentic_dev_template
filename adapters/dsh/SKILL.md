---
name: dsh-architect
description: Architect orchestrator for Tiered Relay Architecture v6.1 on DeepSeek Harness
version: 6.1.0
license: MIT
---

# DSH Architect Skill

## Trigger

Use this skill when:
- Acting as the Architect in a project bootstrapped from agentic_dev_template v6.1
- Before any delegation
- When classifying requirement tiers
- When constructing relay contexts

## Load Core Files

Before delegating, read these files (absolute paths):

1. `<project>/SOUL.md` — Architect identity and boundaries
2. `<project>/CORE_PROTOCOL.md` — Orchestration rules (v6.1)
3. `<project>/.agents.md` — Project adapter (dotfile, invisible to subagents)

The dotfile convention prevents DSH from auto-injecting project context. The relay
context is the subagent's sole source of rules.

## Obligations

### Before delegation:

1. **Verify location:**
   ```bash
   cd <project> && pwd && git rev-parse --show-toplevel
   ```

2. **Stash state files** (pre-delegation stash):
   ```bash
   git add .internal_master_plan.md retry_context.json 2>/dev/null || true
   git commit -m "chore: update state files before delegation" --allow-empty
   ```

3. **Classify requirement tier:**
   - Loose → Minimal (expect 2-3 iterations)
   - Medium → Standard (expect 1-2 iterations)
   - Tight + ≥3 relays → Full
   - Tight + <3 relays → Standard

4. **Construct relay context** with tier-appropriate fields:
   - All tiers: task_id, task_description, target_files, testing_methodology, handover_file
   - Standard: + constraints, shape_contract, surprises_checklist
   - Full: + shared_resource_contract, stop_conditions, pre_flight_command

### Gate matrix (apply top-down, first match wins):

1. **Fabrication** (highest): Claimed evidence contradicts workspace → escalate immediately
2. **Stagnation**: Same error recurs → stop, record signature, escalate
3. **Environment blocker**: Missing capability → stop, don't burn retries
4. **Spec drift**: Test/path wrong → revise relay, retry
5. **Execution error**: Agent didn't follow spec → retry with correction (2 consecutive → escalate)
6. **Contract failure**: Handover incomplete → metadata-only retry
7. **Validation cleared** (lowest): Evidence matches → mark complete

**Max 3 attempts per task ID.** Repeated error signature is a hard stop.

### After delegation:

1. **Wait for completion message** (subagent runs async)
2. **Verify all files** in handover's Files Changed table:
   ```bash
   wc -c <file>    # Size must match
   head -1 <file>  # First line must match
   ```
3. **Confirm agent's commit is latest:**
   ```bash
   git log -1
   ```
4. **Independently re-run declared tests**
5. **Apply gate matrix**
6. **Post-mortem:**
   - Classify learnings (core/adapter/project-specific/historical)
   - Persist to dsh-auto-memory (working/episodic/persona tiers)
   - Iterate if needed (Minimal: Probe → Discover → Refine → Implement)
7. **Verify clean state:**
   ```bash
   git status  # Should be clean
   ```

## Delegation in DSH

Invoke the subagent tool:

```
Tool: subagent
prompt: <filled relay context>
provider: spawn-in-process (default)
```

Optional:
- `persona`: minimal (let relay context be sole rule source)
- `toolFilter`: restrict to adapter's allowed tools
- `outputSchema`: machine-checkable summary format

## Capability needs

Declare in relay context:

```
capability_needs:
  - capability: live_steering
    available: false  # DSH does not provide; workaround: kill + re-spawn
  - capability: cross_session_memory
    available: true   # dsh-auto-memory
  - capability: gateway_notification
    available: false  # DSH does not provide; workaround: dsh-routines digest
  - capability: compression_safety
    available: false  # DSH does not provide; workaround: write to dsh-auto-memory
```

## Error handling

If subagent tool itself errors (fails to start):
1. Retry once
2. If fails again → escalate to user
3. Do NOT silently continue

## References

- CORE_PROTOCOL.md — full orchestration rules
- SOUL.md — Architect identity
- .agents.md — project adapter
- /opt/data/plans/dsh-core-plugin-list.md — recommended plugins
