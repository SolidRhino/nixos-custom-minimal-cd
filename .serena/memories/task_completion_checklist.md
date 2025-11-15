# Task Completion Checklist

## When a Development Task is Completed

### 1. Validation
- [ ] **Syntax Check**: Ensure Nix syntax is valid
  ```bash
  nix flake check  # May not work on Darwin for ISO builds
  nix eval .#packages.x86_64-linux  # Evaluate without building
  ```

- [ ] **Flake Show**: Verify outputs are correct
  ```bash
  nix flake show
  ```

### 2. Documentation
- [ ] **Update CLAUDE.md**: If project patterns or workflows changed
- [ ] **Update README.md**: For user-facing features or configuration changes
- [ ] **Inline Comments**: Add comments for non-obvious choices or overrides

### 3. Git Workflow
- [ ] **Review Changes**: Check what will be committed
  ```bash
  git status
  git diff
  ```

- [ ] **Stage Changes**: Add modified files
  ```bash
  git add <files>
  ```

- [ ] **Commit**: Use descriptive commit message
  ```bash
  git commit -m "feat: description of change"
  ```

### 4. Testing (via GitHub Actions)

Since this is a Darwin (macOS) system, ISO builds must be done via GitHub Actions:

- [ ] **Push to Branch**: Push changes to trigger build
  ```bash
  git push origin <branch-name>
  ```

- [ ] **Monitor Build**: Check GitHub Actions for build status
  - Go to repository Actions tab
  - Verify both builds succeed (x86_64, aarch64)
  - Check build logs for errors or warnings

- [ ] **Validate ISOs**: Download and test built ISOs
  - Download artifacts from successful workflow run
  - Test boot in VM (UTM, QEMU, VirtualBox)
  - Verify SSH access with `installer` password
  - Check that new features/packages are present

### 5. Integration
- [ ] **Merge to Main**: After testing passes
  ```bash
  git checkout main
  git merge <branch-name>
  git push origin main
  ```

- [ ] **Tag Release**: For significant versions (optional)
  ```bash
  git tag v1.0.0
  git push origin v1.0.0
  ```

## Configuration-Specific Checks

### When Modifying Editor Configs
- [ ] Test that editor launches without errors in ISO
- [ ] Verify LSP functionality works
- [ ] Check keybindings and themes are applied

### When Adding System Packages
- [ ] Verify package exists in nixpkgs
- [ ] Check package doesn't conflict with base ISO packages
- [ ] Document why package is included (if non-obvious)

### When Changing SSH/Network Settings
- [ ] Test SSH connectivity in booted ISO
- [ ] Verify network auto-configuration works
- [ ] Document security implications (if any)

## CI/CD Specific

### GitHub Actions Workflow Changes
- [ ] Validate YAML syntax
- [ ] Test workflow with manual trigger first
- [ ] Verify artifact uploads work correctly
- [ ] Check release creation logic (if modified)

## Pre-Release Checklist

Before creating a tagged release:

- [ ] All features tested and working
- [ ] README.md is up to date
- [ ] CLAUDE.md reflects current architecture
- [ ] Both ISOs build successfully (x86_64, aarch64)
- [ ] ISOs boot and function correctly
- [ ] Commit history is clean and meaningful
- [ ] Version tag follows semantic versioning (vX.Y.Z)