import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/expense_providers.dart';
import '../../domain/models/expense.dart';
import '../widgets/expense_filter_bar.dart';
import '../widgets/expense_list_tile.dart';

/// Expense list page showing all expenses with filtering
class ExpenseListPage extends ConsumerWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final selectedCategory = ref.watch(expenseCategoryFilterProvider);
    final dateRange = ref.watch(expenseDateRangeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Column(
        children: [
          ExpenseFilterBar(
            selectedCategory: selectedCategory,
            onCategoryChanged: (category) {
              ref.read(expenseCategoryFilterProvider.notifier).state = category;
            },
            hasDateFilter: dateRange != null,
            onDateRangePressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: dateRange != null
                    ? DateTimeRange(start: dateRange.start, end: dateRange.end)
                    : null,
              );
              if (picked != null) {
                ref.read(expenseDateRangeProvider.notifier).state =
                    DateTimeRange(start: picked.start, end: picked.end);
              } else {
                ref.read(expenseDateRangeProvider.notifier).state = null;
              }
            },
          ),
          // Total amount summary
          filteredExpenses.when(
            data: (expenses) {
              final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${expenses.length} expense${expenses.length == 1 ? '' : 's'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Total: ${NumberFormat.currency(symbol: '\$').format(total)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
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
            child: filteredExpenses.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return ListView.builder(
                  itemCount: expenses.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseListTile(
                      expense: expense,
                      onTap: () {
                        // TODO: Navigate to expense details
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('View ${expense.description}')),
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
                      'Failed to load expenses',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.refresh(expensesStreamProvider),
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
          context.push('/expenses/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasFilters = ref.watch(expenseCategoryFilterProvider) != null ||
        ref.watch(expenseDateRangeProvider) != null;

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
              'No expenses match filters',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(expenseCategoryFilterProvider.notifier).state = null;
                ref.read(expenseDateRangeProvider.notifier).state = null;
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
              'No expenses yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your business expenses to see where your money goes',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.push('/expenses/new');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
