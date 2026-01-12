import '../models/financial_summary.dart';
import '../models/recent_activity.dart';

/// Dashboard repository interface
abstract class IDashboardRepository {
  /// Get financial summary for the current user
  Future<FinancialSummary> getFinancialSummary();

  /// Watch financial summary (real-time updates)
  Stream<FinancialSummary> watchFinancialSummary();

  /// Get recent activity items
  Future<List<RecentActivity>> getRecentActivity({int limit = 5});

  /// Watch recent activity (real-time updates)
  Stream<List<RecentActivity>> watchRecentActivity({int limit = 5});
}
