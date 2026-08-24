# Tiered Relay Architecture v6.1 — Core Protocol

This document defines the project-agnostic orchestration loop. It does not define a project's stack, tools, domain, or deployment environment. Those belong in the project adapter (`.agents.md` and the relay context template).

**Agnosticism principle:** Core files use `{PLACEHOLDER}` tokens and generic capability verbs only; concrete tool/CLI names live in adapters.

## Roles

- **Architect:** plans, writes relay context, delegates, independently verifies, records learnings, and controls retries. Does not write feature code.
- **Subagent:** executes only the assigned relay context, changes only named target files, runs the specified tests, commits the result, and writes the handover.
- **Verification gate:** accepts evidence only when it is reproducible from the workspace and matches the target boundary.

## Loop

1. **Plan** — classify the requirement tier, create/update `.internal_master_plan.md`, and stash state files.
2. **Pre-flight** — verify repository root, clean/known working tree, target paths, and adapter readiness.
3. **Relay** — construct a self-contained Markdown context with absolute paths, scope, constraints, tests, stop conditions, and handover contract.
4. **Delegate** — dispatch the relay context directly. Handle errors. Wait for completion. Do not use JSON relay payload files.
5. **Execute** — subagent edits only target files, validates, commits explicit files, and writes post-commit handover evidence.
6. **Verify** — Architect audits the handover, independently re-runs the declared tests, and verifies all files.
7. **Gate** — pass, retry with a classified correction, or stop/escalate.
8. **Post-mortem** — record evidence, classify learnings, and iterate if needed.
9. **Stabilize** — confirm the workspace is clean and the master plan is consistent before unlocking the next step.

## Requirement tiers

Classify by requirement clarity — clarity predicts iteration count, which drives cost (not context size or file count). Match the relay's detail to the tier.

| Clarity | Tier | What the relay includes | Expected iterations | Empirical failure rate |
|---|---|---|---|---|
| **Loose** — unsure what to build, exploring | **Minimal** | Goal, target files, test command, handover path | 2-3 | ~15% |
| **Medium** — know what, details may shift | **Standard** | Minimal + constraints, shape contract, surprises checklist | 1-2 | ~5% |
| **Tight** — spec stable, multi-relay, high cost of failure | **Full** | Standard + shared resource contract, stop conditions, pre-flight | 0-1 | ~2% |

**Decision tree:**

```text
START: New task
  ├─→ Loose?   → Minimal tier. Expect 2-3 iterations.
  ├─→ Medium?  → Standard tier. Expect 1-2 iterations.
  ├─→ Tight + ≥3 relays? → Full tier.
  └─→ Tight + <3 relays?  → Standard tier.
```

**Iteration pattern for loose requirements:** Probe → Discover → Refine → Implement. Start with a minimal relay to probe; the first completion reveals gaps; tighten the next relay based on discoveries. Do not write a perfect spec upfront for something you do not fully understand. Iteration is triggered by a genuine trade-off or conflicting constraint, not by looseness alone — a loose-but-harmless spec (pick a palette, pick a structure) has an obvious default and is correctly one-shot.

Keep each relay below 30 minutes of expected execution. Split larger work. Never unlock a dependent step before the verification gate passes.

## Relay invariants

Every relay context must contain:

- project name and absolute project root;
- task ID and execution profile;
- **tier** (minimal | standard | full);
- self-contained task description;
- absolute target file paths with create/modify action;
- files explicitly out of scope;
- adapter-declared tool and dependency boundaries;
- verbatim testing methodology with at least one structural assertion and one negative assertion;
- **shape contract** (Standard and Full tiers): exact data shapes, API signatures, decorators, fields — no pseudocode; the testing methodology must include at least one shape assertion;
- stop conditions for known environment dead ends;
- exact handover path and contract;
- explicit commit procedure.

The first subagent command must verify location:

```text
cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel
```

Do not rely on a `workdir` metadata field unless the runtime has independently demonstrated that it changes the actual working directory. Absolute paths remain mandatory.

**Skill isolation:** Keep the project adapter as a dotfile in every project. The harness scans a fixed set of project-convention files (concrete filenames defined in the adapter) for auto-discovery. A dotfile is invisible to progressive subdirectory discovery, preventing the harness from injecting project context as a virtual skill. The relay context is the subagent's sole source of rules.

## Reduced handover (any tier)

A relay whose change is small and reversible may use a reduced handover: a one-paragraph task spec and a two-heading handover (`## Summary`, `## Diff`). The change qualifies only when **all** hold:

- it touches at most two files;
- it adds no new dependency;
- existing test coverage applies (the Architect writes no new tests);
- it is reversible (no schema migration, no state change).

The reduced handover changes **format and context only** — never verification. `success_criteria:` stays mandatory at every tier, and the full gate matrix applies unchanged. A small reversible change is not a license to skip the deterministic gate.

## Pre-delegation stash

Before writing a relay for any step, commit or stash all state-file edits (`.internal_master_plan.md`, `retry_context.json`, `devlog.md`, etc.). The subagent may sweep uncommitted changes into its feature commit.

```bash
# Option 1: commit state files
git add .internal_master_plan.md retry_context.json devlog.md 2>/dev/null || true
git commit -m "chore: update state files before delegation" --allow-empty

# Option 2: stash state files
git stash push -m "state files before {STEP}" -- .internal_master_plan.md retry_context.json
```

Do NOT skip this step. Verified failure mode: the Architect's uncommitted edits pollute the subagent's commit, making rollback impossible.

## Delegation and error handling

Dispatch the relay context to the subagent-spawning tool as the task description. The delegation call returns immediately — the subagent runs asynchronously. **Wait for the subagent's completion message** before proceeding to verification. Do not read the handover file until the subagent has finished.

**If the delegation tool itself errors** (subagent fails to start):

1. Retry once with the same parameters.
2. If it fails again, escalate to the user with the error message.
3. Do NOT silently continue or skip the step.

## Verification levels

Choose verification depth according to the artifact changed:

1. **Structural:** always required. Parse or inspect the output shape with a runtime assertion.
2. **Negative:** always required. Prove a forbidden dependency, forbidden file, invalid state, or out-of-scope mutation is absent.
3. **Shape:** required when a shape contract is declared. Assert a declared field type, response structure, signature, or decorator.
4. **Runtime:** required for runnable applications, services, or served assets.
5. **Browser/DOM:** required when UI, HTML rendering, CSS behavior, or client-side JavaScript changes. Check console errors and key DOM/state properties.
6. **Visual screenshot:** optional. If unavailable or failing, do not loop on the vision provider; use browser console/DOM checks as the fallback.

The adapter declares exact commands and available tools. The core defines the required evidence categories, not a universal command set. Verification is not satisfied by judgment alone — every relay declares machine-verifiable `success_criteria:` (next section) that the gate evaluates deterministically.

## Machine-verifiable success criteria

Every relay must declare `success_criteria:` as machine-checkable items that a deterministic verifier evaluates without judgment. Supported types:

- `test_id` — a named test, identified by its exact ID, that must pass;
- `diff_check` — a file plus a literal string it must contain;
- `checksum` — a file plus the expected hash of its contents;
- `exit_code` — a command plus its expected exit code.

The gate passes only when **all** declared checks pass. The Architect reads the report and the check results, not raw output. Where a check is machine-evaluable, no second judgment is applied — the model is removed from that verification path.

**State-aware re-execution.** Before re-running the declared tests, confirm the subagent's commit is the latest (`git log -1`). Then run the exact testing methodology yourself and compare your output to the subagent's claimed output. Any discrepancy → **FAIL** (execution error or fabrication).

## Git and workspace safety

- Never use `git add -A` or `git add .` in a relay.
- Stage only the explicit target files.
- Never stage internal state, handovers, learnings, or unlisted assets unless the relay names them.
- Before committing, verify `git diff --cached --name-only` against `target_files`.
- Fill the handover from post-commit evidence, not estimates.
- After committing, verify `git status --short` and record any intentional untracked files.

## Handover contract

The completion report must contain these exact sections:

1. `## Raw Test Output`
2. `## Git Evidence`
3. `## Files Changed`
4. `## Surprises Checklist`
5. `## Contract Enforcement`

Raw test output must be complete, not summarized. Git evidence must include the current commit and a diff stat. The files table must match the actual commit. Any surprise must be disclosed.

**Files Changed table** carries, per file: Path, Action, Size (bytes), and First Line — alongside the machine-verifiable `checksum` in `success_criteria:`. The `checksum` is the gate; Size and First Line are a secondary sanity probe: for every file in the table, the Architect independently runs `wc -c <file>` and `head -1 <file>`, and any mismatch → **FAIL** (contract failure or fabrication).

## Gate matrix

Apply the first matching rule (precedence order):

| Precedence | Gate | Condition | Action |
|---|---|---|---|
| 1 (highest) | Fabrication | Claimed evidence contradicts the workspace or cannot be reproduced | Stop and escalate immediately. Trust breach. Do NOT retry. |
| 2 | Stagnation | Same error signature recurs after a correction | Stop, record signature, escalate. |
| 3 | Environment blocker | Missing daemon, package, credential, or permission cannot be fixed within scope | Stop immediately; do not burn retries. |
| 4 | Spec drift | Test or path is wrong because the relay is underspecified | Prune context, correct relay, retry. Log to `retry_context.json` (type `spec_error`). |
| 5 | Execution error | Subagent failed to execute an otherwise valid relay | Retry with a focused correction; two consecutive failures escalate. Log to `retry_context.json` (type `execution_error`). |
| 6 | Machine check failed | A valid declared `success_criteria` check did not pass | Retry with a focused correction; two consecutive failures escalate. |
| 7 | Contract failure | Code passes but handover/evidence is incomplete | Metadata-only retry. |
| 8 (lowest) | Validation cleared | Independent evidence matches scope and contract | Mark complete and unlock the next step. |

Maximum: `max_attempts` attempts per task ID (default 3). A repeated error signature is a hard stop, not an invitation to consume the remaining budget. Exhausting all attempts is never silent — see Failure escalation.

## Failure escalation

Exhausting `max_attempts` (default 3) is never silent. The subagent writes `handovers/{TASK_ID}/failure_postmortem.md` before stopping, with exactly these fields:

- **Root-cause hypothesis** — the most likely reason the relay failed;
- **Diff of each attempt** — what changed between attempt N and N+1;
- **Concrete blocker question** — the single question whose answer would unblock the work;
- **Suggested next action** — retry with revised context, escalate to human, or skip.

The Architect reviews the postmortem and chooses one:

1. **Retry with revised context** — rewrite the relay with the new information; the attempt counter resets.
2. **Escalate to human** — record the blocker in `devlog.md` and notify if a gateway is available.
3. **Mark blocked, continue** — mark the task blocked and proceed to the next task in the plan.

The relay's `escalation_policy` preselects the default: `human_retry` escalates for the retry decision, `skip_on_fail` skips and moves on, `block_and_continue` marks blocked and continues. Minimal relays default to `skip_on_fail`; Standard and Full relays default to `human_retry`.

## Capability negotiation

A relay may depend on runtime capabilities that not every harness provides — live steering, cross-session memory, gateway notification, compression safety. The relay declares its needs in `capability_needs:`; the adapter maps each to `available`, `degraded`, or `not_available`. The core names generic capabilities only, never a harness; the adapter resolves them.

Each capability declares a `fallback` — the behavior used when it is `not_available`:

- `live_steering` — steer a running subagent mid-flight; fallback: kill and respawn;
- `cross_session_memory` — persist context across sessions; fallback: file-based learnings;
- `gateway_notification` — notify a human out-of-band; fallback: `devlog.md` only;
- `compression_safety` — preserve first and last turns under compression; fallback: manual context checkpoints.

The adapter must document which capabilities it provides and how each maps. A capability the adapter does not provide degrades to its fallback, never to silence.

## Progress and abort

Long relays report progress. The subagent writes `handovers/{TASK_ID}/progress.md` every `progress_interval` steps (default 5), recording:

- the current step;
- files touched so far;
- a percent-complete estimate.

The Architect may read `progress.md` at any time. To abort, the Architect writes `handovers/{TASK_ID}/abort.md` with the reason. The subagent checks for `abort.md` between steps and, on finding it, stops cleanly and writes a partial handover (what was done, what remains).

## Hierarchical delegation

A relay may declare `max_depth:` (default 1, nominal maximum 3). At `max_depth` ≥ 2, a subagent may spawn its own children with a reduced-scope relay context: each child inherits the parent's `success_criteria` and adds its own, and every depth level writes its own handover file. The Architect still verifies the top-level result. The core declares the field and the nominal maximum; the adapter enforces the actual ceiling it supports.

## Learning lifecycle

Subagents log every observation to `learnings/pending.md` as a single atomic append-only line per task — never read-modify-write, so concurrent relays cannot clobber each other. Each entry carries one classification:

- **core:** project-agnostic orchestration or evidence rule;
- **adapter:** toolchain, environment, provider, or test-runner rule;
- **project-specific:** domain, design, asset, or product rule;
- **historical:** useful evidence that is not an active rule.

**Promotion.** The Architect is the sole reader and promoter of `pending.md`. During post-mortem, the Architect promotes an item only when it appears in at least two post-mortems, or the subagent tagged it `must-promote` with justification. Promoted items move to `learnings/promoted.md` (a single file). A `core` item may then be proposed for `CORE_PROTOCOL.md`; adapter and project-specific items stay local; historical items stay archived.

**Pruning.** Every 10 relays, or monthly, the Architect archives `pending.md` items older than 30 days that were never promoted.

## Step post-mortem and iteration

After a step passes verification, before proceeding to the next step:

1. **For Minimal tier:** the completion likely revealed gaps. Document what was learned in `.internal_master_plan.md` under the step's notes. If a follow-up is needed, add it as a new step with a tighter spec based on findings.
2. **For Standard tier:** did the surprises checklist reveal anything that should tighten future relays? Did the tests actually prove the feature works, or are they testing trivialities? If tests are weak, add stronger assertions to the next relay.
3. **For Full tier:** cross-check the shared resource contract against parallel steps in the master plan. Any conflict → pause parallel work and resolve.

If a step passes but you suspect the feature is still wrong: escalate to the user with evidence before proceeding.

## Clean state before next step

After post-mortem, run `git status`. The working tree should be clean (the subagent committed its work). If not:

```bash
git status
# If dirty:
git stash   # or commit with a descriptive message
```

Do NOT proceed to the next step with a dirty working tree. Verified failure mode: stale files from step N pollute step N+1.

## Master plan template

Write `.internal_master_plan.md` using this template:

```markdown
# Master Plan — {FEATURE_NAME}
**Created:** {timestamp}
**Last updated:** {timestamp}
**Status:** {in_progress | completed}

## Steps

| ID | Tier | Description | Effort | Depends On | Status |
|---|---|---|---|---|---|
| STEP-01 | Standard | ... | 20m | — | pending |
| STEP-02 | Minimal | ... | 15m | STEP-01 | pending |
```

- Effort must be ≤30m per step. Split larger tasks.
- If requirements change mid-execution: pause the active step, revise the plan, then resume or restart.
- **Never show or pass the entirety of `.internal_master_plan.md` to any subagent.**

## Telemetry

Record, where available: task ID, model/provider, thinking mode, start/end/duration, retries, API/tool-call count, verification levels used, gate result, and error classification. Metrics are observations, not universal model-selection rules.

## Failure → Measure ROI

Add measures only when you hit the corresponding failure. Do not front-load all of them.

| Failure | Add This Measure | ROI |
|---|---|---|
| Subagent summarizes tests | Raw output paste (handover contract) | 45x |
| Subagent skips hard parts | Surprises checklist | 10x |
| Subagent invents data shapes | Shape contract + shape assertion | High |
| Task too large, subagent drifts | ≤30m split (master plan) | High |
| Parallel relays conflict | Shared resource contract (Full tier) | High |
| Environment mismatch | Pre-flight (Full tier) | 18x |
| Subagent lies about pre-flight | Stop condition: "paste raw, do not describe" | Critical |
| State-file pollution | Pre-delegation stash | Preventative |
| Delegation never starts | Delegation error handling | Preventative |
| Step N+1 sees stale files | Clean-state check | Preventative |

## Compatibility

v4 was the JSON relay protocol. v5 introduced direct Markdown delegation context and the first environment-specific tool mandate. v6 keeps direct context, makes the core project-agnostic, and moves environment/project details into adapters. v6.1 adds operational procedures: requirement tiers with a decision tree, pre-delegation stash, error handling, clean-state checks, master plan template, iteration patterns, and ROI rankings.

The core is authoritative for orchestration. The adapter is authoritative for local paths, tools, dependencies, tests, protected files, and domain conventions.
