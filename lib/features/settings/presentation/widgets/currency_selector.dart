import 'package:flutter/material.dart';

/// Currency selector widget for business settings
class CurrencySelector extends StatelessWidget {
  const CurrencySelector({
    required this.selectedCurrency,
    required this.currencies,
    super.key,
    this.onChanged,
  });

  final String selectedCurrency;
  final List<(String code, String name, String symbol)> currencies;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: selectedCurrency,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: currencies.map((currency) {
            final (code, name, symbol) = currency;
            return DropdownMenuItem(
              value: code,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      symbol,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged != null ? (value) => onChanged!(value!) : null,
          selectedItemBuilder: (context) {
            return currencies.map((currency) {
              final (code, name, symbol) = currency;
              return Row(
                children: [
                  Text(symbol),
                  const SizedBox(width: 8),
                  Text('$code - $name'),
                ],
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
