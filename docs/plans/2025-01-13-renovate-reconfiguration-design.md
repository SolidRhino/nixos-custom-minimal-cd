# Renovate Reconfiguration: Security-First, Low-Noise Updates

**Date:** 2025-01-13
**Status:** Design Approved
**Goal:** Eliminate Renovate's always-open dashboard issue while maintaining security-first automated updates

## Problem Statement

Current Renovate configuration creates an always-open "Dependency Dashboard" issue that conflicts with:
- Clean issue state preference (inbox zero workflow)
- Visual clutter in repository
- Unwanted GitHub notifications

## Solution: Approach 1 - Renovate Reconfigured

**Decision:** Keep Renovate but optimize configuration for minimal noise and maximum security automation.

**Rationale:** Already working, mature tool with Nix support. Simple configuration change solves the issue.

## Core Configuration Changes

### Dashboard Removal
```json
"dependencyDashboard": false
```
Eliminates the always-open issue entirely.

### Update Grouping Strategy

**Security Updates (Immediate):**
- **Patches:** Auto-merge immediately if CI passes
- **Minor/Major:** Create immediate PR, require manual review
- **Schedule:** `"at any time"` (no delays)
- **Priority:** Highest (10 for patches, 9 for breaking changes)

**Regular Updates (Weekly):**
- **Nix flake inputs:** Grouped, auto-merge
- **GitHub Actions:** Grouped, auto-merge
- **Major versions:** Manual review required
- **Schedule:** Weekend only
- **Rate limit:** 1 PR at a time

## Expected Behavior

### Normal Week (No Security Issues)
- Zero notifications
- Single grouped PR appears on weekend
- Auto-merges if CI passes
- Only notified on failures or major updates

### Security Vulnerability Detected
- **Patch available:** Immediate PR → Auto-merge if build succeeds → Silent
- **Breaking change:** Immediate PR → Notification → Manual review required
- **Build failure:** Immediate notification

## Configuration Details

### Package Rules Priority

1. **Security patches** (auto-merge)
   - `matchUpdateTypes: ["patch"]`
   - `vulnerabilitySeverity: ["LOW", "MODERATE", "HIGH", "CRITICAL"]`
   - `automerge: true`
   - `schedule: ["at any time"]`
   - Labels: `security`, `auto-merged`

2. **Security breaking changes** (manual review)
   - `matchUpdateTypes: ["minor", "major"]`
   - `vulnerabilitySeverity: ["LOW", "MODERATE", "HIGH", "CRITICAL"]`
   - `automerge: false`
   - `schedule: ["at any time"]`
   - Labels: `security`, `urgent`, `requires-review`

3. **Regular Nix flake inputs** (weekly auto-merge)
   - `matchDatasources: ["git-tags", "github-tags"]`
   - `automerge: true`
   - `schedule: ["every weekend"]`
   - Label: `dependencies`

4. **GitHub Actions** (weekly auto-merge)
   - `matchManagers: ["github-actions"]`
   - `automerge: true`
   - `schedule: ["every weekend"]`
   - Label: `dependencies`

5. **Major version updates** (manual review)
   - `matchUpdateTypes: ["major"]`
   - `automerge: false`
   - Label: `major-update`

### Safety Mechanisms

- `ignoreTests: false` - Only auto-merge if CI passes
- `platformAutomerge: true` - Use GitHub's native auto-merge
- `prConcurrentLimit: 1` - Prevent PR spam
- Branch protection recommended (require CI checks)

## Implementation Steps

### 1. Update renovate.json
Replace entire file with new configuration (see final config below).

### 2. Enable GitHub Repository Settings
**Repository → Settings → General:**
- ✅ Allow auto-merge
- ✅ Automatically delete head branches

**Repository → Settings → Branches → main (recommended):**
- Require status checks to pass before merging
- Required check: "Build NixOS ISO" workflow

### 3. Configure GitHub Notifications
**Profile → Settings → Notifications:**
- Enable: Security alerts
- Enable: Failed Actions
- Disable: Successful Actions (noise reduction)
- Custom: PRs with security labels only

### 4. Deploy Configuration
```bash
git add renovate.json
git commit -m "config: optimize Renovate for security-first, low-noise updates"
git push origin main
```

### 5. Verify Changes
- Dashboard issue should close within 24 hours
- Check Renovate logs on next PR
- Monitor for clean issue list

## Monitoring & Maintenance

### Health Checks

**Weekly:**
- Verify grouped PR appears on weekend
- Confirm auto-merge is working
- Check notification volume

**Monthly:**
- Review Renovate activity logs
- Audit security alert response times
- Adjust grouping if needed

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Dashboard still appears | Verify `dependencyDashboard: false` in config |
| PRs not auto-merging | Check repo auto-merge setting enabled |
| Security updates delayed | Verify `schedule: ["at any time"]` |
| Too many notifications | Review GitHub notification preferences |

### Future Tuning Options

- Adjust `prConcurrentLimit` for different PR volume
- Add more group rules for finer categorization
- Customize commit message formats per group
- Add timezone-specific scheduling

## Success Criteria

✅ No always-open dashboard issue
✅ Zero notifications during normal weeks
✅ Security patches auto-merge within hours
✅ Security breaking changes require review
✅ Regular updates bundled weekly
✅ Only manual review for major versions

## Final Configuration

See `renovate.json` in repository root for complete configuration.

## References

- [Renovate Documentation](https://docs.renovatebot.com/)
- [Renovate Configuration Options](https://docs.renovatebot.com/configuration-options/)
- [GitHub Auto-merge](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/automatically-merging-a-pull-request)
