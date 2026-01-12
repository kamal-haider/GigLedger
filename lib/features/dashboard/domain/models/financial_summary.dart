import 'package:flutter/foundation.dart';

/// Financial summary for dashboard display
@immutable
class FinancialSummary {
  final double incomeThisMonth;
  final double incomeYTD;
  final double expensesThisMonth;
  final double expensesYTD;
  final int pendingInvoices;
  final double pendingAmount;
  final int overdueInvoices;
  final double overdueAmount;

  const FinancialSummary({
    required this.incomeThisMonth,
    required this.incomeYTD,
    required this.expensesThisMonth,
    required this.expensesYTD,
    required this.pendingInvoices,
    required this.pendingAmount,
    required this.overdueInvoices,
    required this.overdueAmount,
  });

  /// Net profit this month (income - expenses)
  double get profitThisMonth => incomeThisMonth - expensesThisMonth;

  /// Net profit year-to-date
  double get profitYTD => incomeYTD - expensesYTD;

  /// Profit margin this month (as percentage)
  double get profitMarginThisMonth =>
      incomeThisMonth > 0 ? (profitThisMonth / incomeThisMonth) * 100 : 0;

  /// Profit margin year-to-date (as percentage)
  double get profitMarginYTD =>
      incomeYTD > 0 ? (profitYTD / incomeYTD) * 100 : 0;

  /// Whether there are any overdue invoices
  bool get hasOverdueInvoices => overdueInvoices > 0;

  /// Whether the user is profitable this month
  bool get isProfitableThisMonth => profitThisMonth > 0;

  /// Empty summary for initial state
  static const empty = FinancialSummary(
    incomeThisMonth: 0,
    incomeYTD: 0,
    expensesThisMonth: 0,
    expensesYTD: 0,
    pendingInvoices: 0,
    pendingAmount: 0,
    overdueInvoices: 0,
    overdueAmount: 0,
  );

  FinancialSummary copyWith({
    double? incomeThisMonth,
    double? incomeYTD,
    double? expensesThisMonth,
    double? expensesYTD,
    int? pendingInvoices,
    double? pendingAmount,
    int? overdueInvoices,
    double? overdueAmount,
  }) {
    return FinancialSummary(
      incomeThisMonth: incomeThisMonth ?? this.incomeThisMonth,
      incomeYTD: incomeYTD ?? this.incomeYTD,
      expensesThisMonth: expensesThisMonth ?? this.expensesThisMonth,
      expensesYTD: expensesYTD ?? this.expensesYTD,
      pendingInvoices: pendingInvoices ?? this.pendingInvoices,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      overdueInvoices: overdueInvoices ?? this.overdueInvoices,
      overdueAmount: overdueAmount ?? this.overdueAmount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialSummary &&
          runtimeType == other.runtimeType &&
          incomeThisMonth == other.incomeThisMonth &&
          incomeYTD == other.incomeYTD &&
          expensesThisMonth == other.expensesThisMonth &&
          expensesYTD == other.expensesYTD;

  @override
  int get hashCode =>
      incomeThisMonth.hashCode ^
      incomeYTD.hashCode ^
      expensesThisMonth.hashCode ^
      expensesYTD.hashCode;
}
