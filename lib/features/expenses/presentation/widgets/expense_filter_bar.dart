import 'package:flutter/material.dart';

import '../../domain/models/expense.dart';

/// Filter bar widget for expenses
class ExpenseFilterBar extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory?>? onCategoryChanged;
  final VoidCallback? onDateRangePressed;
  final bool hasDateFilter;

  const ExpenseFilterBar({
    super.key,
    this.selectedCategory,
    this.onCategoryChanged,
    this.onDateRangePressed,
    this.hasDateFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Date range filter
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.date_range, size: 18),
                const SizedBox(width: 4),
                Text(hasDateFilter ? 'Date Range' : 'All Time'),
              ],
            ),
            selected: hasDateFilter,
            onSelected: (_) => onDateRangePressed?.call(),
          ),
          const SizedBox(width: 8),
          // Category filter
          FilterChip(
            label: const Text('All Categories'),
            selected: selectedCategory == null,
            onSelected: (_) => onCategoryChanged?.call(null),
          ),
          const SizedBox(width: 8),
          ...ExpenseCategory.values.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.displayName),
                  selected: selectedCategory == category,
                  onSelected: (_) => onCategoryChanged?.call(
                    selectedCategory == category ? null : category,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
