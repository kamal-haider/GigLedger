# App Configuration

This directory contains app-level setup that runs once at startup.

## Files to Create

### `app.dart`
Root widget with MaterialApp configuration:
- Theme setup (light/dark)
- Router integration
- Global providers
- Localization

### `router.dart`
GoRouter configuration:
- Route definitions
- Navigation guards
- Deep linking
- Redirect logic

## Example Structure

```dart
// app.dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}

// router.dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomePage()),
    // Add feature routes here
  ],
);
```
