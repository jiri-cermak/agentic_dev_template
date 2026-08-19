# Harness Adapters

This directory contains optional, harness-specific shims that let a bootstrapped
project run the Tiered Relay Architecture with a particular agent runtime.

## Rules

1. **Core ≠ harness names.** `CORE_PROTOCOL.md`, `SOUL.md`, `.agents.md`, and
   `_relay_context_template.md` contain no harness-specific terminology.
2. **Shims are self-contained.** Each adapter lives in `adapters/<name>/` and
   can be installed into a project without modifying core files.
3. **Shims may reference core files, but core may not reference shims.**
   The agnostic core has no knowledge of which adapters exist.

## Directory contract

Every `adapters/<name>/` should provide:
- `README.md` — session opener, provider check, first relay instructions
- `install.sh` or clear install instructions
- Any artifacts whose format is native to that harness (skills, presets, etc.)

## Available adapters

- `dsh/` — DeepSeek Harness adapter

## How to use

```bash
./bootstrap.sh /path/to/project --adapter <name>
```

This copies `adapters/<name>/` into the project's `.dsh-shims/<name>/` and
excludes it from git. The core scaffold remains unchanged.

## Proposing a new adapter

1. Create `adapters/<name>/` with the standard structure
2. Add a `README.md` with setup instructions
3. Test with `./bootstrap.sh /tmp/test --adapter <name>`
4. Submit a PR with the new adapter

## Deleting adapters

If you no longer need an adapter, delete the `adapters/<name>/` directory.
The core scaffold continues to work unchanged.
