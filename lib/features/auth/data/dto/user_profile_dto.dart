import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user_profile.dart';

/// DTO for UserProfile matching Firestore document structure
class UserProfileDTO {
  final String? id;
  final String? email;
  final String? displayName;
  final String? businessName;
  final String? businessLogo;
  final String? businessAddress;
  final String? currency;
  final double? taxRate;
  final String? paymentInstructions;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const UserProfileDTO({
    this.id,
    this.email,
    this.displayName,
    this.businessName,
    this.businessLogo,
    this.businessAddress,
    this.currency,
    this.taxRate,
    this.paymentInstructions,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileDTO.fromJson(Map<String, dynamic> json, String documentId) {
    return UserProfileDTO(
      id: documentId,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      businessName: json['businessName'] as String?,
      businessLogo: json['businessLogo'] as String?,
      businessAddress: json['businessAddress'] as String?,
      currency: json['currency'] as String?,
      taxRate: (json['taxRate'] as num?)?.toDouble(),
      paymentInstructions: json['paymentInstructions'] as String?,
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'businessName': businessName,
      'businessLogo': businessLogo,
      'businessAddress': businessAddress,
      'currency': currency,
      'taxRate': taxRate,
      'paymentInstructions': paymentInstructions,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserProfile toDomain() {
    final now = DateTime.now();
    return UserProfile(
      id: id ?? '',
      email: email ?? '',
      displayName: displayName,
      businessName: businessName,
      businessLogo: businessLogo,
      businessAddress: businessAddress,
      currency: currency ?? 'USD',
      taxRate: taxRate ?? 0.0,
      paymentInstructions: paymentInstructions,
      createdAt: createdAt?.toDate() ?? now,
      updatedAt: updatedAt?.toDate() ?? now,
    );
  }

  factory UserProfileDTO.fromDomain(UserProfile profile) {
    return UserProfileDTO(
      id: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      businessName: profile.businessName,
      businessLogo: profile.businessLogo,
      businessAddress: profile.businessAddress,
      currency: profile.currency,
      taxRate: profile.taxRate,
      paymentInstructions: profile.paymentInstructions,
      createdAt: Timestamp.fromDate(profile.createdAt),
      updatedAt: Timestamp.fromDate(profile.updatedAt),
    );
  }
}
