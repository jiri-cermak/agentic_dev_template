# Migration from agentic_dev_template (Hermes users)

## Who should migrate?

**Migrate if:**
- You're using Hermes Agent (not DSH or another harness)
- You want to leverage Hermes-specific capabilities (Mnemosyne, live steering, gateway)
- You want lite relay for trivial tasks (saves tokens)
- You want structured failure escalation with gateway notifications

**Don't migrate if:**
- You're using DSH or another harness (stay with agentic_dev_template)
- You're happy with the current protocol
- You don't want Hermes-specific extensions

---

## Step-by-step migration

### Step 1: Clone both repos

```bash
git clone https://github.com/jiri-cermak/agentic_dev_template.git
git clone https://github.com/jiri-cermak/hermes_agentic_template.git
```

### Step 2: Bootstrap existing project with agnostic core (if not already done)

```bash
cd agentic_dev_template
./bootstrap.sh /path/to/existing/project
```

### Step 3: Layer hermes overlay

```bash
cd hermes_agentic_template
bash bootstrap_hermes.sh /path/to/existing/project
```

This:
- Replaces SOUL.md with hermes-specific version
- Adds CORE_PROTOCOL_hermes_overlay.md (extensions, not replacement)
- Copies _relay_context_hermes.md (hermes-specific template)
- Installs hermes skills into ~/.hermes/skills/
- Adds hermes-specific files to .gitignore

### Step 4: Update .agents.md

Your project's `.agents.md` stays in place. The hermes overlay reads it at runtime.
Optionally add Hermes-specific tool lists (see `.agents_hermes_template.md` for examples).

### Step 5: Verify with a smoke relay

Start a Hermes session with the standard opener:

```
Act as the Architect per SOUL.md. Read CORE_PROTOCOL.md and CORE_PROTOCOL_hermes_overlay.md
and the project's .agents.md before delegating. Classify the requirement tier
(Minimal/Standard/Full). Begin: plan → stash → pre-flight → relay → delegate → verify →
gate → post-mortem → stabilize.
```

Run a trivial relay (e.g., "add a README section"). Verify:
- Architect reads hermes SOUL.md (not agnostic SOUL.md)
- Relay context includes capability_needs
- Subagent uses delegate_task
- Handover follows contract

### Step 6: Migrate learnings (optional)

If you have existing `learnings/` from prior relays, review and promote critical
patterns to Mnemosyne:

```
memory(action='add', target='persona', content='<stable project fact>')
memory(action='add', target='episodic', content='<pattern across sessions>')
```

---

## What changes, what stays

| File | Before (agnostic) | After (hermes overlay) |
|---|---|---|
| SOUL.md | Model-neutral | Hermes-specific (Mnemosyne, gateway, profiles) |
| CORE_PROTOCOL.md | Unchanged | + _hermes_overlay.md (extensions) |
| _relay_context_template.md | Harness-neutral | + _hermes.md (delegate_task, capability_needs) |
| .agents.md | Unchanged | Unchanged (hermes reads it at runtime) |
| bootstrap.sh | Agnostic | + bootstrap_hermes.sh (layers hermes files) |

---

## Rollback

```bash
cd /path/to/project
git checkout SOUL.md
rm -f CORE_PROTOCOL_hermes_overlay.md
rm -f _relay_context_hermes.md
rm -f .agents_hermes_template.md
rm -rf ~/.hermes/skills/architect-relay
rm -rf ~/.hermes/skills/subagent-worker
rm -rf ~/.hermes/skills/verification-gate
```

You're back to agnostic-only. No data loss.
