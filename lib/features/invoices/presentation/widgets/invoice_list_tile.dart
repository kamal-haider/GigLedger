import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/invoice.dart';

/// List tile widget for displaying an invoice
class InvoiceListTile extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;

  const InvoiceListTile({
    super.key,
    required this.invoice,
    this.onTap,
  });

  Color _getStatusColor(BuildContext context, InvoiceStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case InvoiceStatus.draft:
        return theme.colorScheme.outline;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.viewed:
        return Colors.orange;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return theme.colorScheme.error;
    }
  }

  IconData _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.edit_outlined;
      case InvoiceStatus.sent:
        return Icons.send_outlined;
      case InvoiceStatus.viewed:
        return Icons.visibility_outlined;
      case InvoiceStatus.paid:
        return Icons.check_circle_outlined;
      case InvoiceStatus.overdue:
        return Icons.warning_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, yyyy');

    // Check if invoice is actually overdue (status might not be updated yet)
    final displayStatus =
        invoice.isOverdue && invoice.status != InvoiceStatus.paid
            ? InvoiceStatus.overdue
            : invoice.status;
    final displayColor = _getStatusColor(context, displayStatus);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: displayColor.withValues(alpha: 0.15),
          child: Icon(
            _getStatusIcon(displayStatus),
            color: displayColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                invoice.clientName,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              currencyFormat.format(invoice.total),
              style: TextStyle(
                color: invoice.status == InvoiceStatus.paid
                    ? Colors.green
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: displayColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayStatus.displayName,
                    style: TextStyle(
                      color: displayColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _getDueDateText(dateFormat),
              style: TextStyle(
                color: invoice.isOverdue
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _getDueDateText(DateFormat dateFormat) {
    if (invoice.status == InvoiceStatus.paid && invoice.paidDate != null) {
      return 'Paid on ${dateFormat.format(invoice.paidDate!)}';
    }
    if (invoice.status == InvoiceStatus.draft) {
      return 'Issue date: ${dateFormat.format(invoice.issueDate)}';
    }
    if (invoice.isOverdue) {
      return 'Overdue by ${invoice.daysOverdue} day${invoice.daysOverdue == 1 ? '' : 's'}';
    }
    if (invoice.daysUntilDue == 0) {
      return 'Due today';
    }
    if (invoice.daysUntilDue > 0) {
      return 'Due in ${invoice.daysUntilDue} day${invoice.daysUntilDue == 1 ? '' : 's'}';
    }
    return 'Due ${dateFormat.format(invoice.dueDate)}';
  }
}
