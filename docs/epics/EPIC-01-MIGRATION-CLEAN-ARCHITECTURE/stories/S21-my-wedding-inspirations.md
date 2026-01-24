# Story S21: My Wedding - Inspirations/Albums

## Description

En tant que developpeur, je veux migrer la gestion des albums d'inspiration vers Clean Architecture afin d'avoir une fonctionnalite complete de sauvegarde d'images.

## Criteres d'Acceptance (Gherkin)

- [ ] Given la page Inspirations When j'affiche les albums Then la liste est chargee

- [ ] Given le sheet de creation When je cree un album Then il apparait dans la liste

- [ ] Given un album When je l'ouvre Then les images sont affichees

- [ ] Given une image du feed When je la sauvegarde Then elle est ajoutee a l'album

- [ ] Given une image sauvegardee When je la supprime Then elle est retiree de l'album

## Fichiers Concernes

### Existants (a migrer/verifier)
- `lib/features/my_wedding/presentation/pages/inspirations_page.dart`
- `lib/features/my_wedding/presentation/pages/album_detail_page.dart`
- `lib/features/my_wedding/presentation/sheets/create_album_sheet.dart`
- `lib/features/my_wedding/presentation/sheets/save_to_album_sheet.dart`

### A Creer
- `lib/features/my_wedding/presentation/bloc/inspirations_cubit.dart`
- `lib/features/my_wedding/presentation/bloc/inspirations_state.dart`
- `lib/features/my_wedding/presentation/widgets/album_grid_item.dart`
- `lib/features/my_wedding/presentation/widgets/saved_image_grid.dart`

## Notes Techniques

### Inspirations State
```dart
class InspirationsState {
  final List<InspirationAlbum> albums;
  final InspirationAlbum? selectedAlbum;
  final List<AlbumImage> albumImages;
  final List<SavedPost> savedPosts;
  final bool isLoading;
  final String? error;

  const InspirationsState({
    this.albums = const [],
    this.selectedAlbum,
    this.albumImages = const [],
    this.savedPosts = const [],
    this.isLoading = false,
    this.error,
  });

  /// All items in selected album (images + saved posts)
  List<dynamic> get allItems => [...albumImages, ...savedPosts];

  InspirationsState copyWith({...});
}
```

### Inspirations Cubit
```dart
class InspirationsCubit extends Cubit<InspirationsState> {
  final MyWeddingRepository _repository;
  final String weddingId;

  InspirationsCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  }) : _repository = repository,
       super(const InspirationsState()) {
    loadAlbums();
  }

  Future<void> loadAlbums() async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getInspirationAlbums(weddingId: weddingId);

    result.when(
      success: (albums) => emit(state.copyWith(
        isLoading: false,
        albums: albums,
      )),
      failure: (error) => emit(state.copyWith(
        isLoading: false,
        error: error,
      )),
    );
  }

  Future<void> createAlbum({
    required String name,
    String? category,
    bool isPrivate = false,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.createInspirationAlbum(
      weddingId: weddingId,
      name: name,
      category: category,
      isPrivate: isPrivate,
    );

    result.when(
      success: (album) {
        final updatedAlbums = [...state.albums, album];
        emit(state.copyWith(isLoading: false, albums: updatedAlbums));
      },
      failure: (error) => emit(state.copyWith(isLoading: false, error: error)),
    );
  }

  Future<void> selectAlbum(InspirationAlbum album) async {
    emit(state.copyWith(
      selectedAlbum: album,
      isLoading: true,
    ));

    final results = await Future.wait([
      _repository.getAlbumImages(albumId: album.id),
      _repository.getSavedPosts(albumId: album.id),
    ]);

    final imagesResult = results[0] as RepositoryResult<List<AlbumImage>>;
    final postsResult = results[1] as RepositoryResult<List<SavedPost>>;

    emit(state.copyWith(
      isLoading: false,
      albumImages: imagesResult.data ?? [],
      savedPosts: postsResult.data ?? [],
    ));
  }

  Future<void> deleteAlbum(String albumId) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.deleteInspirationAlbum(albumId: albumId);

    result.when(
      success: (_) {
        final updatedAlbums = state.albums.where((a) => a.id != albumId).toList();
        emit(state.copyWith(
          isLoading: false,
          albums: updatedAlbums,
          selectedAlbum: null,
        ));
      },
      failure: (error) => emit(state.copyWith(isLoading: false, error: error)),
    );
  }

  Future<void> saveImageToAlbum({
    required String albumId,
    required String imageUrl,
    String? sourceProfileId,
  }) async {
    final result = await _repository.saveImageToAlbum(
      albumId: albumId,
      imageUrl: imageUrl,
      sourceProfileId: sourceProfileId,
    );

    result.when(
      success: (savedPost) {
        if (state.selectedAlbum?.id == albumId) {
          final updatedPosts = [...state.savedPosts, savedPost];
          emit(state.copyWith(savedPosts: updatedPosts));
        }
        // Refresh album counts
        loadAlbums();
      },
      failure: (error) => emit(state.copyWith(error: error)),
    );
  }

  Future<void> removeSavedPost(String savedPostId) async {
    final result = await _repository.removeSavedPost(savedPostId: savedPostId);

    result.when(
      success: (_) {
        final updatedPosts = state.savedPosts.where((p) => p.id != savedPostId).toList();
        emit(state.copyWith(savedPosts: updatedPosts));
        loadAlbums(); // Refresh counts
      },
      failure: (error) => emit(state.copyWith(error: error)),
    );
  }
}
```

### Album Grid Item
```dart
class AlbumGridItem extends StatelessWidget {
  final InspirationAlbum album;
  final VoidCallback onTap;

  const AlbumGridItem({
    required this.album,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: context.colors.surfaceVariant,
                image: album.coverImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(album.coverImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: album.coverImageUrl == null
                  ? const Icon(Icons.photo_album, size: 48)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.name,
            style: context.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${album.itemCount} items',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Save to Album Sheet
```dart
class SaveToAlbumSheet extends StatelessWidget {
  final String imageUrl;
  final String? sourceProfileId;

  const SaveToAlbumSheet({
    required this.imageUrl,
    this.sourceProfileId,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? sourceProfileId,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SaveToAlbumSheet(
        imageUrl: imageUrl,
        sourceProfileId: sourceProfileId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InspirationsCubit, InspirationsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save to Album',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (state.albums.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Text('No albums yet'),
                      const SizedBox(height: 8),
                      LynewedButton(
                        text: 'Create Album',
                        onPressed: () => _showCreateAlbum(context),
                      ),
                    ],
                  ),
                )
              else
                ...state.albums.map((album) => ListTile(
                  leading: album.coverImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            album.coverImageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.photo_album),
                  title: Text(album.name),
                  subtitle: Text('${album.itemCount} items'),
                  onTap: () {
                    context.read<InspirationsCubit>().saveImageToAlbum(
                      albumId: album.id,
                      imageUrl: imageUrl,
                      sourceProfileId: sourceProfileId,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved to album')),
                    );
                  },
                )),
            ],
          ),
        );
      },
    );
  }

  void _showCreateAlbum(BuildContext context) {
    Navigator.pop(context);
    CreateAlbumSheet.show(context);
  }
}
```

## Definition of Done

- [ ] InspirationsCubit implemente
- [ ] Page Inspirations migree
- [ ] Album detail page migree
- [ ] Create album sheet migre
- [ ] Save to album sheet migre
- [ ] Integration avec feed (save action)
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S03 : Design system
- S17 : My Wedding - Domain
- S18 : My Wedding - Data

## Stories Dependantes

- S29 : Bride - Feed pages (save action)
