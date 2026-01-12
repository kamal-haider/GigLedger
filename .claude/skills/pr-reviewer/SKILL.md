---
name: pr-reviewer
description: Reviews pull requests for code quality, security, and adherence to GigLedger standards. Use when reviewing PRs before merge. Provides actionable feedback and determines merge-worthiness.
---

# Pull Request Reviewer

## Purpose

This skill reviews pull requests to ensure code quality, security, and adherence to GigLedger standards before merging.

## Review Process

### 1. Gather PR Information

```bash
# View PR details
gh pr view <number>

# View PR diff
gh pr diff <number>

# Check PR status
gh pr checks <number>
```

### 2. Review Checklist

#### Security
- [ ] No API keys, secrets, or credentials in code
- [ ] No hardcoded sensitive data
- [ ] Firestore security rules followed (user-scoped data)
- [ ] Input validation on user-facing forms
- [ ] No SQL/NoSQL injection vulnerabilities

#### Code Quality
- [ ] Follows Clean Architecture (Presentation → Application → Domain → Data)
- [ ] Proper separation of concerns
- [ ] No business logic in presentation layer
- [ ] DTOs used in data layer, domain models elsewhere
- [ ] Meaningful variable and function names
- [ ] No commented-out code (unless intentional)

#### Flutter/Dart Standards
- [ ] `flutter analyze` passes with no errors
- [ ] Proper widget composition (no mega-widgets)
- [ ] Immutable state patterns with Riverpod
- [ ] Const constructors where applicable
- [ ] Proper null safety

#### Architecture Compliance
- [ ] Feature lives in correct `lib/features/<feature>/` directory
- [ ] Repository interface in domain, implementation in data
- [ ] Use cases in application layer
- [ ] No circular dependencies

#### Documentation
- [ ] Complex logic has comments explaining "why"
- [ ] Public APIs have documentation
- [ ] README updated if needed

### 3. Provide Feedback

Structure your review as:

```markdown
## PR #X Review: [Title]

### Summary
Brief description of what the PR does.

### Strengths
- What's done well

### Issues Found
- **[CRITICAL]** Must fix before merge
- **[HIGH]** Should fix before merge
- **[MEDIUM]** Consider fixing
- **[LOW]** Optional improvements

### Suggestions
- Improvement recommendations

### Verdict
**APPROVE** / **APPROVE with changes** / **REQUEST CHANGES**

[Explanation]
```

### 4. Post Review

```bash
# Comment on PR
gh pr comment <number> --body "Your review here"

# If approved and ready to merge
gh pr merge <number> --squash --delete-branch
```

## Merge Criteria

A PR is merge-worthy when:
1. All CRITICAL and HIGH issues are resolved
2. `flutter analyze` passes
3. Code follows architecture patterns
4. No security vulnerabilities
5. Related issue(s) will be closed

## References

- `docs/07_app_architecture.md` - Architecture patterns
- `docs/05_data_model_and_schema.md` - Data layer standards
- `CLAUDE.md` - Development guidelines
