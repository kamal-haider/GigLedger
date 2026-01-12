---
name: architecture-expert
description: Expert on GigLedger's architecture, app structure, feature modules, and state management. Use when implementing features, creating new modules, or understanding the architectural patterns. References docs/07_app_architecture.md.
---

# GigLedger Architecture Expert

## Purpose

This skill provides deep expertise on GigLedger's application architecture:

- [Architecture pattern] architecture
- Feature-based directory structure
- [State management] patterns
- Data flow and layer responsibilities
- Testing strategy per layer

## Source of Truth

**Primary Reference:** `docs/07_app_architecture.md`

This document is the authoritative source for all architectural decisions.

## Layer Architecture

Every feature in GigLedger follows this structure:

```
lib/features/{feature_name}/
├── presentation/
│   ├── pages/           # Screen components
│   ├── widgets/         # Reusable UI components
│   └── providers/       # State management
│
├── application/
│   ├── use_cases/       # Business logic operations
│   └── services/        # Coordinating services
│
├── domain/
│   ├── models/          # Core business entities
│   └── repositories/    # Repository interfaces (contracts)
│
└── data/
    ├── dto/             # Data Transfer Objects
    ├── data_sources/    # Database/API implementations
    └── repository_impl/ # Repository interface implementations
```

## Layer Responsibilities

### Presentation Layer
**What it does:**
- Displays UI
- Manages user interactions
- Holds screen-specific state
- Reacts to state changes

**What it CANNOT do:**
- Call repositories directly
- Contain business logic
- Make API/database calls
- Transform DTOs to domain models

**Dependencies:** Application layer only (use cases)

---

### Application Layer
**What it does:**
- Implements use cases (business operations)
- Orchestrates data flow
- Calls repository interfaces
- Transforms domain models for presentation

**What it CANNOT do:**
- Know about UI
- Know about database/DTOs
- Call data sources directly

**Dependencies:** Domain layer only (models, repository interfaces)

---

### Domain Layer
**What it does:**
- Defines core business entities (models)
- Defines repository contracts (interfaces)
- Contains business rules and validation
- Platform and framework agnostic

**What it CANNOT do:**
- Know about database/DTOs
- Know about UI
- Contain implementation details

**Dependencies:** None (pure code)

---

### Data Layer
**What it does:**
- Implements repository interfaces from domain
- Communicates with database/external APIs
- Transforms DTOs ↔ domain models
- Handles caching and error recovery

**What it CANNOT do:**
- Contain business logic
- Be called directly by presentation layer

**Dependencies:** Domain layer (implements interfaces, uses models)

## Data Flow

The complete data flow through all layers:

```
User Action (UI)
  ↓
Presentation Layer (Component/Provider)
  ↓
Application Layer (Use Case)
  ↓
Domain Layer (Repository Interface)
  ↓
Data Layer (Repository Implementation)
  ↓
Database / Backend
  ↓
Data Layer (DTO → Domain Model)
  ↓
Application Layer (Business Logic)
  ↓
Presentation Layer (Display)
```

## State Management

### Provider/State Types

Reference your framework's state management patterns here.

### State Guidelines
- One state object per screen
- Immutable state
- Async data handled properly

## Feature Module Structure

When creating a new feature (e.g., `profile`):

```bash
mkdir -p lib/features/profile/{presentation,application,domain,data}
mkdir -p lib/features/profile/presentation/{pages,widgets,providers}
mkdir -p lib/features/profile/application/{use_cases,services}
mkdir -p lib/features/profile/domain/{models,repositories}
mkdir -p lib/features/profile/data/{dto,data_sources,repository_impl}
```

## Testing Strategy per Layer

Reference: `docs/07_app_architecture.md` testing section

### Unit Tests
**What to test:**
- Domain models (business logic methods)
- Use cases (application layer)
- DTO transformations
- Repository implementations (mocked database)

### Widget/Component Tests
**What to test:**
- Screen rendering
- User interactions
- State transitions
- Error states

### Integration Tests
**What to test:**
- Database read flows (with emulator if available)
- Navigation paths
- End-to-end user journeys

## Core Module (Shared Code)

Shared utilities live in `lib/core/`:

```
lib/core/
├── config/          # Configuration
├── constants/       # App-wide constants
├── domain/models/   # Shared domain models
├── error/           # Error types and handlers
├── logging/         # Logging utilities
├── network/         # Network utilities
├── services/        # Shared services
├── theme/           # Theming
├── utils/           # Helper functions
└── widgets/         # Shared widgets
```

## Critical Architectural Rules

### 1. Never Skip Layers
**Wrong:** Presentation → Data
**Correct:** Presentation → Application → Domain → Data

### 2. Dependencies Point Inward
- Presentation depends on Application
- Application depends on Domain
- Data depends on Domain (implements interfaces)
- Domain depends on nothing

### 3. DTOs Stay in Data Layer
**Wrong:** Pass DTOs to use cases or presentation
**Correct:** Transform DTOs to domain models in data layer

### 4. Business Logic in Use Cases
**Wrong:** Business logic in widgets or repositories
**Correct:** Business logic in application layer use cases

### 5. State Management for All State
**Wrong:** Local component state for shared data
**Correct:** Proper state management providers

## Platform Considerations

- Responsive layouts
- Test on all target platforms
- Avoid platform-specific code where possible
- Optimize for performance

## Performance Best Practices

- Enable database persistence (offline cache)
- Avoid rebuilding expensive components
- Cache computed data in memory
- Use pagination for large lists

## When to Use This Skill

Use this skill when:
- Creating a new feature module
- Understanding layer responsibilities
- Setting up state providers
- Writing tests for specific layers
- Refactoring code to follow architecture
- Reviewing code for architectural compliance

## Quick Reference Checklist

When implementing a feature:

- [ ] Create four-layer directory structure
- [ ] Define domain models (pure code, no dependencies)
- [ ] Define repository interface in domain layer
- [ ] Implement repository in data layer with DTOs
- [ ] Create use case in application layer
- [ ] Set up state providers in presentation layer
- [ ] Build UI components consuming providers
- [ ] Write unit tests for use cases and models
- [ ] Write component tests for screens
- [ ] Verify no layers are skipped in data flow

## Summary

GigLedger's architecture ensures:
- Clean separation of concerns
- Testability at every layer
- Scalability for future features
- Framework independence in domain layer
- Consistent patterns across all features

**Remember:** Always reference `docs/07_app_architecture.md` as the ultimate source of truth for architectural decisions.
