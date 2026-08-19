#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a new project with the Tiered Relay Architecture v6.1 scaffold.
# Usage: ./bootstrap.sh /absolute/path/to/project [--adapter <name>]

BOOTSTRAP_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET=""
ADAPTER=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --adapter)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --adapter requires a name"
        exit 1
      fi
      ADAPTER="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Usage: $0 /absolute/path/to/new/project [--adapter <name>]"
      exit 1
      ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$1"
        shift
      else
        echo "Error: unexpected argument: $1"
        exit 1
      fi
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "Usage: $0 /absolute/path/to/new/project [--adapter <name>]"
  exit 1
fi

if [ -d "$TARGET" ]; then
  echo "Target exists: $TARGET"
else
  echo "Creating: $TARGET"
  mkdir -p "$TARGET"
fi

echo "Bootstrapping Tiered Relay Architecture v6.1 into $TARGET"

if [ ! -d "$TARGET/.git" ]; then
  git -C "$TARGET" init
  echo "  ✓ git init"
else
  echo "  • git repo already exists"
fi

cp "$BOOTSTRAP_DIR/CORE_PROTOCOL.md" "$TARGET/CORE_PROTOCOL.md"
cp "$BOOTSTRAP_DIR/.agents.md" "$TARGET/.agents.md"
cp "$BOOTSTRAP_DIR/SOUL.md" "$TARGET/SOUL.md"
echo "  ✓ CORE_PROTOCOL.md"
echo "  ✓ .agents.md"
echo "  ✓ SOUL.md"

mkdir -p "$TARGET/handovers/done" "$TARGET/handovers/archive"
cp "$BOOTSTRAP_DIR/_relay_context_template.md" "$TARGET/handovers/_relay_context_template.md"
echo "  ✓ handovers/_relay_context_template.md"

mkdir -p "$TARGET/learnings"
echo "  ✓ learnings/"

touch "$TARGET/.internal_master_plan.md"
touch "$TARGET/devlog.md"
echo "  ✓ .internal_master_plan.md"
echo "  ✓ devlog.md"

EXCLUDE_FILE="$TARGET/.git/info/exclude"
for pattern in ".internal_master_plan.md" "retry_context.json" "devlog.md" "handovers/" "learnings/"; do
  if ! grep -qxF "$pattern" "$EXCLUDE_FILE" 2>/dev/null; then
    echo "$pattern" >> "$EXCLUDE_FILE"
  fi
done
echo "  ✓ .git/info/exclude"

# Handle --adapter flag
if [ -n "$ADAPTER" ]; then
  ADAPTER_DIR="$BOOTSTRAP_DIR/adapters/$ADAPTER"
  if [ ! -d "$ADAPTER_DIR" ]; then
    echo ""
    echo "Error: adapter '$ADAPTER' not found"
    echo "Available adapters:"
    if [ -d "$BOOTSTRAP_DIR/adapters" ]; then
      for dir in "$BOOTSTRAP_DIR/adapters"/*/; do
        if [ -d "$dir" ]; then
          name=$(basename "$dir")
          echo "  - $name"
        fi
      done
    else
      echo "  (none)"
    fi
    exit 1
  fi

  # Copy adapter to project
  ADAPTER_TARGET="$TARGET/.dsh-shims/$ADAPTER"
  mkdir -p "$ADAPTER_TARGET"
  cp -r "$ADAPTER_DIR"/* "$ADAPTER_TARGET"/
  echo "  ✓ harness adapter $ADAPTER installed (optional; not part of the agnostic core)"

  # Exclude .dsh-shims from git
  if ! grep -qxF ".dsh-shims/" "$EXCLUDE_FILE" 2>/dev/null; then
    echo ".dsh-shims/" >> "$EXCLUDE_FILE"
  fi
  echo "  ✓ .dsh-shims/ excluded from git"
fi

echo ""
echo "Done. Next steps:"
echo "  1. Replace {PLACEHOLDERS} in $TARGET/.agents.md"
echo "  2. Replace {PLACEHOLDERS} in $TARGET/handovers/_relay_context_template.md"
echo "  3. Create the initial master plan in $TARGET/.internal_master_plan.md"
echo "  4. Classify requirement tier (Minimal/Standard/Full)"
echo "  5. Start: plan → stash → pre-flight → relay → delegate → verify"

if [ -n "$ADAPTER" ]; then
  echo ""
  echo "Adapter installed: $ADAPTER"
  echo "See $TARGET/.dsh-shims/$ADAPTER/README.md for setup instructions."
fi
