/// Clients feature barrel file
library clients;

// Domain
export 'domain/models/client.dart';
export 'domain/repositories/i_client_repository.dart';

// Data
export 'data/dto/client_dto.dart';
export 'data/data_sources/client_remote_data_source.dart';
export 'data/repositories/client_repository_impl.dart';

// Application
export 'application/providers/client_providers.dart';

// Presentation
export 'presentation/pages/client_list_page.dart';
export 'presentation/widgets/client_list_tile.dart';
export 'presentation/widgets/client_search_bar.dart';
