/// Wedding of the Week page.
///
/// Displays the latest wedding article with video and content blocks.
/// Uses CustomScrollView with SliverAppBar for a modern scrolling experience.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/wed_article.dart';
import '../../domain/entities/wed_content_block.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/content_block_widget.dart';

/// The wedding of the week page.
///
/// Displays a featured wedding article with:
/// - SliverAppBar with cover image
/// - Featured video (if available)
/// - Title and subtitle
/// - Content blocks (text, images, quotes)
class WeddingOfTheWeekPage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'wedding-of-the-week';

  /// Route path for navigation.
  static const String routePath = '/wedding-of-the-week';

  /// Creates the wedding of the week page.
  const WeddingOfTheWeekPage({super.key});

  @override
  State<WeddingOfTheWeekPage> createState() => _WeddingOfTheWeekPageState();
}

class _WeddingOfTheWeekPageState extends State<WeddingOfTheWeekPage> {
  bool _isLoading = true;
  WedArticle? _article;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    // Simulated loading - in a real app, this would fetch from repository
    // For now, we'll show loading state then display placeholder content
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // In production, this would come from ContentRepository
        _article = _createPlaceholderArticle();
      });
    }
  }

  WedArticle _createPlaceholderArticle() {
    return WedArticle(
      id: 'placeholder',
      title: 'Wedding of the Week',
      subtitle: 'A beautiful celebration of love',
      coverImageUrl: null,
      videoUrl: 'https://vimeo.com/example',
      videoType: VideoType.vimeo,
      publishedAt: DateTime.now(),
      status: ArticleStatus.published,
      contentBlocks: const [
        WedContentBlock(
          type: ContentBlockType.text,
          content: 'Discover this week\'s featured wedding celebration.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_isLoading)
            _buildLoadingState()
          else if (_error != null)
            _buildErrorState()
          else if (_article != null)
            ..._buildContent()
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: _article?.hasCoverImage == true ? 250.0 : 0,
      pinned: true,
      backgroundColor: LynewedColors.background,
      foregroundColor: LynewedColors.textPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: _article?.hasCoverImage == true
          ? FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: LynewedColors.gray200,
                  image: _article!.coverImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_article!.coverImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(
          color: LynewedColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48.0,
                color: LynewedColors.error,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Failed to load article',
                style: LynewedTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                _error ?? 'An unknown error occurred',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              LynewedButton(
                text: 'Retry',
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadArticle();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.article_outlined,
                size: 48.0,
                color: LynewedColors.gray300,
              ),
              const SizedBox(height: 16.0),
              Text(
                'No article available',
                style: LynewedTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Check back later for the latest wedding of the week.',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      // Title section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _article!.title,
                style: LynewedTextStyles.headlineLarge,
              ),
              if (_article!.hasSubtitle) ...[
                const SizedBox(height: 8.0),
                Text(
                  _article!.subtitle!,
                  style: LynewedTextStyles.titleMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // Featured video
      if (_article!.hasVideo)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: VideoPlayerWidget(
              videoUrl: _article!.videoUrl!,
              videoType: _article!.videoType ?? VideoType.direct,
              onTap: () {
                // TODO: Open video player
              },
            ),
          ),
        ),

      // Content blocks
      SliverPadding(
        padding: const EdgeInsets.all(16.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ContentBlockWidget(
                block: _article!.contentBlocks[index],
              );
            },
            childCount: _article!.contentBlocks.length,
          ),
        ),
      ),

      // Bottom padding
      const SliverToBoxAdapter(
        child: SizedBox(height: 32.0),
      ),
    ];
  }
}
