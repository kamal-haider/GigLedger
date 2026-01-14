import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../invoices/application/providers/invoice_providers.dart';
import '../../../expenses/application/providers/expense_providers.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/models/income_report.dart';
import '../../domain/repositories/i_reports_repository.dart';

/// Provider for reports repository
final reportsRepositoryProvider = Provider<IReportsRepository>((ref) {
  final invoiceRepo = ref.watch(invoiceRepositoryProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  return ReportsRepositoryImpl(invoiceRepo, expenseRepo);
});

/// Date range presets for reports
enum DateRangePreset {
  thisMonth,
  lastMonth,
  last3Months,
  last6Months,
  yearToDate,
  custom;

  String get displayName {
    switch (this) {
      case DateRangePreset.thisMonth:
        return 'This Month';
      case DateRangePreset.lastMonth:
        return 'Last Month';
      case DateRangePreset.last3Months:
        return 'Last 3 Months';
      case DateRangePreset.last6Months:
        return 'Last 6 Months';
      case DateRangePreset.yearToDate:
        return 'Year to Date';
      case DateRangePreset.custom:
        return 'Custom';
    }
  }

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    switch (this) {
      case DateRangePreset.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case DateRangePreset.lastMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        );
      case DateRangePreset.last3Months:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 2, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case DateRangePreset.last6Months:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 5, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case DateRangePreset.yearToDate:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case DateRangePreset.custom:
        // Default to this month for custom
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
    }
  }
}

/// State for income vs expense report
class IncomeExpenseReportState {
  final DateRangePreset preset;
  final DateTimeRange dateRange;
  final AsyncValue<IncomeReport> report;

  const IncomeExpenseReportState({
    required this.preset,
    required this.dateRange,
    required this.report,
  });

  IncomeExpenseReportState copyWith({
    DateRangePreset? preset,
    DateTimeRange? dateRange,
    AsyncValue<IncomeReport>? report,
  }) {
    return IncomeExpenseReportState(
      preset: preset ?? this.preset,
      dateRange: dateRange ?? this.dateRange,
      report: report ?? this.report,
    );
  }
}

/// Notifier for income vs expense report
class IncomeExpenseReportNotifier extends StateNotifier<IncomeExpenseReportState> {
  final IReportsRepository _repository;

  IncomeExpenseReportNotifier(this._repository)
      : super(IncomeExpenseReportState(
          preset: DateRangePreset.thisMonth,
          dateRange: DateRangePreset.thisMonth.getDateRange(),
          report: const AsyncValue.loading(),
        )) {
    _loadReport();
  }

  Future<void> _loadReport() async {
    state = state.copyWith(report: const AsyncValue.loading());
    try {
      final report = await _repository.getIncomeReport(
        state.dateRange.start,
        state.dateRange.end,
      );
      state = state.copyWith(report: AsyncValue.data(report));
    } catch (e, st) {
      state = state.copyWith(report: AsyncValue.error(e, st));
    }
  }

  void setPreset(DateRangePreset preset) {
    if (preset == DateRangePreset.custom) {
      // For custom, keep current date range
      state = state.copyWith(preset: preset);
    } else {
      final dateRange = preset.getDateRange();
      state = state.copyWith(preset: preset, dateRange: dateRange);
      _loadReport();
    }
  }

  void setCustomDateRange(DateTimeRange dateRange) {
    state = state.copyWith(
      preset: DateRangePreset.custom,
      dateRange: dateRange,
    );
    _loadReport();
  }

  void refresh() {
    _loadReport();
  }
}

/// Provider for income vs expense report state
final incomeExpenseReportProvider =
    StateNotifierProvider<IncomeExpenseReportNotifier, IncomeExpenseReportState>(
        (ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return IncomeExpenseReportNotifier(repository);
});

/// Provider for monthly income data (last 6 months)
final monthlyIncomeProvider =
    FutureProvider.autoDispose<List<MonthlyIncome>>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getMonthlyIncome(6);
});

/// Provider for top clients
final topClientsProvider =
    FutureProvider.autoDispose<List<ClientRevenue>>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getTopClients(limit: 5);
});
