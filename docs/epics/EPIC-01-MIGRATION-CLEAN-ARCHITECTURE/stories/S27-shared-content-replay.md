# Story S27: Shared - Content/Replay Pages

## Description

En tant que developpeur, je veux migrer les pages Content et Replay vers Clean Architecture afin d'avoir une gestion coherente du contenu video/replay.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `ContentReplayWidget` When je la migre Then elle utilise un module content dedie

- [ ] Given `ReplayPlayerPageWidget` When je la migre Then elle utilise le meme module

- [ ] Given `WeddingOfTheWeekWidget` When je la migre Then elle affiche le contenu correctement

- [ ] Given les videos When je les lis Then le player fonctionne correctement

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/shared/content_replay/content_replay_widget.dart`
- `lib/pages/shared/content_replay/content_replay_model.dart`
- `lib/pages/shared/replay_player_page/replay_player_page_widget.dart`
- `lib/pages/shared/replay_player_page/replay_player_page_model.dart`
- `lib/pages/shared/wedding_of_the_week/wedding_of_the_week_widget.dart`
- `lib/pages/shared/wedding_of_the_week/wotw_history_sheet.dart`
- `lib/pages/shared/wow_viewer_carrousel/`
- `lib/pages/shared/wow_simple_viewer/`

### Widgets Custom Code
- `lib/custom_code/widgets/vimeo_player_widget.dart`
- `lib/custom_code/widgets/youtube_player_widget.dart`
- `lib/custom_code/widgets/youtube_player_with_controls.dart`
- `lib/custom_code/widgets/videoplayer_filmmaker.dart`

### Actions Custom Code
- `lib/custom_code/actions/fetch_replays_bundle.dart`
- `lib/custom_code/actions/get_latest_wed_article.dart`
- `lib/custom_code/actions/get_all_wed_articles.dart`
- `lib/custom_code/actions/get_wed_article_by_id.dart`

### A Creer
- `lib/features/content/content.dart` - Barrel
- `lib/features/content/domain/entities/wed_article.dart`
- `lib/features/content/domain/entities/replay.dart`
- `lib/features/content/presentation/pages/content_page.dart`
- `lib/features/content/presentation/pages/replay_player_page.dart`
- `lib/features/content/presentation/pages/wedding_of_the_week_page.dart`

## Notes Techniques

### Structure Module Content
```
lib/features/content/
├── content.dart                   # Barrel
├── domain/
│   ├── entities/
│   │   ├── wed_article.dart
│   │   └── replay.dart
│   └── repositories/
│       └── content_repository.dart
├── data/
│   └── repositories/
│       └── content_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── content_page.dart
    │   ├── replay_player_page.dart
    │   └── wedding_of_the_week_page.dart
    └── widgets/
        ├── video_player_widget.dart
        └── article_renderer.dart
```

### Wed Article Entity
```dart
class WedArticle {
  final String id;
  final String title;
  final String? subtitle;
  final String? coverImageUrl;
  final String? videoUrl;
  final String? videoType; // 'vimeo', 'youtube'
  final List<WedContentBlock> contentBlocks;
  final DateTime publishedAt;
  final String status;

  const WedArticle({
    required this.id,
    required this.title,
    this.subtitle,
    this.coverImageUrl,
    this.videoUrl,
    this.videoType,
    this.contentBlocks = const [],
    required this.publishedAt,
    required this.status,
  });
}

class WedContentBlock {
  final String type; // 'text', 'image', 'video', 'quote'
  final String? content;
  final String? imageUrl;
  final String? videoUrl;

  const WedContentBlock({
    required this.type,
    this.content,
    this.imageUrl,
    this.videoUrl,
  });
}
```

### Replay Entity
```dart
class Replay {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String videoUrl;
  final String videoType;
  final Duration? duration;
  final DateTime createdAt;
  final List<ReplayGuest>? guests;

  const Replay({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.videoUrl,
    required this.videoType,
    this.duration,
    required this.createdAt,
    this.guests,
  });
}
```

### Video Player Widget
```dart
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String videoType; // 'vimeo', 'youtube', 'direct'
  final bool autoPlay;
  final bool showControls;

  const VideoPlayerWidget({
    required this.videoUrl,
    required this.videoType,
    this.autoPlay = false,
    this.showControls = true,
    super.key,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.videoType.toLowerCase()) {
      case 'youtube':
        return _buildYouTubePlayer();
      case 'vimeo':
        return _buildVimeoPlayer();
      default:
        return _buildDirectPlayer();
    }
  }

  Widget _buildYouTubePlayer() {
    final videoId = _extractYouTubeId(widget.videoUrl);
    return YoutubePlayer(
      controller: YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          hideControls: !widget.showControls,
        ),
      ),
    );
  }

  Widget _buildVimeoPlayer() {
    return VimeoPlayerWidget(
      videoId: _extractVimeoId(widget.videoUrl),
      autoPlay: widget.autoPlay,
    );
  }

  Widget _buildDirectPlayer() {
    return VideoPlayer(
      dataSource: widget.videoUrl,
      autoPlay: widget.autoPlay,
    );
  }
}
```

### Wedding of the Week Page
```dart
class WeddingOfTheWeekPage extends StatefulWidget {
  const WeddingOfTheWeekPage({super.key});

  @override
  State<WeddingOfTheWeekPage> createState() => _WeddingOfTheWeekPageState();
}

class _WeddingOfTheWeekPageState extends State<WeddingOfTheWeekPage> {
  WedArticle? _article;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestArticle();
  }

  Future<void> _loadLatestArticle() async {
    final repo = getIt<ContentRepository>();
    final result = await repo.getLatestWedArticle();
    result.when(
      success: (article) {
        setState(() {
          _article = article;
          _isLoading = false;
        });
      },
      failure: (error) {
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_article == null) {
      return const Scaffold(
        body: Center(child: Text('No content available')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cover
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _article!.videoUrl != null
                  ? VideoPlayerWidget(
                      videoUrl: _article!.videoUrl!,
                      videoType: _article!.videoType ?? 'direct',
                      autoPlay: true,
                    )
                  : Image.network(
                      _article!.coverImageUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _article!.title,
                    style: context.textTheme.headlineSmall,
                  ),
                  if (_article!.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _article!.subtitle!,
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Render content blocks
                  ..._article!.contentBlocks.map(_buildContentBlock),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBlock(WedContentBlock block) {
    switch (block.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(block.content ?? ''),
        );
      case 'image':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Image.network(block.imageUrl!),
        );
      case 'video':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VideoPlayerWidget(
            videoUrl: block.videoUrl!,
            videoType: 'direct',
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
```

## Definition of Done

- [ ] Module content cree
- [ ] Entities (WedArticle, Replay)
- [ ] Repository implemente
- [ ] Pages migrees
- [ ] VideoPlayerWidget unifie (YouTube, Vimeo, direct)
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (players video)

## Dependances

- S03 : Design system
- S04 : Navigation

## Stories Dependantes

- Aucune
