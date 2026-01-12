# Feature Template

Copy this entire folder and rename it to create a new feature module.

## Structure

```
feature_name/
├── presentation/          # UI Layer
│   ├── pages/            # Full-screen widgets
│   ├── widgets/          # Reusable UI components
│   └── state/            # Riverpod providers & state
├── application/          # Business Logic Layer
│   └── {use_cases}.dart  # Single-purpose business operations
├── domain/               # Domain Layer
│   ├── models/           # Domain entities
│   └── repositories/     # Repository interfaces (contracts)
└── data/                 # Data Layer
    ├── dtos/             # Data Transfer Objects
    ├── datasources/      # Remote/local data sources
    └── repositories/     # Repository implementations
```

## Layer Dependencies

```
Presentation → Application → Domain ← Data
                               ↑
                          (implements)
```

- **Presentation** depends on Application and Domain
- **Application** depends on Domain only
- **Domain** has NO dependencies (pure Dart)
- **Data** implements Domain interfaces

## Creating a New Feature

1. Copy this `_feature_template` folder
2. Rename to feature name (e.g., `auth`, `races`, `profile`)
3. Start with Domain layer (models, repository interface)
4. Build Data layer (DTOs, data sources, repository impl)
5. Add Application layer (use cases)
6. Create Presentation layer (state, pages, widgets)
7. Register providers
8. Add routes to router

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Pages | `{Feature}Page` | `LoginPage`, `RaceDetailPage` |
| Widgets | Descriptive | `DriverCard`, `StintTimeline` |
| State | `{Feature}State` | `RaceState`, `ProfileState` |
| Notifier | `{Feature}Notifier` | `RaceNotifier` |
| Use Cases | `{Verb}{Noun}UseCase` | `GetRaceUseCase`, `UpdateProfileUseCase` |
| Models | Domain concept | `Race`, `Driver`, `Stint` |
| DTOs | `{Model}DTO` | `RaceDTO`, `DriverDTO` |
| Repository Interface | `I{Feature}Repository` | `IRaceRepository` |
| Repository Impl | `{Feature}RepositoryImpl` | `RaceRepositoryImpl` |
| Data Source | `{Feature}{Source}DataSource` | `RaceFirestoreDataSource` |
| Providers | `{feature}{Type}Provider` | `raceNotifierProvider`, `getRaceUseCaseProvider` |

## Data Flow Example

```
User taps "Load Race"
       ↓
Page calls notifier.loadRace(id)
       ↓
Notifier calls GetRaceUseCase(id)
       ↓
UseCase calls IRaceRepository.getById(id)
       ↓
RaceRepositoryImpl calls RaceDataSource.fetch(id)
       ↓
DataSource returns RaceDTO
       ↓
Repository converts DTO → Race (domain model)
       ↓
UseCase returns Race
       ↓
Notifier updates state with Race
       ↓
Page rebuilds with new state
```

## See Also

- `data/README.md` - Data layer patterns
- `domain/README.md` - Domain layer patterns
- `application/README.md` - Application layer patterns
- `presentation/README.md` - Presentation layer patterns
