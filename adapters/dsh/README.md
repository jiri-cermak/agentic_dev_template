# DeepSeek Harness (DSH) Adapter

Run the Tiered Relay Architecture v6.1 with DeepSeek Harness agents and subagents.

## Prerequisites

- Node.js 22.19+
- DeepSeek Harness installed: `npm install -g @deepseek-ai/dsh`
- Project bootstrapped with `agentic_dev_template`

## Installation

### Option 1: Bootstrap with adapter flag

```bash
./bootstrap.sh /path/to/project --adapter dsh
```

This copies the DSH shim into your project's `.dsh-shims/dsh/` directory.

### Option 2: Manual install

```bash
cp -r adapters/dsh/ /path/to/project/.dsh-shims/dsh/
```

## First-time setup

1. **Verify DSH is installed:**
   ```bash
   dsh --version
   ```

2. **Launch DSH in your project:**
   ```bash
   cd /path/to/project
   npx @deepseek-ai/dsh web
   ```

3. **Verify subagent capability:**
   ```bash
   dsh --profile web --dump-config | grep -i subagent
   ```
   You should see `dsh-tool-subagent` or similar. If missing, add the subagent
   package:
   ```bash
   dsh plugin --profile web add dsh-subagent
   ```

4. **Install recommended plugins** (see `/opt/data/plans/dsh-core-plugin-list.md`):
   - Tier 1 (essential): `dsh-auto-memory`, `dsh-scheduling`, `@dsh-routines/bundle`, `dsh-sessions`
   - Tier 2 (recommended): `dsh-skills`, `dsh-poison-guard`, `dsh-cost-meter`, `dsh-tier-router`, `dsh-context`

## Session opener

Start each DSH session with this message:

> Act as the Architect per SOUL.md. Read CORE_PROTOCOL.md and .agents.md before
> delegating. Classify the requirement tier (Minimal/Standard/Full). Begin: plan
> → stash → pre-flight → relay → delegate → verify → gate → post-mortem →
> stabilize.

## First relay

1. **Architect fills the relay template** (`handovers/_relay_context_template.md`):
   - Replace all `{...}` placeholders
   - Set `tier: minimal|standard|full`
   - Include shape contract (Standard/Full tiers)
   - Define success criteria (test IDs, diff checks, exit codes)

2. **Architect invokes subagent tool:**
   ```
   Tool: subagent
   prompt: <filled relay context>
   provider: spawn-in-process (default)
   ```

3. **Subagent executes:**
   - Runs location pre-flight: `cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel`
   - Edits only target files
   - Runs tests verbatim
   - Stages explicit files only
   - Commits
   - Writes handover to `handovers/done/completion-{TASK_ID}.md`

4. **Architect verifies:**
   - Reads handover file
   - Checks all files in Files Changed table (`wc -c`, `head -1`)
   - Confirms agent's commit is latest (`git log -1`)
   - Independently re-runs declared tests
   - Applies gate matrix

5. **Post-mortem:**
   - Classify learnings (core/adapter/project-specific/historical)
   - Persist critical learnings to `dsh-auto-memory`
   - Iterate if needed (Minimal tier: Probe → Discover → Refine → Implement)

## Capability gaps (honest disclosure)

DSH does not provide these Hermes capabilities:

1. **Live subagent orchestration** (steer/stop mid-flight)
   - Workaround: kill child and re-spawn with revised prompt
2. **Multi-platform gateway** (TG/Discord/Slack/WA/Signal)
   - Workaround: use `dsh-routines` for digest delivery
3. **Compression with protected bookends**
   - Workaround: write critical decisions to `dsh-auto-memory`
4. **FTS5 cross-session search**
   - Workaround: manual note-taking in `learnings/`

The relay context's `capability_needs` field makes these gaps visible. Architect
must compensate manually when capabilities are unavailable.

## Pinning versions

DSH is in developer preview (`0.1.0-rc.x`). Pin versions to avoid breaking changes:

```bash
# Pin DSH version
npm install -g @deepseek-ai/dsh@0.1.0-rc.6

# Pin plugin versions (check each plugin's README for pinning syntax)
```

Re-validate after upgrades. The subagent tool API may change between releases.

## Troubleshooting

- **Subagent tool not found:** Verify `dsh --dump-config | grep subagent`. Install
  `dsh-subagent` plugin if missing.
- **Subagent fails to start:** Check DSH logs. Retry once, then escalate to user.
- **Handover file missing:** Verify subagent committed. Check `git log` for agent's
  commit. If missing, subagent may have failed before commit.
- **Tests fail on independent re-execution:** Spec error. Revise relay context and
  retry with updated testing methodology.

## References

- CORE_PROTOCOL.md — orchestration rules
- SOUL.md — Architect identity
- .agents.md — project adapter
- handovers/_relay_context_template.md — relay template
- /opt/data/plans/dsh-core-plugin-list.md — recommended plugins
- /opt/data/plans/dsh-agentic-template-adaptation-v2.md — full adaptation plan
