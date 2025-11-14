# GitHub Actions Workflow Design

## Current Workflow (build-iso.yml)

**Triggers:**
- Push to main/master branches
- Git tags (v*)
- Manual workflow_dispatch

**Build Strategy:**
- Matrix uses descriptive target names: x86_64-generic, aarch64-generic, x86_64-t2
- Target names clarify that "generic" = standard ISOs, "t2" = hardware variant
- Case statement maps targets to actual Nix package paths
- QEMU emulation for aarch64 on x86_64 runners
- Nix with magic cache for performance
- Uploads to GitHub Actions artifacts (90 days)
- Uploads to GitHub Releases (permanent) on tags

**Build Time:**
- x86_64: ~2-5 minutes (native)
- x86_64-t2: ~3-7 minutes (native with T2 modules)
- aarch64: ~20-45 minutes (QEMU emulation)

## Renovate Integration Discovery

**Key Finding:** Renovate already provides weekly automated builds!

**How it works:**
1. Renovate creates grouped PR every weekend (`"schedule": ["every weekend"]`)
2. PR auto-merges if CI passes (`"automerge": true`, `"platformAutomerge": true`)
3. Auto-merge triggers push to main
4. Push to main triggers ISO build workflow
5. Result: **Automatic weekly validation via Renovate**

**Renovate Configuration Details:**
- `"ignoreTests": false` - Waits for status checks before auto-merge
- `"prConcurrentLimit": 1` - One PR at a time
- Groups Nix flake inputs and GitHub Actions updates
- Auto-merges minor/patch updates
- Major updates require manual review

## Workflow Naming Convention

**Matrix Variable: `target`** (not `arch`)
- Uses descriptive names that clarify purpose
- `x86_64-generic`, `aarch64-generic` = standard ISOs
- `x86_64-t2` = hardware-specific variant (T2 MacBook Pro)
- Avoids confusion with actual Nix system architectures

**Why not `arch`:**
- `x86_64-t2` looked like a system architecture but isn't
- Mixing real architectures (x86_64-linux) with variant labels was confusing
- `target` + descriptive names make intent clear

**ISO Filenames:**
- Keep simple without "generic" suffix for users
- `nixos-minimal-x86_64-custom.iso` (not x86_64-generic)
- `nixos-minimal-x86_64-t2-custom.iso` (explicit T2)

## Optimization Implemented: Smart Build Triggers

**Rationale:**
- Skip builds for documentation-only changes
- Keep automatic builds for code changes
- Renovate ensures weekly validation via dependency PRs
- Most commits are mixed (code + docs), so builds still run normally

**Implemented Trigger Configuration:**
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

**Expected Benefits:**
- ✅ 20-40% fewer builds (skip docs-only commits)
- ✅ Automatic validation for code changes
- ✅ Weekly validation via Renovate
- ✅ Releases still automated (tags)
- ✅ Manual trigger available anytime

## Build Space Optimization

**Rejected Approach:** Using `AdityaGarg8/remove-unwanted-software` action

**Reasons:**
- Current builds succeed without space issues
- Adds ~5-10 minutes to workflow
- Nix builds are generally space-efficient with magic cache
- Premature optimization (no evidence of space problems)

**Decision:** Monitor for space issues, only add if needed

## Workflow Management

### When to Trigger Builds Manually

**Always trigger:**
- After significant configuration changes
- Before creating a release/tag
- When testing new features that affect ISO

**No need to trigger:**
- Documentation-only changes
- Minor code refactors that don't affect ISO
- Let Renovate's weekly build validate

### Using Manual Trigger

```bash
# Via GitHub UI
1. Go to Actions → Build NixOS ISO
2. Click "Run workflow"
3. Select branch (usually main)
4. Click "Run workflow" button

# Via GitHub CLI
gh workflow run build-iso.yml
```

### Creating Releases

```bash
# Tag triggers automatic build + release
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will:
1. Build both architectures
2. Create GitHub Release
3. Upload ISOs as release assets
```

## Future Considerations

### If Space Issues Emerge

Add as first step after checkout:
```yaml
- name: Maximize build space
  uses: AdityaGarg8/remove-unwanted-software@master
  with:
    remove-android: 'true'
    remove-dotnet: 'true'
    # ... other options
```

Monitor: ISO size (~500-800MB) vs available space on GitHub runners

### If Manual Triggers Become Tedious

Consider adding back:
```yaml
on:
  push:
    branches: [main]
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - '.serena/**'
```

But only if documentation commits become more frequent and separate.
