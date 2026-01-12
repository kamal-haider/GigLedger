# Ticket Selection Guide

## Purpose

This document explains how to use GitHub issue labels to select the right tickets to work on at the right time, ensuring efficient parallel development and avoiding blocked work.

## Label System

### Priority Labels

| Label | Color | Meaning | When to Pick |
|-------|-------|---------|--------------|
| `ready-to-work` | Green | No blockers, can start immediately | **Pick these first** |
| `user-config` | Yellow | Requires user configuration (not code) | Can work alongside features |
| `blocked` | Red | Blocked by other issues or dependencies | **Do not pick** |
| `blocked-by-pr` | Red | Blocked by PR merge | **Do not pick** |
| `post-mvp` | Blue | Pick up after core features complete | **Save for later** |
| `in-progress` | Orange | Currently being worked on | Already claimed |

### Category Labels

Existing labels to help filter by type:
- `enhancement` - New features
- `bug` - Bug fixes
- `documentation` - Documentation updates
- `performance` - Performance optimizations
- `[tech1]`, `[tech2]`, `[tech3]` - Technology-specific

## Ticket Selection Strategy

### Phase 1: Build MVP Features (Current Priority)

**Pick tickets with:**
- `ready-to-work` label
- **Without** `post-mvp` label

**Filter command:**
```bash
gh issue list --label "ready-to-work" --search "-label:post-mvp"
```

### Phase 2: User Configuration Tasks

**Pick tickets with:**
- `user-config` label
- `ready-to-work` label

These require manual setup (console configuration, developer accounts, etc.) but can be done alongside feature development.

### Phase 3: Wait for Unblocking

**Monitor blocked tickets:**
```bash
gh issue list --label "blocked"
gh issue list --label "blocked-by-pr"
```

Check issue comments for blocking dependencies.

### Phase 4: Post-MVP Refinement

**Pick tickets with:**
- `post-mvp` label

**Only pick these AFTER core MVP features are complete.**

**Filter command:**
```bash
gh issue list --label "post-mvp"
```

## Workflow Summary

```
1. Pick from ready-to-work (without post-mvp)
   → Ship core MVP features
├──────────────────────────────────────────────
2. Set issue to "In Progress" IMMEDIATELY
   → Prevents duplicate work
├──────────────────────────────────────────────
3. Handle user-config tasks as needed
   → Enable production features
├──────────────────────────────────────────────
4. Monitor blocked tickets
   → Auto-unblock as dependencies complete
├──────────────────────────────────────────────
5. Pick post-mvp tickets last
   → Add tests, polish, infrastructure
```

## Setting Issue Status

**CRITICAL: As soon as you decide to work on an issue, set it to "In Progress"**

### Method 1: GitHub Projects (Recommended)

If the issue is in a GitHub Project board:
- Go to: https://github.com//projects/1
- Find the issue and drag to "In Progress" column

### Method 2: Label + Comment

```bash
gh issue edit <number> --add-label "in-progress"
gh issue comment <number> --body "Started working on this"
```

### When You Finish

```bash
# If work is complete
gh issue close <number> --comment "Completed in PR #123"

# Or move to Done in project board
```

**If you stop working on it:**
```bash
gh issue edit <number> --remove-label "in-progress"
gh issue comment <number> --body "No longer working on this - available for others"
```

## Tips for Efficient Work

### Parallel Development

**Safe to work on in parallel (no conflicts):**
- Any tickets with `ready-to-work` that don't modify the same feature

### Dependency Awareness

**Before picking a ticket:**
1. Check the issue for blocking comments
2. Verify it has `ready-to-work` or `user-config` label
3. Confirm it doesn't have `blocked` or `post-mvp` labels

### When Blocked Tickets Unblock

Labels are automatically updated when:
- PRs are merged (removes `blocked-by-pr`)
- Dependency issues are closed (removes `blocked`, adds `ready-to-work`)

## Quick Reference Commands

```bash
# What should I work on RIGHT NOW?
gh issue list --label "ready-to-work" --search "-label:post-mvp"

# What needs user configuration?
gh issue list --label "user-config"

# What's blocked (don't pick these)?
gh issue list --label "blocked"
gh issue list --label "blocked-by-pr"

# What's for later (post-MVP)?
gh issue list --label "post-mvp"

# All open tickets with labels
gh issue list --json number,title,labels --jq '.[] | "\(.number): \(.title) [\(.labels | map(.name) | join(", "))]"'
```

## Updating Labels

As work progresses, labels should be updated:

**When a PR is merged:**
```bash
gh issue edit <number> --remove-label "blocked-by-pr" --add-label "ready-to-work"
```

**When a dependency is resolved:**
```bash
gh issue edit <number> --remove-label "blocked" --add-label "ready-to-work"
```

---

**Last Updated:** [DATE]
**Maintained By:** Project maintainers
**Reference:** See GitHub issues at /issues
