import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/expense_remote_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/i_expense_repository.dart';

/// Provider for expense data source
final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSourceImpl();
});

/// Provider for expense repository
final expenseRepositoryProvider = Provider<IExpenseRepository>((ref) {
  final dataSource = ref.watch(expenseRemoteDataSourceProvider);
  return ExpenseRepositoryImpl(dataSource);
});

/// Stream provider for all expenses (real-time)
/// Uses autoDispose to prevent wasted Firestore reads when not in use
final expensesStreamProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchAll();
});

/// Provider for expense by ID
final expenseByIdProvider = FutureProvider.family<Expense?, String>((ref, id) {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.getById(id);
});

/// Selected category filter
final expenseCategoryFilterProvider = StateProvider<ExpenseCategory?>((ref) => null);

/// Date range filter (uses Flutter's built-in DateTimeRange)
final expenseDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Helper to normalize DateTime to start of day for inclusive date comparisons
DateTime _startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// Helper to normalize DateTime to end of day for inclusive date comparisons
DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

/// Filtered expenses based on category and date range
final filteredExpensesProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);
  final categoryFilter = ref.watch(expenseCategoryFilterProvider);
  final dateRange = ref.watch(expenseDateRangeProvider);

  return expensesAsync.whenData((expenses) {
    var filtered = expenses;

    if (categoryFilter != null) {
      filtered = filtered.where((e) => e.category == categoryFilter).toList();
    }

    if (dateRange != null) {
      final rangeStart = _startOfDay(dateRange.start);
      final rangeEnd = _endOfDay(dateRange.end);
      filtered = filtered.where((e) {
        final expenseDate = e.date;
        return !expenseDate.isBefore(rangeStart) && !expenseDate.isAfter(rangeEnd);
      }).toList();
    }

    return filtered;
  });
});

/// Expense notifier for CRUD operations
class ExpenseNotifier extends StateNotifier<AsyncValue<void>> {
  final IExpenseRepository _repository;

  ExpenseNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<Expense> createExpense(Expense expense) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repository.create(expense);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Expense> updateExpense(Expense expense) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.update(expense);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> uploadReceipt(String expenseId, String filePath) async {
    return await _repository.uploadReceipt(expenseId, filePath);
  }
}

/// Provider for expense notifier
final expenseNotifierProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpenseNotifier(repository);
});
