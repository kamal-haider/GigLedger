# Branch Protection Setup

This document describes how to configure GitHub branch protection rules to enforce the PR workflow.

## Why Branch Protection?

Branch protection prevents accidental or unauthorized changes to the `main` branch by:
- Requiring pull requests for all changes
- Requiring CI checks to pass before merge
- Requiring code review approval
- Preventing force pushes

## Setup Instructions

### Via GitHub UI

1. Go to **Repository Settings** → **Branches**
2. Under "Branch protection rules", click **Add rule**
3. For "Branch name pattern", enter: `main`
4. Enable these settings:

#### Required Settings
- [x] **Require a pull request before merging**
  - [x] Require approvals: 1
  - [x] Dismiss stale pull request approvals when new commits are pushed

- [x] **Require status checks to pass before merging**
  - [x] Require branches to be up to date before merging
  - Status checks to require:
    - `Flutter Analyze`
    - `Flutter Build`

- [x] **Do not allow bypassing the above settings**

#### Recommended Settings
- [x] **Require conversation resolution before merging**
- [ ] **Require signed commits** (optional, adds complexity)
- [x] **Require linear history** (prevents merge commits, keeps history clean)

### Via GitHub CLI

```bash
# Note: Branch protection rules require admin access
# and are typically set up via the GitHub UI

# View current protection rules
gh api repos/{owner}/{repo}/branches/main/protection

# This is typically configured in the GitHub UI for easier management
```

## CI Checks Required

The following CI workflows must pass before merging to `main`:

1. **Build Check** (`.github/workflows/build-check.yml`)
   - Flutter Analyze - Code quality and linting
   - Flutter Build - Ensures code compiles

2. **Claude Code Review** (`.github/workflows/claude-code-review.yml`)
   - Automated code review (informational, not blocking)

## Workflow After Setup

With branch protection enabled:

1. **Direct pushes to `main` will be rejected**
2. All changes must go through a PR
3. CI must pass before merge is allowed
4. At least one approval is required

### Agent Workflow

Agents (Claude Code) must:
1. Create a feature branch **before any commits**
2. Push to the feature branch
3. Create a PR targeting `main`
4. Wait for CI and review
5. Never attempt to push directly to `main`

## Troubleshooting

### "Push rejected" error
You tried to push directly to `main`. Create a feature branch instead:
```bash
git checkout -b feature/your-feature
git push -u origin feature/your-feature
gh pr create
```

### "Status checks failed" error
CI checks must pass before merge. Fix the issues:
```bash
flutter analyze
dart format lib/
flutter build apk --debug
```

### "Review required" error
Get approval from a maintainer before merging.

## References

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- CLAUDE.md - Git Workflow section
