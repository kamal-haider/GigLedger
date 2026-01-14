import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/financial_summary.dart';

/// Card displaying financial summary metrics
class FinancialSummaryCard extends StatelessWidget {
  final FinancialSummary summary;
  final String currencySymbol;

  const FinancialSummaryCard({
    super.key,
    required this.summary,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Income',
                    value: formatter.format(summary.incomeThisMonth),
                    valueColor: Colors.green,
                    icon: Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Expenses',
                    value: formatter.format(summary.expensesThisMonth),
                    valueColor: Colors.red,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _ProfitTile(
              profit: summary.profitThisMonth,
              formatter: formatter,
              isProfitable: summary.isProfitableThisMonth,
            ),
            if (summary.hasOverdueInvoices) ...[
              const SizedBox(height: 16),
              _AlertTile(
                count: summary.overdueInvoices,
                amount: formatter.format(summary.overdueAmount),
                icon: Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                label:
                    'overdue invoice${summary.overdueInvoices > 1 ? 's' : ''}',
              ),
            ],
            if (summary.pendingInvoices > 0) ...[
              const SizedBox(height: 8),
              _AlertTile(
                count: summary.pendingInvoices,
                amount: formatter.format(summary.pendingAmount),
                icon: Icons.schedule,
                color: theme.colorScheme.tertiary,
                label:
                    'pending invoice${summary.pendingInvoices > 1 ? 's' : ''}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: valueColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _ProfitTile extends StatelessWidget {
  final double profit;
  final NumberFormat formatter;
  final bool isProfitable;

  const _ProfitTile({
    required this.profit,
    required this.formatter,
    required this.isProfitable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isProfitable ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isProfitable ? Icons.celebration : Icons.warning,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Profit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatter.format(profit),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final int count;
  final String amount;
  final IconData icon;
  final Color color;
  final String label;

  const _AlertTile({
    required this.count,
    required this.amount,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$count $label ($amount)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ),
        Icon(Icons.chevron_right, color: color),
      ],
    );
  }
}
