import '../models/expense.dart';

/// Expense repository interface
abstract class IExpenseRepository {
  /// Get all expenses for the current user
  Future<List<Expense>> getAll();

  /// Get expenses by category
  Future<List<Expense>> getByCategory(ExpenseCategory category);

  /// Get expenses within a date range
  Future<List<Expense>> getByDateRange(DateTime start, DateTime end);

  /// Get a single expense by ID
  Future<Expense?> getById(String id);

  /// Watch all expenses (real-time updates)
  Stream<List<Expense>> watchAll();

  /// Watch expenses for a date range
  Stream<List<Expense>> watchByDateRange(DateTime start, DateTime end);

  /// Watch a single expense
  Stream<Expense?> watch(String id);

  /// Create a new expense
  Future<Expense> create(Expense expense);

  /// Update an existing expense
  Future<Expense> update(Expense expense);

  /// Delete an expense
  Future<void> delete(String id);

  /// Upload a receipt image and return the URL
  Future<String> uploadReceipt(String expenseId, String filePath);

  /// Delete a receipt image
  Future<void> deleteReceipt(String expenseId, String receiptUrl);

  /// Get expense count for the current user
  Future<int> getCount();

  /// Get expense count for current month
  Future<int> getMonthlyCount();

  /// Get total expenses for a date range
  Future<double> getTotalExpenses(DateTime start, DateTime end);

  /// Get expenses grouped by category for a date range
  Future<Map<ExpenseCategory, double>> getExpensesByCategory(
    DateTime start,
    DateTime end,
  );
}
