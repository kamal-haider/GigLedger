import '../../domain/models/income_report.dart';
import '../../domain/repositories/i_reports_repository.dart';
import '../../../invoices/domain/models/invoice.dart';
import '../../../invoices/domain/repositories/i_invoice_repository.dart';
import '../../../expenses/domain/models/expense.dart';
import '../../../expenses/domain/repositories/i_expense_repository.dart';

/// Implementation of reports repository that aggregates data from
/// invoices and expenses
class ReportsRepositoryImpl implements IReportsRepository {
  final IInvoiceRepository _invoiceRepository;
  final IExpenseRepository _expenseRepository;

  ReportsRepositoryImpl(this._invoiceRepository, this._expenseRepository);

  @override
  Future<IncomeReport> getIncomeReport(DateTime start, DateTime end) async {
    final invoices = await _invoiceRepository.getAll();
    final expenses = await _expenseRepository.getAll();

    // Filter to paid invoices in date range
    final paidInvoices = invoices.where((inv) =>
        inv.status == InvoiceStatus.paid &&
        inv.paidDate != null &&
        !inv.paidDate!.isBefore(start) &&
        !inv.paidDate!.isAfter(end));

    // Filter expenses in date range
    final rangeExpenses = expenses.where((exp) =>
        !exp.date.isBefore(start) && !exp.date.isAfter(end));

    final totalIncome =
        paidInvoices.fold(0.0, (sum, inv) => sum + inv.total);
    final totalExpenses =
        rangeExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

    // Generate monthly data
    final monthlyData = _generateMonthlyData(
      start,
      end,
      paidInvoices.toList(),
      rangeExpenses.toList(),
    );

    // Get top clients
    final topClients = _getTopClients(paidInvoices.toList());

    // Get expenses by category
    final expensesByCategory = _getExpensesByCategory(rangeExpenses.toList());

    return IncomeReport(
      startDate: start,
      endDate: end,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netProfit: totalIncome - totalExpenses,
      monthlyData: monthlyData,
      topClients: topClients,
      expensesByCategory: expensesByCategory,
    );
  }

  @override
  Future<List<MonthlyIncome>> getMonthlyIncome(int months) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - months + 1, 1);
    final end = DateTime(now.year, now.month + 1, 0);

    final invoices = await _invoiceRepository.getAll();
    final expenses = await _expenseRepository.getAll();

    final paidInvoices = invoices.where((inv) =>
        inv.status == InvoiceStatus.paid &&
        inv.paidDate != null &&
        !inv.paidDate!.isBefore(start) &&
        !inv.paidDate!.isAfter(end));

    final rangeExpenses = expenses.where((exp) =>
        !exp.date.isBefore(start) && !exp.date.isAfter(end));

    return _generateMonthlyData(
      start,
      end,
      paidInvoices.toList(),
      rangeExpenses.toList(),
    );
  }

  @override
  Future<List<ClientRevenue>> getTopClients({int limit = 5}) async {
    final invoices = await _invoiceRepository.getAll();
    final paidInvoices =
        invoices.where((inv) => inv.status == InvoiceStatus.paid).toList();
    return _getTopClients(paidInvoices, limit: limit);
  }

  @override
  Future<List<CategoryExpense>> getExpensesByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final expenses = await _expenseRepository.getAll();
    final rangeExpenses = expenses
        .where((exp) => !exp.date.isBefore(start) && !exp.date.isAfter(end))
        .toList();
    return _getExpensesByCategory(rangeExpenses);
  }

  @override
  Future<String> exportReportPdf(IncomeReport report) async {
    // TODO: Implement PDF export - post-MVP
    throw UnimplementedError('PDF export not yet implemented');
  }

  @override
  Future<double> getQuarterlyTaxEstimate(double taxRate) async {
    final now = DateTime.now();
    final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
    final quarterEnd = DateTime(now.year, quarterStart.month + 3, 0);

    final report = await getIncomeReport(quarterStart, quarterEnd);
    return report.netProfit * (taxRate / 100);
  }

  List<MonthlyIncome> _generateMonthlyData(
    DateTime start,
    DateTime end,
    List<Invoice> invoices,
    List<Expense> expenses,
  ) {
    final months = <MonthlyIncome>[];
    var current = DateTime(start.year, start.month, 1);

    while (!current.isAfter(end)) {
      final monthInvoices = invoices.where((inv) =>
          inv.paidDate != null &&
          inv.paidDate!.year == current.year &&
          inv.paidDate!.month == current.month);

      final monthExpenses = expenses.where((exp) =>
          exp.date.year == current.year && exp.date.month == current.month);

      final income = monthInvoices.fold(0.0, (sum, inv) => sum + inv.total);
      final expenseTotal =
          monthExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

      months.add(MonthlyIncome(
        year: current.year,
        month: current.month,
        income: income,
        expenses: expenseTotal,
      ));

      current = DateTime(current.year, current.month + 1, 1);
    }

    return months;
  }

  List<ClientRevenue> _getTopClients(List<Invoice> invoices, {int limit = 5}) {
    final clientMap = <String, _ClientData>{};

    for (final invoice in invoices) {
      final data = clientMap.putIfAbsent(
        invoice.clientId,
        () => _ClientData(invoice.clientId, invoice.clientName),
      );
      data.totalRevenue += invoice.total;
      data.invoiceCount++;
    }

    final sorted = clientMap.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    return sorted.take(limit).map((data) => ClientRevenue(
          clientId: data.clientId,
          clientName: data.clientName,
          totalRevenue: data.totalRevenue,
          invoiceCount: data.invoiceCount,
        )).toList();
  }

  List<CategoryExpense> _getExpensesByCategory(List<Expense> expenses) {
    final categoryMap = <String, double>{};
    var total = 0.0;

    for (final expense in expenses) {
      final category = expense.category.name;
      categoryMap[category] = (categoryMap[category] ?? 0) + expense.amount;
      total += expense.amount;
    }

    return categoryMap.entries.map((entry) {
      final category = ExpenseCategory.values.firstWhere(
        (c) => c.name == entry.key,
        orElse: () => ExpenseCategory.other,
      );
      return CategoryExpense(
        category: entry.key,
        displayName: category.displayName,
        amount: entry.value,
        percentage: total > 0 ? (entry.value / total) * 100 : 0,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }
}

class _ClientData {
  final String clientId;
  final String clientName;
  double totalRevenue = 0;
  int invoiceCount = 0;

  _ClientData(this.clientId, this.clientName);
}
