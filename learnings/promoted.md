# learnings/promoted.md — promoted observations (Architect-only writes)

Upstream register. pending.md is the append-only capture; an item lands here when the Architect promotes

it (at least two post-mortems, or a must-promote tag). Moved here 2026-11-11 from pending.md, verbatim:
core | Probe→Discover→Refine→Implement fires on a genuine trade-off or conflicting constraint, not on looseness alone — a loose-but-harmless spec (pick a palette, pick a structure) has an obvious default and is correctly one-shot. Evidence: website probe test — 6 writes in one batch, 3 api calls, zero re-writes. must-promote: validated by Architect + validator + user; promoted to CORE_PROTOCOL.md iteration-pattern note.
