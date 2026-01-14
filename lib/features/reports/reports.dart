/// Reports feature barrel file
library reports;

// Domain
export 'domain/models/income_report.dart';
export 'domain/repositories/i_reports_repository.dart';

// Data
export 'data/repositories/reports_repository_impl.dart';

// Application
export 'application/providers/reports_providers.dart';

// Presentation
export 'presentation/pages/income_expense_report_page.dart';
export 'presentation/pages/top_clients_report_page.dart';
