# GitHub Actions Workflow Optimization Design

**Date:** 2025-01-14
**Status:** Design Approved
**Goal:** Reduce unnecessary CI builds while maintaining code quality validation

## Problem Statement

Current GitHub Actions workflow builds ISOs on every push to main, including documentation-only changes. This wastes:
- CI minutes (especially for aarch64 builds: ~20-45 minutes)
- Time waiting for builds that don't validate code changes
- Resources when only markdown files are modified

## Solution: Smart Build Triggers with Path Filtering

**Decision:** Add `paths-ignore` to skip builds for documentation-only changes while keeping automatic builds for code changes.

**Rationale:**
- Mixed commits (code + docs) are common → need automatic validation
- Pure documentation commits don't require ISO rebuilds
- Renovate already provides weekly validation via auto-merged PRs
- Simple configuration change with immediate benefits

## Design

### Updated Workflow Triggers

**Current configuration:**
```yaml
on:
  push:
    branches:
      - main
      - master
    tags:
      - 'v*'

  workflow_dispatch:
```

**Optimized configuration:**
```yaml
on:
  push:
    branches:
      - main
      - master
    tags:
      - 'v*'
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - '.serena/memories/**'

  workflow_dispatch:
```

### Path Ignore Rules

**Files that skip builds when changed alone:**

1. **`**.md`** - All markdown files (README.md, CLAUDE.md, any .md file)
2. **`docs/**`** - Documentation directory and all contents
3. **`.serena/memories/**`** - Serena project memories (documentation)

**Important:** If ANY non-ignored file changes, build runs normally (even if docs also changed).

## Behavior Examples

### Builds That Run

✅ **Code changes:**
```bash
git commit -m "feat: add htop to ISO packages"
# Changes: configuration.nix
# Result: Build runs
```

✅ **Mixed commits:**
```bash
git commit -m "feat: add package + update README"
# Changes: configuration.nix, README.md
# Result: Build runs (code takes precedence)
```

✅ **Configuration changes:**
```bash
git commit -m "config: update Renovate settings"
# Changes: renovate.json
# Result: Build runs
```

✅ **Workflow changes:**
```bash
git commit -m "ci: optimize workflow triggers"
# Changes: .github/workflows/build-iso.yml
# Result: Build runs
```

### Builds That Skip

❌ **Pure documentation:**
```bash
git commit -m "docs: update README installation steps"
# Changes: README.md
# Result: Build skipped
```

❌ **Design documents:**
```bash
git commit -m "docs: add architecture design"
# Changes: docs/plans/design.md
# Result: Build skipped
```

❌ **Serena memories:**
```bash
git commit -m "docs: update Serena memories"
# Changes: .serena/memories/project_overview.md
# Result: Build skipped
```

## Expected Outcomes

### Time Savings

**Before optimization:**
- ~5-10 builds per week
- All pushes trigger builds (including docs-only)

**After optimization:**
- ~3-7 builds per week
- Docs-only pushes skip builds
- **Expected savings: 20-40% fewer builds**

**Per-build time:**
- x86_64: ~2-5 minutes saved
- aarch64: ~20-45 minutes saved
- Total: ~22-50 minutes per skipped build

### Build Frequency Patterns

**Weekly validation maintained:**
1. **Renovate PRs:** Every weekend, auto-merge triggers build
2. **Code changes:** Any push with code changes
3. **Manual triggers:** Available anytime via workflow_dispatch
4. **Releases:** Auto-build on git tags

**Net effect:** Same validation quality, fewer unnecessary builds

## Build Space Optimization Decision

### Considered Approach

Adding `AdityaGarg8/remove-unwanted-software` action:
```yaml
- name: Maximize build space
  uses: AdityaGarg8/remove-unwanted-software@master
  with:
    remove-android: 'true'
    remove-dotnet: 'true'
    remove-haskell: 'true'
    remove-codeql: 'true'
    remove-docker-images: 'true'
    remove-large-packages: 'true'
    remove-cached-tools: 'true'
    remove-swapfile: 'true'
```

### Decision: NOT Implemented

**Reasons:**
1. **No current space issues** - Builds succeed with default runner space (~14GB free)
2. **Performance cost** - Adds 5-10 minutes per build (10-20 min total for both architectures)
3. **Premature optimization** - Solving a problem that doesn't exist yet
4. **Nix efficiency** - Magic Nix Cache already optimizes space usage
5. **Defeats optimization goal** - Time savings from skipping docs builds would be offset

### Future Consideration

Add space optimization **only if**:
- Builds start failing with "No space left on device" errors
- ISO size grows significantly (>1GB)
- Build logs show space warnings

Monitor build logs for space usage; implement as needed.

## Implementation Steps

### 1. Update Workflow File

Edit `.github/workflows/build-iso.yml`:
```yaml
on:
  push:
    branches:
      - main
      - master
    tags:
      - 'v*'
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - '.serena/memories/**'

  workflow_dispatch:
```

### 2. Commit Changes

```bash
git add .github/workflows/build-iso.yml
git commit -m "ci: skip builds for documentation-only changes

- Add paths-ignore for markdown files and docs directory
- Skip builds when only .md files, docs/**, or .serena/memories/** change
- Code changes still trigger builds normally
- Expected savings: 20-40% fewer builds"
git push origin main
```

### 3. Verify Behavior

**Test 1: Documentation-only commit**
```bash
echo "test" >> README.md
git commit -am "docs: test workflow optimization"
git push origin main
# Expected: No build triggered
```

**Test 2: Code change**
```bash
# Edit configuration.nix
git commit -am "feat: add test package"
git push origin main
# Expected: Build triggered
```

**Test 3: Mixed commit**
```bash
# Edit both configuration.nix and README.md
git commit -am "feat: add package and update docs"
git push origin main
# Expected: Build triggered (code takes precedence)
```

## Success Criteria

✅ Documentation-only commits skip builds
✅ Code changes always trigger builds
✅ Mixed commits trigger builds normally
✅ Renovate PRs continue weekly validation
✅ Manual triggers still available
✅ Release tags auto-build ISOs
✅ 20-40% reduction in build frequency
✅ No loss of code quality validation

## Monitoring

### Metrics to Track

**Weekly for first month:**
- Number of builds triggered
- Number of builds skipped (via commit history)
- Build success rate (should remain ~100%)

**Monthly ongoing:**
- Average builds per week
- Time savings estimate
- Any missed validations due to path filtering

### Adjustments if Needed

**If too many builds skip:**
- Review path-ignore patterns
- Consider removing `.serena/memories/**` if memories contain config

**If builds still too frequent:**
- Add more path-ignore patterns (e.g., `*.txt`, `LICENSE`)
- Consider narrower path triggers instead (paths vs paths-ignore)

## Related Configuration

### Renovate Integration

This optimization works with existing Renovate configuration:
- Weekly grouped updates (`"schedule": ["every weekend"]`)
- Auto-merge for minor/patch (`"automerge": true`)
- Weekly builds still guaranteed via Renovate PRs

### Branch Protection

If using branch protection with required status checks:
- Documentation-only commits won't have status checks
- GitHub will show "Expected — Waiting for status to be reported"
- This is expected behavior with `paths-ignore`
- Override protection or merge without checks for docs-only

## References

- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onpushpull_requestpull_request_targetpathspaths-ignore)
- [Filtering Workflow Runs](https://docs.github.com/en/actions/using-workflows/triggering-a-workflow#using-filters)
- Current workflow: `.github/workflows/build-iso.yml`
