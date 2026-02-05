# Story S15: Page liste annonces (feed)

## Description
En tant qu'acheteuse, je veux voir un feed d'annonces de robes et chaussures, afin de trouver ce que je cherche.

## Criteres d'Acceptance (Gherkin)

- [ ] Given active listings in the marketplace When user opens marketplace tab Then listings should display as cards with cover photo, title, price, condition badge, location
- [ ] Given more than 20 listings When user scrolls to bottom Then next page of listings should load (infinite scroll) And loading indicator should show during fetch
- [ ] Given listings of both dresses and shoes When user taps "Dresses" chip Then only dress listings should show When user taps "Shoes" chip Then only shoes listings should show
- [ ] Given the feed screen When user pulls down Then listings should refresh (pull to refresh)
- [ ] Given a listing card When user taps on it Then they should navigate to listing detail page (S16)

---

## Entity Definitions

Reuses **ListingEntity** from S14 (see S14-create-listing-form.md for full definition).

---

## Repository Interface

Extends **MarketplaceRepository** from S14:

```dart
abstract class MarketplaceRepository {
  // ... (methods from S14)

  /// Gets active listings with pagination and optional category filter.
  ///
  /// Returns listings ordered by creation date (newest first).
  /// [category] can be 'dress', 'shoes', or null for all.
  /// [page] is 0-indexed, [pageSize] is typically 20.
  Future<List<ListingEntity>> getListings({
    String? category,
    int page = 0,
    int pageSize = 20,
  });

  /// Gets count of active listings with optional category filter.
  ///
  /// Used for empty state or stats.
  Future<int> getListingsCount({String? category});
}
```

---

## Files to Create

```
CREATE:
- lib/features/marketplace/presentation/pages/marketplace_feed_page.dart
- lib/features/marketplace/presentation/widgets/listing_card.dart
- lib/features/marketplace/presentation/widgets/category_chips.dart
- lib/features/marketplace/presentation/widgets/feed_loading_indicator.dart
- lib/features/marketplace/presentation/widgets/listing_skeleton_card.dart
- test/features/marketplace/presentation/pages/marketplace_feed_page_test.dart
- test/features/marketplace/presentation/widgets/listing_card_test.dart

MODIFY:
- lib/features/marketplace/data/repositories/supabase_marketplace_repository.dart → add getListings()
- lib/core/navigation/routes.dart → ensure marketplace routes exist
- lib/flutter_flow/nav/nav.dart → ensure FFRoute for feed exists
```

---

## DI Registration

Same as S14 (MarketplaceRepository already registered).

---

## Routes

```dart
// In routes.dart (already added in S14)
static const String marketplaceFeed = '/marketplace/feed';

// In nav.dart
FFRoute(
  name: 'MarketplaceFeed',
  path: '/marketplace/feed',
  builder: (context, params) => const MarketplaceFeedPage(),
),
```

---

## Design System Usage

### Widgets
- **LynewedChip** (category filter chips)
- **LynewedColors** for all colors
- **LynewedTextStyles** for text

### Card Specs
```dart
// ListingCard specs
- Aspect ratio: 1:1 (square cover photo)
- Card elevation: 1
- Border radius: 12px
- Padding: 8px
- Title: LynewedTextStyles.bodyMedium, max 2 lines, ellipsis
- Price: LynewedTextStyles.titleSmall, LynewedColors.primary
- Condition badge: LynewedChip overlay on photo top-right, 8px margin
- Location: LynewedTextStyles.bodySmall, LynewedColors.textSecondary
```

### Colors
```dart
// Condition badge colors
- 'new': LynewedColors.success
- 'excellent': LynewedColors.primary
- 'good': LynewedColors.warning
- 'fair': LynewedColors.gray300
```

### Grid Layout
```dart
GridView.builder(
  padding: const EdgeInsets.all(12),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // Mobile
    // crossAxisCount: 3, // Tablet (use MediaQuery to detect)
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 0.7, // Card height ratio
  ),
  // ...
);
```

### Reference
- Copy **grid pattern** from `lib/features/my_wedding/presentation/pages/album_detail_page.dart`

---

## Screen States

### Loading (Initial)
- Show 6 skeleton cards with shimmer effect.
- Use **listing_skeleton_card.dart** widget.

```dart
GridView.builder(
  itemCount: 6,
  itemBuilder: (context, index) => const ListingSkeletonCard(),
);
```

### Empty
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.shopping_bag_outlined,
        size: 64,
        color: LynewedColors.gray300,
      ),
      SizedBox(height: LynewedSpacing.lg),
      Text(
        'No listings yet',
        style: LynewedTextStyles.titleSmall.copyWith(
          color: LynewedColors.textPrimary,
        ),
      ),
      SizedBox(height: LynewedSpacing.sm),
      Text(
        'Be the first to list your wedding dress or shoes!',
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: LynewedSpacing.lg),
      LynewedButton(
        label: 'Create Listing',
        onPressed: () => context.pushNamed(AppRoutes.createListing),
      ),
    ],
  ),
)
```

### Error
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.error_outline,
        size: 64,
        color: LynewedColors.error,
      ),
      SizedBox(height: LynewedSpacing.lg),
      Text(
        'Failed to load listings',
        style: LynewedTextStyles.titleSmall.copyWith(
          color: LynewedColors.textPrimary,
        ),
      ),
      SizedBox(height: LynewedSpacing.sm),
      Text(
        errorMessage,
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: LynewedSpacing.lg),
      LynewedButton(
        label: 'Retry',
        variant: ButtonVariant.secondary,
        onPressed: _loadInitialListings,
      ),
    ],
  ),
)
```

### Data
- GridView with 2 columns (mobile) or 3 columns (tablet).
- Infinite scroll: trigger load more at 200px from bottom.
- Loading indicator at bottom when fetching next page.

---

## Technical Specifications

### Pagination
```dart
// Constants
const int PAGE_SIZE = 20;
const double LOAD_MORE_THRESHOLD = 200.0; // pixels from bottom

// State
int _currentPage = 0;
bool _isLoading = false;
bool _hasMore = true;
List<ListingEntity> _listings = [];

// Load initial
Future<void> _loadInitialListings() async {
  setState(() {
    _isLoading = true;
    _currentPage = 0;
    _hasMore = true;
  });

  final newListings = await ref.read(marketplaceRepositoryProvider).getListings(
    category: _selectedCategory,
    page: 0,
    pageSize: PAGE_SIZE,
  );

  setState(() {
    _listings = newListings;
    _hasMore = newListings.length == PAGE_SIZE;
    _isLoading = false;
  });
}

// Load more (infinite scroll)
Future<void> _loadMoreListings() async {
  if (_isLoading || !_hasMore) return;

  setState(() => _isLoading = true);

  final newListings = await ref.read(marketplaceRepositoryProvider).getListings(
    category: _selectedCategory,
    page: _currentPage + 1,
    pageSize: PAGE_SIZE,
  );

  setState(() {
    _currentPage++;
    _listings.addAll(newListings);
    _hasMore = newListings.length == PAGE_SIZE;
    _isLoading = false;
  });
}

// Scroll listener
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - LOAD_MORE_THRESHOLD) {
    _loadMoreListings();
  }
}

@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  _loadInitialListings();
}
```

### Category Filter
```dart
// Category chips (horizontal scrollable)
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  child: Row(
    children: [
      LynewedChip(
        label: 'All',
        isSelected: _selectedCategory == null,
        onTap: () => _onCategoryChanged(null),
      ),
      SizedBox(width: LynewedSpacing.sm),
      LynewedChip(
        label: 'Dresses',
        isSelected: _selectedCategory == 'dress',
        onTap: () => _onCategoryChanged('dress'),
      ),
      SizedBox(width: LynewedSpacing.sm),
      LynewedChip(
        label: 'Shoes',
        isSelected: _selectedCategory == 'shoes',
        onTap: () => _onCategoryChanged('shoes'),
      ),
    ],
  ),
)

void _onCategoryChanged(String? category) {
  setState(() => _selectedCategory = category);
  _loadInitialListings(); // Reload with new filter
}
```

### Price Format
```dart
// Use CurrencyService for formatting (not hardcode $)
import '/core/utils/currency_service.dart';

// In ListingCard
Text(
  CurrencyService.format(listing.priceCents),
  style: LynewedTextStyles.titleSmall.copyWith(
    color: LynewedColors.primary,
    fontWeight: FontWeight.bold,
  ),
)

// CurrencyService (create if doesn't exist)
class CurrencyService {
  static String format(int cents, {String currency = 'USD'}) {
    final dollars = cents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}
```

### Condition Badge
```dart
// Chip overlay on photo (top-right corner)
Positioned(
  top: 8,
  right: 8,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _getConditionColor(listing.condition),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      listing.condition.capitalize(),
      style: LynewedTextStyles.labelSmall.copyWith(
        color: Colors.white,
      ),
    ),
  ),
)

Color _getConditionColor(String condition) {
  switch (condition) {
    case 'new':
      return LynewedColors.success;
    case 'excellent':
      return LynewedColors.primary;
    case 'good':
      return LynewedColors.warning;
    case 'fair':
      return LynewedColors.gray300;
    default:
      return LynewedColors.gray300;
  }
}
```

### Image Loading
```dart
// Use CachedNetworkImage with shimmer placeholder
CachedNetworkImage(
  imageUrl: listing.coverPhotoUrl ?? '',
  fit: BoxFit.cover,
  placeholder: (context, url) => Container(
    color: LynewedColors.gray200,
    child: const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: LynewedColors.gray300,
      ),
    ),
  ),
  errorWidget: (context, url, error) => Container(
    color: LynewedColors.gray200,
    child: Icon(
      Icons.broken_image,
      color: LynewedColors.gray300,
      size: 48,
    ),
  ),
)
```

### Responsive Grid
```dart
// Detect tablet and adjust columns
int _getCrossAxisCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 768) {
    return 3; // Tablet
  }
  return 2; // Mobile
}

// In GridView
crossAxisCount: _getCrossAxisCount(context),
```

### Supabase Query
```dart
// In SupabaseMarketplaceRepository
@override
Future<List<ListingEntity>> getListings({
  String? category,
  int page = 0,
  int pageSize = 20,
}) async {
  var query = _supabase
    .from('marketplace_listings')
    .select('*, photos:marketplace_photos(storage_path, position)')
    .eq('status', 'active')
    .order('created_at', ascending: false)
    .range(page * pageSize, (page + 1) * pageSize - 1);

  if (category != null) {
    query = query.eq('category', category);
  }

  final response = await query;
  return (response as List)
    .map((json) => ListingEntity.fromJson(json))
    .toList();
}
```

---

## Tests Requis

### Widget Tests
```dart
// test/features/marketplace/presentation/pages/marketplace_feed_page_test.dart

- MarketplaceFeedPage renders grid when data available
- MarketplaceFeedPage shows empty state when no listings
- MarketplaceFeedPage shows error state on fetch failure
- MarketplaceFeedPage shows loading skeletons on initial load
- MarketplaceFeedPage filters by category when chip tapped
- MarketplaceFeedPage loads more listings on scroll to bottom
- MarketplaceFeedPage refreshes listings on pull to refresh
- MarketplaceFeedPage navigates to detail on card tap

// test/features/marketplace/presentation/widgets/listing_card_test.dart

- ListingCard displays cover photo, title, price, condition, location
- ListingCard shows condition badge with correct color
- ListingCard truncates title to 2 lines with ellipsis
- ListingCard formats price correctly
- ListingCard calls onTap when tapped
- ListingCard shows placeholder when no cover photo
```

### Repository Tests
```dart
// Already covered in S14, add:

- getListings returns 20 items by default
- getListings filters by category correctly
- getListings orders by created_at desc
- getListings paginates correctly (page 0, page 1, etc.)
- getListings returns empty list when no active listings
```

---

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
            // Cover photo (aspect ratio 1:1)
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: listing.coverPhotoUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                  // Condition badge overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ConditionBadge(condition: listing.condition),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (max 2 lines)
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodyMedium,
                  ),
                  // Price
                  Text(
                    CurrencyService.format(listing.priceCents),
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Location
                  Text(
                    '${listing.city ?? ''}, ${listing.country}',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
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
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: _getCrossAxisCount(context),
    childAspectRatio: 0.7, // Adjust for card height
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: _listings.length + (_hasMore && _listings.isNotEmpty ? 1 : 0),
  itemBuilder: (context, index) {
    if (index >= _listings.length) {
      return const Center(child: CircularProgressIndicator());
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
