# Playwright Setup for Claude Code - Verification & Direct Browser Control

This guide sets up **two powerful capabilities** for Claude Code:

1. **Verification Tests**: Pre-written tests to check the app after changes
2. **MCP Playwright Server**: Direct browser control for Claude to explore, debug, and verify in real-time

## What This Enables

### With Verification Tests:
- ✅ Run automated checks after code changes
- ✅ Regression testing for existing functionality
- ✅ Visual comparison testing

### With MCP Playwright Server:
- ✅ **Claude can control the browser directly**
- ✅ Navigate to pages and click elements
- ✅ Fill forms and interact with UI
- ✅ Take screenshots on demand
- ✅ Debug issues by exploring the app
- ✅ Verify changes without pre-written tests
- ✅ **Ad-hoc testing and exploration**

## Example: How Claude Uses Both

```
User: "Change the primary blue color to #1a8fff"

Claude:
1. I'll update the color in app.css
2. [Edits the file]
3. Let me verify with the automated tests
4. [Runs: cd tests/e2e && pnpm test]
5. ✅ Tests pass!
6. Now let me take a screenshot to show you the new color
7. [Uses MCP: playwright_navigate to http://localhost:5008]
8. [Uses MCP: playwright_screenshot]
9. Here's what it looks like: [shows screenshot]
```

---

## Part 1: Install MCP Playwright Server (PRIORITY)

This gives Claude direct browser control - **do this first!**

### Step 1: Install the MCP Playwright Server

```bash
# Install globally with npx (recommended)
npm install -g @modelcontextprotocol/server-playwright
```

Or check the latest installation method:
- GitHub: https://github.com/modelcontextprotocol/servers
- NPM: https://www.npmjs.com/package/@modelcontextprotocol/server-playwright

### Step 2: Configure Claude Code to Use MCP Server

Add the MCP server to your Claude Code configuration:

**Location**: `~/.claude/config.json` or wherever your Claude Code config is

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-playwright"
      ]
    }
  }
}
```

**Alternative if installed globally:**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "mcp-server-playwright"
    }
  }
}
```

### Step 3: Restart Claude Code

After updating config:
```bash
# Restart your Claude Code session
# Or restart the application
```

### Step 4: Verify MCP Server is Working

Ask Claude: "Can you navigate to http://localhost:5008 using Playwright and take a screenshot?"

If working, you'll see MCP tools available like:
- `mcp__playwright__navigate`
- `mcp__playwright__screenshot`
- `mcp__playwright__click`
- `mcp__playwright__fill`
- `mcp__playwright__evaluate`

---

## Part 2: Set Up Verification Tests (OPTIONAL BUT RECOMMENDED)

Pre-written tests for common scenarios.

### Prerequisites

- [ ] Node.js installed (check: `node --version` - need v18+)
  - If missing: https://nodejs.org/
- [ ] pnpm installed (check: `pnpm --version`)
  - If missing: `npm install -g pnpm`

### Step 5: Create Test Directory

```bash
# From project root
mkdir -p tests/e2e
cd tests/e2e
pnpm init -y
```

### Step 6: Install Playwright for Tests

```bash
# Install Playwright test runner
pnpm add -D @playwright/test

# Install browser
pnpm exec playwright install chromium
```

### Step 7: Create Configuration File

Create `tests/e2e/playwright.config.ts`:

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './specs',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 1,
  reporter: [['html', { open: 'never' }]],

  use: {
    baseURL: 'http://localhost:5008',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  // Automatically start the Blazor app before tests
  webServer: {
    command: 'cd ../.. && dotnet run --project OctopusHardwareScalingTool/OctopusHardwareScalingTool.csproj',
    url: 'http://localhost:5008',
    reuseExistingServer: true,
    timeout: 120000,
    stdout: 'pipe',
    stderr: 'pipe',
  },
});
```

### Step 8: Create Test Directory and Package Scripts

```bash
mkdir specs
```

Update `tests/e2e/package.json`:

```json
{
  "name": "octopus-hardware-scaling-tool-tests",
  "version": "1.0.0",
  "scripts": {
    "test": "playwright test",
    "test:ui": "playwright test --ui",
    "test:headed": "playwright test --headed",
    "report": "playwright show-report"
  },
  "devDependencies": {
    "@playwright/test": "^1.40.0"
  }
}
```

### Step 9: Create Core Verification Test

Create `tests/e2e/specs/calculator-verification.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

/**
 * Core verification tests for the Octopus Hardware Scaling Calculator
 * Claude runs these after making changes to verify nothing broke
 */
test.describe('Calculator Core Functionality', () => {

  test('page loads with all key elements', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Verify main heading
    await expect(page.locator('h1')).toContainText('Octopus Hardware Scaling Calculator');

    // Verify all input controls
    await expect(page.locator('select#cpuCores')).toBeVisible();
    await expect(page.locator('input#parallelTargets')).toBeVisible();
    await expect(page.locator('input#numDeployments')).toBeVisible();
    await expect(page.locator('select#taskCap')).toBeVisible();

    // Verify results section
    await expect(page.locator('.results-section')).toBeVisible();
  });

  test('calculator updates when inputs change', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Get initial value
    const initialDuration = await page.locator('.metric-value').first().textContent();

    // Change CPU cores
    await page.selectOption('select#cpuCores', '4');
    await page.waitForTimeout(500);

    // Verify value changed
    const updatedDuration = await page.locator('.metric-value').first().textContent();
    expect(updatedDuration).not.toBe(initialDuration);
    expect(updatedDuration).toMatch(/\d+/);
  });

  test('comparison table displays', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    await expect(page.locator('.comparison-table')).toBeVisible();
    const rows = await page.locator('.comparison-table tbody tr').count();
    expect(rows).toBeGreaterThan(1);
  });

  test('responsive - mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    await expect(page.locator('h1')).toBeVisible();
    await expect(page.locator('select#cpuCores')).toBeVisible();
  });

});
```

### Step 10: Create Visual Verification Test

Create `tests/e2e/specs/visual-verification.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

/**
 * Visual verification - catch unintended UI changes
 */
test.describe('Visual Verification', () => {

  test('homepage visual baseline', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Compare with baseline screenshot
    await expect(page).toHaveScreenshot('homepage-full.png', {
      fullPage: true,
      maxDiffPixels: 100,
    });
  });

  test('calculator section baseline', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const calculator = page.locator('.input-section');
    await expect(calculator).toHaveScreenshot('calculator-section.png', {
      maxDiffPixels: 50,
    });
  });

});
```

### Step 11: Update .gitignore

Add to `.gitignore`:

```bash
# Playwright
tests/e2e/node_modules/
tests/e2e/playwright-report/
tests/e2e/test-results/
tests/e2e/playwright/.cache/

# Keep baseline screenshots
!tests/e2e/specs/**/*-snapshots/
```

---

## Part 3: How Claude Uses Both Tools

### MCP Server (Direct Browser Control)

Claude can use MCP tools directly:

**Available MCP Commands:**
```
mcp__playwright__navigate(url)           - Navigate to URL
mcp__playwright__screenshot()            - Take screenshot
mcp__playwright__click(selector)         - Click element
mcp__playwright__fill(selector, text)    - Fill input
mcp__playwright__evaluate(script)        - Run JavaScript
mcp__playwright__locator(selector)       - Find element
```

**Example Use Cases:**

1. **Verify a change visually:**
   ```
   User: "Did that color change work?"
   Claude: [Uses mcp__playwright__navigate, then mcp__playwright__screenshot]
   Claude: "Here's a screenshot showing the new color"
   ```

2. **Debug an issue:**
   ```
   User: "The button isn't working"
   Claude: [Uses mcp__playwright__navigate]
   Claude: [Uses mcp__playwright__click on button]
   Claude: [Uses mcp__playwright__screenshot]
   Claude: "I can see the button is there but not responding, let me check the code"
   ```

3. **Test interactions:**
   ```
   User: "Test if the form submission works"
   Claude: [Uses mcp__playwright__navigate]
   Claude: [Uses mcp__playwright__fill to fill form]
   Claude: [Uses mcp__playwright__click to submit]
   Claude: [Uses mcp__playwright__screenshot to show result]
   ```

### Verification Tests (Automated Checks)

Claude runs these after code changes:

```bash
# Run all tests
cd tests/e2e && pnpm test

# View report
cd tests/e2e && pnpm report
```

**When Claude Uses Tests:**
- After editing code files
- Before committing changes
- When you ask "run the tests"
- When you ask "verify this works"

---

## Part 4: Claude Code Workflow Examples

### Example 1: Style Change

```
User: "Change the primary blue to #1a8fff"

Claude:
1. I'll update app.css with the new color
   [Edits OctopusHardwareScalingTool/wwwroot/app.css]

2. Let me run the verification tests
   [Runs: cd tests/e2e && pnpm test]
   ✅ All 6 tests passed!

3. Now let me show you what it looks like
   [Uses MCP: mcp__playwright__navigate http://localhost:5008]
   [Uses MCP: mcp__playwright__screenshot]
   Here's the new color: [shows screenshot]
```

### Example 2: Logic Change

```
User: "Fix the calculation for 2.5 cores"

Claude:
1. I'll update the calculation logic in Home.razor
   [Edits OctopusHardwareScalingTool/Components/Pages/Home.razor]

2. Let me verify the calculations work correctly
   [Uses MCP: mcp__playwright__navigate http://localhost:5008]
   [Uses MCP: mcp__playwright__click to select 2.5 cores]
   [Uses MCP: mcp__playwright__screenshot]

3. The new calculation shows: [result from screenshot]

4. Running full test suite to check for regressions
   [Runs: cd tests/e2e && pnpm test]
   ✅ All tests pass!
```

### Example 3: Debugging

```
User: "The dropdown isn't visible on mobile"

Claude:
1. Let me check the mobile view
   [Uses MCP: mcp__playwright__navigate http://localhost:5008]
   [Uses MCP: mcp__playwright__evaluate to set viewport to mobile size]
   [Uses MCP: mcp__playwright__screenshot]

2. I can see the issue - the dropdown has no background color on mobile
   [Shows screenshot]

3. I'll fix the CSS
   [Edits app.css]

4. Let me verify the fix
   [Uses MCP to navigate and screenshot again]
   ✅ Fixed! Here's the result: [screenshot]

5. Running tests to ensure nothing broke
   [Runs: cd tests/e2e && pnpm test]
   ✅ All tests pass!
```

---

## Part 5: Configuration for Claude

### Update Project CLAUDE.md

Add this section to `CLAUDE.md`:

```markdown
## Playwright Verification

After making code changes, verify functionality:

### Using MCP (Direct Browser Control)
Claude has access to MCP Playwright tools:
- Navigate to pages
- Click elements
- Take screenshots
- Fill forms
- Execute JavaScript

Use these for ad-hoc verification and debugging.

### Using Verification Tests
```bash
# Run all verification tests
cd tests/e2e && pnpm test

# View detailed report
cd tests/e2e && pnpm report

# Update visual baselines after intentional UI changes
cd tests/e2e && pnpm test --update-snapshots
```

**When to use each:**
- **MCP**: Quick checks, screenshots, debugging, exploring
- **Tests**: After code changes, before commits, comprehensive verification
```

---

## Part 6: Quick Reference

### For Claude Code (MCP Tools)

```
# Direct browser control (no test files needed)
mcp__playwright__navigate      - Go to URL
mcp__playwright__screenshot    - Take screenshot
mcp__playwright__click         - Click element
mcp__playwright__fill          - Fill input field
mcp__playwright__evaluate      - Run JavaScript
```

### For Claude Code (Test Commands)

```bash
# Run verification tests
cd tests/e2e && pnpm test

# View report
cd tests/e2e && pnpm report

# Run specific test file
cd tests/e2e && pnpm test specs/calculator-verification.spec.ts

# Update screenshots after UI changes
cd tests/e2e && pnpm test --update-snapshots
```

### For You (Manual Testing)

```bash
# Watch tests run in browser
cd tests/e2e && pnpm test:headed

# Interactive test UI
cd tests/e2e && pnpm test:ui
```

---

## Checklist

### Part 1: MCP Server (PRIORITY)
- [ ] Installed MCP Playwright server: `npm install -g @modelcontextprotocol/server-playwright`
- [ ] Updated `~/.claude/config.json` with MCP server config
- [ ] Restarted Claude Code
- [ ] Verified MCP tools available (ask Claude to take a screenshot)

### Part 2: Verification Tests (OPTIONAL)
- [ ] Created `tests/e2e/` directory
- [ ] Ran `pnpm init -y`
- [ ] Installed Playwright: `pnpm add -D @playwright/test`
- [ ] Installed browsers: `pnpm exec playwright install chromium`
- [ ] Created `playwright.config.ts`
- [ ] Created test files in `specs/`
- [ ] Updated `.gitignore`
- [ ] Ran first test: `cd tests/e2e && pnpm test`

### Part 3: Documentation
- [ ] Updated project CLAUDE.md with Playwright commands
- [ ] Claude knows about both MCP tools and test commands

---

## Troubleshooting

### MCP Server Issues

**Issue: MCP tools not showing up**
- Check `~/.claude/config.json` is correct
- Restart Claude Code completely
- Verify installation: `npx @modelcontextprotocol/server-playwright --version`

**Issue: "Cannot connect to browser"**
- Make sure app is running at http://localhost:5008
- Check if port is accessible: `curl http://localhost:5008`

### Test Issues

**Issue: Tests fail with "timeout"**
- Increase timeout in `playwright.config.ts`
- Make sure app starts successfully
- Check `webServer` config path is correct

**Issue: Visual tests fail**
- First run creates baseline
- Update baseline after intentional changes: `pnpm test --update-snapshots`

---

## Next Steps

1. **Set up MCP server first** (most important!)
2. **Test it**: Ask Claude to navigate to your app and take a screenshot
3. **Set up verification tests** (optional but recommended)
4. **Start using it**: Make a code change and ask Claude to verify it

---

## Learning Resources

- **MCP Playwright**: https://github.com/modelcontextprotocol/servers
- **Playwright Docs**: https://playwright.dev
- **MCP Protocol**: https://modelcontextprotocol.io

---

**You're ready! Claude can now both use Playwright directly AND run verification tests.**

**Try it now:**
- "Navigate to http://localhost:5008 and take a screenshot"
- "Run the Playwright tests to verify everything works"
