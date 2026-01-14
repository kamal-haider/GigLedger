import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../expenses/application/providers/expense_providers.dart';
import '../../../expenses/domain/models/expense.dart';
import '../../application/providers/reports_providers.dart';
import '../../domain/models/income_report.dart';

/// Expense by Category Report Page
class ExpenseCategoryReportPage extends ConsumerWidget {
  const ExpenseCategoryReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(expenseCategoryReportProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses by Category'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(expenseCategoryReportProvider.notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More reports',
            onSelected: (value) {
              if (value == 'income-expense') {
                context.go('/reports');
              } else if (value == 'top-clients') {
                context.push('/reports/top-clients');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'income-expense',
                child: ListTile(
                  leading: Icon(Icons.bar_chart),
                  title: Text('Income vs Expenses'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'top-clients',
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Top Clients'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range selector
          _DateRangeSelector(
            selectedPreset: reportState.preset,
            dateRange: reportState.dateRange,
            onPresetChanged: (preset) {
              ref
                  .read(expenseCategoryReportProvider.notifier)
                  .setPreset(preset);
            },
            onCustomDateRange: () async {
              final now = DateTime.now();
              final clampedStart = reportState.dateRange.start.isAfter(now)
                  ? now
                  : reportState.dateRange.start;
              final clampedEnd = reportState.dateRange.end.isAfter(now)
                  ? now
                  : reportState.dateRange.end;
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: now,
                initialDateRange: DateTimeRange(
                  start: clampedStart,
                  end: clampedEnd,
                ),
              );
              if (picked != null) {
                ref
                    .read(expenseCategoryReportProvider.notifier)
                    .setCustomDateRange(picked);
              }
            },
          ),
          const Divider(height: 1),
          // Report content
          Expanded(
            child: reportState.categories.when(
              data: (categories) => _ReportContent(
                categories: categories,
                totalExpenses: reportState.totalExpenses,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load report',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(expenseCategoryReportProvider.notifier)
                            .refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateRangePreset selectedPreset;
  final DateTimeRange dateRange;
  final ValueChanged<DateRangePreset> onPresetChanged;
  final VoidCallback onCustomDateRange;

  const _DateRangeSelector({
    required this.selectedPreset,
    required this.dateRange,
    required this.onPresetChanged,
    required this.onCustomDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DateRangePreset.values.map((preset) {
                final isSelected = preset == selectedPreset;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(preset.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (preset == DateRangePreset.custom) {
                        onCustomDateRange();
                      } else {
                        onPresetChanged(preset);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${dateFormat.format(dateRange.start)} - ${dateFormat.format(dateRange.end)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportContent extends ConsumerWidget {
  final List<CategoryExpense> categories;
  final double totalExpenses;

  const _ReportContent({
    required this.categories,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: r'$');

    if (categories.isEmpty) {
      return _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        _SummaryCard(
          totalExpenses: totalExpenses,
          categoryCount: categories.length,
          currencyFormat: currencyFormat,
        ),
        const SizedBox(height: 24),
        // Pie chart
        _PieChartSection(
          categories: categories,
          totalExpenses: totalExpenses,
          currencyFormat: currencyFormat,
        ),
        const SizedBox(height: 24),
        // Category table
        _CategoryTable(
          categories: categories,
          totalExpenses: totalExpenses,
          currencyFormat: currencyFormat,
          onCategoryTap: (category) {
            // Set the filter and navigate to expenses
            final expenseCategory = ExpenseCategory.values.firstWhere(
              (c) => c.name == category.category,
              orElse: () => ExpenseCategory.other,
            );
            ref.read(expenseCategoryFilterProvider.notifier).state =
                expenseCategory;
            context.go('/expenses');
          },
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No expenses for this period',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add expenses to see your spending breakdown by category',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalExpenses;
  final int categoryCount;
  final NumberFormat currencyFormat;

  const _SummaryCard({
    required this.totalExpenses,
    required this.categoryCount,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Expenses',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(totalExpenses),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: theme.dividerColor,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Categories',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryCount',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartSection extends StatelessWidget {
  final List<CategoryExpense> categories;
  final double totalExpenses;
  final NumberFormat currencyFormat;

  const _PieChartSection({
    required this.categories,
    required this.totalExpenses,
    required this.currencyFormat,
  });

  static const List<Color> _chartColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFFFFC107), // Amber
    Color(0xFFFF5722), // Deep Orange
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _getSections(),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categories.take(5).toList().asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final category = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _chartColors[
                                        index % _chartColors.length],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    category.displayName,
                                    style: theme.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    // Show top 5 individually, group rest as "Others"
    final topCategories = categories.take(5).toList();
    final otherAmount =
        categories.skip(5).fold(0.0, (sum, c) => sum + c.amount);

    final sections = <PieChartSectionData>[];

    for (var i = 0; i < topCategories.length; i++) {
      final category = topCategories[i];
      sections.add(
        PieChartSectionData(
          color: _chartColors[i % _chartColors.length],
          value: category.amount,
          title: '${category.percentage.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Add "Others" section if there are more than 5 categories
    if (otherAmount > 0) {
      final percentage =
          totalExpenses > 0 ? (otherAmount / totalExpenses) * 100 : 0;
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: otherAmount,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }
}

class _CategoryTable extends StatelessWidget {
  final List<CategoryExpense> categories;
  final double totalExpenses;
  final NumberFormat currencyFormat;
  final void Function(CategoryExpense) onCategoryTap;

  const _CategoryTable({
    required this.categories,
    required this.totalExpenses,
    required this.currencyFormat,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              children: [
                const Expanded(flex: 3, child: Text('Category')),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    '%',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(),
            // Data rows
            ...categories.map((category) {
              return InkWell(
                onTap: () => onCategoryTap(category),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category.category),
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormat.format(category.amount),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${category.percentage.toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'software':
        return Icons.computer;
      case 'office':
        return Icons.business;
      case 'travel':
        return Icons.flight;
      case 'meals':
        return Icons.restaurant;
      case 'utilities':
        return Icons.power;
      case 'marketing':
        return Icons.campaign;
      case 'equipment':
        return Icons.build;
      case 'professional':
        return Icons.work;
      case 'insurance':
        return Icons.security;
      case 'taxes':
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }
}
