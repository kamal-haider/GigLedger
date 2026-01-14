import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/invoice_providers.dart';
import '../../domain/models/invoice.dart';
import '../widgets/invoice_filter_bar.dart';
import '../widgets/invoice_list_tile.dart';

/// Invoice list page showing all invoices with filtering
class InvoiceListPage extends ConsumerWidget {
  const InvoiceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredInvoices = ref.watch(filteredInvoicesProvider);
    final selectedStatus = ref.watch(invoiceStatusFilterProvider);
    final dateRange = ref.watch(invoiceDateRangeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      body: Column(
        children: [
          InvoiceFilterBar(
            selectedStatus: selectedStatus,
            onStatusChanged: (status) {
              ref.read(invoiceStatusFilterProvider.notifier).state = status;
            },
            hasDateFilter: dateRange != null,
            onDateRangePressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: dateRange != null
                    ? DateTimeRange(start: dateRange.start, end: dateRange.end)
                    : null,
              );
              if (picked != null) {
                ref.read(invoiceDateRangeProvider.notifier).state =
                    DateTimeRange(start: picked.start, end: picked.end);
              } else {
                ref.read(invoiceDateRangeProvider.notifier).state = null;
              }
            },
          ),
          // Summary section
          filteredInvoices.when(
            data: (invoices) {
              final totalAmount = invoices.fold(0.0, (sum, inv) => sum + inv.total);
              final paidAmount = invoices
                  .where((inv) => inv.status == InvoiceStatus.paid)
                  .fold(0.0, (sum, inv) => sum + inv.total);
              final pendingAmount = totalAmount - paidAmount;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${invoices.length} invoice${invoices.length == 1 ? '' : 's'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        if (pendingAmount > 0) ...[
                          Text(
                            'Pending: ${NumberFormat.currency(symbol: '\$').format(pendingAmount)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          'Total: ${NumberFormat.currency(symbol: '\$').format(totalAmount)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredInvoices.when(
              data: (invoices) {
                if (invoices.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return ListView.builder(
                  itemCount: invoices.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return InvoiceListTile(
                      invoice: invoice,
                      onTap: () {
                        context.pushNamed(
                          'invoice-detail',
                          pathParameters: {'id': invoice.id},
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
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
                      'Failed to load invoices',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.refresh(invoicesStreamProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/invoices/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasFilters = ref.watch(invoiceStatusFilterProvider) != null ||
        ref.watch(invoiceDateRangeProvider) != null;

    if (hasFilters) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No invoices match filters',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(invoiceStatusFilterProvider.notifier).state = null;
                ref.read(invoiceDateRangeProvider.notifier).state = null;
              },
              child: const Text('Clear Filters'),
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
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No invoices yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first invoice to start getting paid',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.push('/invoices/new');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
