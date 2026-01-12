# Core Widgets

Reusable UI components for consistent UX across features.

## Standard Widgets to Create

### LoadingIndicator
Centered loading spinner with optional message.
```dart
LoadingIndicator(message: 'Loading...')
```

### ErrorView
Error display with retry action.
```dart
ErrorView(
  message: 'Failed to load',
  onRetry: () => refresh(),
)
```

### EmptyState
Placeholder for empty content.
```dart
EmptyState(
  icon: Icons.inbox,
  title: 'No items',
  message: 'Create your first item',
  action: ElevatedButton(...),
)
```

## Guidelines

- Use theme colors (don't hardcode)
- Support dark mode
- Keep props minimal
- Document with dartdoc comments
