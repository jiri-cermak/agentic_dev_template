# CORE_PROTOCOL_hermes_overlay.md

Hermes-specific extensions to `CORE_PROTOCOL.md`. This file extends but never contradicts the agnostic core.

---

## §1. Lite relay defaults (extends Core Protocol §Requirement tiers)

For Hermes users, lite relay (Minimal tier) is the default for trivial tasks. Criteria:
- Touches ≤2 files
- No new dependencies
- Test coverage exists
- Reversible (no schema migrations, no state changes)

Lite handover format (2 headings instead of 5):

```markdown
## Summary
[1-2 sentences: what was done]

## Diff
[git diff summary or file list]
```

Gate for lite: fabrication, contract, cleared only (skip stagnation, environment, spec drift, execution).

---

## §2. Failure escalation with gateway notification (extends Core Protocol §Gate matrix)

After 3 fails on a task ID, Architect escalates:

1. Write `handovers/<task-id>/failure_postmortem.md`:
   - Root-cause hypothesis
   - Diff of what was tried (each attempt)
   - Concrete blocker question
   - Suggested next action

2. Architect reviews and chooses:
   - (a) Rewrite relay context → retry (counter resets)
   - (b) Escalate to human via gateway notification
   - (c) Mark task as blocked → continue with next task

3. If gateway configured, send notification:
   ```
   ⚠️ Task {TASK_ID} failed after 3 attempts.
   Failure postmortem: handovers/{TASK_ID}/failure_postmortem.md
   Blocker: {one-line summary}
   Suggested: {action}
   ```

Use `delegate_task(action='list')` to check subagent status. If stuck, use `action='steer'` to redirect or `action='stop'` to kill and restart.

---

## §3. Mnemosyne integration (Hermes-specific, no agnostic equivalent)

Learnings are persisted to Mnemosyne (not just `learnings/` files):

- **Working memory:** ephemeral context for current session (task state, temp facts)
- **Episodic memory:** patterns across sessions ("X failed 3 times because Y")
- **Persona memory:** stable facts about the project ("this codebase uses pytest")

**Post-mortem protocol:**

```python
# After each relay, persist critical learnings
memory(action='add', target='working', content='STEP-01: auth module uses bcrypt, salt rounds=12')
memory(action='add', target='episodic', content='Pattern: Django migrations fail when model has unapplied FK changes')
memory(action='add', target='persona', content='Project uses pytest with xdist, test dir is tests/')
```

This persists across sessions automatically. No manual pruning needed (Mnemosyne handles consolidation).

**Pre-delegation recall:**

```python
# Before constructing relay, recall relevant memories
memory_recall(query="auth module patterns")
```

This replaces manual note-taking in `learnings/` for cross-session facts.

---

## §4. Gateway notification triggers (Hermes-specific)

If gateway is configured (TG/Discord/Slack/WA/Signal), Architect notifies on:

- **Critical failure** (escalation to human after 3 retries)
- **Task completion** (if user opted in via `.agents.md`)
- **Overnight watch alerts** (cron job triggers)
- **Memory consolidation complete** (if user opted in)

**Notification format:**

```
✅ Task {TASK_ID} completed.
Files changed: {count}
Tests passed: {count}
Handover: handovers/done/completion-{TASK_ID}.md
```

```
⚠️ Task {TASK_ID} failed after 3 attempts.
Blocker: {one-line summary}
Postmortem: handovers/{TASK_ID}/failure_postmortem.md
```

---

## §5. Profile isolation (Hermes-specific)

Use separate Hermes profiles for separate projects/clients:

```bash
hermes profile switch nuad    # work on nuad
hermes profile switch baan    # work on baan
```

Each profile has its own:
- `skills/` — project-specific skills
- `plugins/` — project-specific plugins
- `cron/` — project-specific cron jobs
- `memories/` — isolated Mnemosyne space

This prevents cross-contamination between projects.

---

## §6. Session search in post-mortem (Hermes-specific)

During step post-mortem, use `session_search` to recall past relays:

```python
session_search(query="auth module similar task", limit=3)
session_search(query="migration failed", limit=5)
```

Check if a similar task was attempted before. Learn from prior approaches (successes and failures). Don't re-discover.

This replaces manual note-taking in `learnings/` for transient context. Mnemosyne handles durable facts; session_search handles transient context.

---

## §7. Compression safety (Hermes-specific)

Hermes protects first-3 + last-4 turns during compression:
- SOUL.md + CORE_PROTOCOL.md (loaded at start) are protected
- Recent handovers (last few turns) are protected
- Middle context is summarized by auxiliary model

**For long sessions:** Write critical decisions to Mnemosyne (persona tier) to ensure they survive compression:

```python
memory(action='add', target='persona', content='Critical: auth module must use bcrypt, not md5')
```

This guarantees survival across compression boundaries.

---

## §8. Live subagent orchestration (Hermes-specific)

Unlike DSH, Hermes allows mid-flight control of subagents:

```python
# List running subagents
delegate_task(action='list')

# Steer a subagent mid-task (course-correct without killing)
delegate_task(action='steer', subagent_id='abc123', message='Stop editing file X, focus on file Y instead')

# Stop a subagent early (kill it)
delegate_task(action='stop', subagent_id='abc123')
```

**Use cases:**
- Subagent drifting off-task → steer it back
- Subagent stuck in loop → stop it and retry with revised context
- Multiple subagents running → monitor and coordinate

This is a significant advantage over DSH (which requires kill + re-spawn).

---

## §9. Subagent tool restriction (extends Core Protocol §Relay invariants)

Hermes names concrete denied tools. Every relay context MUST carry a `Tool restriction`
deny-list; the Architect enforces it by auditing the subagent's execution record.

**Always denied to subagents** (Architect-only verification tools):
- `mcp__opencode__tests` — the isolated test runner. Running the suite is the Architect's
  verification step, never the subagent's.
- `mcp__opencode__run_cli` — the VPS/container bridge. Container/daemon access is the
  Architect's (or human's) step, never the subagent's.

**Also denied for author-only (minimal/lite) relays:**
- `execute_code` — file edits use `patch`/`write_file`; there is no reason to run Python.

**Enforcement:** the Architect audits the subagent's session transcript for these tools —
a forbidden-tool invocation is a gate failure (contract category), never a warning. The
handover's "ran nothing" claim is not proof; the transcript is the ground truth.

**Known limit:** this deny-list is enforced by PROTOCOL + transcript audit, not by the
Hermes toolset resolver — `delegate_task` currently inherits the parent's full toolset
(see `delegate_tool_toolsets.py` `_resolve_child_toolsets`; a mechanical per-tier tool
restriction is an open upstream item).

## Integration with agnostic core

This overlay extends `CORE_PROTOCOL.md` but never contradicts it. The agnostic core defines:
- Orchestration lifecycle
- Evidence gates
- Retry rules
- Git safety
- Handover contract
- Learning lifecycle

This overlay adds:
- Lite relay defaults
- Gateway notifications
- Mnemosyne integration
- Profile isolation
- Session search
- Compression safety
- Live orchestration

If they conflict, the agnostic core wins. Stop and resolve the ambiguity before proceeding.
