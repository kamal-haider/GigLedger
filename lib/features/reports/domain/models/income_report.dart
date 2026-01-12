import 'package:flutter/foundation.dart';

/// Monthly income data point
@immutable
class MonthlyIncome {
  final int year;
  final int month;
  final double income;
  final double expenses;

  const MonthlyIncome({
    required this.year,
    required this.month,
    required this.income,
    required this.expenses,
  });

  double get profit => income - expenses;

  String get monthLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String get fullLabel => '$monthLabel $year';
}

/// Client revenue data
@immutable
class ClientRevenue {
  final String clientId;
  final String clientName;
  final double totalRevenue;
  final int invoiceCount;

  const ClientRevenue({
    required this.clientId,
    required this.clientName,
    required this.totalRevenue,
    required this.invoiceCount,
  });

  double get averageInvoice =>
      invoiceCount > 0 ? totalRevenue / invoiceCount : 0;
}

/// Expense category breakdown
@immutable
class CategoryExpense {
  final String category;
  final String displayName;
  final double amount;
  final double percentage;

  const CategoryExpense({
    required this.category,
    required this.displayName,
    required this.amount,
    required this.percentage,
  });
}

/// Complete income report for export
@immutable
class IncomeReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final List<MonthlyIncome> monthlyData;
  final List<ClientRevenue> topClients;
  final List<CategoryExpense> expensesByCategory;

  const IncomeReport({
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.monthlyData,
    required this.topClients,
    required this.expensesByCategory,
  });

  double get profitMargin =>
      totalIncome > 0 ? (netProfit / totalIncome) * 100 : 0;

  /// Create an empty report (for initial state)
  factory IncomeReport.empty() => IncomeReport(
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        totalIncome: 0,
        totalExpenses: 0,
        netProfit: 0,
        monthlyData: const [],
        topClients: const [],
        expensesByCategory: const [],
      );
}
