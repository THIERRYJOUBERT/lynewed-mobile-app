/// Content feature module.
///
/// Provides content functionality including:
/// - Wedding of the Week articles
/// - Replay video player
/// - Content blocks (text, image, video, quote)
library;

// Domain layer - Entities
export 'domain/entities/wed_article.dart';
export 'domain/entities/wed_content_block.dart';
export 'domain/entities/replay.dart';

// Domain layer - Repositories
export 'domain/repositories/content_repository.dart';

// Data layer
export 'data/repositories/content_repository_impl.dart';

// Presentation layer - Widgets
export 'presentation/widgets/video_player_widget.dart';
export 'presentation/widgets/content_block_widget.dart';

// Presentation layer - Pages
export 'presentation/pages/content_page.dart';
export 'presentation/pages/wedding_of_the_week_page.dart';
export 'presentation/pages/replay_player_page.dart';
