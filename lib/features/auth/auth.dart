/// Auth feature barrel file
library auth;

// Domain
export 'domain/models/user_profile.dart';
export 'domain/repositories/i_auth_repository.dart';

// Data
export 'data/dto/user_profile_dto.dart';
export 'data/data_sources/auth_remote_data_source.dart';
export 'data/repositories/auth_repository_impl.dart';

// Application
export 'application/providers/auth_providers.dart';

// Presentation
export 'presentation/pages/login_page.dart';
export 'presentation/widgets/google_sign_in_button.dart';
