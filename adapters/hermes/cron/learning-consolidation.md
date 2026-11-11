# Learning Consolidation Cron Job

Schedule: weekly (or every 10 relays)

## Purpose

Consolidate learnings from `learnings/` into Mnemosyne and archive old items.

## Cron prompt

```
Read learnings/pending.md and learnings/promoted.md.

For each learning in pending.md:
1. Classify as core/adapter/project-specific/historical
2. If core → propose promotion to CORE_PROTOCOL.md
3. If project-specific → persist to Mnemosyne persona memory
4. If pattern → persist to Mnemosyne episodic memory
5. If historical → archive to learnings/archive/

Prune: move items older than 30 days from pending.md to learnings/archive/

Report: count of items processed, promoted, archived.
```

## Setup

```bash
# Create cron job
hermes cron add --name "learning-consolidation" --schedule "0 9 * * 1" --prompt "$(cat cron/learning-consolidation.md)"
```

## Manual trigger

```bash
hermes cron run learning-consolidation
```
