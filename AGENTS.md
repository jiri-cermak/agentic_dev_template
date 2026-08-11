# Tiered Relay Architecture v6 — Project Adapter

This file combines the project-agnostic core protocol with the adapter for this project. Read `CORE_PROTOCOL.md` first. The sections below define only local project facts and must not be treated as universal rules.

## Adapter identity

- **Project:** {PROJECT_NAME}
- **Root:** {PROJECT_ROOT}
- **Stack:** {STACK}
- **Primary profile:** {PROFILE}
- **Reference specification:** {REFERENCE_SPEC_OR_NONE}

## Local bootstrap guard

Before delegating:

```bash
cd {PROJECT_ROOT}
pwd
git rev-parse --show-toplevel
git status --short
```

Confirm that the repository exists, the adapter's required environment is available, internal state is excluded, and the target files are present or intentionally created by the relay. If a required environment is missing, stop and report it; do not install packages unless the adapter explicitly permits it.

**Skill isolation:** Every `delegate_task` call MUST set `workdir` to a directory outside the project root (e.g., `workdir="/opt/data"`). Some runtimes auto-detect project context files from the working directory and inject them as virtual skills. Running subagents outside the project root prevents this — the relay context is the subagent's sole source of rules.

## Local protected files

Do not modify unless a relay explicitly names them:

- `AGENTS.md`
- `CORE_PROTOCOL.md`
- `.internal_master_plan.md`
- `devlog.md`
- `handovers/`
- `learnings/`
- `.git/`
- {PROJECT_SPECIFIC_PROTECTED_FILES}

## Local boundaries

Replace this list for the project. Do not copy restrictions from another project without verifying them.

- **Allowed tools:** {ALLOWED_TOOLS}
- **Unavailable tools:** {UNAVAILABLE_TOOLS}
- **Dependencies:** {DEPENDENCY_POLICY}
- **Build/deploy policy:** {BUILD_DEPLOY_POLICY}
- **External resources:** {EXTERNAL_RESOURCE_POLICY}

## Local testing adapter

Every relay must declare exact commands appropriate to its artifact. Include:

1. one structural runtime assertion;
2. one negative assertion;
3. runtime proof when the artifact is served or executable;
4. browser/DOM proof when UI or client-side behavior changes.

The adapter may define Python stdlib replacements, browser commands, server startup, ports, cleanup, and provider-specific fallbacks. Do not put those assumptions into the core unless they are genuinely project-agnostic.

## Local handover additions

Use the core's exact five heading contract. Add project-specific evidence requirements here only when needed:

- {PROJECT_SPECIFIC_HANDOVER_REQUIREMENTS}

## Local learning register

Store run observations in `learnings/`. Classify every observation as `core`, `adapter`, `project-specific`, or `historical`. Only `core` observations may be proposed for propagation into `CORE_PROTOCOL.md`; adapter rules remain local.

## Operating rule

The core protocol defines the orchestration lifecycle, evidence gates, retry behavior, git safety, and learning lifecycle. This adapter defines the project. If they appear to conflict, stop and resolve the ambiguity before delegation.

See: `CORE_PROTOCOL.md` and `handovers/_relay_context_template.md`.
