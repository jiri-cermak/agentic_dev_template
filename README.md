# Tiered Relay Architecture — Bootstrap Seed

Self-contained project scaffolding for the agentic loop development system. Drop these files into any new project to start working with the Architect → Subagent → Verify workflow.

## Files

| File | Purpose |
|---|---|
| `AGENTS.md` | Protocol — the Master Architect's instruction set. Read first. |
| `_relay_context_template.md` | Context template — accumulated environment learnings. Copy → fill in → paste into `delegate_task`. |
| `bootstrap.sh` | One-command init for a new project directory. |

## Quick Start

```bash
./bootstrap.sh /opt/data/projects/my-new-project
```

This creates the full workspace: git repo, handover directories, state files, exclude patterns, protocol, and template.

## What Gets Bootstrapped

```
my-new-project/
├── AGENTS.md                          ← protocol rules
├── .internal_master_plan.md           ← Architect-only plan (empty)
├── devlog.md                          ← subagent activity log (empty)
├── handovers/
│   ├── _relay_context_template.md        ← copy+paste into delegate_task
│   ├── done/                              ← subagent completion reports
│   └── archive/                           ← completed step archives
└── learnings/                         ← per-step observation files
```

All state files are gitignored via `.git/info/exclude`.

## After Bootstrap

1. Edit `handovers/_relay_context_template.md` — update project name, absolute paths, `study` references, and `do_not_touch` list for your stack.
2. Write your first master plan in `.internal_master_plan.md`.
3. Start the loop: plan → build context from template → delegate → verify.

## Origin

Extracted from the Plausit project after 3 relay iterations. Core learnings baked in:
- Docker daemon unavailable in subagent environment
- Python stdlib replaces missing shell tools (xxd, od, unzip, file) — §D mandate
- Direct `delegate_task` context replaces JSON relay files (Phase 2 v5)
- `execute_code` approval gate avoided by embedding instructions directly
- CSS grep assertions need regex patterns to handle whitespace variance
- Self-verification loops catch real bugs (confirmed 2 catches in STEP-03)
- Git identity must be configured before first commit
- Font downloads: gwfh.mranftl.com API, `?download=zip` endpoint, Python zipfile extraction
