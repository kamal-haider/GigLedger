# Presentation Layer

UI and state management. Everything the user sees and interacts with.

## Contents

### `state/`
Riverpod state management.

**State class** - Immutable data holder:
```dart
@immutable
class RaceState {
  final List<Race> races;
  final bool isLoading;
  final String? error;
  final Race? selectedRace;

  const RaceState({
    this.races = const [],
    this.isLoading = false,
    this.error,
    this.selectedRace,
  });

  RaceState copyWith({...}) { ... }

  // Computed properties
  bool get hasRaces => races.isNotEmpty;
  bool get hasError => error != null;
}
```

**Notifier** - State mutations:
```dart
class RaceNotifier extends StateNotifier<RaceState> {
  final GetRacesUseCase _getRacesUseCase;

  RaceNotifier(this._getRacesUseCase) : super(const RaceState());

  Future<void> loadRaces() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final races = await _getRacesUseCase();
      state = state.copyWith(races: races, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void selectRace(Race race) {
    state = state.copyWith(selectedRace: race);
  }
}
```

**Providers** - Dependency wiring:
```dart
final raceRepositoryProvider = Provider<IRaceRepository>((ref) {
  return RaceRepositoryImpl(ref.watch(raceDataSourceProvider));
});

final getRacesUseCaseProvider = Provider<GetRacesUseCase>((ref) {
  return GetRacesUseCase(ref.watch(raceRepositoryProvider));
});

final raceNotifierProvider = StateNotifierProvider<RaceNotifier, RaceState>((ref) {
  return RaceNotifier(ref.watch(getRacesUseCaseProvider));
});
```

### `pages/`
Full-screen widgets (routes).

```dart
class RaceListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(raceNotifierProvider);

    if (state.isLoading) return LoadingIndicator();
    if (state.hasError) return ErrorView(message: state.error!);
    if (!state.hasRaces) return EmptyState();

    return ListView.builder(
      itemCount: state.races.length,
      itemBuilder: (_, i) => RaceCard(race: state.races[i]),
    );
  }
}
```

### `widgets/`
Reusable UI components for this feature.

```dart
class RaceCard extends StatelessWidget {
  final Race race;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(race.name),
        subtitle: Text(race.date.toString()),
        onTap: onTap,
      ),
    );
  }
}
```

## Guidelines

1. **One state per screen** - Don't over-complicate
2. **Immutable state** - Always use `copyWith`
3. **ConsumerWidget** - For widgets that read providers
4. **Handle all states** - Loading, error, empty, data
5. **Keep pages thin** - Extract widgets, delegate logic to notifiers
