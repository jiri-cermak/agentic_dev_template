# Tiered Relay Architecture v6.1 — Bootstrap Template

A project-agnostic scaffold for the Architect → Subagent → Verify workflow.

## Files

| File | Purpose |
|---|---|
| `SOUL.md` | Model-neutral Architect identity, boundaries, and invariant principles |
| `CORE_PROTOCOL.md` | Stable, project-agnostic orchestration rules (v6.1) |
| `.agents.md` | Project adapter: local root, stack, tools, tests, and protected files |
| `_relay_context_template.md` | Subagent delegation context template (v6.1) |
| `bootstrap.sh` | Creates the scaffold in a new project |
| `review_by_sol_2026-08-09.md` | Design review and rationale for v6 |
| `adapters/` | Optional harness-specific shims (e.g., DSH, future harnesses) |

## Quick start

```bash
# Basic (agnostic)
./bootstrap.sh /absolute/path/to/new-project

# With harness adapter
./bootstrap.sh /absolute/path/to/new-project --adapter dsh
```

Then replace all adapter placeholders in `.agents.md` and `handovers/_relay_context_template.md`, write `.internal_master_plan.md`, and start:

```text
plan → stash → pre-flight → relay → delegate → verify → gate → post-mortem
```

## Generated workspace

```text
new-project/
├── SOUL.md
├── .agents.md
├── CORE_PROTOCOL.md
├── .internal_master_plan.md
├── devlog.md
├── handovers/
│   ├── _relay_context_template.md
│   ├── done/
│   └── archive/
└── learnings/
```

Internal state is excluded via `.git/info/exclude`. The bootstrap script never stages or commits project files.

## v6.1 design

v6.1 operationalizes the orchestration core with battle-tested procedures:

- **3-tier system:** Minimal/Standard/Full with decision tree and empirical failure rates
- **Pre-delegation stash:** Commit/stash state files before delegation (prevents pollution)
- **Error handling:** Explicit path for delegation tool failures
- **Clean-state checks:** Verify working tree clean between steps
- **Master plan template:** Standardized format with tier, effort, dependencies
- **Iteration pattern:** Probe → Discover → Refine → Implement for loose requirements
- **ROI rankings:** Add anti-hallucination measures only when failures occur
- **Files verification:** Independent `wc -c` and `head -1` checks on all files
- **State-aware re-execution:** Confirm agent's commit is latest before re-running tests
- **Shape contracts:** Exact data shapes/API signatures (Standard/Full tiers)

v4 used JSON relay payloads. v5 introduced direct Markdown context. v6 made the template genuinely project-agnostic. v6.1 adds operational procedures from the prompt evolution session.

## Requirement tiers

| Tier | Clarity | Expected iterations | Failure rate |
|---|---|---|---|
| **Minimal** | Loose (unsure what to build) | 2-3 | ~15% |
| **Standard** | Medium (know what, details may shift) | 1-2 | ~5% |
| **Full** | Tight (spec stable, multi-relay) | 0-1 | ~2% |

Decision: Loose → Minimal. Medium → Standard. Tight + ≥3 relays → Full. Tight + <3 relays → Standard.

## Harness adapters

`adapters/` contains OPTIONAL harness-specific shims — e.g., `adapters/dsh/` for DeepSeek Harness. The template core is harness-agnostic and never references them. Install one per project with `./bootstrap.sh <path> --adapter <name>`. Deleting `adapters/` changes nothing.

Available adapters:
- `dsh/` — DeepSeek Harness adapter (see `adapters/dsh/README.md`)

## Anti-hallucination measures

The protocol includes explicit measures to catch common failure modes:

- **Raw output paste:** Agent must paste complete terminal output, never summaries
- **Surprises checklist:** Agent must disclose every deviation
- **Shape contracts:** Exact data shapes, not pseudocode
- **Negative tests:** Assert something should NOT happen
- **Files verification:** Architect independently checks file size and first line
- **State-aware re-execution:** Confirm agent's commit before re-running tests
- **Pre-delegation stash:** Prevent state-file pollution

Add measures only when you hit the corresponding failure. See CORE_PROTOCOL.md §Failure → Measure ROI.

## Learning policy

Classify every observation as `core`, `adapter`, `project-specific`, or `historical`. Promote only repeatable project-agnostic rules into `CORE_PROTOCOL.md`.

## Safety

The template uses placeholders intentionally. Do not copy environment-specific assumptions from another project without verifying them. Relay agents must stage explicit target files only and independently reproduce the declared tests.

## Rationale

See `review_by_sol_2026-08-09.md` for the full findings-to-change mapping and the changes deliberately not promoted into core.

## License

Add the license appropriate for your use of this template.
