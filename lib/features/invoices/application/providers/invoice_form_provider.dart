import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/application/providers/auth_providers.dart';
import '../../../clients/domain/models/client.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/line_item.dart';
import 'invoice_providers.dart';

/// State for the invoice form
class InvoiceFormState {
  final Client? selectedClient;
  final String invoiceNumber;
  final List<LineItem> lineItems;
  final DateTime issueDate;
  final DateTime dueDate;
  final double taxRate;
  final String notes;
  final String terms;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;
  final String? existingInvoiceId;
  final DateTime? originalCreatedAt;
  final InvoiceStatus? originalStatus;

  const InvoiceFormState({
    this.selectedClient,
    this.invoiceNumber = '',
    this.lineItems = const [],
    required this.issueDate,
    required this.dueDate,
    this.taxRate = 0.0,
    this.notes = '',
    this.terms = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
    this.existingInvoiceId,
    this.originalCreatedAt,
    this.originalStatus,
  });

  bool get isEditMode => existingInvoiceId != null;

  /// Calculate subtotal from line items
  double get subtotal => lineItems.fold(0.0, (sum, item) => sum + item.amount);

  /// Calculate tax amount
  double get taxAmount => subtotal * (taxRate / 100);

  /// Calculate total
  double get total => subtotal + taxAmount;

  /// Check if form is valid for saving as draft
  bool get canSaveAsDraft {
    return invoiceNumber.isNotEmpty && selectedClient != null;
  }

  /// Check if form is valid for sending
  bool get canSend {
    return canSaveAsDraft && lineItems.isNotEmpty;
  }

  InvoiceFormState copyWith({
    Client? selectedClient,
    String? invoiceNumber,
    List<LineItem>? lineItems,
    DateTime? issueDate,
    DateTime? dueDate,
    double? taxRate,
    String? notes,
    String? terms,
    bool? isLoading,
    String? errorMessage,
    bool? isSaved,
    String? existingInvoiceId,
    DateTime? originalCreatedAt,
    InvoiceStatus? originalStatus,
    bool clearClient = false,
    bool clearErrorMessage = false,
  }) {
    return InvoiceFormState(
      selectedClient:
          clearClient ? null : (selectedClient ?? this.selectedClient),
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      lineItems: lineItems ?? this.lineItems,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      taxRate: taxRate ?? this.taxRate,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isSaved: isSaved ?? this.isSaved,
      existingInvoiceId: existingInvoiceId ?? this.existingInvoiceId,
      originalCreatedAt: originalCreatedAt ?? this.originalCreatedAt,
      originalStatus: originalStatus ?? this.originalStatus,
    );
  }
}

/// Notifier for invoice form state management
class InvoiceFormNotifier extends StateNotifier<InvoiceFormState> {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  InvoiceFormNotifier(this._ref)
      : super(InvoiceFormState(
          issueDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 30)),
        ));

  /// Initialize the form for creating a new invoice
  Future<void> initForCreate() async {
    // Get next invoice number
    final invoiceNumber = await _ref.read(nextInvoiceNumberProvider.future);

    state = InvoiceFormState(
      invoiceNumber: invoiceNumber,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// Initialize the form for editing an existing invoice
  void initForEdit(Invoice invoice, Client? client) {
    state = InvoiceFormState(
      selectedClient: client,
      invoiceNumber: invoice.invoiceNumber,
      lineItems: List.from(invoice.lineItems),
      issueDate: invoice.issueDate,
      dueDate: invoice.dueDate,
      taxRate: invoice.taxRate,
      notes: invoice.notes ?? '',
      terms: invoice.terms ?? '',
      existingInvoiceId: invoice.id,
      originalCreatedAt: invoice.createdAt,
      originalStatus: invoice.status,
    );
  }

  void setClient(Client? client) {
    state = state.copyWith(
      selectedClient: client,
      clearClient: client == null,
    );
  }

  void setInvoiceNumber(String invoiceNumber) {
    state = state.copyWith(invoiceNumber: invoiceNumber);
  }

  void setIssueDate(DateTime issueDate) {
    state = state.copyWith(issueDate: issueDate);
  }

  void setDueDate(DateTime dueDate) {
    state = state.copyWith(dueDate: dueDate);
  }

  void setTaxRate(double taxRate) {
    state = state.copyWith(taxRate: taxRate);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void setTerms(String terms) {
    state = state.copyWith(terms: terms);
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  /// Add a new empty line item
  void addLineItem() {
    final newItem = LineItem.create(
      id: _uuid.v4(),
      description: '',
      quantity: 1,
      rate: 0,
    );
    state = state.copyWith(lineItems: [...state.lineItems, newItem]);
  }

  /// Update a line item at the given index
  void updateLineItem(int index, LineItem item) {
    if (index < 0 || index >= state.lineItems.length) return;

    final updatedItems = List<LineItem>.from(state.lineItems);
    updatedItems[index] = item;
    state = state.copyWith(lineItems: updatedItems);
  }

  /// Update line item description
  void updateLineItemDescription(int index, String description) {
    if (index < 0 || index >= state.lineItems.length) return;

    final item = state.lineItems[index];
    final updatedItem = LineItem.create(
      id: item.id,
      description: description,
      quantity: item.quantity,
      rate: item.rate,
    );
    updateLineItem(index, updatedItem);
  }

  /// Update line item quantity
  void updateLineItemQuantity(int index, double quantity) {
    if (index < 0 || index >= state.lineItems.length) return;

    final item = state.lineItems[index];
    final updatedItem = LineItem.create(
      id: item.id,
      description: item.description,
      quantity: quantity,
      rate: item.rate,
    );
    updateLineItem(index, updatedItem);
  }

  /// Update line item rate
  void updateLineItemRate(int index, double rate) {
    if (index < 0 || index >= state.lineItems.length) return;

    final item = state.lineItems[index];
    final updatedItem = LineItem.create(
      id: item.id,
      description: item.description,
      quantity: item.quantity,
      rate: rate,
    );
    updateLineItem(index, updatedItem);
  }

  /// Remove a line item at the given index
  void removeLineItem(int index) {
    if (index < 0 || index >= state.lineItems.length) return;

    final updatedItems = List<LineItem>.from(state.lineItems);
    updatedItems.removeAt(index);
    state = state.copyWith(lineItems: updatedItems);
  }

  /// Save the invoice as a draft
  Future<Invoice?> saveAsDraft() async {
    return _saveInvoice(InvoiceStatus.draft);
  }

  /// Save and send the invoice
  Future<Invoice?> saveAndSend() async {
    if (state.lineItems.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please add at least one line item before sending',
      );
      return null;
    }
    return _saveInvoice(InvoiceStatus.sent);
  }

  /// Internal save method
  Future<Invoice?> _saveInvoice(InvoiceStatus targetStatus) async {
    // Validate required fields
    if (state.selectedClient == null) {
      state = state.copyWith(errorMessage: 'Please select a client');
      return null;
    }

    if (state.invoiceNumber.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter an invoice number');
      return null;
    }

    // Validate line items have descriptions
    for (int i = 0; i < state.lineItems.length; i++) {
      if (state.lineItems[i].description.trim().isEmpty) {
        state = state.copyWith(
          errorMessage: 'Please enter a description for all line items',
        );
        return null;
      }
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final authState = _ref.read(authNotifierProvider);
      final userId = authState.valueOrNull?.id;

      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User not authenticated',
        );
        return null;
      }

      final invoiceNotifier = _ref.read(invoiceNotifierProvider.notifier);
      final now = DateTime.now();
      final client = state.selectedClient!;

      Invoice savedInvoice;

      if (state.isEditMode) {
        // Update existing invoice
        final invoice = Invoice.create(
          id: state.existingInvoiceId!,
          userId: userId,
          invoiceNumber: state.invoiceNumber.trim(),
          clientId: client.id,
          clientName: client.name,
          clientEmail: client.email,
          lineItems: state.lineItems,
          taxRate: state.taxRate,
          issueDate: state.issueDate,
          dueDate: state.dueDate,
          notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
          terms: state.terms.trim().isEmpty ? null : state.terms.trim(),
        ).copyWith(
          status: targetStatus,
          createdAt: state.originalCreatedAt ?? now,
          updatedAt: now,
        );
        savedInvoice = await invoiceNotifier.updateInvoice(invoice);
      } else {
        // Create new invoice
        final invoice = Invoice.create(
          id: '', // Will be generated by Firestore
          userId: userId,
          invoiceNumber: state.invoiceNumber.trim(),
          clientId: client.id,
          clientName: client.name,
          clientEmail: client.email,
          lineItems: state.lineItems,
          taxRate: state.taxRate,
          issueDate: state.issueDate,
          dueDate: state.dueDate,
          notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
          terms: state.terms.trim().isEmpty ? null : state.terms.trim(),
        ).copyWith(
          status: targetStatus,
        );
        savedInvoice = await invoiceNotifier.createInvoice(invoice);
      }

      state = state.copyWith(isLoading: false, isSaved: true);
      return savedInvoice;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
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
    if (errorStr.contains('limit') || errorStr.contains('quota')) {
      return 'Monthly invoice limit reached. Upgrade to Pro for unlimited invoices.';
    }
    return 'Failed to save invoice. Please try again.';
  }
}

/// Provider for invoice form state
final invoiceFormProvider =
    StateNotifierProvider.autoDispose<InvoiceFormNotifier, InvoiceFormState>(
        (ref) {
  return InvoiceFormNotifier(ref);
});
