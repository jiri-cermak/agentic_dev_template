# Tiered Relay Architecture v6.1 — Core Protocol

This document defines the project-agnostic orchestration loop. It does not define a project's stack, tools, domain, or deployment environment. Those belong in the project adapter (`.agents.md` and the relay context template).

## Roles

- **Architect:** plans, writes relay context, delegates, independently verifies, records learnings, and controls retries. Does not write feature code.
- **Subagent:** executes only the assigned relay context, changes only named target files, runs the specified tests, commits the result, and writes the handover.
- **Verification gate:** accepts evidence only when it is reproducible from the workspace and matches the target boundary.

## Loop

1. **Plan** — classify the requirement, create/update `.internal_master_plan.md`, and stash state files.
2. **Pre-flight** — verify repository root, clean/known working tree, target paths, and adapter readiness.
3. **Relay** — construct a self-contained Markdown context with absolute paths, scope, constraints, tests, stop conditions, and handover contract.
4. **Delegate** — invoke the subagent-spawning tool with the context directly. Handle errors. Wait for completion.
5. **Execute** — subagent edits only target files, validates, commits explicit files, and writes post-commit handover evidence.
6. **Verify** — Architect audits the handover, independently re-runs the declared tests, and verifies all files.
7. **Gate** — pass, retry with a classified correction, or stop/escalate.
8. **Post-mortem** — record evidence, classify learnings, and iterate if needed.
9. **Stabilize** — confirm the workspace is clean and the master plan is consistent before unlocking the next step.

## Requirement tiers

| Clarity | Tier | What the relay includes | Empirical failure rate |
|---|---|---|---|
| **Loose** — unsure what to build, exploring | **Minimal** | Goal, target files, test command, handover path | ~15% |
| **Medium** — know what, details may shift | **Standard** | Minimal + constraints, shape contract, surprises checklist | ~5% |
| **Tight** — spec stable, multi-relay, high cost of failure | **Full** | Standard + shared resource contract, stop conditions, agent pre-flight | ~2% |

**Decision tree:**

```
START: New task
  │
  ├─→ Loose?   → Minimal tier. Expect 2-3 iterations.
  ├─→ Medium?  → Standard tier. Expect 1-2 iterations.
  ├─→ Tight + ≥3 relays? → Full tier.
  └─→ Tight + <3 relays?  → Standard tier (overkill but safe).
```

**Iteration pattern for loose requirements:** Probe → Discover → Refine → Implement. Start with a minimal relay to probe. The first completion reveals gaps. Tighten the next relay based on discoveries. Do NOT write a perfect spec upfront for something you don't fully understand.

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
- **shape contract** (Standard and Full tiers): exact data shapes, API signatures, decorators, fields. No pseudocode. Testing methodology must include at least one shape assertion validating a declared field type, response structure, signature, or decorator.
- stop conditions for known environment dead ends;
- exact handover path and contract;
- explicit commit procedure.

The first subagent command must verify location:

```text
cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel
```

Do not rely on a `workdir` metadata field unless the runtime has independently demonstrated that it changes the actual working directory. Absolute paths remain mandatory.

**Skill isolation:** Rename `AGENTS.md` to `.agents.md` (dotfile) in every project. The runtime scans only `.hermes.md`, `AGENTS.md`, `CLAUDE.md`, and `.cursorrules` for auto-discovery. A dotfile is invisible to progressive subdirectory discovery, preventing the runtime from injecting project context as a virtual skill. The relay context is the subagent's sole source of rules.

## Verification levels

Choose verification depth according to the artifact changed:

1. **Structural:** always required. Parse or inspect the output shape with a runtime assertion.
2. **Negative:** always required. Prove a forbidden dependency, forbidden file, invalid state, or out-of-scope mutation is absent.
3. **Runtime:** required for runnable applications, services, or served assets.
4. **Browser/DOM:** required when UI, HTML rendering, CSS behavior, or client-side JavaScript changes. Check console errors and key DOM/state properties.
5. **Visual screenshot:** optional. If unavailable or failing, do not loop on the vision provider; use browser console/DOM checks as the fallback.

The adapter declares exact commands and available tools. The core defines the required evidence categories, not a universal command set.

## Pre-delegation stash

Before writing a relay for any step, commit or stash all state-file edits (`.internal_master_plan.md`, `retry_context.json`, `ORCHESTRATION.md`, etc.). The subagent may run `git add -A` and sweep your uncommitted changes into their feature commit.

```bash
# Option 1: commit state files
git add .internal_master_plan.md retry_context.json ORCHESTRATION.md 2>/dev/null || true
git commit -m "chore: update state files before delegation" --allow-empty

# Option 2: stash state files
git stash push -m "state files before STEP-{N}" -- .internal_master_plan.md retry_context.json
```

Do NOT skip this step. Verified failure mode: Architect's uncommitted edits pollute agent's commit, making rollback impossible.

## Delegation and error handling

Invoke the subagent-spawning tool (e.g., `delegate_task` in Hermes, or the subagent tool in DSH) with the relay context as the `goal` or `prompt` parameter.

**Important:** The delegation call returns immediately — the subagent runs asynchronously. **Wait for the subagent's completion message** before proceeding to verification. Do not read the handover file until the subagent has finished.

**If the delegation tool itself errors** (subagent fails to start):
1. Retry once with the same parameters.
2. If it fails again → escalate to user with the error message.
3. Do NOT silently continue or skip the step.

## Git and workspace safety

- Never use `git add -A` or `git add .` in a relay.
- Stage only the explicit target files.
- Never stage internal state, handovers, learnings, or unlisted assets unless the relay names them.
- Before committing, verify `git diff --cached --name-only` against `target_files`.
- Fill the handover from post-commit evidence, not estimates.
- After committing, verify `git status --short` and record any intentional untracked files.

## Handover contract

The completion report must contain these exact sections:

1. `## Raw Test Output` — complete, unabridged output for every declared test.
2. `## Git Evidence` — `git log --oneline -1`, `git diff HEAD~1 --stat`, and `git status --short`.
3. `## Files Changed` — table with File Path, Action, Size (bytes), and First Line.
4. `## Surprises Checklist` — must be completed truthfully.
5. `## Contract Enforcement` — state where structural and negative assertions appear in raw output.

**Architect verification of files table:** For every file in the handover's Files Changed table, independently verify by running:
```bash
wc -c <file>    # Size must match
head -1 <file>  # First line must match
```
Any mismatch → **FAIL** (contract failure or fabrication).

Raw test output must be complete, not summarized. Git evidence must include the current commit and a diff stat. Any surprise must be disclosed.

## Independent re-execution

Before re-running the declared tests, verify the agent's state changes are applied:

```bash
git log -1  # Confirm agent's commit is the latest
```

Then run the exact testing methodology command yourself. Compare your output to the agent's claimed output. Any discrepancy → **FAIL** (execution error or fabrication).

## Gate matrix

Apply the first matching rule:

| Precedence | Gate | Condition | Action |
|---|---|---|---|
| **1 (highest)** | Fabrication | Claimed evidence contradicts the workspace or cannot be reproduced | **Stop and escalate immediately.** Trust breach. Do NOT retry. |
| **2** | Stagnation | Same error signature recurs after a correction | Stop, record signature, escalate. |
| **3** | Environment blocker | Missing daemon, package, credential, or permission cannot be fixed within scope | Stop immediately; do not burn retries. |
| **4** | Spec drift | Test or path is wrong because the relay is underspecified | Prune context, correct relay, retry. Log to `retry_context.json` with type `spec_error`. |
| **5** | Execution error | Subagent failed to execute an otherwise valid relay | Retry with a focused correction; two consecutive failures escalate. Log to `retry_context.json` with type `execution_error`. |
| **6** | Contract failure | Code passes but handover/evidence is incomplete | Metadata-only retry: "Your handover was incomplete. It must meet the contract." |
| **7 (lowest)** | Validation cleared | Independent evidence matches scope and contract | Mark complete and unlock the next step. |

Maximum: three attempts per task ID. A repeated error signature is a hard stop, not an invitation to consume the remaining budget.

## Step post-mortem and iteration

After a step passes verification, before proceeding to the next step:

1. **For Minimal tier:** The agent's completion likely revealed gaps. Document what was learned in `.internal_master_plan.md` under the step's notes. If a follow-up iteration is needed, add it as a new step (e.g., `STEP-01b`) with Standard tier and a tighter spec based on findings.
2. **For Standard tier:** Ask: did the agent's surprises checklist reveal anything that should tighten future relays? Did the tests actually prove the feature works, or are they testing trivialities? If tests are weak, add stronger assertions to the next relay's testing methodology.
3. **For Full tier:** Cross-check the shared resource contract against parallel steps in the master plan. Any conflict → pause parallel work and resolve.

If a step passes but you suspect the feature is still wrong: escalate to user with evidence before proceeding.

## Clean state before next step

After post-mortem, run `git status`. The working tree should be clean (agent committed their work). If not:

```bash
git status
# If dirty:
git stash   # or commit with descriptive message
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
- If the user changes requirements mid-execution: pause the active step, revise the plan, then resume or restart.
- **Never show or pass the entirety of `.internal_master_plan.md` to any subagent.**

## Learning lifecycle

Every observation receives one classification:

- **core:** project-agnostic orchestration or evidence rule;
- **adapter:** toolchain, environment, provider, or test-runner rule;
- **project-specific:** domain, design, asset, or product rule;
- **historical:** useful evidence that is not an active rule.

A learning enters the reusable template only when it is classified as `core`. Adapter and project-specific learnings remain in the project. Historical learnings remain archived. A single run may justify an adapter rule; core promotion normally requires repetition or an important safety/integrity reason.

## Telemetry

Record, where available: task ID, model/provider, thinking mode, start/end/duration, retries, API/tool-call count, verification levels used, gate result, and error classification. Metrics are observations, not universal model-selection rules.

## Failure → Measure ROI

Add measures only when you hit the corresponding failure. Don't front-load all of them.

| Failure | Add This Measure | ROI |
|---|---|---|
| Agent summarizes tests | Raw output paste (Completion File Contract) | 45x |
| Agent skips hard parts | Surprises checklist | 10x |
| Agent invents data shapes | Shape contract in relay + shape assertion in testing_methodology | High |
| Task too large, agent drifts | ≤30m split (Master plan) | High |
| Parallel relays conflict | Shared resource contract (Full tier) | High |
| Environment mismatch | Agent pre-flight (Full tier) | 18x |
| Agent lies about pre-flight | Stop condition protocol: "Paste raw. Do NOT describe." | Critical |
| State-file pollution | Pre-delegation stash | Preventative |
| Delegate never starts | Delegation error handling | Preventative |
| Step N+1 sees stale files | Clean-state check | Preventative |

## Compatibility

v4 was the JSON relay protocol. v5 introduced direct Markdown delegation context and the first environment-specific tool mandate. v6 keeps direct context, makes the core project-agnostic, and moves environment/project details into adapters. v6.1 adds operational procedures: pre-delegation stash, error handling, clean-state checks, master plan template, iteration patterns, and ROI rankings.

The core is authoritative for orchestration. The adapter is authoritative for local paths, tools, dependencies, tests, protected files, and domain conventions.
