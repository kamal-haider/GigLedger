# Data Layer

Handles external data - APIs, databases, local storage. Implements domain interfaces.

## Contents

### `dtos/`
Data Transfer Objects matching external data structure.

```dart
class RaceDTO {
  final String? id;        // Nullable - defensive
  final String? name;
  final String? dateStr;   // Match API format

  factory RaceDTO.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }

  // Convert to domain model
  Race toDomain() {
    if (id == null || name == null) {
      throw FormatException('Missing required fields');
    }
    return Race(
      id: id!,
      name: name!,
      date: DateTime.parse(dateStr!),
    );
  }

  // Convert from domain model
  factory RaceDTO.fromDomain(Race race) { ... }
}
```

**Guidelines:**
- Nullable fields (external data is unreliable)
- Match external structure exactly
- `fromJson`/`toJson` for serialization
- `toDomain()`/`fromDomain()` for conversion
- Throw on invalid data in `toDomain()`

### `datasources/`
Actual data fetching implementations.

```dart
abstract class IRaceRemoteDataSource {
  Future<RaceDTO> fetch(String id);
  Future<List<RaceDTO>> fetchAll();
}

class RaceFirestoreDataSource implements IRaceRemoteDataSource {
  final FirebaseFirestore _firestore;

  @override
  Future<RaceDTO> fetch(String id) async {
    final doc = await _firestore.collection('races').doc(id).get();
    return RaceDTO.fromJson(doc.data()!);
  }
}
```

**Guidelines:**
- Interface + Implementation pattern
- One per data source (Firestore, REST API, local cache)
- Throws exceptions on failure (ServerException, CacheException)
- Returns DTOs, not domain models

### `repositories/`
Implements domain repository interface.

```dart
class RaceRepositoryImpl implements IRaceRepository {
  final IRaceRemoteDataSource _remote;
  final IRaceLocalDataSource _local;  // Optional caching

  @override
  Future<Race> getById(String id) async {
    try {
      final dto = await _remote.fetch(id);
      return dto.toDomain();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
```

**Guidelines:**
- Implements domain interface
- Coordinates data sources
- Converts DTOs → Domain models
- Converts Exceptions → Failures
- Handles caching logic

## Data Flow

```
Repository.getById(id)
       ↓
DataSource.fetch(id)  ← calls Firebase/API
       ↓
Returns RaceDTO
       ↓
Repository calls dto.toDomain()
       ↓
Returns Race (domain model)
```
