# Flutter App Structure

This follows Clean Architecture with a feature-based organization.

## Directory Overview

```
lib/
├── main.dart              # App entry point
├── app/                   # App-level configuration
│   ├── app.dart          # Root widget (MaterialApp)
│   └── router.dart       # Navigation/routing setup
├── core/                  # Shared code across features
│   ├── constants/        # App-wide constants
│   ├── error/            # Failure/Exception classes
│   ├── network/          # Network utilities
│   ├── utils/            # Extensions, helpers
│   └── widgets/          # Reusable UI components
└── features/             # Feature modules
    └── {feature_name}/   # Each feature follows 4-layer structure
```

## Creating a New Feature

1. Create folder under `features/` with feature name
2. Add the four layers: `data/`, `domain/`, `application/`, `presentation/`
3. See `features/_feature_template/README.md` for detailed guidance

## Key Patterns

- **State Management**: Riverpod (providers, notifiers)
- **Navigation**: GoRouter with declarative routes
- **Dependencies**: Inject via Riverpod providers
- **Error Handling**: Result types or try/catch with typed exceptions
