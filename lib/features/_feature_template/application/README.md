# Application Layer

Business logic orchestration. Use cases that coordinate domain operations.

## Contents

### Use Cases
Single-purpose classes that execute one business operation.

```dart
class GetRaceUseCase {
  final IRaceRepository _repository;

  GetRaceUseCase(this._repository);

  Future<Race> call(String id) async {
    return _repository.getById(id);
  }
}

class GetRacesWithFilterUseCase {
  final IRaceRepository _repository;

  GetRacesWithFilterUseCase(this._repository);

  Future<List<Race>> call({
    int? season,
    bool completedOnly = false,
  }) async {
    final races = await _repository.getAll();

    return races.where((race) {
      if (season != null && race.season != season) return false;
      if (completedOnly && !race.isCompleted) return false;
      return true;
    }).toList();
  }
}
```

## Guidelines

1. **Single Responsibility** - One use case = one operation
2. **Named `call` method** - Allows `useCase(params)` syntax
3. **Inject repositories** - Via constructor
4. **Return domain models** - Not DTOs
5. **Business logic here** - Filtering, sorting, combining data

## When to Create Use Cases

**Do create** when you need to:
- Combine data from multiple repositories
- Apply business rules/filtering
- Transform data for presentation
- Coordinate multiple operations

**Don't create** for simple CRUD:
- If it's just `repository.getById(id)`, call repository directly
- Use cases add value when there's actual logic

## Naming Convention

`{Verb}{Noun}UseCase`

Examples:
- `GetRaceUseCase`
- `GetRacesForSeasonUseCase`
- `UpdateUserProfileUseCase`
- `CalculateDriverStatsUseCase`
- `CompareDriversUseCase`
