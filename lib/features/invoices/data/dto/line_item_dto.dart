import 'package:uuid/uuid.dart';

import '../../domain/models/line_item.dart';

const _uuid = Uuid();

/// DTO for LineItem matching Firestore document structure
class LineItemDTO {
  final String? id;
  final String? description;
  final double? quantity;
  final double? rate;
  final double? amount;

  const LineItemDTO({
    this.id,
    this.description,
    this.quantity,
    this.rate,
    this.amount,
  });

  factory LineItemDTO.fromJson(Map<String, dynamic> json) {
    return LineItemDTO(
      id: json['id'] as String?,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      rate: (json['rate'] as num?)?.toDouble(),
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }

  LineItem toDomain() {
    // Generate a UUID if the ID is null or empty to prevent duplicate key errors
    final itemId = (id != null && id!.isNotEmpty) ? id! : _uuid.v4();
    return LineItem(
      id: itemId,
      description: description ?? '',
      quantity: quantity ?? 0,
      rate: rate ?? 0,
      amount: amount ?? 0,
    );
  }

  factory LineItemDTO.fromDomain(LineItem lineItem) {
    return LineItemDTO(
      id: lineItem.id,
      description: lineItem.description,
      quantity: lineItem.quantity,
      rate: lineItem.rate,
      amount: lineItem.amount,
    );
  }
}
