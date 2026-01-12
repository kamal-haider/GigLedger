# GigLedger — Document Usage & Reference Guide

## Purpose

This document explains:
- **When to read each document**
- **What decisions it governs**
- **Which phases of the project it applies to**

It ensures the GigLedger document suite is used correctly and consistently
throughout ideation, development, launch, and iteration.

Think of this as the **map to the map**.

---

## How to Use This Guide

- If you're **deciding what to build** → start with Vision & PRD
- If you're **designing UX or screens** → IA & Personas
- If you're **writing code** → Architecture, Data Model, Integration
- If you're **preparing to ship** → Roadmap & Launch Checklist

---

## 1. Vision & Positioning
**File:** `01_vision_and_positioning.md`

### When to Check This
- At the start of the project
- When evaluating new feature ideas
- When prioritizing roadmap changes
- When explaining GigLedger to others

### What It Governs
- Product identity
- Differentiation
- Target audience
- Long-term direction

### Key Question It Answers
> "What are we building, and why does it exist?"

If a feature doesn't align with this document, it should not be built.

---

## 2. MVP Product Requirements Document (PRD)
**File:** `02_mvp_prd.md`

### When to Check This
- Before starting implementation
- When creating tickets
- When deciding if something is in or out of scope
- When pushing back on feature creep

### What It Governs
- MVP feature scope
- Explicit non-goals
- Acceptance criteria
- Success metrics

### Key Question It Answers
> "Is this required for MVP, or is it future work?"

This is the **scope authority**.

---

## 3. User Personas & Jobs-To-Be-Done
**File:** `03_user_personas_and_jobs.md`

### When to Check This
- During UX design
- When making UI/UX tradeoffs
- When deciding how much explanation to include
- When shaping monetization boundaries

### What It Governs
- Who the app is for
- What problems matter most
- How features should feel to users

### Key Question It Answers
> "Who are we solving this for, and what job are they hiring GigLedger to do?"

---

## 4. Information Architecture & Screens
**File:** `04_information_architecture_and_screens.md`

### When to Check This
- Before building screens
- When adding new navigation paths
- When deciding screen responsibilities
- When resolving UI ambiguity

### What It Governs
- Screen list
- Navigation structure
- Screen ownership
- Mobile vs web behavior

### Key Question It Answers
> "Where does this feature live in the app?"

---

## 5. Data Model & Schema
**File:** `05_data_model_and_schema.md`

### When to Check This
- Before writing backend code
- Before creating database collections/tables
- When optimizing performance or cost
- When debugging data issues

### What It Governs
- Database structure
- DTO vs domain model separation
- Caching strategy
- Cost safeguards

### Key Question It Answers
> "How is data stored, derived, and consumed safely?"

---

## 6. Integration Specification
**File:** `06_integration_spec.md`

### When to Check This
- Before integrating external APIs
- When updating backend logic
- When external services change behavior
- When debugging data inconsistencies

### What It Governs
- Which external endpoints are used
- Backend proxy behavior
- Polling vs caching rules
- Error handling

### Key Question It Answers
> "How does GigLedger communicate with external services safely?"

---

## 7. App Architecture
**File:** `07_app_architecture.md`

### When to Check This
- Before writing code
- When adding new features
- When refactoring
- When onboarding developers

### What It Governs
- Folder structure
- Layer responsibilities
- State management
- Data flow

### Key Question It Answers
> "Where does this code belong, and how should it be written?"

---

## 8. Monetization & Pricing Strategy
**File:** `08_monetization_and_pricing.md`

### When to Check This
- When gating features
- When designing Pro-only UX
- When evaluating new revenue ideas
- Before launch

### What It Governs
- Free vs Pro boundaries
- Pricing logic
- Expansion options

### Key Question It Answers
> "Is this feature part of the value users pay for?"

---

## 9. Product & Engineering Roadmap
**File:** `09_roadmap.md`

### When to Check This
- During planning
- When sequencing work
- When understanding project phases
- After MVP launch

### What It Governs
- Development phases
- Milestones
- Risk management

### Key Question It Answers
> "What should we be working on right now?"

---

## 10. Launch Checklist
**File:** `10_launch_checklist.md`

### When to Check This
- Before store submission
- Before public launch
- During release reviews

### What It Governs
- Production readiness
- Compliance
- Stability and monitoring

### Key Question It Answers
> "Are we actually ready to ship?"

---

## 11. Ticket Selection Guide
**File:** `11_ticket_selection_guide.md`

### When to Check This
- When choosing which issues to work on
- When creating new issues
- When managing the backlog

### What It Governs
- Label system
- Work prioritization
- Blocking/unblocking workflow

### Key Question It Answers
> "What should I work on next?"

---

## 12. Security Rules
**File:** `12_security_rules.md`

### When to Check This
- When setting up authentication
- When configuring database rules
- During security reviews

### What It Governs
- Access control
- Data protection
- Security best practices

### Key Question It Answers
> "Is this data protected appropriately?"

---

## How These Docs Work Together

- **Vision → PRD → Architecture → Execution**
- Each document has authority in its domain
- Conflicts are resolved by moving *up* the chain:
  - Architecture conflicts → PRD
  - PRD conflicts → Vision

---

## Final Rule

If you're unsure what to do next:
1. Check the **Roadmap**
2. Validate against the **PRD**
3. Confirm alignment with the **Vision**

If all three agree — proceed.

---

## Exit Criteria

This guide is complete when:
- Every document has a clear purpose
- No document overlaps ambiguously
- New contributors can onboard without verbal explanation
