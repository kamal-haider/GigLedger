import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/providers/auth_providers.dart';
import '../../domain/models/client.dart';
import '../../domain/repositories/i_client_repository.dart';
import 'client_providers.dart';

/// State for the client form
@immutable
class ClientFormState {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String notes;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isEditMode;

  const ClientFormState({
    this.id,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isEditMode = false,
  });

  ClientFormState copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? notes,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isEditMode,
    bool clearError = false,
  }) {
    return ClientFormState(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  /// Check if form has unsaved changes compared to original client
  bool hasChanges(Client? originalClient) {
    if (originalClient == null) {
      // For new client, any non-empty field means changes
      return name.isNotEmpty ||
          email.isNotEmpty ||
          phone.isNotEmpty ||
          address.isNotEmpty ||
          notes.isNotEmpty;
    }
    return name != originalClient.name ||
        email != originalClient.email ||
        phone != (originalClient.phone ?? '') ||
        address != (originalClient.address ?? '') ||
        notes != (originalClient.notes ?? '');
  }
}

/// Notifier for client form state management
class ClientFormNotifier extends StateNotifier<ClientFormState> {
  final IClientRepository _repository;
  final String? _userId;
  Client? _originalClient;

  ClientFormNotifier(this._repository, this._userId)
      : super(const ClientFormState());

  /// Initialize form for creating a new client
  void initForCreate() {
    state = const ClientFormState(isEditMode: false);
    _originalClient = null;
  }

  /// Initialize form for editing an existing client
  Future<void> initForEdit(String clientId) async {
    if (_userId == null) {
      state = state.copyWith(errorMessage: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, isEditMode: true, clearError: true);
    try {
      final client = await _repository.getById(clientId);
      if (client != null) {
        _originalClient = client;
        state = ClientFormState(
          id: client.id,
          name: client.name,
          email: client.email,
          phone: client.phone ?? '',
          address: client.address ?? '',
          notes: client.notes ?? '',
          isEditMode: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Client not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Update form fields
  void updateName(String value) =>
      state = state.copyWith(name: value, clearError: true);
  void updateEmail(String value) =>
      state = state.copyWith(email: value, clearError: true);
  void updatePhone(String value) =>
      state = state.copyWith(phone: value, clearError: true);
  void updateAddress(String value) =>
      state = state.copyWith(address: value, clearError: true);
  void updateNotes(String value) =>
      state = state.copyWith(notes: value, clearError: true);

  /// Clear any error message
  void clearError() => state = state.copyWith(clearError: true);

  /// Check if form has unsaved changes
  bool get hasChanges => state.hasChanges(_originalClient);

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Save the client (create or update)
  Future<Client?> saveClient() async {
    if (_userId == null) {
      state = state.copyWith(errorMessage: 'User not authenticated');
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final now = DateTime.now();
      final client = Client(
        id: state.id ?? '', // Will be generated by Firestore for new clients
        userId: _userId!,
        name: state.name.trim(),
        email: state.email.trim(),
        phone: state.phone.trim().isEmpty ? null : state.phone.trim(),
        address: state.address.trim().isEmpty ? null : state.address.trim(),
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        totalBilled: _originalClient?.totalBilled ?? 0.0,
        totalPaid: _originalClient?.totalPaid ?? 0.0,
        createdAt: _originalClient?.createdAt ?? now,
        updatedAt: now,
      );

      Client savedClient;
      if (state.isEditMode && state.id != null) {
        savedClient = await _repository.update(client);
      } else {
        savedClient = await _repository.create(client);
      }

      state = state.copyWith(isSaving: false);
      _originalClient = savedClient;
      return savedClient;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _getErrorMessage(e),
      );
      return null;
    }
  }

  String _getErrorMessage(Object error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return 'Permission denied. Please sign in again.';
    }
    if (errorStr.contains('auth')) {
      return 'Authentication error. Please sign in again.';
    }
    return 'Failed to save client. Please try again.';
  }
}

/// Provider for client form notifier
final clientFormNotifierProvider =
    StateNotifierProvider.autoDispose<ClientFormNotifier, ClientFormState>(
        (ref) {
  final repository = ref.watch(clientRepositoryProvider);
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.valueOrNull?.id;
  return ClientFormNotifier(repository, userId);
});
