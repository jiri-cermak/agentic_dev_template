# Plugin System

## Overview

The Hermes Agentic Template uses a plugin architecture to allow modular, composable extensions. Plugins can add new skills, verification strategies, protocol modes, orchestration modes, and more.

## Plugin Types

### 1. Skill Plugins
Add new skills that agents can use. Skills are markdown files with frontmatter that define:
- Trigger conditions
- Step-by-step procedures
- Integration with other skills

Example: `skills/code-review/SKILL.md`

### 2. Verification Strategy Plugins
Define how to verify agent work. Strategies include:
- What to check
- How to check it
- Pass/fail criteria

Example: `verification_strategies/security_scan.md`

### 3. Protocol Mode Plugins
Define different workflow protocols:
- Primitives: Minimal overhead
- Standard: Full verification
- Custom: User-defined

Example: `protocol_modes/iterative.md`

### 4. Orchestration Mode Plugins
Define how agents coordinate:
- Fire-and-forget
- Iterative
- Supervised
- Collaborative
- Parallel
- Hierarchical

Example: `orchestration_modes/parallel.md`

## Plugin Manifest

Every plugin must have a `plugin.yaml` file in its root directory:

```yaml
name: my-plugin
version: 1.0.0
type: skill | verification_strategy | protocol_mode | orchestration_mode
description: What this plugin does
author: Your Name
license: MIT

# Dependencies on other plugins
dependencies:
  - name: hermes-core
    version: ">=1.0.0"

# Plugin capabilities
capabilities:
  - name: code-review
    description: Review code for best practices
    
# Entry point (for executable plugins)
entry: null  # or path to executable

# Configuration options
config:
  strict_mode: false
  output_format: markdown
```

## Plugin Directory Structure

```
hermes-agentic-template/
├── plugins/
│   ├── code-review/
│   │   ├── plugin.yaml
│   │   └── SKILL.md
│   ├── security-scan/
│   │   ├── plugin.yaml
│   │   └── verify.py
│   └── iterative-mode/
│       ├── plugin.yaml
│       └── protocol.md
├── skills/           # Built-in skills
├── verification_strategies/
├── protocol_modes/
└── orchestration_modes/
```

## Installing Plugins

### Local Installation
```bash
# Copy plugin to plugins directory
cp -r my-plugin/ ~/.hermes/plugins/

# Or use the plugin manager (if available)
hermes plugin install ./my-plugin
```

### Plugin Discovery
Hermes automatically discovers plugins in:
1. `~/.hermes/plugins/` - User plugins
2. `./plugins/` - Project plugins
3. Built-in plugins in the template

## Using Plugins

### In Relay Context
```markdown
**Plugin:** code-review
**Version:** 1.0.0

## Task
Review this code for security issues.
```

### In Configuration
```yaml
# .agents.md or project config
plugins:
  enabled:
    - code-review
    - security-scan
  disabled:
    - experimental-feature
```

## Creating a Plugin

### Step 1: Create Directory
```bash
mkdir -p plugins/my-plugin
cd plugins/my-plugin
```

### Step 2: Create Manifest
```bash
cat > plugin.yaml << 'EOF'
name: my-plugin
version: 1.0.0
type: skill
description: My custom plugin
author: Your Name
license: MIT
dependencies: []
capabilities:
  - name: my-capability
    description: What it does
EOF
```

### Step 3: Implement Plugin
For a skill:
```markdown
# SKILL.md
---
name: my-plugin
version: 1.0.0
triggers:
  - when: user asks for code review
---

# My Plugin

## Steps
1. Analyze the code
2. Check for issues
3. Provide recommendations
```

### Step 4: Test Plugin
```bash
# Test in isolation
hermes plugin test ./plugins/my-plugin

# Test in a real session
hermes session --plugin my-plugin
```

## Plugin Lifecycle

1. **Discovery**: Hermes scans plugin directories
2. **Validation**: Check manifest and dependencies
3. **Loading**: Load plugin into memory
4. **Execution**: Use plugin in sessions
5. **Cleanup**: Unload when session ends

## Plugin Dependencies

Plugins can depend on other plugins:

```yaml
dependencies:
  - name: hermes-core
    version: ">=1.0.0"
  - name: code-analysis
    version: "^2.0.0"
```

Hermes will:
- Check if dependencies are installed
- Warn if versions don't match
- Fail if critical dependencies are missing

## Best Practices

1. **Version your plugins**: Use semantic versioning (MAJOR.MINOR.PATCH)
2. **Document thoroughly**: Include README.md with examples
3. **Test independently**: Plugins should work in isolation
4. **Declare dependencies**: List all external requirements
5. **Keep it focused**: One plugin = one capability
6. **Use standard formats**: Follow YAML/Markdown conventions

## Plugin Security

Plugins can execute arbitrary code. Security considerations:

1. **Sandbox execution**: Run plugins in isolated environments
2. **Permission model**: Declare required permissions in manifest
3. **Audit logging**: Log all plugin actions
4. **Code review**: Review plugin code before installation

## Troubleshooting

### Plugin not loading
- Check `plugin.yaml` syntax
- Verify dependencies are installed
- Check Hermes logs: `hermes logs`

### Plugin conflicts
- Disable conflicting plugins
- Check version compatibility
- Review plugin capabilities

### Performance issues
- Profile plugin execution
- Check for infinite loops
- Optimize resource usage

## Examples

See `plugins/examples/` for sample plugins:
- `code-review/` - Skill plugin
- `security-scan/` - Verification strategy
- `iterative-mode/` - Protocol mode
- `parallel-orchestration/` - Orchestration mode
