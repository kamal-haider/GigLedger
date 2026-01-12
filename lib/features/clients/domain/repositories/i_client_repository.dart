import '../models/client.dart';

/// Client repository interface
abstract class IClientRepository {
  /// Get all clients for the current user
  Future<List<Client>> getAll();

  /// Get a client by ID
  Future<Client?> getById(String id);

  // Note: Client-side search is performed in filteredClientsProvider
  // to avoid Firestore costs and enable instant filtering.
  // Server-side search can be added later if needed for large client lists.

  /// Watch all clients (real-time updates)
  Stream<List<Client>> watchAll();

  /// Watch a single client
  Stream<Client?> watch(String id);

  /// Create a new client
  Future<Client> create(Client client);

  /// Update an existing client
  Future<Client> update(Client client);

  /// Delete a client
  Future<void> delete(String id);

  /// Get client count for the current user
  Future<int> getCount();

  /// Update client totals after invoice changes
  Future<void> updateTotals(String clientId, {double? billed, double? paid});
}
