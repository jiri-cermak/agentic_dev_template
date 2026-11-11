# Lite Session Opener (Hermes)

For trivial tasks (≤2 files, no new dependencies, reversible). Copy this message:

---

Act as the Architect per SOUL.md. This is a lite relay (Minimal tier).

Read CORE_PROTOCOL.md and CORE_PROTOCOL_hermes_overlay.md and .agents.md.

Task: {TASK_DESCRIPTION}

Target files:
- {FILE_1}
- {FILE_2}

Tests:
```bash
{TEST_COMMAND}
```

Constraints:
- No new dependencies
- Reversible change only

Handover format (2 headings):
1. Summary — 1-2 sentences
2. Diff — git diff summary or file list

Gate: fabrication, contract, cleared only.

Max 1 attempt. If it fails, escalate to human.

Begin: plan → stash → pre-flight → delegate → verify → gate.
