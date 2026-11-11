#!/usr/bin/env bash
set -euo pipefail

# Layer Hermes-specific files over an agentic_dev_template scaffold.
# Usage: ./bootstrap_hermes.sh /path/to/project

if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/project"
  exit 1
fi

PROJECT_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: $PROJECT_DIR is not a directory"
  exit 1
fi

# Check if agnostic core is present
if [ ! -f "$PROJECT_DIR/CORE_PROTOCOL.md" ]; then
  echo "⚠ Agnostic core not found. Bootstrapping agentic_dev_template first..."
  AGNOSTIC_DIR="$SCRIPT_DIR/../tra-v6-agentic-dev-template"
  if [ ! -d "$AGNOSTIC_DIR" ]; then
    echo "Error: Cannot find agentic_dev_template at $AGNOSTIC_DIR"
    echo "Clone it first: git clone https://github.com/jiri-cermak/agentic_dev_template.git"
    exit 1
  fi
  bash "$AGNOSTIC_DIR/bootstrap.sh" "$PROJECT_DIR"
  echo ""
fi

echo "Layering Hermes-specific files over $PROJECT_DIR..."

# Replace agnostic SOUL.md with hermes SOUL.md
cp "$SCRIPT_DIR/SOUL.md" "$PROJECT_DIR/SOUL.md"
echo "  ✓ SOUL.md (hermes-specific)"

# Add hermes overlay files
cp "$SCRIPT_DIR/CORE_PROTOCOL_hermes_overlay.md" "$PROJECT_DIR/"
echo "  ✓ CORE_PROTOCOL_hermes_overlay.md"

cp "$SCRIPT_DIR/_relay_context_hermes.md" "$PROJECT_DIR/handovers/"
echo "  ✓ handovers/_relay_context_hermes.md"

cp "$SCRIPT_DIR/.agents_hermes_template.md" "$PROJECT_DIR/"
echo "  ✓ .agents_hermes_template.md"

# Install hermes skills
HERMES_SKILLS_DIR="${HERMES_HOME:-$HOME/.hermes}/skills"
mkdir -p "$HERMES_SKILLS_DIR"

for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  if [ -d "$skill_dir" ]; then
    skill_name=$(basename "$skill_dir")
    cp -r "$skill_dir" "$HERMES_SKILLS_DIR/$skill_name"
    echo "  ✓ skill: $skill_name"
  fi
done

# Copy protocol modes
if [ -d "$SCRIPT_DIR/protocol_modes" ]; then
  mkdir -p "$PROJECT_DIR/protocol_modes"
  cp -r "$SCRIPT_DIR/protocol_modes"/* "$PROJECT_DIR/protocol_modes/"
  echo "  ✓ protocol modes"
fi

# Copy verification strategies
if [ -d "$SCRIPT_DIR/verification_strategies" ]; then
  mkdir -p "$PROJECT_DIR/verification_strategies"
  cp -r "$SCRIPT_DIR/verification_strategies"/* "$PROJECT_DIR/verification_strategies/"
  echo "  ✓ verification strategies"
fi

# Copy orchestration modes
if [ -d "$SCRIPT_DIR/orchestration_modes" ]; then
  mkdir -p "$PROJECT_DIR/orchestration_modes"
  cp -r "$SCRIPT_DIR/orchestration_modes"/* "$PROJECT_DIR/orchestration_modes/"
  echo "  ✓ orchestration modes"
fi

# Copy plugin system
if [ -d "$SCRIPT_DIR/plugins" ]; then
  mkdir -p "$PROJECT_DIR/plugins"
  cp -r "$SCRIPT_DIR/plugins"/* "$PROJECT_DIR/plugins/"
  echo "  ✓ plugin system"
fi

# Add hermes files to .gitignore
GITIGNORE="$PROJECT_DIR/.gitignore"
touch "$GITIGNORE"
for pattern in "CORE_PROTOCOL_hermes_overlay.md" "_relay_context_hermes.md" ".agents_hermes_template.md"; do
  if ! grep -qxF "$pattern" "$GITIGNORE" 2>/dev/null; then
    echo "$pattern" >> "$GITIGNORE"
  fi
done
echo "  ✓ .gitignore updated"

echo ""
echo "Done. Next steps:"
echo "  1. Start a Hermes session with: session_openers/standard.md"
echo "  2. For trivial tasks, use: session_openers/lite.md"
echo "  3. See examples/ for usage patterns"
