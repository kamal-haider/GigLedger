import '../models/invoice.dart';

/// Invoice repository interface
abstract class IInvoiceRepository {
  /// Get all invoices for the current user
  Future<List<Invoice>> getAll();

  /// Get invoices by status
  Future<List<Invoice>> getByStatus(InvoiceStatus status);

  /// Get invoices for a specific client
  Future<List<Invoice>> getByClientId(String clientId);

  /// Get a single invoice by ID
  Future<Invoice?> getById(String id);

  /// Watch all invoices (real-time updates)
  Stream<List<Invoice>> watchAll();

  /// Watch invoices by status
  Stream<List<Invoice>> watchByStatus(InvoiceStatus status);

  /// Watch a single invoice
  Stream<Invoice?> watch(String id);

  /// Create a new invoice
  Future<Invoice> create(Invoice invoice);

  /// Update an existing invoice
  Future<Invoice> update(Invoice invoice);

  /// Delete an invoice
  Future<void> delete(String id);

  /// Mark invoice as sent
  Future<Invoice> markAsSent(String id);

  /// Mark invoice as paid
  Future<Invoice> markAsPaid(String id, DateTime paidDate);

  /// Get the next invoice number
  Future<String> getNextInvoiceNumber();

  /// Get invoice count for the current user
  Future<int> getCount();

  /// Get invoice count for current month
  Future<int> getMonthlyCount();

  /// Get total income for a date range
  Future<double> getTotalIncome(DateTime start, DateTime end);

  /// Get overdue invoices
  Future<List<Invoice>> getOverdue();

  /// Duplicate an existing invoice
  Future<Invoice> duplicate(String id);
}
