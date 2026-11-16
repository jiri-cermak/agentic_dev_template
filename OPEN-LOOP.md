# OPEN-LOOP — Agentic-loop workstream resume note

> Last verified: **2026-11-16** · Upstream `agentic_dev_template` at tag **v6.2.2**.

## 1. What this file is

This is the resume note for the **agentic-loop workstream** and its backlog. When
the owner says "agentic loop", read this file first, then act on an item only if
its **trigger** (a stated condition) has fired.

It is **not** a protocol document. The protocol is `CORE_PROTOCOL.md` — the
single source of loop rules. This note does **not** restate core rules; if a rule
lives in core, go read it there. This note only records: the loop's current
state, what is parked and under what trigger, what rides the next bump, and what
is merely being considered. When a parked item is done or a trigger fires, update
the table/dates here so the next session starts from truth.

A one-line pointer to this file lives in Hermes memory for convenience; memory
holds no backlog. Per project, the live-state handoff is `CONTEXT_RESTART.md`
(split-mode projects) or the single `CONTEXT_RESTART.md` (legacy projects) — this
file is upstream-wide, not project-wide.

## 2. State of the loop

| Participant | Layout | Pinned to | Status |
|---|---|---|---|
| **Upstream** (`agentic_dev_template`) | full template | self — `core-manifest.sha256` pins the 5 core files at each tag | tag **v6.2.2**; agnosticism gate green; tree clean |
| **jong** (`/opt/data/projects/jong`) | split | upstream **v6.2** (`60ff79f`), 4 adopted files pinned verbatim | **v6.3**, tag `loop-v6.3-jong-freeze-20261111`; gates `ops/loop_check.sh`, `ops/state_check.sh`, `ops/index_check.sh`; `.githooks/pre-push` + `core.hooksPath`; CI `loop-gates` green |
| **t_unity** (`/opt/data/projects/t_unity`) | split | upstream **v6.2** (`60ff79f`), 3 adopted files pinned verbatim | **v6.2.7**, tag `loop-v6.2.7-t-unity` (local — not pushed); same three gates; `.githooks/pre-push` + `core.hooksPath`; CI green |
| **Legacy set** (kubera, nuad, …) | legacy | none — no pin, no `ops/state_check.sh`, no gates | single `CONTEXT_RESTART.md`, dated log below the marker |

Upstream core = `CORE_PROTOCOL.md`, `SOUL.md`, `.agents.md`, `bootstrap.sh`,
`_relay_context_template.md`. The manifest verifies `5/5`. jong and t_unity
exclude `.agents.md` because each keeps its own project adapter (frozen
separately); t_unity also drops `bootstrap.sh`. The architect-profile
`session-close` routine detects layout (`CONTEXT_HISTORY.md` + `ops/state_check.sh`
present → **SPLIT MODE**, else **LEGACY MODE**) and runs the gates accordingly.

**Version scheme:** upstream core bumps stay on **v6.2.x** (v6.2 canonical, v6.2.1
docs-only, v6.2.2 core) because **v6.3 is kubera's direct-copy freeze**
(2026-10-16), not an upstream tag — reusing the number would give two different
file sets one name.

## 3. Parked items — with triggers

These are not scheduled; each runs only when its trigger fires.

### P1 · CONTEXT_HISTORY.md growth policy

**Trigger = doubling.** Both split projects keep a date-indexed `CONTEXT_HISTORY.md`
(log per session) with an index at its head. It has doubled once and will again.

- jong: **298,351 B / 2,984 lines**
- t_unity: **114,678 B / 1,082 lines**

**The cost that motivates it:** a whole read of jong's log is ~80–86k tokens per
session — large enough to distort every future session's context budget and to
discourage actually reading it.

**The decision to make:** retention window vs rotation vs archive-by-year (the
index must survive either way, and `ops/index_check.sh` asserts its integrity —
the split must not break that gate). For each project at next doubling, decide
and record the outcome here.

**Re-measure (exact):** `wc -lc CONTEXT_HISTORY.md` in the project root of jong
and t_unity. Fire the item when either value has ~doubled since the figures above.

### P2 · This note's own staleness

**Trigger = any version bump or un-pin.** Every time jong/t_unity/kubera bumps
its freeze tag or unpins upstream, this note's section 2 (and any figures in it,
e.g. the log sizes above) _may_ go stale. Re-verify section 2 against the repos
before trusting it, and update this file rather than leaving drift.
This note itself is documentation (like `templates/`), so it never needs a new
upstream tag by itself — a tag is required only when canonizing it changes a
project's adopted core.

## 4. Riding the next natural bump in each project

Not parked; these ride the project's next freeze bump rather than landing in
isolation, so the version/reuse pin and the adoption prose stay in lockstep
(see `templates/README.md`, "Record the adoption").

- **jong's next bump** — record, in the adapter's bootstrap-guard prose: the
  installed pre-push hook (`.githooks/pre-push`, `core.hooksPath`=`.githooks`)
  and the core pin (`adapters/loop-upstream-v6.2.sha256`). The gate files are in
  already; the prose describing them is not.
- **t_unity's next bump** — same pair, same timing.

## 5. Candidate next work — not yet decided

These are ideas with shape but no owner decision. Do not start them early.

- **Migrate kubera (and each later project) to split layout + the three gates**
  by copying `templates/` (`checks/index_check.sh` → `ops/index_check.sh`;
  `hooks/pre-push` → `.githooks/pre-push` + `core.hooksPath`; `github/loop-gates.yml`
  → `.github/workflows/loop-gates.yml`), writing project-shaped
  `ops/loop_check.sh` and `ops/state_check.sh` per project. All gates must be
  **demonstrated to fail first**, and any pre-existing state that would go red on
  day one must be fixed or **grandfathered in writing** (see §6).
- **Whether kubera gets CI.** Proxy for the general rule: adopt the detector only
  where pushes can originate from clones that lack the hook. Decide per project.
- **Branch protection (deferred).** Unavailable on private Free-plan repos
  ("Upgrade to GitHub Pro or make this repository public") — so per-project CI is
  a **detector** and only the versioned `.githooks/pre-push` **blocks**. Pushes
  originate in this container, which is why the hook is effective. The open
  question is the price: upgrade to Pro or open the repos — owner decision, not
  architect's.
- **Name the pruning destination in `CORE_PROTOCOL.md`.** §Learning lifecycle says `pending.md` items older
  than 30 days "are archived" but never says where. The first prune (2026-11-11, jong) used
  `learnings/archive/pending-<date>.md` — a de-facto convention, not canon. Decide and amend the core; it
  rides an upstream bump.
- **A promotion sweep before the next prune.** Pruning archives never-promoted items, so unmined `[core]`
  observations become invisible to the promotion pass (jong's archive holds a large backlog; t_unity keeps
  per-file learnings and has no `pending.md`, so it is unaffected). Decide whether to promote the ≥2-occurrence
  core items first, or accept the archive as their permanent home.

## 6. Invariants worth preserving

Hard-won rules, stated with the evidence that produced them.

- **A gate must be demonstrated to FAIL, not just pass.** Passing proves nothing
  the code already accepts; a designed failure proves the gate actually gags.
  Run each new gate against a deliberately broken input once and keep the red
  evidence where the project records gates.
- **A gate red on day one is worse than no gate.** Shipping a gate that the
  current tree fails means every push and every CI run cries wolf forever — it
  dies from noise. Either make it green before it gates, or **grandfather the
  specific existing case explicitly, in writing** (named, dated), never by
  lowering the bar.
- **Verbatim moves inherit present-tense claims.** When you adopt someone's text
  unchanged after deleting a file, a sentence that was true there (e.g. "the
  guide is at X") can silently become false here. A verbatim move can make a
  `README`'s claims lie. Corrections are **declared and dated, never silent** —
  if a moved line is no longer true, fix the prose and say so, on the same bump.
- **Measure from the repository you are changing.** A whole proposal was once
  drafted against the wrong repo's state. Verify `pwd`/target paths before
  reading sizes, gates, or history; never carry measurements across projects.
- **Per-project adapters stay per-project.** Only the five-file core is unified
  and pinned. `.agents.md`, bootstrap guards, state caps, and gate budgets are
  project-specific (jong's caps/preamble differ from t_unity's) and must not be
  folded upstream.
- **Hook `core.hooksPath` is per-clone, not per-repo.** It does not transfer with
  a clone, which is precisely why the container re-sets it during bootstrapping
  and why the CI detector matters at all. Never assume a fresh clone is gated.
- **Process lives in the protocol; skills carry tools.** A skill that decides what
  to do — triage, gating, next steps — becomes a second source of loop rules and
  loads in every session matching its trigger. When a skill accumulates
  instructions rather than commands, fold the process into `CORE_PROTOCOL.md` (or
  the adapter) and leave the skill a tool. Evidence (2026-11-16):
  `plan-verification` was loaded in **26 of 27** sessions for the words "next
  steps" — it had become the de-facto triage skill; deleting its next-steps
  section (31.1 KB → 28.5 KB) removed the trigger. Three process skills were
  archived the same day (`project-next-block-triage` 435 patches,
  `relay-gate-authoring` 31 patches in a day, `documents-of-record` 25).

## 7. One-command verification of the whole loop

Run each; green means the loop is intact.

**Upstream** (`cd /opt/data/projects/agentic_dev_template`):

```bash
sha256sum -c core-manifest.sha256          # 5/5 OK
# agnosticism scan — must print NO matches:
grep -rniE "dsh|delegate_task|deepseek|hermes|browser_navigate|browser_console|browser_vision" \
  CORE_PROTOCOL.md SOUL.md .agents.md bootstrap.sh _relay_context_template.md
git status --porcelain                      # empty (tree clean)
```

**Each split project** (jong, t_unity; `cd /opt/data/projects/<name>`):

```bash
bash ops/loop_check.sh    # core drift vs the project's upstream pin + its freeze manifest
bash ops/state_check.sh   # state-file budgets/probes (caps + hard limits)
bash ops/index_check.sh   # CONTEXT_HISTORY.md index integrity
git config core.hooksPath # must print .githooks
# CI detector (GitHub API), green bool. Both repos are PRIVATE, so the call must
# authenticate (via the org token in /opt/data/.env — NOT committed to the repo),
# and must FAIL LOUDLY if it cannot read the runs instead of silently 403ing.
set -a; . /opt/data/.env; set +a   # exports GITHUB_TOKEN from the local env file
runs=$(curl -sf -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/jiri-cermak/<name>/actions/workflows/loop-gates.yml/runs?per_page=1")
[ -z "$runs" ] && { echo "ERROR: could not read CI runs (auth or network)" >&2; exit 1; }
echo "$runs" | grep -o '"conclusion":"success"'
```

**Legacy projects:** no gates — the whole check is reading `CONTEXT_RESTART.md`
(dated log below the marker) and confirming no orphaned references to removed
state files.

## 8. Skill-watcher tripwires

A daily job (`/root/ops-manual/scripts/hermes-skill-watch.py` in the architect
profile; runs 05:30 UTC, reported in the 08:05 briefing) produces four signals.
The first two are context; the last two are **tripwires** — a hit means a skill is
doing the protocol's job, so fold the process back into core and archive the
skill.

- **New skills since the baseline** — either the protocol has a gap, or a tool was
  authored in the wrong place.
- **Cumulative most-patched** — churn where the rule sits means it is unstable
  there.
- **Process candidates** — unpinned skill over **12 KB** with **≥8 patches in 14
  days**. Size plus churn says it triages or blocks, rather than carrying a tool.
- **Big and heavily patched** — unpinned skill over **24 KB** with **≥40 patches**:
  the same diagnosis at a later stage.

Motivating evidence (2026-11-16): the three skills archived that day totalled 491
patches, and `plan-verification` — loaded in 26 of 27 sessions — is the case these
tripwires exist to catch.
