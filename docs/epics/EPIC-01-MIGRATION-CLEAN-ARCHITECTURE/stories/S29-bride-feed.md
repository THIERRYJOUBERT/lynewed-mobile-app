# Story S29: Bride - Feed Pages

## Description

En tant que developpeur, je veux migrer les pages Feed Bride vers Clean Architecture afin d'avoir une navigation de portfolio professionnels coherente.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `FeedBridesWidget` When je la migre Then elle utilise un module feed dedie

- [ ] Given `FeedDetailViewerWidget` When je la migre Then elle affiche les details du portfolio

- [ ] Given les filtres (profession, location) When je les applique Then le feed est filtre

- [ ] Given une image When je la sauvegarde Then elle est ajoutee a mes albums

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/bride/feed_brides/feed_brides_widget.dart`
- `lib/pages/bride/feed_brides/feed_brides_model.dart`
- `lib/pages/bride/feed_brides/feed_profession_filter_grid.dart`
- `lib/pages/bride/feed_brides/feed_profession_grid.dart`
- `lib/pages/bride/feed_brides/feed_location_filter.dart`
- `lib/pages/bride/feed_detail_viewer/feed_detail_viewer_widget.dart`
- `lib/pages/shared/portfolio_image_viewer/`

### Widgets Custom Code
- `lib/custom_code/widgets/feed_portfolio_grid.dart`
- `lib/custom_code/widgets/portfolio_grid.dart`

### Actions Custom Code
- `lib/custom_code/actions/get_feed_professionals_action.dart`
- `lib/custom_code/actions/get_portfolio_feed_action.dart`
- `lib/custom_code/actions/toggle_wishlist_action.dart`
- `lib/custom_code/actions/get_favorited_professionals_action.dart`

### A Creer
- `lib/features/feed/feed.dart` - Barrel
- `lib/features/feed/domain/entities/portfolio_item.dart`
- `lib/features/feed/domain/entities/feed_professional.dart`
- `lib/features/feed/domain/repositories/feed_repository.dart`
- `lib/features/feed/presentation/pages/feed_page.dart`
- `lib/features/feed/presentation/pages/feed_detail_page.dart`
- `lib/features/feed/presentation/bloc/feed_cubit.dart`
- `lib/features/feed/presentation/widgets/`

## Notes Techniques

### Feed Entities
```dart
class FeedProfessional {
  final String profileId;
  final String displayName;
  final String? avatarUrl;
  final String profession;
  final String? location;
  final List<PortfolioItem> portfolioItems;
  final bool isFavorited;
  final double? rating;
  final int? reviewCount;

  const FeedProfessional({...});
}

class PortfolioItem {
  final String id;
  final String imageUrl;
  final String? thumbnailUrl;
  final String professionalId;
  final String professionalName;
  final String? profession;
  final String? caption;
  final DateTime createdAt;

  const PortfolioItem({...});
}

class FeedFilter {
  final List<String> professions;
  final String? locationQuery;
  final double? lat;
  final double? lng;
  final int? radiusKm;
  final String? sortBy; // 'newest', 'popular', 'nearby'

  const FeedFilter({
    this.professions = const [],
    this.locationQuery,
    this.lat,
    this.lng,
    this.radiusKm,
    this.sortBy,
  });
}
```

### Feed Cubit
```dart
class FeedCubit extends Cubit<FeedState> {
  final FeedRepository _repository;

  FeedCubit({required FeedRepository repository})
      : _repository = repository,
        super(const FeedState());

  Future<void> loadFeed({FeedFilter? filter}) async {
    emit(state.copyWith(isLoading: true, filter: filter ?? state.filter));

    final result = await _repository.getFeed(
      filter: state.filter,
      offset: 0,
    );

    result.when(
      success: (items) {
        emit(state.copyWith(
          isLoading: false,
          items: items,
          hasMore: items.length >= 20,
        ));
      },
      failure: (error) {
        emit(state.copyWith(isLoading: false, error: error));
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await _repository.getFeed(
      filter: state.filter,
      offset: state.items.length,
    );

    result.when(
      success: (items) {
        emit(state.copyWith(
          isLoadingMore: false,
          items: [...state.items, ...items],
          hasMore: items.length >= 20,
        ));
      },
      failure: (error) {
        emit(state.copyWith(isLoadingMore: false, error: error));
      },
    );
  }

  void updateFilter(FeedFilter filter) {
    loadFeed(filter: filter);
  }

  Future<void> toggleFavorite(String profileId) async {
    // Optimistic update
    final updatedItems = state.items.map((item) {
      if (item.professionalId == profileId) {
        return item.copyWith(isFavorited: !item.isFavorited);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));

    // API call
    await _repository.toggleWishlist(profileId);
  }
}

class FeedState {
  final List<PortfolioItem> items;
  final FeedFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const FeedState({
    this.items = const [],
    this.filter = const FeedFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({...});
}
```

### Feed Page
```dart
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedCubit(
        repository: getIt<FeedRepository>(),
      )..loadFeed(),
      child: const _FeedPageView(),
    );
  }
}

class _FeedPageView extends StatelessWidget {
  const _FeedPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<FeedCubit, FeedState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FeedCubit>().loadFeed(),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  // Load more trigger
                  context.read<FeedCubit>().loadMore();
                  return const Center(child: CircularProgressIndicator());
                }

                final item = state.items[index];
                return FeedGridItem(
                  item: item,
                  onTap: () => _openDetail(context, item),
                  onSave: () => _saveToAlbum(context, item),
                  onFavorite: () => context.read<FeedCubit>().toggleFavorite(item.professionalId),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const FeedFilterSheet(),
    );
  }

  void _openDetail(BuildContext context, PortfolioItem item) {
    context.pushNamed(
      FeedDetailPage.routeName,
      pathParameters: {'itemId': item.id},
    );
  }

  void _saveToAlbum(BuildContext context, PortfolioItem item) {
    SaveToAlbumSheet.show(
      context,
      imageUrl: item.imageUrl,
      sourceProfileId: item.professionalId,
    );
  }
}
```

### Feed Grid Item
```dart
class FeedGridItem extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onFavorite;

  const FeedGridItem({
    required this.item,
    required this.onTap,
    required this.onSave,
    required this.onFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.thumbnailUrl ?? item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Text(
                item.professionalName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Action buttons
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.bookmark_border,
                  onTap: onSave,
                ),
                _ActionButton(
                  icon: Icons.favorite_border,
                  onTap: onFavorite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Definition of Done

- [ ] Module feed cree
- [ ] FeedCubit implemente
- [ ] FeedPage migree
- [ ] FeedDetailPage migree
- [ ] Filter sheet (profession, location)
- [ ] Save to album integration
- [ ] Wishlist integration
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 8
**Complexite** : Elevee
**Risque** : Moyen

## Dependances

- S03 : Design system
- S04 : Navigation
- S21 : My Wedding - Inspirations (save to album)

## Stories Dependantes

- Aucune
