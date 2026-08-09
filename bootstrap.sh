#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a new project with the Tiered Relay Architecture scaffolding.
# Usage: ./bootstrap.sh /opt/data/projects/my-new-project

BOOTSTRAP_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 /path/to/new/project"
  exit 1
fi

if [ -d "$TARGET" ]; then
  echo "Target exists: $TARGET"
else
  echo "Creating: $TARGET"
  mkdir -p "$TARGET"
fi

echo "Bootstrapping Tiered Relay Architecture v4 into $TARGET"

# ── Git repo ──
if [ ! -d "$TARGET/.git" ]; then
  git -C "$TARGET" init
  echo "  ✓ git init"
else
  echo "  • git repo already exists"
fi

# ── AGENTS.md ──
cp "$BOOTSTRAP_DIR/AGENTS.md" "$TARGET/AGENTS.md"
echo "  ✓ AGENTS.md"

# ── Relay template ──
mkdir -p "$TARGET/handovers/done" "$TARGET/handovers/archive"
cp "$BOOTSTRAP_DIR/_relay_context_template.md" "$TARGET/handovers/_relay_context_template.md"
echo "  ✓ handovers/_relay_context_template.md"

# ── Learnings dir ──
mkdir -p "$TARGET/learnings"
echo "  ✓ learnings/"

# ── Internal state files ──
touch "$TARGET/.internal_master_plan.md"
touch "$TARGET/devlog.md"
echo "  ✓ .internal_master_plan.md"
echo "  ✓ devlog.md"

# ── Git exclude patterns ──
EXCLUDE_FILE="$TARGET/.git/info/exclude"
for pattern in ".internal_master_plan.md" "relay_payload_*.json" "retry_context.json" "devlog.md" "handovers/" "learnings/"; do
  if ! grep -qxF "$pattern" "$EXCLUDE_FILE" 2>/dev/null; then
    echo "$pattern" >> "$EXCLUDE_FILE"
  fi
done
echo "  ✓ .git/info/exclude (6 patterns)"

echo ""
echo "Done. Next steps:"
echo "  1. Edit $TARGET/handovers/_relay_context_template.md — set project name and paths"
echo "  2. Create initial master plan in $TARGET/.internal_master_plan.md"
echo "  3. Start building."
