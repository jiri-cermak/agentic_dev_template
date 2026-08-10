# Tiered Relay Architecture v6 — Bootstrap Template

A project-agnostic scaffold for the Architect → Subagent → Verify workflow.

## Files

| File | Purpose |
|---|---|
| `SOUL.md` | Model-neutral Architect identity and invariant principles |
| `CORE_PROTOCOL.md` | Stable, project-agnostic orchestration rules |
| `AGENTS.md` | Project adapter: local root, stack, tools, tests, and protected files |
| `_relay_context_template.md` | Direct `delegate_task` context template |
| `bootstrap.sh` | Creates the scaffold in a new project |
| `review_by_sol_2026-08-09.md` | Design review and rationale for v6 |

## Quick start

```bash
./bootstrap.sh /absolute/path/to/new-project
```

Then replace all adapter placeholders in `AGENTS.md` and `handovers/_relay_context_template.md`, write `.internal_master_plan.md`, and start:

```text
plan → pre-flight → relay → delegate → verify → gate → post-mortem
```

## Generated workspace

```text
new-project/
├── SOUL.md
├── AGENTS.md
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

## v6 design

v6 separates stable orchestration from local assumptions:

- **Core:** lifecycle, evidence gates, retry rules, git safety, handover contract, and learning promotion.
- **Adapter:** project paths, tools, dependencies, test commands, protected files, and domain conventions.
- **Run evidence:** handovers, devlog, and classified learnings.

v4 used JSON relay payloads. v5 introduced direct Markdown context. v6 keeps direct context and makes the template genuinely project-agnostic.

## Learning policy

Classify every observation as `core`, `adapter`, `project-specific`, or `historical`. Promote only repeatable project-agnostic rules into `CORE_PROTOCOL.md`.

## Safety

The template uses placeholders intentionally. Do not copy environment-specific assumptions from another project without verifying them. Relay agents must stage explicit target files only and independently reproduce the declared tests.

## Rationale

See `review_by_sol_2026-08-09.md` for the full findings-to-change mapping and the changes deliberately not promoted into core.

## License

Add the license appropriate for your use of this template.
