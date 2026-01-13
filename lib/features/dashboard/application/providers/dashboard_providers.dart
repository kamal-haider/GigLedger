import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/models/financial_summary.dart';
import '../../domain/models/recent_activity.dart';
import '../../domain/repositories/i_dashboard_repository.dart';

/// Provider for dashboard data source
final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSourceImpl();
});

/// Provider for dashboard repository
final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  final dataSource = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(dataSource);
});

/// Stream provider for financial summary (real-time updates)
/// Uses autoDispose to prevent wasted Firestore reads when not in use
final financialSummaryStreamProvider = StreamProvider.autoDispose<FinancialSummary>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.watchFinancialSummary();
});

/// Future provider for financial summary (one-time fetch)
final financialSummaryProvider = FutureProvider<FinancialSummary>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getFinancialSummary();
});

/// Stream provider for recent activity (real-time updates)
final recentActivityStreamProvider = StreamProvider.autoDispose<List<RecentActivity>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.watchRecentActivity(limit: 5);
});

/// Future provider for recent activity (one-time fetch)
final recentActivityProvider = FutureProvider<List<RecentActivity>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRecentActivity(limit: 5);
});
