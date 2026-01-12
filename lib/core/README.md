# Core Module

Shared code used across multiple features. Nothing feature-specific lives here.

## Subdirectories

### `constants/`
App-wide constants:
- API URLs, timeouts
- UI constants (padding, border radius)
- Route names
- Asset paths

### `error/`
Error handling classes:
- `Failure` - Domain-level error representations
- `Exception` - Data-level exceptions
- Keep these generic, not feature-specific

### `network/`
Networking utilities:
- Network connectivity checking
- HTTP client configuration
- API interceptors

### `utils/`
Helper utilities:
- Extension methods on BuildContext, String, DateTime
- Formatters
- Validators

### `widgets/`
Reusable UI components:
- `LoadingIndicator` - Centered spinner with optional message
- `ErrorView` - Error display with retry action
- `EmptyState` - Empty content placeholder

## Guidelines

- Only add code here if it's used by 2+ features
- Keep dependencies minimal
- No business logic - just utilities
- Document public APIs
