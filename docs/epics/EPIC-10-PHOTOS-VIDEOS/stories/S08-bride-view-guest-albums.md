# Story S08: Vue bride des albums guests partages

## Description
En tant que **bride**, je veux **voir les albums des guests qui ont choisi de partager avec moi**, afin de **decouvrir les photos et videos de mon mariage prises par mes invites**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the bride has 3 guests who shared their albums When the bride navigates to "Guest Albums" section Then 3 albums should be displayed And each album should show the guest's name And each album should show photo/video count
- [ ] Given no guests have shared their albums When the bride navigates to "Guest Albums" section Then empty state should be shown And message "No guests have shared their albums yet" should appear
- [ ] Given guest "Alice" has shared 10 photos When the bride taps on Alice's album Then a grid of 10 photos should be displayed And each photo should be tappable for full view
- [ ] Given a guest album contains a video When the bride taps on the video thumbnail Then video should play inline And playback controls should be visible
- [ ] Given guest "Bob" has NOT shared their album When the bride views guest albums list Then Bob's album should NOT appear And bride should not be able to access Bob's media
- [ ] Given bride is viewing guest albums list When guest "Charlie" enables sharing Then Charlie's album should appear in the list (realtime update via Supabase Realtime)

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/presentation/pages/guest_albums_page.dart`
- `lib/features/my_wedding/presentation/widgets/guest_album_card.dart`
- `lib/features/my_wedding/domain/usecases/get_shared_guest_albums_use_case.dart`
- `lib/features/my_wedding/domain/entities/guest_album.dart`
- `lib/features/my_wedding/data/models/guest_album_model.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` - Ajouter navigation vers Guest Albums
- `lib/features/my_wedding/data/repositories/media_repository.dart` - Ajouter queries guest albums

## Notes Techniques

### GuestAlbum Entity
```dart
// lib/features/my_wedding/domain/entities/guest_album.dart
import 'package:equatable/equatable.dart';

class GuestAlbum extends Equatable {
  final String id;
  final String weddingId;
  final String guestUserId;
  final String guestName;
  final String? guestAvatarUrl;
  final bool sharedWithBride;
  final int photoCount;
  final int videoCount;
  final DateTime createdAt;

  const GuestAlbum({
    required this.id,
    required this.weddingId,
    required this.guestUserId,
    required this.guestName,
    this.guestAvatarUrl,
    required this.sharedWithBride,
    required this.photoCount,
    required this.videoCount,
    required this.createdAt,
  });

  int get totalMediaCount => photoCount + videoCount;

  @override
  List<Object?> get props => [id, weddingId, guestUserId];
}
```

### GetSharedGuestAlbumsUseCase
```dart
// lib/features/my_wedding/domain/usecases/get_shared_guest_albums_use_case.dart
class GetSharedGuestAlbumsUseCase {
  final GuestAlbumRepository repository;

  GetSharedGuestAlbumsUseCase(this.repository);

  /// Gets all guest albums shared with the bride for her wedding
  /// RLS ensures only shared albums are returned
  Future<Either<Failure, List<GuestAlbum>>> execute({
    required String weddingId,
  }) async {
    return repository.getSharedGuestAlbums(weddingId);
  }

  /// Stream for realtime updates when guests share/unshare
  Stream<List<GuestAlbum>> watch({required String weddingId}) {
    return repository.watchSharedGuestAlbums(weddingId);
  }
}
```

### GuestAlbumsPage
```dart
// lib/features/my_wedding/presentation/pages/guest_albums_page.dart
class GuestAlbumsPage extends StatelessWidget {
  final String weddingId;

  const GuestAlbumsPage({super.key, required this.weddingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guest Albums')),
      body: BlocBuilder<GuestAlbumsBloc, GuestAlbumsState>(
        builder: (context, state) {
          if (state is GuestAlbumsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GuestAlbumsLoaded) {
            if (state.albums.isEmpty) {
              return _buildEmptyState();
            }
            return _buildAlbumsList(state.albums);
          }

          if (state is GuestAlbumsError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_album_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No guests have shared their albums yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'When guests share their photos with you,\nthey will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumsList(List<GuestAlbum> albums) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        return GuestAlbumCard(
          album: albums[index],
          onTap: () => _navigateToAlbum(context, albums[index]),
        );
      },
    );
  }

  void _navigateToAlbum(BuildContext context, GuestAlbum album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuestAlbumDetailPage(album: album),
      ),
    );
  }
}
```

### GuestAlbumCard Widget
```dart
// lib/features/my_wedding/presentation/widgets/guest_album_card.dart
class GuestAlbumCard extends StatelessWidget {
  final GuestAlbum album;
  final VoidCallback onTap;

  const GuestAlbumCard({
    super.key,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Guest avatar
              CircleAvatar(
                radius: 24,
                backgroundImage: album.guestAvatarUrl != null
                  ? NetworkImage(album.guestAvatarUrl!)
                  : null,
                child: album.guestAvatarUrl == null
                  ? Text(album.guestName[0].toUpperCase())
                  : null,
              ),
              const SizedBox(width: 16),

              // Album info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.guestName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildMediaCountText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _buildMediaCountText() {
    final parts = <String>[];
    if (album.photoCount > 0) {
      parts.add('${album.photoCount} photo${album.photoCount > 1 ? 's' : ''}');
    }
    if (album.videoCount > 0) {
      parts.add('${album.videoCount} video${album.videoCount > 1 ? 's' : ''}');
    }
    return parts.isEmpty ? 'No media yet' : parts.join(', ');
  }
}
```

### Query SQL (via repository)
```sql
-- Query pour recuperer les albums partages avec count
SELECT
  ga.id,
  ga.wedding_id,
  ga.guest_user_id,
  p.first_name || ' ' || p.last_name as guest_name,
  p.avatar_url as guest_avatar_url,
  ga.shared_with_bride,
  ga.created_at,
  COUNT(CASE WHEN gm.media_type = 'photo' THEN 1 END) as photo_count,
  COUNT(CASE WHEN gm.media_type = 'video' THEN 1 END) as video_count
FROM guest_albums ga
JOIN profiles p ON p.id = ga.guest_user_id
LEFT JOIN guest_media gm ON gm.album_id = ga.id
WHERE ga.wedding_id = :wedding_id
  AND ga.shared_with_bride = TRUE  -- RLS devrait filtrer mais explicit pour clarte
GROUP BY ga.id, p.id
ORDER BY ga.created_at DESC;
```

### Realtime Subscription
```dart
// Dans le BLoC, subscribe aux changements
supabase
  .from('guest_albums')
  .stream(primaryKey: ['id'])
  .eq('wedding_id', weddingId)
  .listen((data) {
    // Refresh la liste quand un album est partage/departage
    add(RefreshGuestAlbums());
  });
```

## Definition of Done
- [ ] GuestAlbumsPage cree et fonctionnel
- [ ] GuestAlbumCard widget avec avatar, nom, counts
- [ ] Empty state quand aucun album partage
- [ ] Navigation vers detail album
- [ ] Grille de medias dans album detail
- [ ] Lecture video inline
- [ ] Realtime updates via Supabase Realtime
- [ ] Albums non partages invisibles (RLS)
- [ ] Tests unitaires pour use case
- [ ] Tests widget
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (queries avec joins, realtime)

## Dependances
- S02 (table guest_albums)
- S03 (table guest_media)
- S07 (toggle shared_with_bride)

## Stories Dependantes
- S09 (Telechargement) - bride peut telecharger depuis albums guests
