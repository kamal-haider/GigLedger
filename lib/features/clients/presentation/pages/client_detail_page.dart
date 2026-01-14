import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/client_providers.dart';
import '../../domain/models/client.dart';

/// Client detail page showing client info and invoice history
class ClientDetailPage extends ConsumerWidget {
  final String clientId;

  const ClientDetailPage({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientStreamProvider(clientId));
    final theme = Theme.of(context);

    return clientAsync.when(
      data: (client) {
        if (client == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Client')),
            body: const Center(child: Text('Client not found')),
          );
        }
        return _ClientDetailContent(client: client);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              const Text('Failed to load client'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(clientStreamProvider(clientId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientDetailContent extends ConsumerWidget {
  final Client client;

  const _ClientDetailContent({required this.client});

  Future<void> _deleteClient(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client?'),
        content: Text(
          'Are you sure you want to delete "${client.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(clientNotifierProvider.notifier).deleteClient(client.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete client: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Client',
            onPressed: () {
              context.pushNamed(
                'edit-client',
                pathParameters: {'id': client.id},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Client',
            onPressed: () => _deleteClient(context, ref),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Outstanding Balance Card
          _BalanceCard(
            balance: client.outstandingBalance,
            totalBilled: client.totalBilled,
            totalPaid: client.totalPaid,
            currencyFormat: currencyFormat,
          ),

          // Contact Info Section
          _SectionHeader(title: 'Contact Information'),
          _ContactInfoCard(client: client),

          // Notes Section (if present)
          if (client.notes != null && client.notes!.isNotEmpty) ...[
            _SectionHeader(title: 'Notes'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  client.notes!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],

          // Invoice History Section
          _SectionHeader(title: 'Invoice History'),
          _InvoiceHistorySection(clientId: client.id),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create invoice with client pre-selected
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice creation coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.receipt_long),
        label: const Text('New Invoice'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double totalBilled;
  final double totalPaid;
  final NumberFormat currencyFormat;

  const _BalanceCard({
    required this.balance,
    required this.totalBilled,
    required this.totalPaid,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBalance = balance > 0;

    return Card(
      margin: const EdgeInsets.all(16),
      color: hasBalance
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Outstanding Balance',
              style: theme.textTheme.titleSmall?.copyWith(
                color: hasBalance
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(balance),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: hasBalance
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BalanceStat(
                  label: 'Total Billed',
                  value: currencyFormat.format(totalBilled),
                  color: hasBalance
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: (hasBalance
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer)
                      .withValues(alpha: 0.3),
                ),
                _BalanceStat(
                  label: 'Total Paid',
                  value: currencyFormat.format(totalPaid),
                  color: hasBalance
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BalanceStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final Client client;

  const _ContactInfoCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          _ContactRow(
            icon: Icons.email,
            label: 'Email',
            value: client.email,
          ),
          if (client.phone != null && client.phone!.isNotEmpty)
            _ContactRow(
              icon: Icons.phone,
              label: 'Phone',
              value: client.phone!,
            ),
          if (client.address != null && client.address!.isNotEmpty)
            _ContactRow(
              icon: Icons.location_on,
              label: 'Address',
              value: client.address!,
              isMultiline: true,
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMultiline;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge,
        maxLines: isMultiline ? null : 1,
        overflow: isMultiline ? null : TextOverflow.ellipsis,
      ),
    );
  }
}

class _InvoiceHistorySection extends StatelessWidget {
  final String clientId;

  const _InvoiceHistorySection({required this.clientId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with actual invoice query when invoice providers are implemented
    // For now, show empty state
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No invoices yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first invoice for this client',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
