import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/invoice_remote_data_source.dart';
import '../../data/repositories/invoice_repository_impl.dart';
import '../../domain/models/invoice.dart';
import '../../domain/repositories/i_invoice_repository.dart';

/// Provider for invoice data source
final invoiceRemoteDataSourceProvider =
    Provider<InvoiceRemoteDataSource>((ref) {
  return InvoiceRemoteDataSourceImpl();
});

/// Provider for invoice repository
final invoiceRepositoryProvider = Provider<IInvoiceRepository>((ref) {
  final dataSource = ref.watch(invoiceRemoteDataSourceProvider);
  return InvoiceRepositoryImpl(dataSource);
});

/// Stream provider for all invoices (real-time)
/// Uses autoDispose to prevent wasted Firestore reads when not in use
final invoicesStreamProvider = StreamProvider.autoDispose<List<Invoice>>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.watchAll();
});

/// Provider for invoice by ID
final invoiceByIdProvider = FutureProvider.family<Invoice?, String>((ref, id) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getById(id);
});

/// Stream provider for watching a single invoice
final invoiceStreamProvider =
    StreamProvider.family<Invoice?, String>((ref, id) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.watch(id);
});

/// Selected status filter for invoice list
final invoiceStatusFilterProvider =
    StateProvider<InvoiceStatus?>((ref) => null);

/// Date range filter for invoices
final invoiceDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Search term filter for invoices
final invoiceSearchTermProvider = StateProvider<String>((ref) => '');

/// Helper to normalize DateTime to start of day for inclusive date comparisons
DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Helper to normalize DateTime to end of day for inclusive date comparisons
DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

/// Filtered invoices based on status, date range, and search term
final filteredInvoicesProvider = Provider<AsyncValue<List<Invoice>>>((ref) {
  final invoicesAsync = ref.watch(invoicesStreamProvider);
  final statusFilter = ref.watch(invoiceStatusFilterProvider);
  final dateRange = ref.watch(invoiceDateRangeProvider);
  final searchTerm = ref.watch(invoiceSearchTermProvider).toLowerCase().trim();

  return invoicesAsync.whenData((invoices) {
    var filtered = invoices;

    // Filter by status
    if (statusFilter != null) {
      filtered = filtered.where((inv) => inv.status == statusFilter).toList();
    }

    // Filter by date range
    if (dateRange != null) {
      final rangeStart = _startOfDay(dateRange.start);
      final rangeEnd = _endOfDay(dateRange.end);
      filtered = filtered.where((inv) {
        final issueDate = inv.issueDate;
        return !issueDate.isBefore(rangeStart) && !issueDate.isAfter(rangeEnd);
      }).toList();
    }

    // Filter by search term (client name or invoice number)
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((inv) {
        final clientNameMatch =
            inv.clientName.toLowerCase().contains(searchTerm);
        final invoiceNumberMatch =
            inv.invoiceNumber.toLowerCase().contains(searchTerm);
        return clientNameMatch || invoiceNumberMatch;
      }).toList();
    }

    return filtered;
  });
});

/// Provider for overdue invoices
final overdueInvoicesProvider =
    FutureProvider.autoDispose<List<Invoice>>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getOverdue();
});

/// Provider for next invoice number
final nextInvoiceNumberProvider = FutureProvider.autoDispose<String>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getNextInvoiceNumber();
});

/// Provider for monthly invoice count (for freemium limit checking)
final monthlyInvoiceCountProvider = FutureProvider.autoDispose<int>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getMonthlyCount();
});

/// Invoice notifier for CRUD operations
class InvoiceNotifier extends StateNotifier<AsyncValue<void>> {
  final IInvoiceRepository _repository;

  InvoiceNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<Invoice> createInvoice(Invoice invoice) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repository.create(invoice);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Invoice> updateInvoice(Invoice invoice) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.update(invoice);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Invoice> markAsSent(String id) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.markAsSent(id);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Invoice> markAsPaid(String id, DateTime paidDate) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.markAsPaid(id, paidDate);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Invoice> duplicateInvoice(String id) async {
    state = const AsyncValue.loading();
    try {
      final duplicated = await _repository.duplicate(id);
      state = const AsyncValue.data(null);
      return duplicated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider for invoice notifier
final invoiceNotifierProvider =
    StateNotifierProvider<InvoiceNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return InvoiceNotifier(repository);
});
