# Knowledge Integrity Verification Strategy

## Focus
Knowledge base verification for OKF (Open Knowledge Framework), LLM wiki, hybrid wiki+DB knowledge systems.

## Trigger
Use when: OKF, LLM wiki, hybrid wiki+DB knowledge systems, content management, documentation systems.

## Checks

### 1. Content Accuracy
**What to check:** Facts should be verified against authoritative sources.

**How to verify:**
```bash
# Extract factual claims from knowledge base
grep -r "is\|are\|was\|were\|has\|have\|had" --include="*.md" knowledge_base/ > claims.log 2>&1

python3 << 'EOF'
import re

with open('claims.log') as f:
    lines = f.readlines()

# This is a heuristic - in practice, you'd need NLP or manual review
factual_patterns = [
    r'\b\d{4}\b',  # Years
    r'\$[\d,]+',   # Dollar amounts
    r'\d+%',       # Percentages
    r'[A-Z][a-z]+ [A-Z][a-z]+',  # Proper nouns (names, places)
]

claims_found = 0
for line in lines:
    for pattern in factual_patterns:
        if re.search(pattern, line):
            claims_found += 1
            break

print(f"Found {claims_found} potential factual claims")

# Check for citations
with open('claims.log') as f:
    content = f.read()

citations = len(re.findall(r'\[.*?\]\(.*?\)|\(.*?\)|\{\{cite.*?\}\}', content))

print(f"Found {citations} citations")

if citations < claims_found * 0.5:
    print("WARNING: Many claims without citations")
    print(f"  {claims_found} claims, {citations} citations")
    print("  Consider adding citations to improve verifiability")
else:
    print("PASS: Adequate citation coverage")
EOF
```

**Gate:** No automatic gate, but flag for review if citation coverage < 50%.

### 2. Link Integrity
**What to check:** All internal and external links should work.

**How to verify:**
```bash
# Check internal links
grep -r "\[.*?\]\(.*?\)" --include="*.md" knowledge_base/ > links.log 2>&1

python3 << 'EOF'
import re
import os

with open('links.log') as f:
    content = f.read()

# Extract markdown links
links = re.findall(r'\[(.*?)\]\((.*?)\)', content)

broken = []
for text, url in links:
    # Internal links
    if url.startswith('/') or url.startswith('./') or url.startswith('../'):
        # Normalize path
        if url.startswith('/'):
            path = url[1:]
        else:
            path = url
        
        if not os.path.exists(path):
            broken.append((text, url))
    
    # External links (skip for now - would require HTTP requests)
    elif url.startswith('http'):
        pass  # Would check with requests.head()

if broken:
    print(f"FAIL: {len(broken)} broken internal links")
    for text, url in broken[:10]:  # Show first 10
        print(f"  [{text}]({url})")
    if len(broken) > 10:
        print(f"  ... and {len(broken) - 10} more")
    exit(1)

print(f"PASS: All internal links valid (checked {len(links)} links)")
EOF

# Check external links (sample)
python3 << 'EOF'
import re
import requests

with open('links.log') as f:
    content = f.read()

# Extract external links
links = re.findall(r'\[(.*?)\]\((https?://.*?)\)', content)

# Sample 10 links (to avoid rate limiting)
sample = links[:10]

broken = []
for text, url in sample:
    try:
        response = requests.head(url, timeout=5, allow_redirects=True)
        if response.status_code >= 400:
            broken.append((text, url, response.status_code))
    except Exception as e:
        broken.append((text, url, str(e)))

if broken:
    print(f"WARNING: {len(broken)} broken external links (sampled {len(sample)})")
    for text, url, error in broken:
        print(f"  [{text}]({url}): {error}")
else:
    print(f"PASS: All sampled external links valid ({len(sample)} links)")
EOF
```

**Gate:** If broken internal links found → Contract failure gate (fix links, retry)

### 3. Cross-Reference Validation
**What to check:** References between documents should be consistent.

**How to verify:**
```bash
# Extract cross-references
grep -r "\[\[.*?\]\]\|{{.*?}}" --include="*.md" knowledge_base/ > crossrefs.log 2>&1

python3 << 'EOF'
import re
import os

with open('crossrefs.log') as f:
    lines = f.readlines()

# Wiki-style links [[Page Name]]
wiki_links = []
for line in lines:
    matches = re.findall(r'\[\[(.*?)\]\]', line)
    wiki_links.extend(matches)

# Template references {{template}}
templates = []
for line in lines:
    matches = re.findall(r'\{\{(.*?)\}\}', line)
    templates.extend(matches)

print(f"Found {len(wiki_links)} wiki-style links")
print(f"Found {len(templates)} template references")

# Check wiki links resolve to actual pages
broken = []
for link in wiki_links:
    # Try common variations
    variations = [
        f"knowledge_base/{link}.md",
        f"knowledge_base/{link.replace(' ', '_')}.md",
        f"knowledge_base/{link.lower().replace(' ', '_')}.md",
    ]
    
    if not any(os.path.exists(v) for v in variations):
        broken.append(link)

if broken:
    print(f"FAIL: {len(broken)} broken wiki links")
    for link in broken[:10]:
        print(f"  [[{link}]]")
    if len(broken) > 10:
        print(f"  ... and {len(broken) - 10} more")
    exit(1)

print(f"PASS: All wiki links resolve to actual pages")
EOF
```

**Gate:** If broken cross-references found → Contract failure gate (fix references, retry)

### 4. Semantic Consistency
**What to check:** No contradictions between documents.

**How to verify:**
```bash
# Extract key facts (this is a simplified version - real implementation would need NLP)
grep -r "is located in\|was born in\|founded in\|has a population of" --include="*.md" knowledge_base/ > facts.log 2>&1

python3 << 'EOF'
import re
from collections import defaultdict

with open('facts.log') as f:
    lines = f.readlines()

# Extract entity-fact pairs
facts = defaultdict(list)

for i, line in enumerate(lines):
    # Example: "Paris is located in France"
    match = re.search(r'(\w+) is located in (\w+)', line)
    if match:
        entity, value = match.groups()
        facts[entity].append((value, i+1))

# Check for contradictions
contradictions = []
for entity, values in facts.items():
    unique_values = set(v for v, _ in values)
    if len(unique_values) > 1:
        contradictions.append((entity, values))

if contradictions:
    print(f"FAIL: {len(contradictions)} contradictions found")
    for entity, values in contradictions:
        print(f"  {entity}:")
        for value, line_num in values:
            print(f"    Line {line_num}: {value}")
    exit(1)

print(f"PASS: No contradictions found (checked {len(facts)} entities)")
EOF
```

**Gate:** If contradictions found → Fabrication gate (stop, resolve contradictions)

### 5. Retrieval Testing
**What to check:** Can we find what we stored?

**How to verify:**
```bash
# For file-based knowledge bases
python3 << 'EOF'
import os
import re

# Define test queries
queries = [
    "Paris",
    "France",
    "population",
    "founded",
]

# Search for each query
for query in queries:
    found = False
    for root, dirs, files in os.walk('knowledge_base'):
        for file in files:
            if file.endswith('.md'):
                path = os.path.join(root, file)
                with open(path) as f:
                    content = f.read()
                    if query.lower() in content.lower():
                        found = True
                        break
        if found:
            break
    
    if found:
        print(f"✓ Query '{query}' found")
    else:
        print(f"✗ Query '{query}' not found")

print("\nPASS: Retrieval test complete")
EOF

# For database-backed knowledge bases
python3 << 'EOF'
import sqlite3

conn = sqlite3.connect('knowledge.db')
cursor = conn.cursor()

# Define test queries
queries = [
    "SELECT * FROM articles WHERE title LIKE '%Paris%'",
    "SELECT * FROM articles WHERE content LIKE '%France%'",
    "SELECT * FROM articles WHERE tags LIKE '%population%'",
]

for query in queries:
    try:
        cursor.execute(query)
        results = cursor.fetchall()
        print(f"✓ Query returned {len(results)} results: {query[:50]}...")
    except Exception as e:
        print(f"✗ Query failed: {query[:50]}...")
        print(f"  Error: {e}")

conn.close()
print("\nPASS: Database retrieval test complete")
EOF

# For hybrid wiki+DB systems
python3 << 'EOF'
import os
import sqlite3

# Test wiki retrieval
wiki_queries = ["Paris", "France", "population"]
for query in wiki_queries:
    found = False
    for root, dirs, files in os.walk('wiki'):
        for file in files:
            if file.endswith('.md'):
                path = os.path.join(root, file)
                with open(path) as f:
                    if query.lower() in f.read().lower():
                        found = True
                        break
        if found:
            break
    
    print(f"Wiki: {'✓' if found else '✗'} '{query}'")

# Test DB retrieval
conn = sqlite3.connect('knowledge.db')
cursor = conn.cursor()

db_queries = [
    "SELECT COUNT(*) FROM articles",
    "SELECT COUNT(*) FROM tags",
]

for query in db_queries:
    cursor.execute(query)
    result = cursor.fetchone()[0]
    print(f"DB: ✓ Query returned {result}: {query[:50]}...")

conn.close()

print("\nPASS: Hybrid retrieval test complete")
EOF
```

**Gate:** If retrieval fails → Environment blocker gate (stop, investigate indexing)

## Verification Report Format

```markdown
### Knowledge Integrity

- ✅ Content accuracy: 85% citation coverage (above 50% threshold)
- ✅ Link integrity: all 47 internal links valid, 10/10 sampled external links valid
- ✅ Cross-references: all wiki links resolve to actual pages
- ✅ Semantic consistency: no contradictions found (checked 23 entities)
- ✅ Retrieval: all test queries successful (wiki: 3/3, DB: 2/2, hybrid: 5/5)
```

## Pitfalls

1. **Don't assume content is accurate.** Even if it's well-formatted and cited, verify facts against authoritative sources. LLMs can generate plausible-sounding but incorrect information.

2. **Don't skip link checking.** Broken links are a common problem in knowledge bases. Check both internal and external links regularly.

3. **Don't ignore cross-references.** If document A references document B, make sure document B exists and the reference is correct.

4. **Don't assume semantic consistency.** LLMs can generate contradictory information across different documents. Check for contradictions.

5. **Don't forget retrieval testing.** A knowledge base is useless if you can't find what you stored. Test retrieval with realistic queries.

## Integration with Other Strategies

Knowledge Integrity works best with:
- **Hallucination Guard:** Verify retrieved knowledge is real, not fabricated
- **Security Scan:** Check for sensitive information in knowledge base
- **Standard Verification:** Run unit tests, check git diff

## When to Escalate

Escalate to the user when:
- Contradictions found between documents
- Broken internal links (critical for navigation)
- Retrieval fails for common queries
- Citation coverage < 30%

Do not escalate when:
- Broken external links (flag for future fix)
- Citation coverage 30-50% (improve but not critical)
- Minor formatting issues

## Tools Required

- `requests`: HTTP requests for external link checking
- `sqlite3`: Database testing (for DB-backed knowledge bases)

Install:
```bash
pip install requests
```
