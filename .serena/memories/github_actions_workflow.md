# GitHub Actions Workflow Design

## Current Workflow (build-iso.yml)

**Triggers:**
- Push to main/master branches
- Git tags (v*)
- Manual workflow_dispatch
- Paths-ignore: **.md, docs/**, .serena/memories/**

**Build Strategy - Dual Jobs:**

### Job 1: build-standard (x86_64, aarch64)
- Matrix builds in parallel (fast, 2-5 minutes)
- Use pre-built kernels from cache
- No space cleanup needed
- QEMU for aarch64 emulation on x86_64 runners

### Job 2: build-t2 (separate job)
- Dedicated runner for T2 kernel compilation
- **GC_DONT_GC=1**: Prevents garbage collection during 90+ minute kernel build
- Maximize build space before compilation
- Uses --accept-flake-config flag
- Cleanup result after upload
- No QEMU (T2 is x86_64 only)

**T2 Disk Space Protection (Dual Strategy):**
1. **Separate Job**: T2 gets dedicated runner (~14GB space, no competition)
2. **GC Protection**: GC_DONT_GC=1 prevents deletion of intermediate build artifacts

**Rationale:**
- T2 builds custom patched kernel (massive, 90+ minutes)
- Standard builds use pre-built kernels (fast, 2-5 minutes)
- Previous parallel matrix exhausted disk space during T2 kernel compilation
- Matches proven t2linux/nixos-t2-iso build strategy

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
