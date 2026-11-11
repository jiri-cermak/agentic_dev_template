# Visual Regression Verification Strategy

## Focus
Visual testing for web apps, mobile-first web, and UI changes.

## Trigger
Use when: Web apps, mobile-first web, UI changes, frontend development.

## Checks

### 1. Screenshot Comparison (Before/After)
**What to check:** Visual changes should be intentional, not accidental regressions.

**How to verify:**
```bash
# Capture before screenshot
playwright screenshot --viewport-size=1280,720 http://localhost:3000 before.png

# Apply changes...

# Capture after screenshot
playwright screenshot --viewport-size=1280,720 http://localhost:3000 after.png

# Compare screenshots (pixel diff)
python3 << 'EOF'
from PIL import Image, ImageChops
import numpy as np

before = Image.open('before.png')
after = Image.open('after.png')

# Convert to numpy arrays
before_arr = np.array(before)
after_arr = np.array(after)

# Calculate difference
diff = np.abs(before_arr - after_arr)
diff_percentage = np.sum(diff > 0) / diff.size * 100

print(f"Visual difference: {diff_percentage:.2f}%")

# Threshold: < 5% is acceptable (minor rendering differences)
if diff_percentage > 5:
    print("FAIL: Significant visual regression detected")
    exit(1)
else:
    print("PASS: Visual changes within acceptable range")
EOF

# Save diff image for review
python3 << 'EOF'
from PIL import Image, ImageChops
before = Image.open('before.png')
after = Image.open('after.png')
diff = ImageChops.difference(after, before)
diff.save('diff.png')
EOF
```

**Gate:** If diff > 5% → Contract failure gate (review changes, retry if unintended)

### 2. DOM Structure Validation
**What to check:** DOM structure should match expected layout, no missing elements.

**How to verify:**
```bash
# Extract DOM structure
playwright eval --browser=chromium "document.body.innerHTML" > dom_after.html

# Check for required elements
python3 << 'EOF'
from bs4 import BeautifulSoup

with open('dom_after.html') as f:
    soup = BeautifulSoup(f.read(), 'html.parser')

# Check required elements exist
required_selectors = [
    'header nav',
    'main .content',
    'footer',
    '.user-profile',
    '#main-cta'
]

for selector in required_selectors:
    if not soup.select_one(selector):
        print(f"FAIL: Required element '{selector}' not found")
        exit(1)

print("PASS: All required DOM elements present")
EOF
```

**Gate:** If required elements missing → Contract failure gate (retry)

### 3. CSS Property Verification
**What to check:** CSS properties should match design spec.

**How to verify:**
```bash
# Extract computed styles
playwright eval --browser=chromium "
  const el = document.querySelector('.user-profile');
  const styles = window.getComputedStyle(el);
  console.log(JSON.stringify({
    color: styles.color,
    backgroundColor: styles.backgroundColor,
    fontSize: styles.fontSize,
    fontFamily: styles.fontFamily,
    padding: styles.padding,
    margin: styles.margin
  }));
" > styles.json

# Verify against design spec
python3 << 'EOF'
import json

with open('styles.json') as f:
    actual = json.load(f)

# Design spec (from design system or mockup)
expected = {
    'color': 'rgb(33, 37, 41)',  # #212529
    'backgroundColor': 'rgb(255, 255, 255)',  # #ffffff
    'fontSize': '16px',
    'fontFamily': 'Inter, sans-serif',
    'padding': '16px',
    'margin': '0px'
}

for prop, expected_value in expected.items():
    actual_value = actual.get(prop)
    if actual_value != expected_value:
        print(f"FAIL: {prop} = {actual_value}, expected {expected_value}")
        exit(1)

print("PASS: All CSS properties match design spec")
EOF
```

**Gate:** If CSS properties don't match → Contract failure gate (retry)

### 4. Responsive Design Checks
**What to check:** UI should work correctly on mobile, tablet, and desktop viewports.

**How to verify:**
```bash
# Test viewports
viewports=(
  "375,667"   # Mobile (iPhone SE)
  "768,1024"  # Tablet (iPad)
  "1280,720"  # Desktop
)

for viewport in "${viewports[@]}"; do
  echo "Testing viewport: $viewport"
  
  playwright screenshot --viewport-size=$viewport http://localhost:3000 "viewport_${viewport}.png"
  
  # Check for layout issues
  playwright eval --browser=chromium --viewport-size=$viewport "
    const body = document.body;
    const html = document.documentElement;
    
    const height = Math.max(
      body.scrollHeight, body.offsetHeight,
      html.clientHeight, html.scrollHeight, html.offsetHeight
    );
    
    // Check for horizontal overflow (common mobile issue)
    if (body.scrollWidth > html.clientWidth) {
      console.log('FAIL: Horizontal overflow detected');
      process.exit(1);
    }
    
    // Check for reasonable page height (not too short, not too long)
    if (height < 300) {
      console.log('FAIL: Page too short, content may be missing');
      process.exit(1);
    }
    
    console.log('PASS: Viewport OK');
  "
done
```

**Gate:** If horizontal overflow or content missing → Contract failure gate (retry)

### 5. Accessibility Compliance (WCAG 2.1 AA)
**What to check:** UI should meet WCAG 2.1 AA accessibility standards.

**How to verify:**
```bash
# Run axe-core accessibility audit
playwright eval --browser=chromium "
  const axe = require('axe-core');
  axe.run().then(results => {
    console.log(JSON.stringify(results, null, 2));
  });
" > accessibility_report.json

# Check for critical violations
python3 << 'EOF'
import json

with open('accessibility_report.json') as f:
    report = json.load(f)

# WCAG 2.1 AA critical violations
critical_violations = [v for v in report['violations'] if v['impact'] in ['critical', 'serious']]

if critical_violations:
    print(f"FAIL: {len(critical_violations)} critical accessibility violations found")
    for v in critical_violations:
        print(f"  - {v['id']}: {v['description']}")
        print(f"    Impact: {v['impact']}")
        print(f"    Help: {v['helpUrl']}")
    exit(1)

# Count minor violations
minor_violations = [v for v in report['violations'] if v['impact'] in ['moderate', 'minor']]
print(f"PASS: No critical violations ({len(minor_violations)} minor violations)")
EOF
```

**Gate:** If critical violations found → Contract failure gate (retry)

## Verification Report Format

```markdown
### Visual Regression

- ✅ Screenshot comparison: 2.3% diff (within 5% threshold)
- ✅ DOM structure: all required elements present
- ✅ CSS properties: match design spec
- ✅ Responsive design: mobile/tablet/desktop pass (no horizontal overflow)
- ✅ Accessibility: WCAG 2.1 AA compliant (0 critical violations, 3 minor)
```

## Pitfalls

1. **Don't over-threshold screenshots.** 5% diff is reasonable for minor rendering differences (font rendering, anti-aliasing). But if you're changing the entire layout, expect higher diff and review manually.

2. **Use consistent environments.** Screenshot comparison is sensitive to browser version, OS, font rendering. Always use the same browser/OS for before/after. Consider using Docker for consistency.

3. **Don't test visual regression in isolation.** Combine with Hallucination Guard (verify screenshots are real, not fabricated).

4. **Allow intentional changes.** If you're redesigning a page, the diff will be high. That's expected. The key is to review the diff and confirm changes are intentional.

5. **Test real user flows, not just pages.** Screenshot a page is not enough. Test actual user flows (login, checkout, form submission) to catch interaction-related visual issues.

## Integration with Other Strategies

Visual Regression works best with:
- **Hallucination Guard:** Verify screenshots are real, not fabricated
- **Security Scan:** Check for XSS vulnerabilities in dynamic content
- **Standard Verification:** Run unit tests, check git diff

## When to Escalate

Escalate to the user when:
- Screenshot diff is > 20% (major visual regression)
- Critical accessibility violations found
- Horizontal overflow on mobile (common but serious UX issue)
- Required DOM elements missing (functional regression)

Do not escalate when:
- Screenshot diff is < 5% (minor rendering differences)
- Minor accessibility violations (flag for future fix)
- CSS properties are slightly off (e.g., 1px difference)

## Tools Required

- `playwright`: Browser automation for screenshots and DOM evaluation
- `Pillow` (Python): Image comparison
- `beautifulsoup4` (Python): DOM parsing
- `axe-core`: Accessibility testing

Install:
```bash
npm install -g playwright
pip install pillow beautifulsoup4
```
