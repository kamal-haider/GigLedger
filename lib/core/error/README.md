# Error Handling

Two types of error classes for different layers:

## Exceptions (Data Layer)
Thrown by data sources when operations fail.

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
}

class ServerException extends AppException { ... }
class CacheException extends AppException { ... }
class NetworkException extends AppException { ... }
```

## Failures (Domain Layer)
Returned to presentation layer (not thrown).

```dart
abstract class Failure {
  final String message;
}

class ServerFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
```

## Flow

```
Data Source throws Exception
       ↓
Repository catches Exception → converts to Failure
       ↓
Use Case returns Failure (or Success)
       ↓
Presentation handles Failure (show error UI)
```
