# Hermes Agentic Template

A Hermes-specific orchestration overlay for [agentic_dev_template](https://github.com/jiri-cermak/agentic_dev_template).

## Purpose

This repository provides Hermes-specific extensions that leverage Hermes Agent's unique capabilities:

- **Mnemosyne Memory**: Persistent memory across sessions (working/episodic/persona tiers)
- **Live Subagent Orchestration**: Steer/stop subagents mid-flight
- **Multi-Platform Gateway**: Deliver to TG/Discord/Slack/WA/Signal
- **Compression Bookends**: Protect first-3 + last-4 turns during compression
- **FTS5 Session Search**: Cross-session recall
- **Profile Isolation**: Separate contexts per project

## Architecture

```
hermes_agentic_template/          ← Hermes-specific overlay
├── SOUL.md                       ← Hermes Architect identity
├── CORE_PROTOCOL_hermes_overlay.md  ← Hermes extensions
├── _relay_context_hermes.md      ← Hermes relay template
├── .agents_hermes_template.md    ← Project adapter template
├── bootstrap_hermes.sh           ← Overlay installer
├── protocol_modes/               ← Protocol mode plugins
│   ├── primitives.md             # Minimal ceremony
│   ├── standard.md               # Full 9-step lifecycle
│   └── custom.md                 # User-defined protocols
├── verification_strategies/      ← Verification plugins
│   ├── hallucination_guard.md    # Detect fabrication
│   ├── visual_regression.md      # Web UI testing
│   ├── sql_migration.md          # Database safety
│   ├── state_consistency.md      # Async systems
│   ├── security_scan.md          # Security vulnerabilities
│   └── knowledge_integrity.md    # Knowledge base verification
├── orchestration_modes/          ← Orchestration plugins
│   ├── fire_and_forget.md        # Maximum delegation
│   ├── iterative.md              # Cyclical refinement
│   ├── supervised.md             # Checkpoint reviews
│   ├── collaborative.md          # Human-AI partnership
│   ├── parallel.md               # Multi-subagent parallelism
│   └── hierarchical.md           # Multi-level delegation
├── plugins/                      ← Plugin system
│   ├── README.md                 # Plugin architecture
│   └── examples/                 # Example plugins
│       ├── code-review/          # Skill plugin
│       └── security-scan/        # Verification plugin
├── skills/                       ← Hermes skills
│   ├── architect-relay/          # Architect orchestration
│   ├── subagent-worker/          # Subagent execution
│   └── verification-gate/        # Verification logic
├── session_openers/              # Ready-to-use openers
│   ├── standard.md               # Full protocol
│   └── lite.md                   # Trivial tasks
└── cron/                         # Cron job examples
    ├── learning-consolidation.md # Weekly learning cleanup
    └── overnight-watch.md        # Daily repo watch
```

## Installation

### 1. Bootstrap agnostic core

```bash
git clone https://github.com/jiri-cermak/agentic_dev_template.git
cd agentic_dev_template
./bootstrap.sh /path/to/project
```

### 2. Layer Hermes overlay

```bash
git clone https://github.com/jiri-cermak/hermes_agentic_template.git
cd hermes_agentic_template
./bootstrap_hermes.sh /path/to/project
```

This:
- Copies Hermes SOUL.md (replaces agnostic version)
- Adds CORE_PROTOCOL_hermes_overlay.md
- Copies _relay_context_hermes.md
- Installs skills to ~/.hermes/skills/
- Adds Hermes files to .gitignore
- Copies protocol modes, verification strategies, orchestration modes
- Sets up plugin system

## Usage

### Standard workflow

```
1. Start Hermes session in project directory
2. Use session_openers/standard.md as first message
3. Architect reads SOUL.md + CORE_PROTOCOL.md + overlay + .agents.md
4. Architect selects protocol mode (primitives/standard/custom)
5. Architect selects orchestration mode (fire_and_forget/iterative/supervised/collaborative/parallel/hierarchical)
6. Architect selects verification strategies (hallucination_guard + project-specific)
7. Architect classifies tier (Minimal/Standard/Full)
8. Architect delegates via delegate_task
9. Architect verifies (audit handover, verify files, re-run tests, run verification strategies)
10. Architect gates (fabrication → stagnation → environment → spec → execution → contract → cleared)
11. Post-mortem: classify learnings, persist to Mnemosyne
12. Verify clean state, proceed to next step
```

### Lite workflow

For trivial tasks (≤2 files, no dependencies, reversible):

```
1. Use session_openers/lite.md
2. Architect uses Primitives protocol mode
3. Architect uses Fire-and-forget orchestration mode
4. Architect uses Hallucination Guard verification strategy
5. 2-heading handover (Summary + Diff)
6. Simplified gate (fabrication, contract, cleared only)
```

## Hermes-Specific Features

### Mnemosyne Memory

```python
# Persist learnings after each relay
memory(action='add', target='working', content='task state')
memory(action='add', target='episodic', content='pattern across sessions')
memory(action='add', target='persona', content='stable project fact')
```

### Live Steering

```python
# Steer subagent mid-task
delegate_task(action='steer', subagent_id='abc123', message='...')

# Stop subagent early
delegate_task(action='stop', subagent_id='abc123')
```

### Gateway Notifications

Configure in `.agents.md`:

```yaml
gateway:
  enabled: true
  channels: [telegram, discord]
  triggers:
    - failure: escalation
    - completion: summary
    - cron: watch_alerts
```

### Session Search

```python
# Recall past relays
session_search(query="auth module similar task", limit=3)
```

## Protocol Modes

### Primitives

Minimal ceremony for simple tasks:
- Just delegate work, verify results, record learnings
- No pre-delegation stash, clean-state checks, or post-mortem
- Best for: trivial tasks, well-defined work

### Standard

Full 9-step lifecycle:
- Plan, stash, pre-flight, relay, delegate, verify, gate, post-mortem, stabilize
- All anti-hallucination measures
- Best for: normal development tasks

### Custom

Define your own protocol in `.agents.md`:

```yaml
protocol:
  mode: custom
  steps:
    - plan
    - delegate
    - verify
    - postmortem
```

See `protocol_modes/` for detailed documentation.

## Verification Strategies

### Hallucination Guard (always active)

Detects:
- Fabricated evidence
- False confidence
- Missing verification
- Inconsistent claims

### Visual Regression (web apps)

- Screenshot comparison
- DOM validation
- Layout shift detection

### SQL Migration (database projects)

- Migration safety checks
- Rollback verification
- Data integrity validation

### State Consistency (async systems)

- State machine validation
- Race condition detection
- Consistency guarantees

### Security Scan (all projects)

- Dependency vulnerability scanning
- Code injection detection
- Secrets management

### Knowledge Integrity (knowledge bases)

- Content accuracy verification
- Link validation
- Semantic consistency

### Plugin-based

Add custom strategies via `verification_strategies/`:

```yaml
# verification_strategies/custom.md
name: custom_verification
trigger: "specific project type"
checks:
  - "check 1"
  - "check 2"
```

See `verification_strategies/` for detailed documentation.

## Orchestration Modes

### Fire-and-Forget

Maximum delegation, minimum oversight:
- Delegate task, wait for completion
- No mid-flight monitoring
- Best for: simple, well-defined tasks

### Iterative

Cyclical refinement through feedback:
- Delegate, review, provide feedback, repeat
- Typically 2-3 iterations
- Best for: complex tasks, quality-critical work

### Supervised

Active monitoring with checkpoints:
- Subagent reports at defined checkpoints
- Architect reviews and approves
- Best for: high-risk, complex tasks

### Collaborative

True partnership between Architect and Subagent:
- Both contribute to solution
- Decisions made together
- Best for: design work, debugging

### Parallel

Multiple subagents work simultaneously:
- Architect decomposes task
- Subagents work on independent parts
- Architect merges results
- Best for: multi-file refactoring, large tasks

### Hierarchical

Multi-level delegation:
- Architect → Lead Subagent → Worker Subagents
- Results flow up through hierarchy
- Best for: very large, complex tasks

See `orchestration_modes/` for detailed documentation.

## Plugin System

See [plugins/README.md](plugins/README.md) for full documentation.

### Plugin Types

1. **Skill Plugins**: Add new skills (e.g., code-review)
2. **Verification Strategy Plugins**: Add verification strategies (e.g., security-scan)
3. **Protocol Mode Plugins**: Add protocol modes
4. **Orchestration Mode Plugins**: Add orchestration modes

### Installing Plugins

```bash
# Local installation
cp -r my-plugin/ ~/.hermes/plugins/

# Or use plugin manager (if available)
hermes plugin install ./my-plugin
```

### Creating Plugins

1. Create plugin directory with `plugin.yaml`
2. Implement plugin (SKILL.md, verify.md, etc.)
3. Test in isolation
4. Install to ~/.hermes/plugins/

### Plugin Examples

See `plugins/examples/` for:
- `code-review/` - Skill plugin for code review
- `security-scan/` - Verification plugin for security scanning

## Cron Jobs

### Learning Consolidation

Weekly cleanup of `learnings/` directory:

```bash
# cron: 0 3 * * 0 (Sunday 3am)
cd /path/to/project
./cron/learning-consolidation.md
```

Promotes recurring patterns to Mnemosyne, archives old entries.

### Overnight Watch

Daily check for uncommitted changes, failed tests, stale handovers:

```bash
# cron: 0 2 * * * (daily 2am)
cd /path/to/project
./cron/overnight-watch.md
```

Alerts via gateway if issues found.

## Migration from Agnostic Core

See [MIGRATION.md](MIGRATION.md) for step-by-step instructions.

## Version Compatibility

| Hermes Overlay | Agnostic Core |
|----------------|---------------|
| v2.0.0         | v6.1.x        |

Check `CORE_PROTOCOL.md` version header for compatibility.

## License

MIT
