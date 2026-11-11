# Hermes Agent Adapter

Run the Tiered Relay Architecture v6.2 with Hermes Agent (Nous Research) as the Architect's harness. This adapter layers the Hermes-specific overlay onto a project bootstrapped from the agnostic core.

## Supersedes the standalone overlay repo

This directory is the re-homed home of the former standalone repository
`github.com/jiri-cermak/hermes_agentic_template` (Hermes Agentic Template v2). That
repo is now **retired** — it is referenced by nothing in this org and would drift if
kept in parallel. Its content lives here, under `adapters/hermes/`, as a first-class
adapter so an org has one canonical upstream (this template) and every harness
overlay is a subdirectory of it. Do not edit the retired repo; change `adapters/hermes/`
instead.

The original repository `README.md` is preserved verbatim as `OVERLAY-README.md` (its
"Installation — clone + bootstrap_hermes.sh" section is historical; the modern install
is the `--adapter hermes` flag below). Two overlay files were captured from the retired
repo's working tree, so they carry uncommitted `§9 Subagent tool restriction` /
`## Tool restriction` content that was never in a commit there:
`CORE_PROTOCOL_hermes_overlay.md` and `_relay_context_hermes.md`.

## Prerequisites

- Hermes Agent installed (the harness runs on the Host profile / project profile)
- Project bootstrapped with `agentic_dev_template`
- Read `OVERLAY-README.md` for the overlay's feature set (Mnemosyne memory, live
  subagent steering, multi-platform gateway, FTS5 session search, profile isolation)

## Installation

### Option 1: Bootstrap with adapter flag (recommended)

```bash
./bootstrap.sh /path/to/project --adapter hermes
```

This copies the whole `adapters/hermes/` directory into the project's
`.adapter-shims/hermes/` and excludes `.adapter-shims/` from git.

### Option 2: Manual install

```bash
cp -r adapters/hermes/ /path/to/project/.adapter-shims/hermes/
```

## First-time setup / provider check

1. **Verify Hermes is installed** and the profile resolves:
   ```bash
   hermes --version
   hermes -p <architect-profile> config get delegation.reasoning_effort
   ```
   Use the absolute binary path if `hermes` is not on the terminal PATH. Prefer the
   profile's own home for config writes (`-p <profile>`) so the shared root config is
   never touched.

2. **Apply the tier → reasoning-effort mapping** (from the promoted `.agents.md`
   "Local execution profile by tier" section) before dispatching each relay. The
   delegation mechanism carries no reasoning parameter — only a config write on the
   spawn path changes a subagent's effort.

3. **Install skills/plugins** from the overlay into the harness profile:
   - `skills/` → the harness's skills directory
   - `plugins/` and `protocol_modes/`, `orchestration_modes/`, `verification_strategies/`
     per the overlay docs in `OVERLAY-README.md`

## Session opener

Start each Hermes session with this message:

> Act as the Architect per SOUL.md. Read CORE_PROTOCOL.md and .agents.md before
> delegating. Load the Hermes overlay (CORE_PROTOCOL_hermes_overlay.md) and the relay
> template (_relay_context_hermes.md). Classify the requirement tier
> (Minimal/Standard/Full). Begin: plan → stash → pre-flight → relay → delegate →
> verify → gate → post-mortem → stabilize.

## First relay

1. **Architect fills the Hermes relay template** (`_relay_context_hermes.md`):
   - Replace all `{...}` placeholders
   - Set `tier: minimal|standard|full`
   - Include the `## Tool restriction` deny-list (per the overlay §9)
   - Include shape contract (Standard/Full tiers) and success criteria
2. **Architect invokes `delegate_task`** with the filled relay context as the prompt.
3. **Subagent executes:** runs location pre-flight
   (`cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel`), edits only target
   files, runs tests verbatim, stages explicit files only, commits, and writes the
   handover to `handovers/{TASK_ID}/completion.md`.
4. **Architect verifies:** audits the handover + execution record, checks the Files
   Changed table (`wc -c`, `head -1`, `sha256sum`), confirms the subagent's commit is
   latest (`git log -1`), independently re-runs the declared tests, and applies the
   gate matrix.
5. **Post-mortem:** classify learnings (core/adapter/project-specific/historical),
   persist to Mnemosyne, iterate if needed (Minimal tier: Probe → Discover → Refine →
   Implement).

## Key files (this adapter)

- `CORE_PROTOCOL_hermes_overlay.md` — Hermes-specific extensions over the agnostic core
- `_relay_context_hermes.md` — Hermes relay template (with tool-restriction deny-list)
- `SOUL.md` — Hermes Architect identity overlay
- `.agents_hermes_template.md` — project-adapter template for a Hermes project
- `protocol_modes/`, `orchestration_modes/`, `verification_strategies/`, `session_openers/`,
  `skills/`, `plugins/`, `cron/` — overlay subsystems
- `OVERLAY-README.md` — the original overlay readme, preserved verbatim
- `bootstrap_hermes.sh` — legacy standalone overlay installer (now equivalent to
  `--adapter hermes`); retained for reference

## References

- `CORE_PROTOCOL.md` — orchestration core (agnostic)
- `.agents.md` — project adapter skeleton (covers the promoted adapter practices)
- `CORE_PROTOCOL_hermes_overlay.md` — Hermes extensions
