import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget displaying invoice totals (subtotal, tax, total)
class InvoiceTotals extends StatelessWidget {
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;

  const InvoiceTotals({
    super.key,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Subtotal
            _TotalRow(
              label: 'Subtotal',
              value: currencyFormat.format(subtotal),
              isTotal: false,
            ),
            const SizedBox(height: 8),

            // Tax
            _TotalRow(
              label: 'Tax (${taxRate.toStringAsFixed(1)}%)',
              value: currencyFormat.format(taxAmount),
              isTotal: false,
            ),
            const Divider(height: 24),

            // Total
            _TotalRow(
              label: 'Total',
              value: currencyFormat.format(total),
              isTotal: true,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final ThemeData? theme;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.isTotal,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: isTotal
              ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : textTheme.bodyMedium,
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 100,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: isTotal
                ? textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme?.colorScheme.primary,
                  )
                : textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
