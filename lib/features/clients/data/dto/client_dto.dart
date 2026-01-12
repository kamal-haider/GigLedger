import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/client.dart';

/// DTO for Client matching Firestore document structure
class ClientDTO {
  final String? id;
  final String? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;
  final double? totalBilled;
  final double? totalPaid;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ClientDTO({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.notes,
    this.totalBilled,
    this.totalPaid,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientDTO.fromJson(Map<String, dynamic> json, String documentId) {
    return ClientDTO(
      id: documentId,
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      totalBilled: (json['totalBilled'] as num?)?.toDouble(),
      totalPaid: (json['totalPaid'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'totalBilled': totalBilled,
      'totalPaid': totalPaid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Converts DTO to domain model.
  /// Throws [FormatException] if required fields (id, name) are missing.
  Client toDomain() {
    if (id == null || id!.isEmpty) {
      throw const FormatException('Client ID is required');
    }
    if (name == null || name!.isEmpty) {
      throw const FormatException('Client name is required');
    }

    final now = DateTime.now();
    return Client(
      id: id!,
      userId: userId ?? '',
      name: name!,
      email: email ?? '', // Email is optional
      phone: phone,
      address: address,
      notes: notes,
      totalBilled: totalBilled ?? 0,
      totalPaid: totalPaid ?? 0,
      createdAt: createdAt?.toDate() ?? now,
      updatedAt: updatedAt?.toDate() ?? now,
    );
  }

  factory ClientDTO.fromDomain(Client client) {
    return ClientDTO(
      id: client.id,
      userId: client.userId,
      name: client.name,
      email: client.email,
      phone: client.phone,
      address: client.address,
      notes: client.notes,
      totalBilled: client.totalBilled,
      totalPaid: client.totalPaid,
      createdAt: Timestamp.fromDate(client.createdAt),
      updatedAt: Timestamp.fromDate(client.updatedAt),
    );
  }
}
