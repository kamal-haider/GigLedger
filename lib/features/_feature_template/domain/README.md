# Domain Layer

The core of your feature - pure business logic with zero external dependencies.

## Contents

### `models/`
Domain entities representing business concepts.

```dart
@immutable
class Race {
  final String id;
  final String name;
  final DateTime date;
  final List<Driver> drivers;

  // Computed properties (derived values)
  bool get isCompleted => date.isBefore(DateTime.now());

  // copyWith for immutability
  Race copyWith({String? name, ...}) { ... }

  // Equality
  @override
  bool operator ==(Object other) { ... }
}
```

**Guidelines:**
- Immutable (use `@immutable` annotation)
- No nullable fields unless truly optional
- Computed properties for derived values
- Implement `==` and `hashCode`
- Include `copyWith` method

### `repositories/`
Interfaces (contracts) that define data operations.

```dart
abstract class IRaceRepository {
  Future<Race> getById(String id);
  Future<List<Race>> getAll();
  Future<void> save(Race race);
  Stream<Race> watch(String id);
}
```

**Guidelines:**
- Abstract classes only (no implementations)
- Use domain models, not DTOs
- Define all operations the feature needs
- Include streams for real-time data

## Key Rules

1. **No imports from data layer** - Domain doesn't know about DTOs, Firebase, APIs
2. **No Flutter imports** - Pure Dart only
3. **No external packages** - Except equatable, freezed if needed
4. **Business rules live here** - Validation, calculations, domain logic
