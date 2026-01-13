import '../../domain/models/financial_summary.dart';
import '../../domain/models/recent_activity.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
import '../data_sources/dashboard_remote_data_source.dart';

/// Implementation of IDashboardRepository
class DashboardRepositoryImpl implements IDashboardRepository {
  final DashboardRemoteDataSource _dataSource;

  DashboardRepositoryImpl(this._dataSource);

  @override
  Future<FinancialSummary> getFinancialSummary() {
    return _dataSource.getFinancialSummary();
  }

  @override
  Stream<FinancialSummary> watchFinancialSummary() {
    return _dataSource.watchFinancialSummary();
  }

  @override
  Future<List<RecentActivity>> getRecentActivity({int limit = 5}) {
    return _dataSource.getRecentActivity(limit: limit);
  }

  @override
  Stream<List<RecentActivity>> watchRecentActivity({int limit = 5}) {
    return _dataSource.watchRecentActivity(limit: limit);
  }
}
