import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/client_providers.dart';
import '../widgets/client_list_tile.dart';
import '../widgets/client_search_bar.dart';

/// Client list page showing all clients with search functionality
class ClientListPage extends ConsumerWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredClients = ref.watch(filteredClientsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: Column(
        children: [
          ClientSearchBar(
            onChanged: (query) {
              ref.read(clientSearchQueryProvider.notifier).state = query;
            },
          ),
          Expanded(
            child: filteredClients.when(
              data: (clients) {
                if (clients.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return ListView.builder(
                  itemCount: clients.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return ClientListTile(
                      client: client,
                      onTap: () {
                        context.goNamed(
                          'client-detail',
                          pathParameters: {'id': client.id},
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load clients',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getErrorMessage(error),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => ref.refresh(clientsStreamProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('new-client'),
        icon: const Icon(Icons.add),
        label: const Text('Add Client'),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return "You don't have permission to view clients. Please sign in again.";
    }
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorStr.contains('auth') || errorStr.contains('unauthenticated')) {
      return 'Please sign in to view your clients.';
    }
    return 'Something went wrong. Please try again.';
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchQuery = ref.watch(clientSearchQueryProvider);

    if (searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No clients found',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No clients yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first client to start tracking invoices and payments',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.goNamed('new-client'),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Client'),
            ),
          ],
        ),
      ),
    );
  }
}
