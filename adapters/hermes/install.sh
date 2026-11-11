#!/usr/bin/env bash
set -euo pipefail

# Install the Hermes adapter for a project.
# Usage: ./install.sh /path/to/project
#
# Equivalent to: ./bootstrap.sh /path/to/project --adapter hermes
# Copies this adapter into the project's .adapter-shims/hermes/ and
# excludes .adapter-shims/ from git.

if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/project"
  exit 1
fi

PROJECT_DIR="$1"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: $PROJECT_DIR is not a directory"
  exit 1
fi

if [ ! -f "$PROJECT_DIR/CORE_PROTOCOL.md" ]; then
  echo "Error: $PROJECT_DIR does not appear to be bootstrapped with agentic_dev_template"
  echo "Run bootstrap.sh first"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Hermes adapter into $PROJECT_DIR..."

SHIM_DIR="$PROJECT_DIR/.adapter-shims/hermes"
mkdir -p "$SHIM_DIR"

cp -r "$SCRIPT_DIR"/. "$SHIM_DIR"/
echo "  ✓ Copied adapter files to .adapter-shims/hermes/"

EXCLUDE_FILE="$PROJECT_DIR/.git/info/exclude"
if ! grep -qxF ".adapter-shims/" "$EXCLUDE_FILE" 2>/dev/null; then
  echo ".adapter-shims/" >> "$EXCLUDE_FILE"
fi
echo "  ✓ .adapter-shims/ excluded from git"

echo ""
echo "Done. Next steps:"
echo "  1. Read .adapter-shims/hermes/README.md for setup / provider check"
echo "  2. Apply tier → reasoning-effort mapping before each dispatch"
echo "  3. Start with the session opener in the adapter README"
