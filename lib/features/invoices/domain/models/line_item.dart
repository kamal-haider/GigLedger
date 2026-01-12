import 'package:flutter/foundation.dart';

/// Line item for an invoice
@immutable
class LineItem {
  final String id;
  final String description;
  final double quantity;
  final double rate;
  final double amount;

  const LineItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  /// Create a line item with calculated amount
  factory LineItem.create({
    required String id,
    required String description,
    required double quantity,
    required double rate,
  }) {
    return LineItem(
      id: id,
      description: description,
      quantity: quantity,
      rate: rate,
      amount: quantity * rate,
    );
  }

  LineItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? rate,
    double? amount,
  }) {
    return LineItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          description == other.description &&
          quantity == other.quantity &&
          rate == other.rate;

  @override
  int get hashCode =>
      id.hashCode ^ description.hashCode ^ quantity.hashCode ^ rate.hashCode;
}
