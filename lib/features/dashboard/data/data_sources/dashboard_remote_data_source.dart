import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      throw const AuthException('User not authenticated', code: 'not-authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _invoicesCollection =>
      _firestore.collection('users').doc(_userId).collection('invoices');

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('users').doc(_userId).collection('expenses');

  @override
  Future<FinancialSummary> getFinancialSummary() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);

      // Get all invoices and expenses in parallel
      final results = await Future.wait([
        _invoicesCollection.get(),
        _expensesCollection.get(),
      ]);

      final invoices = results[0].docs;
      final expenses = results[1].docs;

      return _calculateSummary(
        invoices: invoices,
        expenses: expenses,
        startOfMonth: startOfMonth,
        startOfYear: startOfYear,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('Failed to get financial summary: $e', code: 'firestore-read-error');
    }
  }

  @override
  Stream<FinancialSummary> watchFinancialSummary() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    // Combine streams from invoices and expenses
    return _invoicesCollection.snapshots().asyncMap((invoiceSnapshot) async {
      final expenseSnapshot = await _expensesCollection.get();
      return _calculateSummary(
        invoices: invoiceSnapshot.docs,
        expenses: expenseSnapshot.docs,
        startOfMonth: startOfMonth,
        startOfYear: startOfYear,
      );
    });
  }

  FinancialSummary _calculateSummary({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> invoices,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> expenses,
    required DateTime startOfMonth,
    required DateTime startOfYear,
  }) {
    double incomeThisMonth = 0;
    double incomeYTD = 0;
    int pendingInvoices = 0;
    double pendingAmount = 0;
    int overdueInvoices = 0;
    double overdueAmount = 0;

    for (final doc in invoices) {
      final data = doc.data();
      final status = data['status'] as String?;
      final total = (data['total'] as num?)?.toDouble() ?? 0;
      final paidDateData = data['paidDate'];

      if (status == 'paid' && paidDateData != null) {
        final paidDate = (paidDateData as Timestamp).toDate();
        if (paidDate.isAfter(startOfYear)) {
          incomeYTD += total;
          if (paidDate.isAfter(startOfMonth)) {
            incomeThisMonth += total;
          }
        }
      } else if (status == 'sent' || status == 'viewed') {
        pendingInvoices++;
        pendingAmount += total;
      } else if (status == 'overdue') {
        overdueInvoices++;
        overdueAmount += total;
      }
    }

    double expensesThisMonth = 0;
    double expensesYTD = 0;

    for (final doc in expenses) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final dateData = data['date'];

      if (dateData != null) {
        final date = (dateData as Timestamp).toDate();
        if (date.isAfter(startOfYear)) {
          expensesYTD += amount;
          if (date.isAfter(startOfMonth)) {
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
      pendingInvoices: pendingInvoices,
      pendingAmount: pendingAmount,
      overdueInvoices: overdueInvoices,
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
        final data = doc.data();
        final activity = _invoiceToActivity(doc.id, data);
        if (activity != null) {
          activities.add(activity);
        }
      }

      // Convert expenses to activities
      for (final doc in results[1].docs) {
        final data = doc.data();
        final activity = _expenseToActivity(doc.id, data);
        if (activity != null) {
          activities.add(activity);
        }
      }

      // Sort by timestamp and take top N
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(limit).toList();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('Failed to get recent activity: $e', code: 'firestore-read-error');
    }
  }

  @override
  Stream<List<RecentActivity>> watchRecentActivity({int limit = 5}) {
    return _invoicesCollection
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((invoiceSnapshot) async {
      final activities = <RecentActivity>[];

      // Convert invoices to activities
      for (final doc in invoiceSnapshot.docs) {
        final data = doc.data();
        final activity = _invoiceToActivity(doc.id, data);
        if (activity != null) {
          activities.add(activity);
        }
      }

      // Get recent expenses
      final expenseSnapshot = await _expensesCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      for (final doc in expenseSnapshot.docs) {
        final data = doc.data();
        final activity = _expenseToActivity(doc.id, data);
        if (activity != null) {
          activities.add(activity);
        }
      }

      // Sort by timestamp and take top N
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(limit).toList();
    });
  }

  RecentActivity? _invoiceToActivity(String id, Map<String, dynamic> data) {
    final status = data['status'] as String?;
    final clientName = data['clientName'] as String? ?? 'Unknown';
    final total = (data['total'] as num?)?.toDouble() ?? 0;
    final updatedAtData = data['updatedAt'];

    if (updatedAtData == null) return null;

    final timestamp = (updatedAtData as Timestamp).toDate();
    ActivityType type;
    String title;

    switch (status) {
      case 'draft':
        type = ActivityType.invoiceCreated;
        title = 'Invoice created for $clientName';
        break;
      case 'sent':
        type = ActivityType.invoiceSent;
        title = 'Invoice sent to $clientName';
        break;
      case 'paid':
        type = ActivityType.invoicePaid;
        title = 'Payment received from $clientName';
        break;
      case 'overdue':
        type = ActivityType.invoiceOverdue;
        title = 'Invoice overdue for $clientName';
        break;
      default:
        type = ActivityType.invoiceCreated;
        title = 'Invoice updated for $clientName';
    }

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
