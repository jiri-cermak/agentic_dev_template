# Overnight Watch Cron Job

Schedule: daily at 23:00

## Purpose

Watch repo for uncommitted changes, failed tests, or stale handovers. Alert via gateway if issues found.

## Cron prompt

```
Check project health:

1. git status — are there uncommitted changes?
2. Run tests — do they pass?
3. Check handovers/ — are there stale handovers (older than 7 days)?
4. Check .internal_master_plan.md — are there pending tasks?

If any issue found:
- Write summary to devlog.md
- Notify via gateway (if configured): "⚠️ Overnight watch: {issue summary}"

If all clear:
- Log to devlog.md: "✓ Overnight watch: all clear"
- No gateway notification
```

## Setup

```bash
# Create cron job
hermes cron add --name "overnight-watch" --schedule "0 23 * * *" --prompt "$(cat cron/overnight-watch.md)"
```

## Manual trigger

```bash
hermes cron run overnight-watch
```
