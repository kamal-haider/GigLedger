import 'package:flutter/material.dart';

import '../../domain/models/invoice.dart';

/// Filter bar widget for invoices
class InvoiceFilterBar extends StatelessWidget {
  final InvoiceStatus? selectedStatus;
  final ValueChanged<InvoiceStatus?>? onStatusChanged;
  final VoidCallback? onDateRangePressed;
  final bool hasDateFilter;

  const InvoiceFilterBar({
    super.key,
    this.selectedStatus,
    this.onStatusChanged,
    this.onDateRangePressed,
    this.hasDateFilter = false,
  });

  @override
  Widget build(BuildContext context) {
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
          // All statuses filter
          FilterChip(
            label: const Text('All'),
            selected: selectedStatus == null,
            onSelected: (_) => onStatusChanged?.call(null),
          ),
          const SizedBox(width: 8),
          // Status filters
          ...InvoiceStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status.displayName),
                  selected: selectedStatus == status,
                  onSelected: (_) => onStatusChanged?.call(
                    selectedStatus == status ? null : status,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
