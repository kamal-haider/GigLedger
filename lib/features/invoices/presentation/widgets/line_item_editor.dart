import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/models/line_item.dart';

/// Widget for editing a single line item
class LineItemEditor extends StatefulWidget {
  final LineItem item;
  final int index;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<double> onQuantityChanged;
  final ValueChanged<double> onRateChanged;
  final VoidCallback onRemove;

  const LineItemEditor({
    super.key,
    required this.item,
    required this.index,
    required this.onDescriptionChanged,
    required this.onQuantityChanged,
    required this.onRateChanged,
    required this.onRemove,
  });

  @override
  State<LineItemEditor> createState() => _LineItemEditorState();
}

class _LineItemEditorState extends State<LineItemEditor> {
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _rateController;

  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _quantityController = TextEditingController(
      text: widget.item.quantity == widget.item.quantity.toInt()
          ? widget.item.quantity.toInt().toString()
          : widget.item.quantity.toString(),
    );
    _rateController = TextEditingController(
      text: widget.item.rate.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(LineItemEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controllers if the item ID changed (e.g., reordering)
    if (oldWidget.item.id != widget.item.id) {
      _descriptionController.text = widget.item.description;
      _quantityController.text =
          widget.item.quantity == widget.item.quantity.toInt()
              ? widget.item.quantity.toInt().toString()
              : widget.item.quantity.toString();
      _rateController.text = widget.item.rate.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with item number and delete button
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Item ${widget.index + 1}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove item',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter item description',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onChanged: widget.onDescriptionChanged,
            ),
            const SizedBox(height: 12),

            // Quantity, Rate, and Amount row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 0;
                      widget.onQuantityChanged(qty);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Rate
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _rateController,
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      final rate = double.tryParse(value) ?? 0;
                      widget.onRateChanged(rate);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Amount (calculated, read-only)
                Expanded(
                  flex: 3,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Text(
                      _currencyFormat.format(widget.item.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for the line items section with add button
class LineItemsSection extends StatelessWidget {
  final List<LineItem> lineItems;
  final VoidCallback onAddItem;
  final void Function(int, String) onDescriptionChanged;
  final void Function(int, double) onQuantityChanged;
  final void Function(int, double) onRateChanged;
  final void Function(int) onRemoveItem;

  const LineItemsSection({
    super.key,
    required this.lineItems,
    required this.onAddItem,
    required this.onDescriptionChanged,
    required this.onQuantityChanged,
    required this.onRateChanged,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Line Items',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Line items list
        if (lineItems.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No line items yet',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: onAddItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Item'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...lineItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return LineItemEditor(
              key: ValueKey(item.id),
              item: item,
              index: index,
              onDescriptionChanged: (desc) => onDescriptionChanged(index, desc),
              onQuantityChanged: (qty) => onQuantityChanged(index, qty),
              onRateChanged: (rate) => onRateChanged(index, rate),
              onRemove: () => onRemoveItem(index),
            );
          }),
      ],
    );
  }
}
