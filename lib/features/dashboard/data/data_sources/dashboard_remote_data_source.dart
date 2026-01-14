import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/models/financial_summary.dart';
import '../../domain/models/recent_activity.dart';

/// Remote data source for dashboard data
abstract class DashboardRemoteDataSource {
  Future<FinancialSummary> getFinancialSummary();
  Stream<FinancialSummary> watchFinancialSummary();
  Future<List<RecentActivity>> getRecentActivity({int limit = 5});
  Stream<List<RecentActivity>> watchRecentActivity({int limit = 5});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  DashboardRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String get _userId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated',
          code: 'not-authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _invoicesCollection =>
      _firestore.collection('users').doc(_userId).collection('invoices');

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('users').doc(_userId).collection('expenses');

  /// Get date boundaries dynamically
  ({DateTime startOfYear, DateTime startOfMonth}) _getDateBoundaries() {
    final now = DateTime.now();
    return (
      startOfYear: DateTime(now.year, 1, 1),
      startOfMonth: DateTime(now.year, now.month, 1),
    );
  }

  @override
  Future<FinancialSummary> getFinancialSummary() async {
    try {
      final dates = _getDateBoundaries();
      final startOfYearTimestamp = Timestamp.fromDate(dates.startOfYear);

      // Fetch only current year data to reduce costs
      // For invoices: get pending/overdue (any date) + paid this year
      // For expenses: get only this year
      final results = await Future.wait([
        // Get paid invoices from this year
        _invoicesCollection
            .where('status', isEqualTo: 'paid')
            .where('paidDate', isGreaterThanOrEqualTo: startOfYearTimestamp)
            .get(),
        // Get pending invoices (sent/viewed status)
        _invoicesCollection.where('status', whereIn: ['sent', 'viewed']).get(),
        // Get overdue invoices
        _invoicesCollection.where('status', isEqualTo: 'overdue').get(),
        // Get expenses from this year
        _expensesCollection
            .where('date', isGreaterThanOrEqualTo: startOfYearTimestamp)
            .get(),
      ]);

      return _calculateSummary(
        paidInvoices: results[0].docs,
        pendingInvoices: results[1].docs,
        overdueInvoices: results[2].docs,
        expenses: results[3].docs,
        startOfMonth: dates.startOfMonth,
        startOfYear: dates.startOfYear,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unable to load financial data. Please check your connection.',
        code: 'firestore-read-error',
      );
    }
  }

  @override
  Stream<FinancialSummary> watchFinancialSummary() {
    final dates = _getDateBoundaries();
    final startOfYearTimestamp = Timestamp.fromDate(dates.startOfYear);

    // Create streams for each query
    final paidInvoicesStream = _invoicesCollection
        .where('status', isEqualTo: 'paid')
        .where('paidDate', isGreaterThanOrEqualTo: startOfYearTimestamp)
        .snapshots();

    final pendingInvoicesStream = _invoicesCollection
        .where('status', whereIn: ['sent', 'viewed']).snapshots();

    final overdueInvoicesStream =
        _invoicesCollection.where('status', isEqualTo: 'overdue').snapshots();

    final expensesStream = _expensesCollection
        .where('date', isGreaterThanOrEqualTo: startOfYearTimestamp)
        .snapshots();

    // Combine all streams using rxdart
    return Rx.combineLatest4(
      paidInvoicesStream,
      pendingInvoicesStream,
      overdueInvoicesStream,
      expensesStream,
      (paidSnapshot, pendingSnapshot, overdueSnapshot, expenseSnapshot) {
        // Recalculate date boundaries on each emission for accuracy
        final currentDates = _getDateBoundaries();
        return _calculateSummary(
          paidInvoices: paidSnapshot.docs,
          pendingInvoices: pendingSnapshot.docs,
          overdueInvoices: overdueSnapshot.docs,
          expenses: expenseSnapshot.docs,
          startOfMonth: currentDates.startOfMonth,
          startOfYear: currentDates.startOfYear,
        );
      },
    );
  }

  FinancialSummary _calculateSummary({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> paidInvoices,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> pendingInvoices,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> overdueInvoices,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
    required DateTime startOfMonth,
    required DateTime startOfYear,
  }) {
    var incomeThisMonth = 0.0;
    var incomeYTD = 0.0;

    // Process paid invoices
    for (final doc in paidInvoices) {
      final data = doc.data();
      final total = (data['total'] as num?)?.toDouble() ?? 0;
      final paidDateData = data['paidDate'];

      if (paidDateData != null) {
        final paidDate = (paidDateData as Timestamp).toDate();
        // Use !isBefore to include boundary dates (Jan 1, 1st of month)
        if (!paidDate.isBefore(startOfYear)) {
          incomeYTD += total;
          if (!paidDate.isBefore(startOfMonth)) {
            incomeThisMonth += total;
          }
        }
      }
    }

    // Calculate pending totals
    var pendingCount = pendingInvoices.length;
    var pendingAmount = 0.0;
    for (final doc in pendingInvoices) {
      final data = doc.data();
      pendingAmount += (data['total'] as num?)?.toDouble() ?? 0;
    }

    // Calculate overdue totals
    var overdueCount = overdueInvoices.length;
    var overdueAmount = 0.0;
    for (final doc in overdueInvoices) {
      final data = doc.data();
      overdueAmount += (data['total'] as num?)?.toDouble() ?? 0;
    }

    // Process expenses
    var expensesThisMonth = 0.0;
    var expensesYTD = 0.0;

    for (final doc in expenses) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final dateData = data['date'];

      if (dateData != null) {
        final date = (dateData as Timestamp).toDate();
        // Use !isBefore to include boundary dates
        if (!date.isBefore(startOfYear)) {
          expensesYTD += amount;
          if (!date.isBefore(startOfMonth)) {
            expensesThisMonth += amount;
          }
        }
      }
    }

    return FinancialSummary(
      incomeThisMonth: incomeThisMonth,
      incomeYTD: incomeYTD,
      expensesThisMonth: expensesThisMonth,
      expensesYTD: expensesYTD,
      pendingInvoices: pendingCount,
      pendingAmount: pendingAmount,
      overdueInvoices: overdueCount,
      overdueAmount: overdueAmount,
    );
  }

  @override
  Future<List<RecentActivity>> getRecentActivity({int limit = 5}) async {
    try {
      final activities = <RecentActivity>[];

      // Get recent invoices and expenses in parallel
      final results = await Future.wait([
        _invoicesCollection
            .orderBy('updatedAt', descending: true)
            .limit(limit)
            .get(),
        _expensesCollection
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get(),
      ]);

      // Convert invoices to activities
      for (final doc in results[0].docs) {
        final activity = _invoiceToActivity(doc.id, doc.data());
        if (activity != null) {
          activities.add(activity);
        }
      }

      // Convert expenses to activities
      for (final doc in results[1].docs) {
        final activity = _expenseToActivity(doc.id, doc.data());
        if (activity != null) {
          activities.add(activity);
        }
      }

      // Sort by timestamp and take top N
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(limit).toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unable to load recent activity. Please check your connection.',
        code: 'firestore-read-error',
      );
    }
  }

  @override
  Stream<List<RecentActivity>> watchRecentActivity({int limit = 5}) {
    final invoicesStream = _invoicesCollection
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots();

    final expensesStream = _expensesCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();

    // Combine both streams for real-time updates from either source
    return Rx.combineLatest2(
      invoicesStream,
      expensesStream,
      (invoiceSnapshot, expenseSnapshot) {
        final activities = <RecentActivity>[];

        for (final doc in invoiceSnapshot.docs) {
          final activity = _invoiceToActivity(doc.id, doc.data());
          if (activity != null) {
            activities.add(activity);
          }
        }

        for (final doc in expenseSnapshot.docs) {
          final activity = _expenseToActivity(doc.id, doc.data());
          if (activity != null) {
            activities.add(activity);
          }
        }

        activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return activities.take(limit).toList();
      },
    );
  }

  RecentActivity? _invoiceToActivity(String id, Map<String, dynamic> data) {
    final status = data['status'] as String?;
    final clientName = data['clientName'] as String? ?? 'Unknown';
    final total = (data['total'] as num?)?.toDouble() ?? 0;
    final updatedAtData = data['updatedAt'];

    if (updatedAtData == null) return null;

    final timestamp = (updatedAtData as Timestamp).toDate();
    final (type, title) = switch (status) {
      'draft' => (
          ActivityType.invoiceCreated,
          'Invoice created for $clientName'
        ),
      'sent' => (ActivityType.invoiceSent, 'Invoice sent to $clientName'),
      'paid' => (ActivityType.invoicePaid, 'Payment received from $clientName'),
      'overdue' => (
          ActivityType.invoiceOverdue,
          'Invoice overdue for $clientName'
        ),
      _ => (ActivityType.invoiceCreated, 'Invoice updated for $clientName'),
    };

    return RecentActivity(
      id: 'invoice_$id',
      type: type,
      title: title,
      amount: total,
      timestamp: timestamp,
      relatedId: id,
    );
  }

  RecentActivity? _expenseToActivity(String id, Map<String, dynamic> data) {
    final description = data['description'] as String? ?? 'Expense';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final createdAtData = data['createdAt'];

    if (createdAtData == null) return null;

    final timestamp = (createdAtData as Timestamp).toDate();

    return RecentActivity(
      id: 'expense_$id',
      type: ActivityType.expenseAdded,
      title: description,
      subtitle: data['category'] as String?,
      amount: amount,
      timestamp: timestamp,
      relatedId: id,
    );
  }
}
