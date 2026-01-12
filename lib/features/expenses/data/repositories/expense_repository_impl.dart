import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../data_sources/expense_remote_data_source.dart';
import '../dto/expense_dto.dart';

/// Implementation of IExpenseRepository using Firestore
class ExpenseRepositoryImpl implements IExpenseRepository {
  final ExpenseRemoteDataSource _dataSource;

  ExpenseRepositoryImpl(this._dataSource);

  @override
  Future<List<Expense>> getAll() async {
    try {
      final dtos = await _dataSource.getAll();
      return dtos.map((dto) => dto.toDomain()).toList();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<List<Expense>> getByCategory(ExpenseCategory category) async {
    try {
      final dtos = await _dataSource.getAll();
      return dtos
          .map((dto) => dto.toDomain())
          .where((expense) => expense.category == category)
          .toList();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<List<Expense>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final dtos = await _dataSource.getByDateRange(start, end);
      return dtos.map((dto) => dto.toDomain()).toList();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Expense?> getById(String id) async {
    try {
      final dto = await _dataSource.getById(id);
      return dto?.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Stream<List<Expense>> watchAll() {
    return _dataSource.watchAll().map(
        (dtos) => dtos.map((dto) => dto.toDomain()).toList());
  }

  @override
  Stream<List<Expense>> watchByDateRange(DateTime start, DateTime end) {
    return watchAll().map((expenses) => expenses
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .toList());
  }

  @override
  Stream<Expense?> watch(String id) {
    return _dataSource.watch(id).map((dto) => dto?.toDomain());
  }

  @override
  Future<Expense> create(Expense expense) async {
    try {
      final dto = ExpenseDTO.fromDomain(expense);
      final savedDto = await _dataSource.create(dto);
      return savedDto.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<Expense> update(Expense expense) async {
    try {
      final dto = ExpenseDTO.fromDomain(expense);
      final savedDto = await _dataSource.update(dto);
      return savedDto.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dataSource.delete(id);
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<String> uploadReceipt(String expenseId, String filePath) async {
    try {
      return await _dataSource.uploadReceipt(expenseId, filePath);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<void> deleteReceipt(String expenseId, String receiptUrl) async {
    try {
      await _dataSource.deleteReceipt(receiptUrl);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<int> getCount() async {
    try {
      return await _dataSource.getCount();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<int> getMonthlyCount() async {
    try {
      return await _dataSource.getMonthlyCount();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    final expenses = await getByDateRange(start, end);
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Future<Map<ExpenseCategory, double>> getExpensesByCategory(
      DateTime start, DateTime end) async {
    final expenses = await getByDateRange(start, end);
    final result = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }
}
