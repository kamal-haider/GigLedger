---
name: feature-implementer
description: Implements GigLedger features following Clean Architecture. Use when building out feature modules from GitHub issues. Creates all layers (presentation, application, domain, data) with proper patterns.
---

# Feature Implementer

## Purpose

This skill implements complete features following GigLedger's Clean Architecture pattern, from GitHub issue to working code.

## Implementation Workflow

### 1. Understand the Issue

```bash
# View issue details
gh issue view <number>

# Check dependencies
gh issue view <number> --comments
```

### 2. Create Feature Branch

```bash
git checkout main
git pull
git checkout -b feature/<feature-name>
```

### 3. Feature Structure

Each feature follows this structure:

```
lib/features/<feature>/
├── <feature>.dart           # Barrel file (exports)
├── presentation/
│   ├── pages/               # Full screens
│   │   └── <feature>_page.dart
│   ├── widgets/             # Reusable widgets
│   │   └── <widget>_widget.dart
│   └── providers/           # Riverpod providers
│       └── <feature>_provider.dart
├── application/
│   └── <use_case>_use_case.dart
├── domain/
│   ├── models/
│   │   └── <model>.dart
│   └── repositories/
│       └── i_<feature>_repository.dart
└── data/
    ├── dto/
    │   └── <model>_dto.dart
    ├── datasources/
    │   └── <feature>_remote_data_source.dart
    └── repositories/
        └── <feature>_repository_impl.dart
```

### 4. Implementation Order

Always implement in this order:

1. **Domain Layer** (if not exists)
   - Models (immutable, with computed properties)
   - Repository interface

2. **Data Layer**
   - DTOs with `fromJson`, `toJson`, `toDomain`, `fromDomain`
   - Data sources (Firestore queries)
   - Repository implementation

3. **Application Layer**
   - Use cases for business logic
   - One use case per action

4. **Presentation Layer**
   - Providers (Riverpod)
   - Pages
   - Widgets

### 5. Code Patterns

#### Domain Model
```dart
@immutable
class Client {
  final String id;
  final String name;
  final String email;

  const Client({
    required this.id,
    required this.name,
    required this.email,
  });

  // Computed properties allowed
  bool get hasEmail => email.isNotEmpty;
}
```

#### DTO
```dart
class ClientDTO {
  final String? id;
  final String? name;
  final String? email;

  ClientDTO({this.id, this.name, this.email});

  factory ClientDTO.fromJson(Map<String, dynamic> json) => ClientDTO(
    id: json['id'] as String?,
    name: json['name'] as String?,
    email: json['email'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  Client toDomain() => Client(
    id: id ?? '',
    name: name ?? '',
    email: email ?? '',
  );

  factory ClientDTO.fromDomain(Client client) => ClientDTO(
    id: client.id,
    name: client.name,
    email: client.email,
  );
}
```

#### Repository Interface
```dart
abstract class IClientRepository {
  Future<Either<Failure, List<Client>>> getClients();
  Future<Either<Failure, Client>> getClient(String id);
  Future<Either<Failure, void>> createClient(Client client);
  Future<Either<Failure, void>> updateClient(Client client);
  Future<Either<Failure, void>> deleteClient(String id);
}
```

#### Riverpod Provider
```dart
@riverpod
class ClientsNotifier extends _$ClientsNotifier {
  @override
  Future<List<Client>> build() async {
    final repository = ref.watch(clientRepositoryProvider);
    final result = await repository.getClients();
    return result.fold(
      (failure) => throw failure,
      (clients) => clients,
    );
  }
}
```

### 6. Firestore Paths

All user data is scoped:
- `users/{uid}/clients/{clientId}`
- `users/{uid}/invoices/{invoiceId}`
- `users/{uid}/expenses/{expenseId}`

### 7. Testing

Create tests in `test/features/<feature>/`:
- `domain/` - Model tests
- `data/` - DTO and repository tests
- `presentation/` - Widget tests

### 8. Commit and PR

```bash
git add .
git commit -m "feat(<feature>): <description>"
git push -u origin feature/<feature-name>
gh pr create --title "feat: <Feature Name>" --body "Closes #<issue>"
```

## References

- `docs/07_app_architecture.md` - Full architecture guide
- `docs/05_data_model_and_schema.md` - Database schemas
- `docs/02_mvp_prd.md` - Feature requirements
