# Tiered Relay Architecture v6.2 — Bootstrap Template

A project-agnostic scaffold for the Architect → Subagent → Verify workflow.

## Files

| File | Purpose |
|---|---|
| `SOUL.md` | Model-neutral Architect identity, boundaries, and invariant principles |
| `CORE_PROTOCOL.md` | Stable, project-agnostic orchestration rules (v6.2) |
| `.agents.md` | Project adapter: local root, stack, tools, tests, and protected files |
| `_relay_context_template.md` | Subagent delegation context template (v6.2) |
| `bootstrap.sh` | Creates the scaffold in a new project |
| `review_by_sol_2026-08-09.md` | Design review and rationale for v6 |
| `adapters/` | Optional harness-specific shims |

## Quick start

```bash
# Basic (agnostic)
./bootstrap.sh /absolute/path/to/new-project

# With a harness adapter
./bootstrap.sh /absolute/path/to/new-project --adapter dsh
```

Then replace all adapter placeholders in `.agents.md` and `_relay_context_template.md`, write `.internal_master_plan.md`, and start:

```text
plan → stash → pre-flight → relay → delegate → verify → gate → post-mortem
```

## Generated workspace

```text
new-project/
├── SOUL.md
├── .agents.md
├── CORE_PROTOCOL.md
├── _relay_context_template.md
├── .internal_master_plan.md
├── devlog.md
├── handovers/
│   ├── done/
│   └── archive/
└── learnings/
```

Internal state is excluded via `.git/info/exclude`. The bootstrap script never stages or commits project files.

> **Agentic-loop workstream:** read [`OPEN-LOOP.md`](OPEN-LOOP.md) — state, parked items with triggers, next-bump items, and verification commands for the loop.

## Requirement tiers

Classify by requirement clarity — clarity predicts iteration count, which drives cost.

| Tier | Clarity | Expected iterations | Failure rate |
|---|---|---|---|
| **Minimal** | Loose (unsure what to build) | 2-3 | ~15% |
| **Standard** | Medium (know what, details may shift) | 1-2 | ~5% |
| **Full** | Tight (spec stable, multi-relay) | 0-1 | ~2% |

Decision: Loose → Minimal. Medium → Standard. Tight + ≥3 relays → Full. Tight + <3 relays → Standard.

`success_criteria:` (the machine-verifiable gate) is mandatory at every tier. A reduced handover changes format and context only, never verification.

## v6.1 design

v6.1 operationalizes the orchestration core with battle-tested procedures:

- **3-tier system:** Minimal/Standard/Full with a decision tree and empirical failure rates
- **Pre-delegation stash:** Commit/stash state files before delegation (prevents pollution)
- **Error handling:** Explicit path for delegation tool failures
- **Clean-state checks:** Verify working tree clean between steps
- **Master plan template:** Standardized format with tier, effort, dependencies
- **Iteration pattern:** Probe → Discover → Refine → Implement for loose requirements
- **ROI rankings:** Add anti-hallucination measures only when failures occur
- **Files verification:** Machine-verifiable `checksum` gate + `wc -c` / `head -1` secondary probe
- **State-aware re-execution:** Confirm the subagent's commit is latest before re-running tests
- **Shape contracts:** Exact data shapes / API signatures (Standard/Full tiers)

v4 used JSON relay payloads. v5 introduced direct Markdown context. v6 made the template genuinely project-agnostic. v6.1 adds operational procedures.

## v6.2 changes

v6.2 makes the template the one canonical upstream that every org project (kubera, nuad, t_unity, jong, …) can pin to, and re-homes the Hermes overlay into it:

- **Agnosticism gate restored.** `CORE_PROTOCOL.md` §Skill creation prohibition now forbids restating loop rules in any harness's skill system, stated harness-agnostically (no product/tool/CLI names), so the template's own `agnosticism.yml` gate passes.
- **Six template-only sections retained.** `Execution record schema`, `Architect pre-flight verification`, `Impeccable design gates (UI relays)`, `Plan-level retry governance`, `Retry context schema`, and `Skill creation prohibition` are unchanged and intact.
- **Transcript-integrity merge (additive).** The production lineage's transcript-integrity block and the "Raw test output means the filtered signal, verbatim, plus an artifact reference" definition are folded into the core from the `9100dc10` lineage (kubera = nuad = t_unity), so the template is a superset of every consumer core.
- **Adapter-practice promotion.** The skeleton `.agents.md` now ships the family's proven practices: local test-output hygiene (artifact path + `sha256` + filtered signal verbatim), local execution profile by tier (tier → reasoning effort, set before dispatch), local delegation timing & tier recording (fs-derived `relay.md`→`completion.md` mtime, never self-reported), and the runtime-state `.git/info/exclude` pattern list.
- **Hermes overlay re-homed as `adapters/hermes/`.** The standalone `hermes_agentic_template` overlay repo is retired and its content lives here as a first-class adapter.
- **Core manifest.** `core-manifest.sha256` pins the five core files so bootstrapped/consumer projects can verify they match the upstream tag being pinned against.

## Harness adapters

`adapters/` contains OPTIONAL harness-specific shims — e.g., `adapters/dsh/` for the DeepSeek Harness. The template core is harness-agnostic and never references them. Install one per project with `./bootstrap.sh <path> --adapter <name>`. Deleting `adapters/` changes nothing.

Available adapters:
- `dsh/` — DeepSeek Harness adapter (see `adapters/dsh/README.md`)
- `hermes/` — Hermes Agent overlay adapter (see `adapters/hermes/README.md`); re-homed from the retired `hermes_agentic_template` overlay repo

## Anti-hallucination measures

The protocol includes explicit measures to catch common failure modes:

- **Raw output paste:** the subagent must paste complete terminal output, never summaries
- **Surprises checklist:** the subagent must disclose every deviation
- **Shape contracts:** exact data shapes, not pseudocode
- **Negative tests:** assert something should NOT happen
- **Machine-verifiable success criteria:** `test_id` / `diff_check` / `checksum` / `exit_code` at every tier
- **Files verification:** size and first line checked independently
- **State-aware re-execution:** confirm the subagent's commit before re-running tests
- **Pre-delegation stash:** prevent state-file pollution

Add measures only when you hit the corresponding failure. See `CORE_PROTOCOL.md` §Failure → Measure ROI.

## Learning policy

Classify every observation as `core`, `adapter`, `project-specific`, or `historical`. Promote only repeatable project-agnostic rules into `CORE_PROTOCOL.md`.

## Safety

The template uses placeholders intentionally. Do not copy environment-specific assumptions from another project without verifying them. Relay agents must stage explicit target files only and independently reproduce the declared tests.

## Rationale

See `review_by_sol_2026-08-09.md` for the full findings-to-change mapping and the changes deliberately not promoted into core.

## License

MIT — see `LICENSE`.
