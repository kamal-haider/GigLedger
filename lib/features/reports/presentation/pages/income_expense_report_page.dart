import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/providers/reports_providers.dart';
import '../../domain/models/income_report.dart';

/// Income vs Expense Report Page
class IncomeExpenseReportPage extends ConsumerWidget {
  const IncomeExpenseReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(incomeExpenseReportProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income vs Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(incomeExpenseReportProvider.notifier).refresh();
            },
            tooltip: 'Refresh',
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
              ref.read(incomeExpenseReportProvider.notifier).setPreset(preset);
            },
            onCustomDateRange: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: reportState.dateRange,
              );
              if (picked != null) {
                ref
                    .read(incomeExpenseReportProvider.notifier)
                    .setCustomDateRange(picked);
              }
            },
          ),
          const Divider(height: 1),
          // Report content
          Expanded(
            child: reportState.report.when(
              data: (report) => _ReportContent(report: report),
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
                            .read(incomeExpenseReportProvider.notifier)
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
          // Preset chips
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
          // Date range display
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

class _ReportContent extends StatelessWidget {
  final IncomeReport report;

  const _ReportContent({required this.report});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    if (report.monthlyData.isEmpty) {
      return _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        _SummaryCards(report: report, currencyFormat: currencyFormat),
        const SizedBox(height: 24),
        // Chart
        if (report.monthlyData.length > 1) ...[
          _ChartSection(report: report, currencyFormat: currencyFormat),
          const SizedBox(height: 24),
        ],
        // Monthly breakdown
        _MonthlyBreakdown(report: report, currencyFormat: currencyFormat),
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
              Icons.bar_chart_outlined,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No data for this period',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create invoices and log expenses to see your financial report',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final IncomeReport report;
  final NumberFormat currencyFormat;

  const _SummaryCards({
    required this.report,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = report.netProfit >= 0;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Income',
            value: currencyFormat.format(report.totalIncome),
            color: Colors.green,
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Expenses',
            value: currencyFormat.format(report.totalExpenses),
            color: Colors.red,
            icon: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Profit',
            value: currencyFormat.format(report.netProfit.abs()),
            color: isProfit ? Colors.blue : Colors.orange,
            icon: isProfit ? Icons.trending_up : Icons.trending_down,
            subtitle: isProfit ? null : 'Loss',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final String? subtitle;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
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
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  subtitle ?? title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  final IncomeReport report;
  final NumberFormat currencyFormat;

  const _ChartSection({
    required this.report,
    required this.currencyFormat,
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
              'Monthly Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Legend
            Row(
              children: [
                _LegendItem(color: Colors.green, label: 'Income'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.red, label: 'Expenses'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = report.monthlyData[groupIndex];
                        final value = rodIndex == 0 ? month.income : month.expenses;
                        final label = rodIndex == 0 ? 'Income' : 'Expenses';
                        return BarTooltipItem(
                          '$label\n${currencyFormat.format(value)}',
                          TextStyle(
                            color: rodIndex == 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= report.monthlyData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              report.monthlyData[index].monthLabel,
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatAxisValue(value),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getMaxY() / 4,
                  ),
                  barGroups: _getBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (final month in report.monthlyData) {
      if (month.income > max) max = month.income;
      if (month.expenses > max) max = month.expenses;
    }
    return max * 1.2; // Add 20% padding
  }

  String _formatAxisValue(double value) {
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}k';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  List<BarChartGroupData> _getBarGroups() {
    return report.monthlyData.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: month.income,
            color: Colors.green,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: month.expenses,
            color: Colors.red,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MonthlyBreakdown extends StatelessWidget {
  final IncomeReport report;
  final NumberFormat currencyFormat;

  const _MonthlyBreakdown({
    required this.report,
    required this.currencyFormat,
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
              'Monthly Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              children: [
                const Expanded(flex: 2, child: Text('Month')),
                Expanded(
                  flex: 2,
                  child: Text('Income',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.green.shade700)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Expenses',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.red.shade700)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Profit',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: theme.colorScheme.primary)),
                ),
              ],
            ),
            const Divider(),
            // Data rows
            ...report.monthlyData.map((month) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(month.fullLabel,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormat.format(month.income),
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormat.format(month.expenses),
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormat.format(month.profit),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: month.profit >= 0
                                ? theme.colorScheme.primary
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
