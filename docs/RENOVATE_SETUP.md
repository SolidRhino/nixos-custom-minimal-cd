# Renovate Setup Verification

This document contains the GitHub repository settings you need to verify for the new Renovate configuration to work correctly.

## Required GitHub Repository Settings

### 1. Enable Auto-Merge Feature

**Location:** `Repository → Settings → General`

**Settings to enable:**
- ✅ **Allow auto-merge** - Lets Renovate automatically merge PRs
- ✅ **Automatically delete head branches** - Cleans up merged PR branches

**How to verify:**
1. Go to: `https://github.com/<owner>/custom-minimal-cd/settings`
2. Scroll to "Pull Requests" section
3. Check the boxes for both settings above

### 2. Branch Protection Rules (Recommended)

**Location:** `Repository → Settings → Branches`

**For branch: `main`**

**Required status checks:**
- ✅ **Require status checks to pass before merging**
  - Select: `build (x86_64-linux)`
  - Select: `build (aarch64-linux)`
- ✅ **Require branches to be up to date before merging**

**Why:** This ensures security patches only auto-merge if both ISO builds succeed.

**How to configure:**
1. Go to: `https://github.com/<owner>/custom-minimal-cd/settings/branches`
2. Click "Add branch protection rule"
3. Branch name pattern: `main`
4. Check "Require status checks to pass before merging"
5. Search and select both build jobs
6. Save changes

### 3. GitHub Notifications (Optional but Recommended)

**Location:** `Your Profile → Settings → Notifications`

**Recommended settings for this repository:**

**Watching:**
- Set to: **Custom**
- Enable: ✅ Security alerts
- Disable: ❌ All activity (too noisy)

**Participating and @mentions:**
- Enable: ✅ Pull requests
- Enable: ✅ Issues

**Email notifications:**
- Enable: ✅ Security vulnerability alerts
- Enable: ✅ Failed Actions workflows
- Disable: ❌ Successful Actions (reduces noise)

**How to configure:**
1. Go to repository page
2. Click "Watch" dropdown (top right)
3. Select "Custom"
4. Configure as above

## Verification Checklist

After pushing the configuration changes:

- [ ] Auto-merge is enabled in repository settings
- [ ] Branch protection is configured for `main` branch
- [ ] Notification preferences are set
- [ ] Existing Renovate dashboard issue closes within 24 hours
- [ ] Wait for first weekend to see grouped PR

## Expected Behavior After Setup

### Normal Week (No Security Issues)
- ✅ Clean issue list (no always-open dashboard)
- ✅ Zero notifications
- ✅ Single grouped PR on weekend
- ✅ Auto-merges if CI passes

### Security Vulnerability Detected
- 🚨 **Patch available:**
  - Immediate PR created
  - Auto-merges if both ISO builds pass
  - Silent (no notification unless build fails)

- ⚠️ **Breaking change (minor/major):**
  - Immediate PR created
  - Labeled: `security`, `urgent`, `requires-review`
  - You get notified
  - Requires manual review and merge

### Build Failures
- ❌ Any PR (security or regular) that fails CI
- ❌ Notification sent immediately
- ❌ PR remains open for investigation

## Troubleshooting

### Dashboard Issue Still Appears
**Check:** `renovate.json` has `"dependencyDashboard": false`
**Action:** If present but issue persists, close the issue manually. Renovate will not recreate it.

### PRs Not Auto-Merging
**Check:** Repository → Settings → General → "Allow auto-merge" is enabled
**Action:** Enable the setting and re-trigger Renovate by commenting `@renovatebot rebase` on an open PR

### Security Updates Delayed
**Check:** Package rule with `"schedule": ["at any time"]` exists for security updates
**Action:** Verify the configuration matches the design document

### Too Many Notifications
**Check:** GitHub notification settings
**Action:** Adjust to "Custom" watching mode with only security alerts enabled

## Push Configuration to GitHub

The configuration has been committed locally. To activate it:

```bash
# Push to GitHub
git push origin main

# Renovate will detect the change on its next run
# Dashboard issue should close within 24 hours
```

## Testing the Configuration

### Immediate Test
1. Go to any existing Renovate PR (if one exists)
2. Comment: `@renovatebot rebase`
3. Watch for Renovate to apply new configuration

### Wait for Automatic Run
- Renovate runs on a schedule (typically hourly)
- Changes will be applied automatically
- Check logs on next PR creation

## Monitoring

### Check Renovate Activity
- Go to: Repository → Insights → Dependency graph
- View recent Renovate activity
- Verify configuration is being followed

### Review First Weekend PR
- Should appear on weekend
- Should be a single grouped PR
- Should auto-merge if CI passes
- Verify commit message follows: `chore(deps): update <group>`

## Support Resources

- [Renovate Documentation](https://docs.renovatebot.com/)
- [Renovate Configuration Options](https://docs.renovatebot.com/configuration-options/)
- [GitHub Auto-merge Docs](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/automatically-merging-a-pull-request)
- Design Document: `docs/plans/2025-01-13-renovate-reconfiguration-design.md`
