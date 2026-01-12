import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/expense.dart';

/// List tile widget for displaying an expense
class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
  });

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Icons.flight;
      case ExpenseCategory.office:
        return Icons.business_center;
      case ExpenseCategory.software:
        return Icons.computer;
      case ExpenseCategory.marketing:
        return Icons.campaign;
      case ExpenseCategory.meals:
        return Icons.restaurant;
      case ExpenseCategory.equipment:
        return Icons.build;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: expense.hasReceipt
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CachedNetworkImage(
                    imageUrl: expense.receiptUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.receipt, size: 24),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.receipt, size: 24),
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.category.displayName,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            Text(
              dateFormat.format(expense.date),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(expense.amount),
          style: TextStyle(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
