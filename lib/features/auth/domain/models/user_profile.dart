import 'package:flutter/foundation.dart';

/// User profile containing business information and preferences
@immutable
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? businessName;
  final String? businessLogo;
  final String? businessAddress;
  final String currency;
  final double taxRate;
  final String? paymentInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.businessName,
    this.businessLogo,
    this.businessAddress,
    this.currency = 'USD',
    this.taxRate = 0.0,
    this.paymentInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the user has completed business profile setup
  bool get hasCompletedSetup => businessName != null && businessName!.isNotEmpty;

  /// Display name for UI (business name or email)
  String get displayNameOrEmail => businessName ?? displayName ?? email;

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? businessName,
    String? businessLogo,
    String? businessAddress,
    String? currency,
    double? taxRate,
    String? paymentInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      businessLogo: businessLogo ?? this.businessLogo,
      businessAddress: businessAddress ?? this.businessAddress,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      paymentInstructions: paymentInstructions ?? this.paymentInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          businessName == other.businessName &&
          currency == other.currency &&
          taxRate == other.taxRate;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      businessName.hashCode ^
      currency.hashCode ^
      taxRate.hashCode;
}
