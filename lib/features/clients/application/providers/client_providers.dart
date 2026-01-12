import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/client_remote_data_source.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/models/client.dart';
import '../../domain/repositories/i_client_repository.dart';

/// Provider for the client remote data source
final clientRemoteDataSourceProvider = Provider<ClientRemoteDataSource>((ref) {
  return ClientRemoteDataSourceImpl();
});

/// Provider for the client repository
final clientRepositoryProvider = Provider<IClientRepository>((ref) {
  final dataSource = ref.watch(clientRemoteDataSourceProvider);
  return ClientRepositoryImpl(dataSource);
});

/// Stream provider for all clients (real-time updates)
final clientsStreamProvider = StreamProvider<List<Client>>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.watchAll();
});

/// Future provider for all clients
final clientsProvider = FutureProvider<List<Client>>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.getAll();
});

/// Provider for a single client by ID
final clientByIdProvider = FutureProvider.family<Client?, String>((ref, id) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.getById(id);
});

/// Stream provider for a single client
final clientStreamProvider = StreamProvider.family<Client?, String>((ref, id) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.watch(id);
});

/// Provider for client count
final clientCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.getCount();
});

/// Search query state provider
final clientSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered clients based on search query
final filteredClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final clientsAsync = ref.watch(clientsStreamProvider);
  final query = ref.watch(clientSearchQueryProvider).toLowerCase();

  return clientsAsync.whenData((clients) {
    if (query.isEmpty) return clients;
    return clients.where((client) =>
        client.name.toLowerCase().contains(query) ||
        client.email.toLowerCase().contains(query)).toList();
  });
});

/// Client notifier for CRUD operations
class ClientNotifier extends StateNotifier<AsyncValue<void>> {
  final IClientRepository _repository;

  ClientNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<Client> createClient(Client client) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repository.create(client);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Client> updateClient(Client client) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.update(client);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteClient(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider for client notifier
final clientNotifierProvider =
    StateNotifierProvider<ClientNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return ClientNotifier(repository);
});
