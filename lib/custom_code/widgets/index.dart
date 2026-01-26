// Custom widgets barrel export.
//
// This file exports all legacy custom widgets used by FlutterFlow pages.
//
// ## Migration Status (EPIC-01 S41)
//
// ### Removed Widgets (migrated to Clean Architecture):
// - ChatMessageList -> lib/features/chat/presentation/widgets/message_list.dart
// - ChatComposerWidget -> lib/features/chat/presentation/widgets/message_composer.dart
// - AudioPlayerWidget -> lib/features/chat/presentation/widgets/audio_player_widget.dart
// - AudioRecorderWidget -> integrated in message_composer.dart
//
// ### Active Widgets (used by legacy pages):
// - LynewedMiniMap: mini map for pro profiles
// - YoutubePlayerWidget: YouTube video playback
// - VimeoPlayerWidget: Vimeo video playback
// - FeedPortfolioGrid: portfolio grid in feed
// - AgoraVideoViewWidget: Agora video call UI
// - WedArticleRenderer: wed article content rendering
// - VideoplayerFilmmaker: video player for filmmaker content
// - PortfolioGrid: portfolio display grid

export 'lynewed_mini_map.dart' show LynewedMiniMap;
export 'youtube_player_widget.dart' show YoutubePlayerWidget;
export 'vimeo_player_widget.dart' show VimeoPlayerWidget;
export 'feed_portfolio_grid.dart' show FeedPortfolioGrid;
export 'agora_video_view.dart' show AgoraVideoViewWidget;
export 'wed_article_renderer.dart' show WedArticleRenderer;
export 'videoplayer_filmmaker.dart' show VideoplayerFilmmaker;
export 'portfolio_grid.dart' show PortfolioGrid;
