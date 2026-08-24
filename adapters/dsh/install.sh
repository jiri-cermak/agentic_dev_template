#!/usr/bin/env bash
set -euo pipefail

# Install DSH adapter for a project
# Usage: ./install.sh /path/to/project

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

echo "Installing DSH adapter into $PROJECT_DIR..."

# Create .dsh-shims directory
SHIM_DIR="$PROJECT_DIR/.dsh-shims/dsh"
mkdir -p "$SHIM_DIR"

# Copy adapter files
cp "$SCRIPT_DIR/README.md" "$SHIM_DIR/"
cp "$SCRIPT_DIR/SKILL.md" "$SHIM_DIR/"
echo "  ✓ Copied adapter files to .dsh-shims/dsh/"

# Exclude from git
EXCLUDE_FILE="$PROJECT_DIR/.git/info/exclude"
if ! grep -qxF ".dsh-shims/" "$EXCLUDE_FILE" 2>/dev/null; then
  echo ".dsh-shims/" >> "$EXCLUDE_FILE"
  echo "  ✓ Excluded .dsh-shims/ from git"
else
  echo "  • .dsh-shims/ already excluded"
fi

# Install SKILL.md to user-level DSH skills directory (if DSH is installed)
if command -v dsh &> /dev/null; then
  DSH_SKILLS_DIR="${DSH_HOME:-$HOME/.dsh}/skills/dsh-architect"
  mkdir -p "$DSH_SKILLS_DIR"
  cp "$SCRIPT_DIR/SKILL.md" "$DSH_SKILLS_DIR/SKILL.md"
  echo "  ✓ Installed SKILL.md to $DSH_SKILLS_DIR"
else
  echo "  • DSH not found in PATH; skipping user-level skill install"
  echo "    Install DSH with: npm install -g @deepseek-ai/dsh"
fi

echo ""
echo "Done. See $SHIM_DIR/README.md for setup instructions."
