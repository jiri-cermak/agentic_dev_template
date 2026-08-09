# Relay Context Template — trebon-sites

Copy this block into `delegate_task` `context`. Fill in `REPLACE_ME` fields.
Update as new patterns emerge in `learnings/*.md`.

```
**Project:** trebon-sites at /opt/data/projects/trebon-sites
**Task ID:** STEP-NN
**Profile:** thinking_type: disabled, reasoning_effort: null

## Task
REPLACE_ME — Self-contained. No project shorthand, no "as discussed."

## Target Files
- `/opt/data/projects/trebon-sites/REPLACE_ME` — create | modify

## Constraints
**Study:**
- /opt/data/projects/trebon-sites/REPLACE_ME — reference files for conventions
- /opt/data/projects/redesign/NEW_V5_design_specification.md — canonical design source

**Do NOT touch:**
- AGENTS.md, .internal_master_plan.md, devlog.md
- handovers/, learnings/, .git/
- nginx.conf, shared.conf, Dockerfile, scripts/

**Boundaries:**
- NO npm packages
- NO build steps (Tailwind/PostCSS/webpack)
- NO frameworks (React/Vue/Svelte)
- NO pip install (unavailable in container)
- NO apt-get/apt install (no sudo)
- CSS/HTML/JS only — no backend code

## Testing Methodology
REPLACE_ME — Verbatim shell commands. Must include ≥1 negative test + ≥1 structural assertion.

Rules:
- ALL hex/file/archive operations use Python stdlib, not xxd/od/unzip/file — see §D
- Docker is UNAVAILABLE — use python3 -m http.server for web validation
- Background server pattern:
  python3 -m http.server PORT --bind 127.0.0.1  (use terminal background=true)
  curl -sS http://localhost:PORT/path
  kill $(lsof -t -i:PORT) 2>/dev/null || pkill -f 'http.server PORT'
- CSS grep: use regex like 'prop.*value' not 'prop:value' — whitespace varies
- grep -c exit code 1 on zero matches → append || true for negative tests
- Verification scripts go under /opt/data/, not /tmp/

## Stop Conditions
- ⚠️ STOP: If Docker commands fail, do NOT attempt to install or start Docker. Use python3 -m http.server instead.
- ⚠️ STOP: If pip/apt-get/apt fail, do NOT attempt alternative package managers. Work with what's installed.
- ⚠️ STOP: If git commit fails with 'Author identity unknown', run: git config user.email 'architect@trebon-sites' && git config user.name 'Master Architect'. ONE attempt only.
- ⚠️ STOP: Avoid raw IPs/URLs in git commit messages — use descriptive text instead.
- ⚠️ STOP: Do NOT use Fontsource CDN / npm-based font packages — blocked by security scanner. Use gwfh API instead.
- ⚠️ GWLINK — Google WebFonts Helper API for font downloads:
  curl -sL -o fonts.zip "https://gwfh.mranftl.com/api/fonts/FAMILY?download=zip&subsets=latin,latin-ext&variants=WEIGHTS&formats=woff2"
  Then extract with: python3 -c "import zipfile; zipfile.ZipFile('fonts.zip').extractall('fonts/')"

## Handover
Write to: `handovers/done/completion-STEP-NN.md`

Required sections (Contract §A):
1. Raw Test Output — complete terminal dump, never summarized
2. Git Evidence — git log --oneline -1 + git diff HEAD~1 --stat
3. Files Table — | File Path | Action | Lines Added | Lines Deleted |
4. Surprises Checklist:
   - Did every command succeed on first attempt?
   - Did you read anything outside this relay context?
   - Did any test need adjustment beyond what was specified?
   - Did you modify any file NOT in target_files?
   - Did you add any dependency not in constraints?
5. Contract Enforcement — negative case + shape assertions confirmed

## Commit
Use the EOF pattern — avoids shell escaping issues:
```
git commit -F - << 'EOF'
STEP-NN: short description of what was done
EOF
```
Commit messages: no raw IPs, use descriptive text. After commit, keep working tree clean.
```
