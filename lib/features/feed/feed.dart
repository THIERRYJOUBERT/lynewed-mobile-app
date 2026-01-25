/// Feed Feature - Professional portfolio browsing for brides
///
/// This module provides:
/// - Feed of professional portfolios
/// - Profession-based filtering
/// - Favorites functionality
/// - Professional detail view
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/features/feed/feed.dart';
/// ```
library;

// Domain - Entities
export 'domain/entities/feed_filter.dart';
export 'domain/entities/feed_professional.dart';
export 'domain/entities/portfolio_item.dart';

// Domain - Repositories
export 'domain/repositories/feed_repository.dart';

// Data - Repositories
export 'data/repositories/feed_repository_impl.dart';

// Presentation - Bloc
export 'presentation/bloc/feed_cubit.dart';
export 'presentation/bloc/feed_state.dart';

// Presentation - Widgets
export 'presentation/widgets/portfolio_card.dart';
export 'presentation/widgets/portfolio_grid.dart';
export 'presentation/widgets/profession_filter_chips.dart';

// Presentation - Pages
export 'presentation/pages/feed_detail_page.dart';
export 'presentation/pages/feed_page.dart';
