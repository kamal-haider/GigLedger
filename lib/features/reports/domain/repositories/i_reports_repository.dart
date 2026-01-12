import '../models/income_report.dart';

/// Reports repository interface
abstract class IReportsRepository {
  /// Get income report for a date range
  Future<IncomeReport> getIncomeReport(DateTime start, DateTime end);

  /// Get monthly income data for the last N months
  Future<List<MonthlyIncome>> getMonthlyIncome(int months);

  /// Get top clients by revenue
  Future<List<ClientRevenue>> getTopClients({int limit = 5});

  /// Get expenses by category for a date range
  Future<List<CategoryExpense>> getExpensesByCategory(
    DateTime start,
    DateTime end,
  );

  /// Export report as PDF
  Future<String> exportReportPdf(IncomeReport report);

  /// Get quarterly tax estimate
  Future<double> getQuarterlyTaxEstimate(double taxRate);
}
