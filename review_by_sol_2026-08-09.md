# Review by Sol — Tiered Relay Architecture v6

**Date:** 2026-08-09  
**Repository:** `jiri-cermak/agentic_dev_template`  
**Review basis:** Plausit Run 1, trebon-sites Run 1, trebon-sites Run 2, and the GitHub template at commit `23ac3ae`.

## Executive decision

The template should not simply copy the newest trebon-sites `AGENTS.md`. Trebon-sites is a better and newer run, but it contains environment and web-project assumptions. The correct change is to extract stable orchestration rules into a project-agnostic core and keep local assumptions in an adapter.

This release implements that separation as **v6**.

## Findings → implementation

| Finding | v6 change | Location |
|---|---|---|
| v4/v5 naming was inconsistent | Added explicit compatibility history and v6 naming | `CORE_PROTOCOL.md`, `README.md`, `bootstrap.sh` |
| Core mixed with trebon-sites assumptions | Replaced hardcoded project details with placeholders and adapter fields | `AGENTS.md`, `_relay_context_template.md` |
| No learning lifecycle | Added `core`, `adapter`, `project-specific`, `historical` classification | `CORE_PROTOCOL.md`, `AGENTS.md` |
| Browser verification was accidental | Added verification taxonomy: structural, negative, runtime, browser/DOM, visual optional | `CORE_PROTOCOL.md`, relay template |
| CWD/workdir was unreliable | Required first-command root verification and absolute target paths | `CORE_PROTOCOL.md`, relay template |
| Tool policy was over-generalized | Tool availability and dependency policy moved to adapter placeholders | `AGENTS.md`, relay template |
| Git staging boundary was too soft | Explicitly prohibit `git add -A`/`git add .`, require staged-file audit | `CORE_PROTOCOL.md`, relay template |
| Handover was not machine-checkable enough | Exact five headings and required post-commit evidence | `CORE_PROTOCOL.md`, relay template |
| Model findings risked becoming universal rules | Telemetry is retained; model preferences remain adapter/run evidence | `CORE_PROTOCOL.md` |
| Bootstrap still printed v4 | Bootstrap output now prints v6 | `bootstrap.sh` |

## What was intentionally not promoted to core

These findings are valuable but local and therefore belong in adapters or run records:

- Docker unavailable in one subagent environment;
- exact missing shell-tool list and Python replacements;
- GWFH font download procedure;
- trebon-sites untracked image policy;
- HTML/CSS grep details;
- browser provider limitations;
- specific model preference such as FLASH over PRO;
- project-specific SEO, design, asset, and deployment rules.

## Why v6 uses an adapter

A reusable template cannot safely assume that every project:

- uses HTML/CSS;
- has Docker unavailable;
- has the same shell tools missing;
- uses Python as its verification language;
- has browser tools;
- downloads fonts;
- shares the same protected files or deployment model.

The core therefore defines the evidence and control contract, while the adapter defines executable local commands and boundaries.

## Evidence from the two runs

### Plausit Run 1

Exposed wrong-CWD discovery, Docker recovery waste, and the value of self-verification.

### trebon-sites Run 1

Confirmed direct context and batch parallelism, but structural tests alone missed rendered-output issues and an iframe/design mismatch.

### trebon-sites Run 2

Browser/DOM verification caught quality issues that grep could not. It also showed that visual screenshot tooling may fail while browser console/DOM inspection remains usable. This supports a generic verification taxonomy and fallback, not a universal browser command.

## Migration notes

Existing projects using the old protocol can migrate incrementally:

1. Keep their domain `AGENTS.md` and local learnings.
2. Copy the v6 core concepts and classify existing rules.
3. Replace hardcoded template values with adapter values.
4. Update relay contexts to include absolute root, target boundary, exact tests, and the five handover headings.
5. Do not rewrite historical run records.

## Scope of this release

This release changes the GitHub template only. It does not automatically rewrite Plausit, trebon-sites, or any other project. Existing project adapters should be migrated deliberately after their local constraints are reviewed.

## Final principle

New learnings improve the system through controlled promotion:

```text
run evidence → classification → adapter or core proposal → verification → promotion
```

A newer project run is evidence for improvement, not permission to copy all of its local assumptions into the global protocol.

— Sol
เขียนโดย Sol
