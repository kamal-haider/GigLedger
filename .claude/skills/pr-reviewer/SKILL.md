---
name: pr-reviewer
description: Reviews pull requests for code quality, security, and adherence to GigLedger standards. Use when reviewing PRs before merge. Provides actionable feedback and determines merge-worthiness.
---

# Pull Request Reviewer

## Purpose

This skill reviews pull requests contextually - understanding the ticket goals, reviewing only relevant scope, and providing actionable feedback prioritized by actual impact.

## Review Process

### 1. Gather Full Context (REQUIRED FIRST STEP)

```bash
# View PR details and linked issue
gh pr view <number>

# Get the linked issue details (extract issue number from PR body/title)
gh issue view <issue_number>

# View PR diff (the actual changes)
gh pr diff <number>

# Read existing PR comments for context
gh pr view <number> --comments

# Check PR status
gh pr checks <number>
```

**Before reviewing code, you MUST understand:**

#### App North Star (Reference: `docs/01_vision_and_positioning.md`)
- GigLedger helps freelancers manage finances - invoicing, expenses, clients, insights
- Core philosophy: **Speed over features** - every action should feel instant
- Simplicity over comprehensiveness - effortless, not powerful

#### Feature Intention
- What ticket/issue is this PR addressing?
- What are the acceptance criteria?
- How does this feature help reach the app's north star?
- What user problem does this solve?

#### PR Scope
- What scope of work was intended?
- Have previous comments explained any decisions?

### 1b. Context Validation

**If you don't have enough context to review properly, you MUST say so.**

Before proceeding, verify you can answer:
1. What is the user-facing goal of this change?
2. What acceptance criteria define "done"?
3. How does this fit into the app's overall mission?

If ANY of these are unclear, your review should START with:

```markdown
## Context Needed

Before I can properly review this PR, I need clarification on:

- [ ] [Specific question 1]
- [ ] [Specific question 2]

Please update the PR description or add a comment with this context.
```

**Do NOT review code until you have sufficient context.** A review without understanding the goal is just noise.

### 2. Scope-Aware Review

**CRITICAL RULE: Only review changes within the PR's intended scope.**

- If the ticket is "Add expense form", don't flag unrelated code quality issues in other files
- If a comment says "will handle in separate issue", verify the issue exists and move on
- Focus on: Does this PR accomplish its stated goal correctly?

### 3. Severity Definitions

Be precise about severity. Misclassifying issues wastes everyone's time.

| Severity | Definition | Examples | Blocks Merge? |
|----------|------------|----------|---------------|
| **CRITICAL** | Will break the app or cause data loss | Null pointer crashes, data corruption, security vulnerabilities exposing user data | YES |
| **HIGH** | Significant bug within PR scope | Feature doesn't work as specified, missing required validation | YES |
| **MEDIUM** | Code quality issue within PR scope | Poor naming, missing error handling for edge cases | NO - create issue |
| **LOW** | Minor improvement suggestions | Style preferences, minor optimizations | NO - optional |

**What is NOT critical:**
- Architectural preferences ("should use X pattern instead")
- Missing tests (unless specifically required by ticket)
- Code in files not modified by this PR
- Future improvements ("should also add Y feature")

### 4. Issue Management

Before flagging a non-critical concern:

```bash
# Search for existing issues covering this concern
gh issue list --search "keyword from concern"
```

**For MEDIUM/LOW concerns:**
1. Check if an existing issue already covers it
2. If yes: Note "Covered by #XX" and don't block
3. If no: Create an issue with appropriate labels

```bash
# Create issue for deferred work
gh issue create --title "Brief description" --body "Context from PR review" --label "post-mvp,enhancement"
```

### 5. Review Output Format

```markdown
## PR #X Review: [Title]

### TL;DR
> One-line summary for quick scanning

**[VERDICT]** [One sentence: what's the status and what's needed]

Example: "APPROVE - Feature works as specified, ready for manual testing"
Example: "REQUEST CHANGES - 1 critical bug: null crash on empty list"
Example: "CONTEXT NEEDED - Missing acceptance criteria from ticket"

---

### Context Status
> State whether you have full context or what's missing

**[FULL CONTEXT]** I understand the goal, acceptance criteria, and how this fits the app's mission.

OR

**[CONTEXT NEEDED]** I'm missing the following to review effectively:
- [ ] [What's unclear]

### Ticket Context
- **Issue:** #XX - [Issue Title]
- **Goal:** [1-sentence summary of what this PR should accomplish]
- **North Star Alignment:** [How this helps freelancers manage finances more easily]
- **Acceptance Criteria:** [List from ticket]

### Acceptance Criteria Check
> Go through each acceptance criterion from the ticket

- [ ] [Criterion 1 from ticket] - MET / NOT MET / PARTIALLY MET
- [ ] [Criterion 2 from ticket] - MET / NOT MET / PARTIALLY MET

### Scope Check
- [ ] Changes are within intended scope
- [ ] PR accomplishes the stated goal
- [ ] No regressions to existing working features

### Suggested Manual Testing
> What should be tested before merge (be specific)

1. [Step 1]
2. [Step 2]
3. [Expected result]

### Issues Found

#### CRITICAL (Blocks Merge)
> Only issues that will break the app or cause data loss

- None / [Specific issue with file:line reference]

#### HIGH (Blocks Merge)
> Bugs within the PR's scope that prevent the feature from working

- None / [Specific issue]

#### MEDIUM (Create Issue, Don't Block)
> Code quality concerns - create issues for later

- [Concern] → Created #XX / Covered by existing #XX

#### LOW (Optional)
> Nice-to-haves, style suggestions

- [Suggestion]

### Context from PR Comments
> Any decisions explained in comments that affect this review

- [Summary of relevant discussions]

### Performance Check (North Star: Speed)
> Since GigLedger prioritizes speed, flag anything that could slow the app

- [ ] No unnecessary rebuilds or re-renders
- [ ] No blocking operations on UI thread
- [ ] Efficient data fetching (no N+1 queries)
- N/A if not applicable to this PR

### Review Confidence
**HIGH** / **MEDIUM** / **LOW**

[Explain what affects your confidence - e.g., "HIGH - clear ticket, straightforward changes" or "MEDIUM - missing acceptance criteria, reviewed based on PR description only"]

### Verdict
**APPROVE** / **REQUEST CHANGES**

[If REQUEST CHANGES: List only the CRITICAL/HIGH items that must be fixed]
[If APPROVE: Confirm the PR accomplishes its goal and is ready for the suggested manual testing]

### Next Steps
> Clear, actionable list of what happens next

**If APPROVED:**
1. Complete manual testing above
2. Merge when ready

**If CHANGES REQUESTED:**
1. [Specific fix needed]
2. [Specific fix needed]
3. Re-request review when done

**If CONTEXT NEEDED:**
1. Answer the questions above
2. Comment or update PR description
3. Re-request review
```

### 5b. PR Quality Feedback

If the PR itself needs improvement (separate from the code):

```markdown
### PR Quality
> Help improve the PR for future reviewers

- **Description:** Clear / Needs improvement - [what's missing]
- **Linked Issue:** Present / Missing - should reference #XX
- **Size:** Appropriate / Too large - consider splitting [suggestion]
```

### 6. Follow-Up Reviews

When re-reviewing after comments/updates are added:

```markdown
## PR #X Follow-Up Review

### Context Update
**[RESOLVED]** The following questions have been answered:
- [x] [Question that was answered]
- [x] [Question that was answered]

I now have full context to review.

OR

**[STILL NEEDED]** Thanks for the update. I still need clarification on:
- [ ] [Remaining question]
```

Always acknowledge what new information was provided and whether it resolves your previous questions.

### 7. Post Review Actions

```bash
# If approved
gh pr comment <number> --body "Review comment"
gh pr merge <number> --squash --delete-branch

# If changes requested - only for CRITICAL/HIGH issues
gh pr comment <number> --body "Review comment"
```

## Key Principles

1. **North Star Aligned**: Understand how this PR helps freelancers manage finances effortlessly
2. **Ticket-First**: Always understand the goal before reviewing code
3. **Context-Transparent**: Explicitly state what you know and what you're missing
4. **Scope-Bound**: Only flag issues within the PR's intended scope
5. **Impact-Based Severity**: CRITICAL = app breaks, not "could be better"
6. **Issue-Driven Deferral**: Non-blocking concerns become tracked issues, not PR blockers
7. **Comment-Aware**: Read comments, understand decisions, don't re-litigate
8. **Acknowledge Updates**: When context is added, confirm what's resolved vs still unclear
9. **Actionable Output**: Every piece of feedback should have a clear action

## Special Review Cases

### Dependency Changes (pubspec.yaml)

When a PR adds or modifies dependencies, **search the ENTIRE codebase** before flagging issues:

```bash
# Check if a dependency is used ANYWHERE in the codebase (not just PR files)
grep -r "import.*package_name" lib/

# Example: Before saying "rxdart is unused"
grep -r "import.*rxdart" lib/
```

**CRITICAL RULE:** A dependency added in a PR may already be used elsewhere in the codebase. Only flag a dependency as unused if `grep` confirms zero imports across ALL of `lib/`.

**Common false positives to avoid:**
- Dependency added to pubspec.yaml but used in files NOT changed by this PR
- Transitive dependencies being made explicit (already used indirectly)
- Dependencies used by code generation (build_runner, riverpod_generator)

## Anti-Patterns to Avoid

- **Reviewing without context**: Never review code without understanding the goal first
- **Ignoring the north star**: Feedback should align with making freelance finances effortless
- **Silent confusion**: If you don't understand something, ASK - don't guess
- Flagging code that wasn't changed by this PR
- Marking style preferences as CRITICAL
- Blocking PRs for missing tests when tests weren't in scope
- Re-raising concerns that were already discussed and resolved
- Suggesting scope expansion ("while you're here, also do X")
- Creating duplicate issues for existing concerns
- **Ignoring follow-up context**: When someone answers your questions, acknowledge it
- **Flagging dependencies as unused without searching the full codebase** - Always grep before claiming a package is unused

## References

- `docs/01_vision_and_positioning.md` - App north star and philosophy
- `docs/02_mvp_prd.md` - MVP scope and acceptance criteria
- `docs/05_data_model_and_schema.md` - Data layer standards
- `docs/07_app_architecture.md` - Architecture patterns
- `CLAUDE.md` - Development guidelines
