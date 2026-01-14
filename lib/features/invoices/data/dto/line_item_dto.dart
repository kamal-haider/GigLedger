import '../../domain/models/line_item.dart';

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
    return LineItem(
      id: id ?? '',
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
