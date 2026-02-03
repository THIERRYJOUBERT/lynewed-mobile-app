# Story S07: UI Bride vue albums guests

> **Revision 2026-02-03**: Cette story REMPLACE l'ancienne S07 (toggle shared_with_bride) qui a ete supprimee. La bride voit AUTOMATIQUEMENT tous les albums guests de son mariage.

## Description
En tant que **bride**, je veux **voir tous les albums des guests de mon mariage**, afin de **decouvrir les photos et videos prises par mes invites le jour du mariage**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Bride views guest albums

  Background:
    Given I am logged in as a bride
    And my wedding has ID "wedding-456"

  Scenario: Viewing list of guest albums
    Given guest "Alice" has an album with 5 photos and 2 videos
    And guest "Bob" has an album with 3 photos
    When I navigate to the "Guest Albums" section
    Then I should see 2 albums in the list
    And Alice's album should show "5 photos, 2 videos"
    And Bob's album should show "3 photos"
    And each album should show the guest's name and avatar
    And each album should show a thumbnail of the first media

  Scenario: Empty state when no guest albums exist
    Given no guests have uploaded any media
    When I navigate to the "Guest Albums" section
    Then I should see an empty state
    And the message should say "No guest albums yet"
    And a subtitle should say "Photos and videos from your guests will appear here"

  Scenario: Opening a guest album to view media grid
    Given guest "Alice" has an album with 5 photos
    When I tap on Alice's album card
    Then I should see a grid of 5 photos
    And the page header should show "Alice's Album"
    And the header should show "5 media"

  Scenario: Viewing guest's video inline
    Given guest "Alice" has an album with 1 video
    When I open Alice's album
    And I tap on the video thumbnail
    Then the video should play inline
    And playback controls should be visible
```

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/presentation/pages/guest_albums_page.dart` - Liste des albums guests
- `lib/features/my_wedding/presentation/widgets/guest_album_card.dart` - Card pour un album guest
- `lib/features/my_wedding/domain/usecases/get_guest_albums_use_case.dart` - Use case pour recuperer les albums
- `lib/features/my_wedding/domain/entities/guest_album.dart` - Entity GuestAlbum
- `lib/features/my_wedding/data/models/guest_album_model.dart` - Model avec fromJson
- `test/features/my_wedding/presentation/pages/guest_albums_page_test.dart`
- `test/features/my_wedding/presentation/widgets/guest_album_card_test.dart`
- `test/features/my_wedding/domain/usecases/get_guest_albums_use_case_test.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` - Ajouter navigation vers Guest Albums
- `lib/features/my_wedding/domain/repositories/my_wedding_repository.dart` - Interface pour getGuestAlbums
- `lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart` - Implementation getGuestAlbums

## Notes Techniques

### GuestAlbum Entity
```dart
// lib/features/my_wedding/domain/entities/guest_album.dart
import 'package:equatable/equatable.dart';

/// Represents a guest's album for the bride's view.
///
/// Each guest has exactly one album per wedding.
/// The bride sees ALL albums automatically (no opt-in).
class GuestAlbum extends Equatable {
  final String id;
  final String weddingId;
  final String guestUserId;
  final String guestName;
  final String? guestAvatarUrl;
  final int photoCount;
  final int videoCount;
  final String? thumbnailUrl; // First media thumbnail
  final DateTime createdAt;

  const GuestAlbum({
    required this.id,
    required this.weddingId,
    required this.guestUserId,
    required this.guestName,
    this.guestAvatarUrl,
    required this.photoCount,
    required this.videoCount,
    this.thumbnailUrl,
    required this.createdAt,
  });

  int get totalMediaCount => photoCount + videoCount;

  bool get isEmpty => totalMediaCount == 0;

  @override
  List<Object?> get props => [
    id,
    weddingId,
    guestUserId,
    photoCount,
    videoCount,
  ];
}
```

### GuestAlbumModel
```dart
// lib/features/my_wedding/data/models/guest_album_model.dart
import '../../domain/entities/guest_album.dart';

class GuestAlbumModel extends GuestAlbum {
  const GuestAlbumModel({
    required super.id,
    required super.weddingId,
    required super.guestUserId,
    required super.guestName,
    super.guestAvatarUrl,
    required super.photoCount,
    required super.videoCount,
    super.thumbnailUrl,
    required super.createdAt,
  });

  factory GuestAlbumModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return GuestAlbumModel(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      guestUserId: json['guest_user_id'] as String,
      guestName: _buildGuestName(profile),
      guestAvatarUrl: profile?['avatar_url'] as String?,
      photoCount: json['photo_count'] as int? ?? 0,
      videoCount: json['video_count'] as int? ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static String _buildGuestName(Map<String, dynamic>? profile) {
    if (profile == null) return 'Guest';
    final firstName = profile['first_name'] as String? ?? '';
    final lastName = profile['last_name'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'Guest' : fullName;
  }
}
```

### GetGuestAlbumsUseCase
```dart
// lib/features/my_wedding/domain/usecases/get_guest_albums_use_case.dart
import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '../entities/guest_album.dart';
import '../repositories/my_wedding_repository.dart';

/// Use case to get all guest albums for a wedding.
///
/// RLS ensures the bride only sees albums from her own wedding.
/// No opt-in filter - bride sees ALL albums automatically.
class GetGuestAlbumsUseCase {
  final MyWeddingRepository repository;

  const GetGuestAlbumsUseCase(this.repository);

  /// Gets all guest albums for the given wedding.
  ///
  /// Returns albums ordered by most recent first.
  /// Empty albums (0 media) are included in the list.
  Future<Either<Failure, List<GuestAlbum>>> call({
    required String weddingId,
  }) {
    return repository.getGuestAlbums(weddingId: weddingId);
  }
}
```

### Repository Interface Addition
```dart
// Add to lib/features/my_wedding/domain/repositories/my_wedding_repository.dart

/// Gets all guest albums for a wedding.
///
/// Returns albums with photo/video counts and first thumbnail.
/// RLS ensures only the bride of this wedding can access.
Future<Either<Failure, List<GuestAlbum>>> getGuestAlbums({
  required String weddingId,
});

/// Gets all media for a specific guest album.
///
/// Returns media ordered by creation date (newest first).
Future<Either<Failure, List<GuestMedia>>> getGuestAlbumMedia({
  required String albumId,
});
```

### Repository Implementation Query
```dart
// Add to lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart

@override
Future<Either<Failure, List<GuestAlbum>>> getGuestAlbums({
  required String weddingId,
}) async {
  try {
    // Query guest_albums with joined profile and media counts
    final response = await _supabase
        .from('guest_albums')
        .select('''
          id,
          wedding_id,
          guest_user_id,
          created_at,
          profiles!guest_albums_guest_user_id_fkey (
            first_name,
            last_name,
            avatar_url
          ),
          guest_media (
            id,
            media_type,
            thumbnail_path
          )
        ''')
        .eq('wedding_id', weddingId)
        .order('created_at', ascending: false);

    final albums = (response as List).map((json) {
      final mediaList = json['guest_media'] as List? ?? [];
      final photoCount = mediaList.where((m) => m['media_type'] == 'photo').length;
      final videoCount = mediaList.where((m) => m['media_type'] == 'video').length;
      final firstMedia = mediaList.isNotEmpty ? mediaList.first : null;

      return GuestAlbumModel.fromJson({
        ...json,
        'photo_count': photoCount,
        'video_count': videoCount,
        'thumbnail_url': firstMedia?['thumbnail_path'],
      });
    }).toList();

    return Right(albums);
  } catch (e) {
    return Left(ServerFailure(message: 'Failed to load guest albums: $e'));
  }
}
```

### GuestAlbumsPage (reference: MessagesPage style)
```dart
// lib/features/my_wedding/presentation/pages/guest_albums_page.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '/core/design/design.dart';
import '../../domain/entities/guest_album.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../widgets/guest_album_card.dart';

/// Page displaying all guest albums for the bride.
///
/// Shows a list of guest albums with avatar, name, media count, and thumbnail.
/// Style reference: messages_page.dart (list layout)
class GuestAlbumsPage extends StatefulWidget {
  const GuestAlbumsPage({
    super.key,
    required this.weddingId,
  });

  final String weddingId;

  static const String routeName = 'GuestAlbums';
  static const String routePath = '/guest-albums';

  @override
  State<GuestAlbumsPage> createState() => _GuestAlbumsPageState();
}

class _GuestAlbumsPageState extends State<GuestAlbumsPage> {
  bool _isLoading = true;
  String? _error;
  List<GuestAlbum> _albums = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAlbums();
    });
  }

  Future<void> _loadAlbums() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = MyWeddingRepositoryImpl();
    final result = await repository.getGuestAlbums(weddingId: widget.weddingId);

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (albums) => setState(() {
        _albums = albums;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Guest Albums',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: LynewedColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              LynewedButton(
                text: 'Retry',
                onPressed: _loadAlbums,
                type: LynewedButtonType.secondary,
              ),
            ],
          ),
        ),
      );
    }

    if (_albums.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAlbums,
      color: LynewedColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _albums.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final album = _albums[index];
          return GuestAlbumCard(
            album: album,
            onTap: () => _navigateToAlbum(album),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_album_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No guest albums yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Photos and videos from your guests will appear here',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAlbum(GuestAlbum album) {
    // Navigate to album detail page (reuse AlbumDetailPage with isReadOnly: true)
    // This will be implemented to show the guest's media in a grid
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _GuestAlbumDetailPage(album: album),
      ),
    );
  }
}

/// Detail page for viewing a specific guest's album.
///
/// Style reference: album_detail_page.dart (grid layout)
class _GuestAlbumDetailPage extends StatefulWidget {
  const _GuestAlbumDetailPage({required this.album});

  final GuestAlbum album;

  @override
  State<_GuestAlbumDetailPage> createState() => _GuestAlbumDetailPageState();
}

class _GuestAlbumDetailPageState extends State<_GuestAlbumDetailPage> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _media = []; // GuestMedia list

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadMedia();
    });
  }

  Future<void> _loadMedia() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = MyWeddingRepositoryImpl();
    final result = await repository.getGuestAlbumMedia(albumId: widget.album.id);

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (media) => setState(() {
        _media = media;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.album.guestName}'s Album",
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.album.totalMediaCount} media',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadMedia,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_media.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No media yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.album.guestName} hasn\'t uploaded any photos or videos yet',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMedia,
      color: LynewedColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _media.length,
        itemBuilder: (context, index) {
          return _buildMediaTile(_media[index]);
        },
      ),
    );
  }

  Widget _buildMediaTile(dynamic media) {
    // TODO: Implement proper media tile with video indicator
    // For now, placeholder - will use GuestMedia entity
    return Container(
      color: LynewedColors.gray200,
      child: const Center(
        child: Icon(Icons.image, color: LynewedColors.gray300),
      ),
    );
  }
}
```

### GuestAlbumCard Widget
```dart
// lib/features/my_wedding/presentation/widgets/guest_album_card.dart
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/guest_album.dart';

/// Card widget displaying a guest's album summary.
///
/// Shows guest avatar, name, media count, and optional thumbnail.
/// Style reference: conversation_tile.dart
class GuestAlbumCard extends StatelessWidget {
  const GuestAlbumCard({
    super.key,
    required this.album,
    required this.onTap,
  });

  final GuestAlbum album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LynewedColors.gray200),
        ),
        child: Row(
          children: [
            // Guest avatar
            _buildAvatar(),
            const SizedBox(width: 12),

            // Album info (name + count)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.guestName,
                    style: LynewedTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildMediaCountText(),
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Thumbnail preview
            if (album.thumbnailUrl != null) ...[
              _buildThumbnail(),
              const SizedBox(width: 8),
            ],

            // Chevron
            const Icon(
              Icons.chevron_right,
              color: LynewedColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: LynewedColors.gray200,
      backgroundImage: album.guestAvatarUrl != null
          ? CachedNetworkImageProvider(album.guestAvatarUrl!)
          : null,
      child: album.guestAvatarUrl == null
          ? Text(
              album.guestName.isNotEmpty
                  ? album.guestName[0].toUpperCase()
                  : '?',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            )
          : null,
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: album.thumbnailUrl!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 44,
          height: 44,
          color: LynewedColors.gray200,
        ),
        errorWidget: (_, __, ___) => Container(
          width: 44,
          height: 44,
          color: LynewedColors.gray200,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 20,
            color: LynewedColors.gray300,
          ),
        ),
      ),
    );
  }

  String _buildMediaCountText() {
    if (album.isEmpty) {
      return 'No media yet';
    }

    final parts = <String>[];
    if (album.photoCount > 0) {
      parts.add('${album.photoCount} photo${album.photoCount > 1 ? 's' : ''}');
    }
    if (album.videoCount > 0) {
      parts.add('${album.videoCount} video${album.videoCount > 1 ? 's' : ''}');
    }
    return parts.join(', ');
  }
}
```

## Definition of Done
- [ ] GuestAlbum entity cree avec tous les champs necessaires
- [ ] GuestAlbumModel avec fromJson fonctionnel
- [ ] GetGuestAlbumsUseCase cree et teste
- [ ] GuestAlbumsPage cree avec header/body/empty state
- [ ] GuestAlbumCard widget avec avatar, nom, count, thumbnail
- [ ] Detail page avec grille de medias (read-only)
- [ ] Empty state pour liste vide
- [ ] Empty state pour album sans media
- [ ] Navigation depuis MyWeddingPage
- [ ] Tests unitaires pour use case
- [ ] Tests widget pour GuestAlbumsPage
- [ ] Tests widget pour GuestAlbumCard
- [ ] `flutter analyze --fatal-infos` passe (0 warnings)
- [ ] `flutter test` passe

## Estimation
**Points** : 5
**Complexite** : Medium
**Risque** : Faible (UI pure, pas de logique complexe)

## Dependances
- S02 (table guest_albums doit exister)
- S03 (table guest_media doit exister)

## Stories Dependantes
- S08 (Download media - bride peut telecharger depuis albums guests)

---

## Historique des Revisions

| Date | Changement |
|------|------------|
| 2026-02-03 | **REMPLACEMENT COMPLET**: Ancienne S07 (toggle shared_with_bride) supprimee. Nouvelle S07 = UI Bride vue albums guests (ancienne S08 adaptee). Suppression de toute reference a shared_with_bride - la bride voit TOUT automatiquement. Suppression realtime subscription (pas necessaire sans toggle). Ajout GuestMedia entity reference. Points: 5. |
| 2026-01-28 | Creation initiale (toggle shared_with_bride) |
