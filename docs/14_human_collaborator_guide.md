# Human Collaborator Guide

This document describes the role of the human collaborator in the GigLedger agent-assisted development process. It's intended for the human to understand their responsibilities, and to enable handoffs to other humans or AI agents that could simulate this role.

## Your Role: Quality Gate & Decision Maker

You are **not** writing code. You are the:
- **Product owner** - deciding what gets built and in what order
- **Quality gate** - testing features and approving releases
- **Process enforcer** - ensuring agents follow the documented workflow
- **Final authority** - approving PRs and merges

The agent handles implementation; you handle validation and direction.

---

## What You Actually Do

### 1. Direct Work ("what's next", "let's do X")

You tell the agent what to work on. This can be:
- Selecting from ready issues: "let's do #17"
- Responding to agent recommendations: "sure, do that"
- Providing new requirements: "add a dark mode toggle"

**You don't need to**: Specify how to implement, which files to edit, or technical approach.

### 2. Manual Testing (UAT)

When the agent says something is ready to test, you:
1. Run the app on simulator/device
2. Test the feature against acceptance criteria
3. Report what works and what doesn't

**How to report bugs effectively:**
```
"still getting a duplicate invoice number 5 when i duplicate"
[attach screenshot]
```

**You don't need to**: Diagnose root causes, suggest fixes, or look at code.

### 3. PR Review & Merge Approval

When the agent creates a PR:
- CI runs automatically
- Agent may request review
- You approve and say "merge X" when ready

**What to check:**
- Does the PR description make sense?
- Are issues linked?
- Did your manual testing pass?

**You don't need to**: Review code line-by-line (the agent and CI handle that).

### 4. Process Enforcement

This is critical. You catch the agent when it:
- Pushes directly to main (should use PRs)
- Fixes bugs without creating issues
- Skips adding work to the project board
- Makes promises but doesn't encode them in docs

**How to enforce:**
```
"you keep saying you will do that going forward but you seem to go back
to the other process over-time, do you just forget after awhile or is
there a way we can put up better guards?"
```

This feedback led to the "Issue-First Development" rule being added to CLAUDE.md.

### 5. Decision Making

When the agent presents options, you choose:
- Which issue to work on next
- Whether to merge a PR
- Whether a fix is acceptable
- Prioritization and scope decisions

---

## Typical Interaction Patterns

### Starting a work session
```
Human: "what's next"
Agent: [lists ready issues with recommendation]
Human: "let's do #17"
Agent: [creates issue if needed, starts work]
```

### During implementation
```
Agent: "Created PR #72, ready for testing"
Human: [tests on device]
Human: "works" or "still broken, [description + screenshot]"
```

### Merging
```
Human: "merge 72"
Agent: [merges, closes issues, updates project]
```

### Process correction
```
Human: "i don't see this work in the project"
Agent: [creates issues retroactively, updates process docs]
```

---

## What You Should Push Back On

1. **Agent writing code without an issue** - "create an issue first"
2. **Agent pushing to main** - "use a PR"
3. **Agent making verbal promises** - "add that to CLAUDE.md so future agents see it"
4. **Scope creep** - "is that in the MVP?"
5. **Untested changes** - "did you run the tests?"

---

## Time Commitment

A typical feature cycle:
- **2 min**: Select issue, say "let's do X"
- **0 min**: Agent implements (you can do other things)
- **5 min**: Test on device when agent says ready
- **1 min**: Report results, approve merge

You're the bottleneck only for testing and approvals - everything else is async.

---

## Handoff Checklist

If handing off to another human:
- [ ] They have access to the GitHub repo
- [ ] They can run the app on simulator/device
- [ ] They understand they're NOT writing code
- [ ] They know to check the GitHub project for status
- [ ] They've read this document

---

## Key Principle

**The GitHub project is the source of truth.**

If it's not in the project, it doesn't exist. All communication with agents should result in trackable artifacts (issues, PRs, comments). Verbal agreements in chat are lost when context resets.

Your job is to ensure the agent maintains this discipline.
