# Development Workflow

This document describes the development and code review process for GigLedger.

## Branch Strategy

### Branch Naming Convention

```
feature/<descriptive-name>   # New features
bugfix/<descriptive-name>    # Bug fixes
docs/<descriptive-name>      # Documentation updates
refactor/<descriptive-name>  # Code refactoring
```

### Rules

1. **NEVER push directly to `main`** - Always use feature branches and PRs
2. **One feature per branch** - Keep branches focused
3. **Branch from latest `main`** - Always start fresh

## Development Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     DEVELOPMENT WORKFLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Pick Issue          gh issue list --label "ready-to-work"   │
│         │                                                        │
│         ▼                                                        │
│  2. Mark In Progress    gh issue edit <n> --add-label "in-progress" │
│         │                                                        │
│         ▼                                                        │
│  3. Create Branch       git checkout -b feature/<name>          │
│         │                                                        │
│         ▼                                                        │
│  4. Implement           Follow Clean Architecture patterns      │
│         │                                                        │
│         ▼                                                        │
│  5. Test & Lint         flutter test && flutter analyze         │
│         │                                                        │
│         ▼                                                        │
│  6. Commit              git commit -m "feat: description"       │
│         │                                                        │
│         ▼                                                        │
│  7. Push & PR           git push && gh pr create                │
│         │                                                        │
│         ▼                                                        │
│  8. Review              Claude agent reviews PR                 │
│         │                                                        │
│         ▼                                                        │
│  9. Address Feedback    Fix issues, push updates                │
│         │                                                        │
│         ▼                                                        │
│  10. Merge              gh pr merge --squash --delete-branch    │
│         │                                                        │
│         ▼                                                        │
│  11. Close Issue        gh issue close <n>                      │
│         │                                                        │
│         ▼                                                        │
│  12. Unblock Others     Update dependent issues                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Guide

### 1. Pick an Issue

```bash
# Find ready issues (not blocked)
gh issue list --label "ready-to-work" --search "-label:blocked"

# View issue details
gh issue view <number>
```

### 2. Mark Issue In Progress

```bash
gh issue edit <number> --add-label "in-progress"
gh issue comment <number> --body "Started working on this"
```

### 3. Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/<descriptive-name>
```

### 4. Implement Feature

Follow the architecture in `docs/07_app_architecture.md`:

1. **Domain Layer** - Models and repository interfaces
2. **Data Layer** - DTOs, data sources, repository implementations
3. **Application Layer** - Use cases
4. **Presentation Layer** - Providers, pages, widgets

### 5. Test and Lint

```bash
# Run tests
flutter test

# Run analyzer
flutter analyze

# Format code
dart format lib/
```

### 6. Commit Changes

```bash
git add .
git commit -m "feat(<scope>): <description>

- Detailed change 1
- Detailed change 2

Closes #<issue-number>

Co-Authored-By: Claude <model-name> <noreply@anthropic.com>"
```

### 7. Create Pull Request

```bash
git push -u origin feature/<name>

gh pr create --title "feat: <Title>" --body "## Summary
- Change 1
- Change 2

## Related Issues
Closes #<number>

## Testing
- [ ] Tested on iOS
- [ ] Tested on Android
- [ ] flutter analyze passes"
```

### 8. Code Review

PRs are reviewed for:
- Security (no secrets, proper auth)
- Code quality (Clean Architecture, naming)
- Flutter standards (widget composition, state management)
- Test coverage

### 9. Address Feedback

```bash
# Make fixes
git add .
git commit -m "fix: address review feedback"
git push
```

### 10. Merge PR

```bash
gh pr merge <number> --squash --delete-branch
```

### 11. Close Issue

```bash
gh issue close <number> --comment "Completed via PR #<pr-number>"
```

### 12. Unblock Dependent Issues

```bash
# Find issues blocked by this one
gh issue list --label "blocked"

# Unblock them
gh issue edit <blocked-number> --remove-label "blocked" --add-label "ready-to-work"
gh issue comment <blocked-number> --body "Unblocked by #<completed-number>"
```

## Parallel Development (Worktrees)

For parallel feature development, use git worktrees:

```bash
# Create worktrees for parallel work
git worktree add ../GigLedger-auth feature/auth
git worktree add ../GigLedger-clients feature/clients
git worktree add ../GigLedger-expenses feature/expenses

# Each worktree is independent
cd ../GigLedger-auth
# ... work on auth feature

# Remove worktree when done
git worktree remove ../GigLedger-auth
```

### Parallel-Safe Features

These can be developed simultaneously without conflicts:

| Worktree | Feature | Issues |
|----------|---------|--------|
| A | Auth | #1, #2, #3 |
| B | Clients | #14, #15, #16 |
| C | Expenses | #11, #12, #13 |
| D | Settings | #20, #21, #22 |

### Sequential Features (Wait for Dependencies)

| Feature | Depends On |
|---------|------------|
| Invoices | Auth + Clients |
| Dashboard | Auth + Invoices + Expenses |
| Reports | All data features |

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance

### Examples

```
feat(auth): implement Google Sign-In

- Add GoogleSignInButton widget
- Create AuthRepository with signInWithGoogle method
- Add auth state provider with Riverpod

Closes #1

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## GitHub Actions (CI)

### Claude Code Review

PRs are automatically reviewed by Claude. To enable:

1. Go to repo Settings > Secrets
2. Add `CLAUDE_CODE_OAUTH_TOKEN` (get from claude.ai/code)

The review checks:
- Code quality
- Security concerns
- Architecture compliance
- Test coverage

## Quick Reference

```bash
# Start new feature
gh issue list --label "ready-to-work" -L 10
gh issue edit <n> --add-label "in-progress"
git checkout -b feature/<name>

# Submit for review
flutter analyze && flutter test
git add . && git commit -m "feat: ..."
git push -u origin feature/<name>
gh pr create

# After approval
gh pr merge <n> --squash --delete-branch
gh issue close <issue-n>
```
