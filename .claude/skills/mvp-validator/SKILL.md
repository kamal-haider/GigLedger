---
name: mvp-validator
description: Validates features and changes against GigLedger's MVP scope. Use before implementing new features to confirm they're in scope, when reviewing scope creep, or checking acceptance criteria. References docs/02_mvp_prd.md.
---

# GigLedger MVP Validator

## Purpose

This skill provides **fast scope validation** for GigLedger features:

- Check if a feature is in MVP scope
- Verify acceptance criteria
- Identify scope creep
- Flag future roadmap items
- Validate against PRD requirements

## Source of Truth

**Primary Reference:** `docs/02_mvp_prd.md`

This document defines what is and is not in the MVP.

## Core Principle

> **If it's not in the docs, it's not a requirement.**

Before implementing ANY feature, validate it against the PRD.

## In-Scope Features (MVP)

These features are **APPROVED for implementation**:

Reference: `docs/02_mvp_prd.md` section 3

[List your in-scope features from the PRD]

---

## Out of Scope (Explicit Rejections)

These features are **NOT in MVP** - reject implementation requests:

Reference: `docs/02_mvp_prd.md` section 4

[List your out-of-scope features from the PRD]

---

## Monetization (MVP-Compatible)

### Free Tier
**In Scope**
[List free tier features]

### Pro Tier
**In Scope** (configurable at launch)
[List pro tier features]

**Pricing TBD** - see `docs/08_monetization_and_pricing.md`

Reference: `docs/02_mvp_prd.md` section 5

---

## Technical Constraints

### [Backend]
- [Constraint 1]
- [Constraint 2]
- [Constraint 3]

### [External API] (if applicable)
- [Constraint 1]
- [Constraint 2]

### [Framework]
- [Constraint 1]
- [Constraint 2]
- [Constraint 3]

Reference: `docs/02_mvp_prd.md` section 6

---

## Acceptance Criteria (High-Level)

**MVP is complete when:**

- [ ] User can [key action 1]
- [ ] User can [key action 2]
- [ ] User can [key action 3]
- [ ] App runs consistently on [platforms]
- [ ] No sensitive credentials exposed client-side

Reference: `docs/02_mvp_prd.md` section 7

---

## MVP Exit Criteria

**MVP is considered complete when:**

- [ ] All in-scope features are implemented
- [ ] Performance is acceptable on mid-range devices
- [ ] Data accuracy is validated against known test cases
- [ ] App is deployable to [stores/platforms]

Reference: `docs/02_mvp_prd.md` section 8

---

## Validation Workflow

### When Evaluating a Feature Request

**Step 1: Check In-Scope List**
- Is the feature explicitly listed in section 3 of `docs/02_mvp_prd.md`?
- If YES → Proceed with implementation
- If NO → Go to Step 2

**Step 2: Check Out-of-Scope List**
- Is the feature explicitly listed in section 4 of `docs/02_mvp_prd.md`?
- If YES → Reject the feature (add to roadmap if valuable)
- If NO → Go to Step 3

**Step 3: Evaluate Against MVP Goals**
Ask:
1. Does it help users [achieve core value]?
2. Does it enable [core user journey]?
3. Is it essential for MVP validation?

- If YES to all → Consult with product owner, potentially add to docs first
- If NO to any → Reject as scope creep

**Step 4: Document Decision**
- If accepted: Update `docs/02_mvp_prd.md` section 3
- If rejected: Update `docs/09_roadmap.md` for future consideration

---

## Common Scope Questions

### Q: [Common question 1]?
**Answer:** [Answer with reference]

### Q: [Common question 2]?
**Answer:** [Answer with reference]

### Q: [Common question 3]?
**Answer:** [Answer with reference]

---

## Quick Validation Checklist

Before implementing a feature:

- [ ] Feature is explicitly listed in `docs/02_mvp_prd.md` section 3
- [ ] Feature is NOT in the out-of-scope list (section 4)
- [ ] Acceptance criteria are defined
- [ ] Technical constraints are understood
- [ ] No scope creep - feature is minimal viable version
- [ ] Feature aligns with MVP goals

If all boxes are checked → Proceed

If any box is unchecked → Consult PRD or product owner

---

## When to Use This Skill

Use this skill when:
- Starting a new feature (validate scope first)
- Reviewing a GitHub ticket or feature request
- Deciding if a bug fix is in scope
- Evaluating a suggested enhancement
- Planning sprint priorities
- Reviewing PRs for scope creep

## Example Validations

### Example 1: "[Feature that's out of scope]"

**Validation:**
1. Check in-scope list → Not found
2. Check out-of-scope list → [Related item] explicitly out of scope
3. **Decision:** Reject (add to roadmap)

### Example 2: "[Feature that's in scope]"

**Validation:**
1. Check in-scope list → Section 3.X "[Feature description]"
2. **Decision:** Approve (explicitly in scope)

### Example 3: "[Optional feature]"

**Validation:**
1. Check in-scope list → Section 3.X (optional MVP+)
2. **Decision:** Optional (implement if time permits, not blocking MVP)

---

## Summary

The MVP Validator ensures:
- Features align with documented scope
- Scope creep is identified and prevented
- Development stays focused on MVP goals
- Future ideas are captured in roadmap, not MVP

**Remember:** Always reference `docs/02_mvp_prd.md` before implementing any feature. If it's not documented, stop and validate first.

## Final Rule

> **If a feature is not explicitly in `docs/02_mvp_prd.md` section 3, it is OUT OF SCOPE until documented.**

No exceptions. Update docs first, then code.
