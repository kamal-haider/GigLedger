import 'package:flutter/foundation.dart';

/// Sentinel value for copyWith to distinguish between "not provided" and "set to null"
const _undefined = Object();

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
  bool get hasCompletedSetup =>
      businessName != null && businessName!.isNotEmpty;

  /// Display name for UI (business name or email)
  String get displayNameOrEmail => businessName ?? displayName ?? email;

  /// Creates a copy with updated fields.
  /// Use explicit null to clear nullable fields (e.g., businessLogo: null).
  /// Omit a parameter to keep its current value.
  UserProfile copyWith({
    String? id,
    String? email,
    Object? displayName = _undefined,
    Object? businessName = _undefined,
    Object? businessLogo = _undefined,
    Object? businessAddress = _undefined,
    String? currency,
    double? taxRate,
    Object? paymentInstructions = _undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName:
          displayName == _undefined ? this.displayName : displayName as String?,
      businessName: businessName == _undefined
          ? this.businessName
          : businessName as String?,
      businessLogo: businessLogo == _undefined
          ? this.businessLogo
          : businessLogo as String?,
      businessAddress: businessAddress == _undefined
          ? this.businessAddress
          : businessAddress as String?,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      paymentInstructions: paymentInstructions == _undefined
          ? this.paymentInstructions
          : paymentInstructions as String?,
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
