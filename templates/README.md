# GitHub gate pattern — adoption guide

This directory holds the reusable GitHub gate pattern that a bootstrapped
project adopts by **copy** to enforce its loop gates locally and surface them
remotely. Branch protection is unavailable on private+Free-plan repos, so there
are two complementary layers:

- **`hooks/pre-push`** — the *blocking* gate. Runs the loop/state/index checks
  in the working tree and refuses the push on any failure. Lives locally because
  a push cannot be refused server-side without branch protection.
- **`github/loop-gates.yml`** — the *detector*. A minute-cheap GitHub Actions
  workflow that surfaces the same drift on push/PR/weekly, catching pushes a
  foreign clone made without the hook configured.
- **`checks/index_check.sh`** — the canonical history-index integrity check; the
  canonical copy that a project's `ops/index_check.sh` is drawn from.

## Adopt (per project)

1. **`ops/`** — copy the check scripts your project carries (only the ones it
   needs; kubera-class projects have a subset) into the project's `ops/`. Start
   with `checks/index_check.sh` → `ops/index_check.sh`. `ops/loop_check.sh`
   (core drift vs the project's upstream pin + its own freeze manifest) and
   `ops/state_check.sh` (state-file budgets/probes) are project-shaped and are
   written per project against this pattern.
2. **`.githooks/`** — `mkdir -p .githooks && cp hooks/pre-push .githooks/pre-push
   && chmod +x .githooks/pre-push && git config core.hooksPath .githooks`.
   `core.hooksPath` is per-clone and does NOT transfer with a clone — set it on
   every clone that pushes (this container is where every push originates, so it
   is set during bootstrapping).
3. **`.github/workflows/`** — copy `github/loop-gates.yml` as
   `.github/workflows/loop-gates.yml`.

## Record the adoption

The project's *adapter / bootstrap text* is the right place to record that these
gates are active (hook install command, `core.hooksPath` note, which check
scripts are carried). That prose **rides the project's next freeze bump** — it is
documented at the next bump rather than bundled into it, so adoption and the
version/reuse pin stay in lockstep and the gate files land standalone today
without forcing a re-pin of the project's loop upstream hashes.
