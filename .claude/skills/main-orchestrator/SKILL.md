---
name: gigledger-dev
description: GigLedger development orchestrator. Expert on all GigLedger documentation, architecture, and development standards. Use when implementing features from GitHub tickets, updating launch checklists, or ensuring code follows GigLedger standards. Always consults docs/ as source of truth.
---

# GigLedger Development Orchestrator

## Purpose

This skill serves as the **primary development guide** for GigLedger. It orchestrates development by:

1. **Enforcing documentation as source of truth** - All decisions reference `docs/`
2. **Managing GitHub project tickets** - Implements features from https://github.com//projects/1
3. **Updating launch checklist** - Marks items complete in `docs/10_launch_checklist.md`
4. **Ensuring code standards** - Validates implementation against architectural docs

## Core Principle

> **If it's not in the docs, it's not a requirement.**

All implementation decisions must reference the appropriate documentation file.

## Documentation Structure (Source of Truth)

| Document | Purpose | When to Reference |
|----------|---------|-------------------|
| `docs/00_document_usage_guide.md` | Meta-guide for using all docs | Start of any task |
| `docs/01_vision_and_positioning.md` | Product identity & differentiation | Understanding product goals |
| `docs/02_mvp_prd.md` | MVP scope & acceptance criteria | **Before implementing any feature** |
| `docs/03_user_personas_and_jobs.md` | Target users & motivations | UX decisions |
| `docs/04_information_architecture_and_screens.md` | Screen map & navigation | Routing & navigation |
| `docs/05_data_model_and_schema.md` | Database structure & caching | Database design & DTOs |
| `docs/06_integration_spec.md` | External API integration | API integration |
| `docs/07_app_architecture.md` | App structure | **Primary architecture reference** |
| `docs/08_monetization_and_pricing.md` | Free vs Pro model | Payment features |
| `docs/09_roadmap.md` | Development phases | Future planning |
| `docs/10_launch_checklist.md` | Production readiness | **Track implementation progress** |

## Critical Architectural Rules

These rules are **non-negotiable** and enforced on every feature:

### 1. [Backend Communication Rule]
- Client communicates through proper channels only
- No direct external API calls from client

Reference: `docs/06_integration_spec.md`

### 2. [Architecture Pattern] Architecture
Every feature must follow this structure:

```
lib/features/{feature_name}/
├── presentation/    # UI components, pages, state
├── application/     # Use cases, business logic services
├── domain/         # Models, repository interfaces
└── data/           # DTOs, implementations
```

Reference: `docs/07_app_architecture.md`

### 3. Data Flow Direction
```
UI → State → Use Case → Repository (Domain)
  → Repository Impl (Data) → Backend
```

Never bypass layers or skip the domain layer.

### 4. DTO vs Domain Models
- **DTOs** (data layer): Match database, nullable, defensive
- **Domain Models** (domain/application): Non-null, computed fields allowed

Reference: `docs/05_data_model_and_schema.md`

## Workflow for Implementing GitHub Tickets

When working on a ticket from https://github.com//projects/1:

### Step 1: Validate Scope
1. Read the ticket requirements
2. Check `docs/02_mvp_prd.md` to confirm it's in scope
3. If out of scope, flag it and ask for clarification

### Step 2: Reference Documentation
1. Identify which docs apply to this feature
2. Read the relevant sections completely
3. Note any constraints or requirements

### Step 3: Plan Implementation
1. Determine which feature module this belongs to
2. Plan the four-layer structure
3. Identify required database collections (reference `docs/05_data_model_and_schema.md`)
4. Plan data flow from backend to UI

### Step 4: Implement
1. Create feature directory structure
2. Implement layers in order: Domain → Data → Application → Presentation
3. Use [state management] for state management
4. Follow best practices from `docs/07_app_architecture.md`

### Step 5: Update Checklist
After completing a feature, update `docs/10_launch_checklist.md`:
- Mark relevant items as `[x]` when completed
- Add notes if needed
- Commit the checklist update with the feature

## Updating the Launch Checklist

The checklist in `docs/10_launch_checklist.md` tracks production readiness. Update it as you complete items:

**Before:**
```markdown
- [ ] All MVP screens implemented
```

**After:**
```markdown
- [x] All MVP screens implemented
```

Always update the checklist in the same commit as the feature that completes it.

## MVP Scope Enforcement

### In Scope (Implement These)
Reference: `docs/02_mvp_prd.md` section 3

### Out of Scope (Reject These)
Reference: `docs/02_mvp_prd.md` section 4

## Code Quality Standards

### State Management
- Use [state management solution] providers
- One state object per screen
- Immutable state patterns
- Handle async with [async pattern]

### Error Handling
- Graceful degraded UI for missing data
- Never block navigation on errors
- Show data freshness indicators
- Log errors for monitoring

### Performance
- Enable database persistence
- Cache expensive computations in memory
- Avoid rebuilding expensive UI
- Use server-aggregated data
- Paginate large datasets

### Security
- No API keys in client code
- Read-only access to protected data
- Users only read/write their own profile
- All sensitive operations through backend

## Testing Requirements

Reference: `docs/07_app_architecture.md` (testing section)

- **Unit tests**: Domain models, use cases, aggregation logic
- **Widget/Component tests**: Core screens, critical interactions
- **Integration tests**: Database read flows, navigation paths

## GitHub Project Integration

When pulling tickets from https://github.com//projects/1:

1. **Read ticket description fully**
2. **Map to documentation** - Which docs apply?
3. **Validate scope** - Is it in MVP?
4. **Plan implementation** - Four-layer structure
5. **Implement with docs open** - Reference constantly
6. **Update checklist** - Mark progress in `docs/10_launch_checklist.md`
7. **Test according to standards**
8. **Commit with documentation references** in commit message

## When to Use Other Skills

This orchestrator skill delegates to specialized skills for deep dives:

- **architecture-expert**: Detailed four-layer implementation questions
- **schema-expert**: Database design and DTO questions
- **integration-expert**: Backend integration specifics
- **mvp-validator**: Quick scope validation checks

## Questions to Ask Before Coding

1. Is this feature in `docs/02_mvp_prd.md` section 3 (In-Scope)?
2. Which database collections do I need? (Check `docs/05_data_model_and_schema.md`)
3. Does this require external data? (If yes, must use backend proxy per `docs/06_integration_spec.md`)
4. Which feature module does this belong to?
5. What are the acceptance criteria? (Check PRD)

## Documentation Updates

If you discover something unclear or not documented:

1. **Do not assume** - Stop and ask for clarification
2. **Update docs first** - Add the decision to appropriate doc
3. **Then implement** - Code only after docs are clear

## Summary

This skill ensures that GigLedger development:
- Always follows documented architecture
- Validates scope against MVP PRD
- Updates launch checklist as features complete
- References GitHub tickets with documentation context
- Maintains code quality and testing standards
- Never bypasses architectural constraints

**Remember:** Docs are the source of truth. Code follows docs, not the other way around.
