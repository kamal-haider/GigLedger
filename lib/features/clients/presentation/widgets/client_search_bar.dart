import 'package:flutter/material.dart';

/// Search bar widget for filtering clients
class ClientSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const ClientSearchBar({
    super.key,
    this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search clients by name or email...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
