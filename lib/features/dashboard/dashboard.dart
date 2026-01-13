/// Dashboard feature barrel file
library dashboard;

// Application
export 'application/providers/dashboard_providers.dart';

// Data
export 'data/data_sources/dashboard_remote_data_source.dart';
export 'data/repositories/dashboard_repository_impl.dart';

// Domain
export 'domain/models/financial_summary.dart';
export 'domain/models/recent_activity.dart';
export 'domain/repositories/i_dashboard_repository.dart';

// Presentation
export 'presentation/pages/dashboard_page.dart';
export 'presentation/widgets/financial_summary_card.dart';
