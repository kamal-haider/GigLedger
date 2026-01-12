import 'package:flutter/foundation.dart';

/// Client entity representing a business contact
@immutable
class Client {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? notes;
  final double totalBilled;
  final double totalPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.notes,
    this.totalBilled = 0.0,
    this.totalPaid = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Outstanding balance (billed - paid)
  double get outstandingBalance => totalBilled - totalPaid;

  /// Whether client has any unpaid invoices
  bool get hasOutstandingBalance => outstandingBalance > 0;

  /// Whether this is a new client (no invoices yet)
  bool get isNew => totalBilled == 0;

  Client copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? notes,
    double? totalBilled,
    double? totalPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalBilled: totalBilled ?? this.totalBilled,
      totalPaid: totalPaid ?? this.totalPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}
