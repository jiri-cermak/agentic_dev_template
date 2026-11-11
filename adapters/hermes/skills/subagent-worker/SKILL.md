---
name: subagent-worker
version: 1.0.0
description: Subagent execution for Tiered Relay Architecture on Hermes — read relay context, pre-flight, edit target files only, run tests verbatim, commit, write handover.
triggers:
  - when: acting as a subagent executing a relay task
  - when: executing a relay context in a Hermes Agent session
  - when: writing a handover file
---

# Subagent Worker Skill (Hermes)

## Trigger

Use when: acting as a subagent executing a relay task.

## Obligations

1. **Read only the relay context** — do not open ARCHITECTURE.md, PLAN.md, or any source not listed in constraints
2. **Location pre-flight** — `cd {PROJECT_ROOT} && pwd && git rev-parse --show-toplevel`
3. **Edit only target files** — never modify out-of-scope files
4. **Run tests verbatim** — paste complete raw output, never summarize
5. **Stage explicit files only** — `git diff --cached --name-only` must match target_files
6. **Commit** — `git commit -m '{TASK_ID}: short description'`
7. **Write handover** — to `handovers/done/completion-{TASK_ID}.md` with all required headings
8. **Complete surprises checklist** — truthfully disclose every deviation

## Handover format

For full tier (5 headings):
1. Raw Test Output — complete, unabridged
2. Git Evidence — `git log --oneline -1`, `git diff HEAD~1 --stat`, `git status --short`
3. Files Changed — table with File Path, Action, Size (bytes), First Line
4. Surprises Checklist — every box checked or unchecked, with description if any checked
5. Contract Enforcement — state where structural/negative/shape assertions appear

For lite tier (2 headings):
1. Summary — 1-2 sentences
2. Diff — git diff summary or file list

## Progress reporting (if requested)

If relay context includes `progress_interval: N`, write `handovers/{TASK_ID}/progress.md` every N steps with:
- Current step
- Files touched
- % complete estimate

## Abort handling

Check for `handovers/{TASK_ID}/abort.md` between steps. If present:
1. Stop work immediately
2. Write partial handover (what was done, what remains)
3. Exit cleanly

## Pitfalls

- Do NOT read files outside the relay context
- Do NOT summarize test output — paste raw
- Do NOT use `git add -A` — stage only target files
- Do NOT claim "all tests pass" without raw output
- Do NOT modify files not in target_files
- Do NOT add dependencies not in constraints
