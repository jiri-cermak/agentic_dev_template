#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a new project with the Tiered Relay Architecture v6 scaffold.
# Usage: ./bootstrap.sh /absolute/path/to/project

BOOTSTRAP_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 /absolute/path/to/new/project"
  exit 1
fi

if [ -d "$TARGET" ]; then
  echo "Target exists: $TARGET"
else
  echo "Creating: $TARGET"
  mkdir -p "$TARGET"
fi

echo "Bootstrapping Tiered Relay Architecture v6 into $TARGET"

if [ ! -d "$TARGET/.git" ]; then
  git -C "$TARGET" init
  echo "  ✓ git init"
else
  echo "  • git repo already exists"
fi

cp "$BOOTSTRAP_DIR/CORE_PROTOCOL.md" "$TARGET/CORE_PROTOCOL.md"
cp "$BOOTSTRAP_DIR/AGENTS.md" "$TARGET/AGENTS.md"
cp "$BOOTSTRAP_DIR/SOUL.md" "$TARGET/SOUL.md"
echo "  ✓ CORE_PROTOCOL.md"
echo "  ✓ AGENTS.md"
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

echo ""
echo "Done. Next steps:"
echo "  1. Replace {PLACEHOLDERS} in $TARGET/AGENTS.md"
echo "  2. Replace {PLACEHOLDERS} in $TARGET/handovers/_relay_context_template.md"
echo "  3. Create the initial master plan in $TARGET/.internal_master_plan.md"
echo "  4. Start: plan → pre-flight → relay → delegate → verify"
