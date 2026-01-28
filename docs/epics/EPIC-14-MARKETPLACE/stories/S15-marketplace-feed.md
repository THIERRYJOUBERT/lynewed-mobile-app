# Story S15: Page liste annonces (feed)

## Description
En tant qu'acheteuse, je veux voir un feed d'annonces de robes et chaussures, afin de trouver ce que je cherche.

## Criteres d'Acceptance (Gherkin)

- [ ] Given active listings in the marketplace When user opens marketplace tab Then listings should display as cards with cover photo, title, price, condition badge, location
- [ ] Given more than 20 listings When user scrolls to bottom Then next page of listings should load (infinite scroll) And loading indicator should show during fetch
- [ ] Given listings of both dresses and shoes When user taps "Dresses" chip Then only dress listings should show When user taps "Shoes" chip Then only shoes listings should show
- [ ] Given the feed screen When user pulls down Then listings should refresh (pull to refresh)
- [ ] Given a listing card When user taps on it Then they should navigate to listing detail page (S16)

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/pages/marketplace_feed_page.dart` - Main feed page
- `lib/features/marketplace/presentation/widgets/listing_card.dart` - Card widget
- `lib/features/marketplace/presentation/widgets/category_chips.dart` - Quick filter chips
- `lib/features/marketplace/presentation/widgets/feed_loading_indicator.dart` - Loading states
- `lib/features/marketplace/data/repositories/listing_repository_impl.dart` - Repository (add if not exists)
- `lib/features/marketplace/domain/usecases/get_listings.dart` - Use case

### A Modifier
- `lib/features/marketplace/presentation/pages/marketplace_page.dart` - Integrate feed

## Notes Techniques

### Feed Architecture
```dart
class MarketplaceFeedPage extends ConsumerStatefulWidget {
  // Use InfiniteScrollPagination or custom pagination
  // State: listings, isLoading, hasMore, selectedCategory
}

class MarketplaceFeedState extends ConsumerState<MarketplaceFeedPage> {
  final ScrollController _scrollController = ScrollController();
  final List<ListingEntity> _listings = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _selectedCategory; // null = all, 'dress', 'shoes'

  @override
  void initState() {
    super.initState();
    _loadInitialListings();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreListings();
    }
  }
}
```

### Listing Card Widget
```dart
class ListingCard extends StatelessWidget {
  final ListingEntity listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover photo (aspect ratio 4:3 or 1:1)
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: listing.coverPhotoUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (max 2 lines)
                  Text(listing.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  // Price
                  Text('\$${listing.priceFormatted}', style: Theme.of(context).textTheme.titleMedium),
                  // Condition badge
                  ConditionBadge(condition: listing.condition),
                  // Location
                  Text('${listing.city}, ${listing.country}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Grid Layout
```dart
// Use GridView.builder or SliverGrid
GridView.builder(
  controller: _scrollController,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.65, // Adjust for card height
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: _listings.length + (_hasMore ? 1 : 0),
  itemBuilder: (context, index) {
    if (index >= _listings.length) {
      return const LoadingIndicator();
    }
    return ListingCard(
      listing: _listings[index],
      onTap: () => _navigateToDetail(_listings[index]),
    );
  },
);
```

### Supabase Query with Pagination
```dart
Future<List<ListingEntity>> getListings({
  String? category,
  int page = 0,
  int pageSize = 20,
}) async {
  var query = supabase
    .from('marketplace_listings')
    .select('*, photos:marketplace_photos(storage_path, position)')
    .eq('status', 'active')
    .order('created_at', ascending: false)
    .range(page * pageSize, (page + 1) * pageSize - 1);

  if (category != null) {
    query = query.eq('category', category);
  }

  final response = await query;
  return response.map((json) => ListingEntity.fromJson(json)).toList();
}
```

## Definition of Done
- [ ] Feed page avec grid de cards
- [ ] Infinite scroll pagination (20 items/page)
- [ ] Pull to refresh
- [ ] Category filter chips (All/Dresses/Shoes)
- [ ] Loading states (initial, more)
- [ ] Empty state si pas d'annonces
- [ ] Navigation vers detail
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S01 (marketplace_listings table)

## Stories Dependantes
- S16 (detail page - navigation depuis feed)
- S17 (filtres avances - integration)
- S26 (navbar integration)
