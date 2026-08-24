# Tiered Relay Architecture v6 — Core Protocol

This document defines the project-agnostic orchestration loop. It does not define a project's stack, tools, domain, or deployment environment. Those belong in the project adapter (`.agents.md` and the relay context template).

**Agnosticism principle:** Core files use `{PLACEHOLDER}` tokens and generic capability verbs only; concrete tool/CLI names live in adapters.

## Roles

- **Architect:** plans, writes relay context, delegates, independently verifies, records learnings, and controls retries. Does not write feature code.
- **Subagent:** executes only the assigned relay context, changes only named target files, runs the specified tests, commits the result, and writes the handover.
- **Verification gate:** accepts evidence only when it is reproducible from the workspace and matches the target boundary.

## Loop

1. **Plan** — classify the requirement and create/update `.internal_master_plan.md`.
2. **Pre-flight** — verify repository root, clean/known working tree, target paths, and adapter readiness.
3. **Relay** — construct a self-contained Markdown context with absolute paths, scope, constraints, tests, stop conditions, and handover contract.
4. **Delegate** — dispatch the relay context directly. Do not use JSON relay payload files.
5. **Execute** — subagent edits only target files, validates, commits explicit files, and writes post-commit handover evidence.
6. **Verify** — Architect audits the handover and independently re-runs the declared tests.
7. **Gate** — pass, retry with a classified correction, or stop/escalate.
8. **Post-mortem** — record evidence and classify each new learning before propagating it.
9. **Stabilize** — confirm the workspace and master plan are consistent before unlocking the next step.

## Requirement tiers

- **Minimal:** loose requirement; goal, target files, tests, handover, and stop conditions.
- **Standard:** known feature; adds constraints, shape contract, and surprises checklist.
- **Full:** stable multi-relay work; adds shared-resource contract, dependency map, pre-flight, and explicit stop conditions.

Keep each relay below 30 minutes of expected execution. Split larger work. Never unlock a dependent step before the verification gate passes.

## Relay invariants

Every relay context must contain:

- project name and absolute project root;
- task ID and execution profile;
- self-contained task description;
- absolute target file paths with create/modify action;
- files explicitly out of scope;
- adapter-declared tool and dependency boundaries;
- verbatim testing methodology with at least one structural assertion and one negative assertion;
- stop conditions for known environment dead ends;
- exact handover path and contract;
- explicit commit procedure.

The first subagent command must verify location:

```text
cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel
```

Do not rely on a `workdir` metadata field unless the runtime has independently demonstrated that it changes the actual working directory. Absolute paths remain mandatory.

**Skill isolation:** Keep the project adapter as a dotfile in every project. The harness scans a fixed set of project-convention files (concrete filenames defined in the adapter) for auto-discovery. A dotfile is invisible to progressive subdirectory discovery, preventing the harness from injecting project context as a virtual skill. The relay context is the subagent's sole source of rules.

## Verification levels

Choose verification depth according to the artifact changed:

1. **Structural:** always required. Parse or inspect the output shape with a runtime assertion.
2. **Negative:** always required. Prove a forbidden dependency, forbidden file, invalid state, or out-of-scope mutation is absent.
3. **Runtime:** required for runnable applications, services, or served assets.
4. **Browser/DOM:** required when UI, HTML rendering, CSS behavior, or client-side JavaScript changes. Check console errors and key DOM/state properties.
5. **Visual screenshot:** optional. If unavailable or failing, do not loop on the vision provider; use browser console/DOM checks as the fallback.

The adapter declares exact commands and available tools. The core defines the required evidence categories, not a universal command set. Verification is not satisfied by judgment alone — every relay declares machine-verifiable `success_criteria:` (next section) that the gate evaluates deterministically.

## Machine-verifiable success criteria

Every relay must declare `success_criteria:` as machine-checkable items that a deterministic verifier evaluates without judgment. Supported types:

- `test_id` — a named test, identified by its exact ID, that must pass;
- `diff_check` — a file plus a literal string it must contain;
- `checksum` — a file plus the expected hash of its contents;
- `exit_code` — a command plus its expected exit code.

The gate passes only when **all** declared checks pass. The Architect reads the report and the check results, not raw output. Where a check is machine-evaluable, no second judgment is applied — the model is removed from that verification path.

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

## Gate matrix

Apply the first matching rule:

| Gate | Condition | Action |
|---|---|---|
| Fabrication | Claimed evidence contradicts the workspace or cannot be reproduced | Stop and escalate. |
| Stagnation | Same error signature recurs after a correction | Stop, record signature, escalate. |
| Environment blocker | Missing daemon, package, credential, or permission cannot be fixed within scope | Stop immediately; do not burn retries. |
| Spec drift | Test or path is wrong because the relay is underspecified | Prune context, correct relay, retry. |
| Execution error | Subagent failed to execute an otherwise valid relay | Retry with a focused correction; two consecutive failures escalate. |
| Machine check failed | A valid declared `success_criteria` check did not pass | Retry with a focused correction; two consecutive failures escalate. |
| Contract failure | Code passes but handover/evidence is incomplete | Metadata-only retry. |
| Validation cleared | Independent evidence matches scope and contract | Mark complete and unlock the next step. |

Maximum: three attempts per task ID. A repeated error signature is a hard stop, not an invitation to consume the remaining budget.

## Learning lifecycle

Every observation receives one classification:

- **core:** project-agnostic orchestration or evidence rule;
- **adapter:** toolchain, environment, provider, or test-runner rule;
- **project-specific:** domain, design, asset, or product rule;
- **historical:** useful evidence that is not an active rule.

A learning enters the reusable template only when it is classified as `core`. Adapter and project-specific learnings remain in the project. Historical learnings remain archived. A single run may justify an adapter rule; core promotion normally requires repetition or an important safety/integrity reason.

## Telemetry

Record, where available: task ID, model/provider, thinking mode, start/end/duration, retries, API/tool-call count, verification levels used, gate result, and error classification. Metrics are observations, not universal model-selection rules.

## Compatibility

v4 was the JSON relay protocol. v5 introduced direct Markdown delegation context and the first environment-specific tool mandate. v6 keeps direct context, makes the core project-agnostic, and moves environment/project details into adapters.

The core is authoritative for orchestration. The adapter is authoritative for local paths, tools, dependencies, tests, protected files, and domain conventions.
