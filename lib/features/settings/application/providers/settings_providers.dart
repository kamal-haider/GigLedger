import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/domain/models/user_profile.dart';

/// Provider for current business profile (from user profile)
final businessProfileProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.valueOrNull;
});

/// List of supported currencies
const supportedCurrencies = [
  ('USD', 'US Dollar', r'$'),
  ('EUR', 'Euro', '\u20AC'),
  ('GBP', 'British Pound', '\u00A3'),
  ('CAD', 'Canadian Dollar', r'C$'),
  ('AUD', 'Australian Dollar', r'A$'),
  ('JPY', 'Japanese Yen', '\u00A5'),
  ('CHF', 'Swiss Franc', 'CHF'),
  ('INR', 'Indian Rupee', '\u20B9'),
];

/// Business profile notifier for updates
class BusinessProfileNotifier extends StateNotifier<AsyncValue<void>> {
  BusinessProfileNotifier(this._authNotifier, this._currentProfile)
      : super(const AsyncValue.data(null));

  final AuthNotifier _authNotifier;
  final UserProfile? _currentProfile;

  Future<void> updateBusinessName(String name) async {
    final profile = _currentProfile;
    if (profile == null) return;
    state = const AsyncValue.loading();
    try {
      await _authNotifier.updateProfile(
        profile.copyWith(businessName: name, updatedAt: DateTime.now()),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateBusinessAddress(String address) async {
    final profile = _currentProfile;
    if (profile == null) return;
    state = const AsyncValue.loading();
    try {
      await _authNotifier.updateProfile(
        profile.copyWith(businessAddress: address, updatedAt: DateTime.now()),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateCurrency(String currency) async {
    final profile = _currentProfile;
    if (profile == null) return;
    state = const AsyncValue.loading();
    try {
      await _authNotifier.updateProfile(
        profile.copyWith(currency: currency, updatedAt: DateTime.now()),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateTaxRate(double taxRate) async {
    final profile = _currentProfile;
    if (profile == null) return;
    state = const AsyncValue.loading();
    try {
      await _authNotifier.updateProfile(
        profile.copyWith(taxRate: taxRate, updatedAt: DateTime.now()),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updatePaymentInstructions(String instructions) async {
    final profile = _currentProfile;
    if (profile == null) return;
    state = const AsyncValue.loading();
    try {
      await _authNotifier.updateProfile(
        profile.copyWith(
          paymentInstructions: instructions,
          updatedAt: DateTime.now(),
        ),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update business logo. Pass null to clear the logo.
  Future<void> updateBusinessLogo(String? logoUrl) async {
    final profile = _currentProfile;
    if (profile == null) return;
    state = const AsyncValue.loading();
    try {
      await _authNotifier.updateProfile(
        profile.copyWith(businessLogo: logoUrl, updatedAt: DateTime.now()),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateFullProfile({
    String? businessName,
    String? businessAddress,
    String? currency,
    double? taxRate,
    String? paymentInstructions,
    String? businessLogo,
  }) async {
    final profile = _currentProfile;
    if (profile == null) return;
    state = const AsyncValue.loading();
    try {
      await _authNotifier.updateProfile(
        profile.copyWith(
          businessName: businessName ?? profile.businessName,
          businessAddress: businessAddress ?? profile.businessAddress,
          currency: currency ?? profile.currency,
          taxRate: taxRate ?? profile.taxRate,
          paymentInstructions: paymentInstructions ?? profile.paymentInstructions,
          businessLogo: businessLogo ?? profile.businessLogo,
          updatedAt: DateTime.now(),
        ),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider for business profile notifier
final businessProfileNotifierProvider =
    StateNotifierProvider<BusinessProfileNotifier, AsyncValue<void>>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  final currentProfile = ref.watch(businessProfileProvider);
  return BusinessProfileNotifier(authNotifier, currentProfile);
});
