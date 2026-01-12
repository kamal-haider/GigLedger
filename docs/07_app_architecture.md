# GigLedger — App Architecture

## Purpose

This document defines the **application architecture** for GigLedger.

It ensures:
- Clear separation of concerns
- Testability
- Scalability
- Long-term maintainability

This architecture is optimized for:
- [Backend type]-backed apps
- Read-heavy data flows
- [UI complexity type - e.g., Complex visualizations]

---

## 1. Architectural Style

### Chosen Pattern
**Clean Architecture + Feature-Based Structure**

Layers:
- Presentation
- Application
- Domain
- Data

This aligns with:
- [Framework] best practices
- [Backend] usage
- Long-term feature expansion

---

## 2. High-Level Directory Structure

```txt
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── domain/
│   │   └── models/      # Shared domain models (used by 3+ features)
│   ├── error/
│   ├── logging/
│   ├── network/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── home/
│   ├── [feature1]/
│   ├── [feature2]/
│   ├── [feature3]/
│   └── profile/
│
├── app/
│   ├── app.dart
│   └── router.dart
│
└── main.dart
```

Each feature follows the same internal structure.

---

## 3. Feature Module Structure

```txt
feature/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/       # Or state/
│
├── application/
│   ├── use_cases/
│   └── services/
│
├── domain/
│   ├── models/
│   └── repositories/
│
└── data/
    ├── dto/             # Or models/
    ├── data_sources/
    └── repository_impl/ # Or repositories/
```

### Shared Domain Models

When domain models are used by **3 or more features**, they should be moved to `core/domain/models/` to avoid cross-feature imports.

**Guidelines:**
- Feature-specific models stay in `features/{feature}/domain/models/`
- Shared models (used by 3+ features) move to `core/domain/models/`
- Use barrel exports for clean imports
- Document which features use each shared model

---

## 4. Layer Responsibilities

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

**Dependencies:** Application layer only

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

**Dependencies:** Domain layer only

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

---

## 5. State Management

### Recommended: [State Management Solution]

Why:
- Works well with async data
- Easy to test
- Supports scoped overrides
- Web-safe

### State Guidelines
- One state object per screen
- Immutable state
- Async data handled via [async pattern]

**Example:**
```dart
// Example state management pattern
final [feature]Provider = FutureProvider.family<[Type], String>((ref, id) {
  final useCase = ref.read([useCase]Provider);
  return useCase(id);
});
```

---

## 6. Data Flow

```txt
UI Widget
  ↓
State Provider / Notifier
  ↓
Use Case
  ↓
Repository (Domain Interface)
  ↓
Repository Impl (Data)
  ↓
Database / Backend API
```

---

## 7. Routing

- Declarative routing
- Named routes per feature
- Deep-link ready

Example routes:
- `/home`
- `/[feature]/:id`
- `/[feature2]/:parentId/:childId`
- `/profile`

---

## 8. Networking

### Client Networking Rules
- Client never calls [external service] directly
- Client only calls:
  - [Database] (read operations)
  - [Backend functions] (HTTPS endpoints)

---

## 9. Caching Strategy (Client-Side)

- Database persistence enabled
- In-memory caching for [expensive operations]
- Avoid re-fetching immutable data

---

## 10. Error Handling

- Centralized error mapping
- User-friendly error states
- Silent retries for transient failures

---

## 11. Testing Strategy

### Unit Tests
- Domain models
- Use cases
- Aggregation logic

### Widget Tests
- Core screens
- Critical interactions

### Integration Tests
- Database read flows
- Navigation paths

---

## 12. [Platform] Considerations

### Mobile
- [Mobile-specific consideration]
- [Mobile-specific consideration]

### Web
- Responsive layouts
- Test performance on web explicitly
- Avoid platform-specific plugins

---

## 13. Theme System (Optional)

### Overview
[Description of theme approach]

### Architecture
```txt
lib/core/theme/
└── [theme_file].dart
    ├── [ThemeExtension] (if applicable)
    ├── Theme builder function
    └── Custom styles
```

---

## 14. Non-Goals

- [Non-goal 1]
- [Non-goal 2]
- [Non-goal 3]

---

## 15. Exit Criteria

This architecture is complete when:
- All MVP features map cleanly to layers
- No feature bypasses domain layer
- App builds consistently on all platforms
