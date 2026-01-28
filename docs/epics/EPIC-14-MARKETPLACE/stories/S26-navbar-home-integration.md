# Story S26: Navbar integration + Home preview

## Description
En tant que bride, je veux acceder facilement au marketplace, afin de decouvrir les articles disponibles.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a bride user When viewing navbar Then marketplace tab should be visible with shopping bag icon
- [ ] Given a professional user When viewing navbar Then marketplace tab should NOT be visible (bride-only feature)
- [ ] Given active marketplace listings When bride views home page Then "Marketplace" section should show with 3-5 recent listings as cards
- [ ] Given the home page marketplace section When user taps "See all" Then they should navigate to full marketplace feed
- [ ] Given the marketplace tab When tapped Then it should navigate to marketplace feed page

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/widgets/home_marketplace_preview.dart` - Home section

### A Modifier
- `lib/core/navigation/app_navigation.dart` - Add marketplace tab
- `lib/core/navigation/bottom_nav_bar.dart` - Add marketplace item (bride only)
- `lib/features/home/presentation/pages/home_page.dart` - Add marketplace preview section

## Notes Techniques

### Bottom Navigation Bar Update
```dart
class BottomNavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    final isBride = userRole == UserRole.bride;

    return NavigationBar(
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),

        const NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Map',
        ),

        // Marketplace tab - BRIDE ONLY
        if (isBride)
          const NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Marketplace',
          ),

        const NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),

        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedIndex: _getSelectedIndex(currentRoute, isBride),
      onDestinationSelected: (index) => _onDestinationSelected(index, isBride),
    );
  }

  int _getSelectedIndex(String route, bool isBride) {
    // Adjust index mapping based on whether marketplace tab exists
    if (isBride) {
      switch (route) {
        case '/home': return 0;
        case '/map': return 1;
        case '/marketplace': return 2;
        case '/messages': return 3;
        case '/profile': return 4;
      }
    } else {
      switch (route) {
        case '/home': return 0;
        case '/map': return 1;
        case '/messages': return 2;
        case '/profile': return 3;
      }
    }
    return 0;
  }
}
```

### Home Page Marketplace Preview
```dart
class HomeMarketplacePreview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    if (userRole != UserRole.bride) return const SizedBox.shrink();

    final listingsAsync = ref.watch(recentMarketplaceListingsProvider);

    return listingsAsync.when(
      data: (listings) {
        if (listings.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Marketplace',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/marketplace'),
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Horizontal list of recent listings
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _MiniListingCard(
                      listing: listing,
                      onTap: () => context.push('/marketplace/${listing.id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MiniListingCard extends StatelessWidget {
  final ListingEntity listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: listing.coverPhotoUrl,
                  fit: BoxFit.cover,
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '\$${listing.priceFormatted}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Provider for Recent Listings
```dart
final recentMarketplaceListingsProvider = FutureProvider<List<ListingEntity>>((ref) async {
  final response = await supabase
    .from('marketplace_listings')
    .select('*, photos:marketplace_photos(storage_path, position)')
    .eq('status', 'active')
    .order('created_at', ascending: false)
    .limit(5);

  return response.map((json) => ListingEntity.fromJson(json)).toList();
});
```

### Home Page Integration
```dart
// In home_page.dart - Add to existing sections
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Existing sections...
            const HeroSection(),
            const FeaturedProfessionalsSection(),
            const UpcomingEventsSection(),

            // NEW: Marketplace preview (bride only)
            const HomeMarketplacePreview(),

            const RecentArticlesSection(),
            // ... other sections
          ],
        ),
      ),
    );
  }
}
```

### Router Configuration
```dart
// In app_router.dart - Add marketplace routes
GoRoute(
  path: '/marketplace',
  builder: (context, state) => const MarketplaceFeedPage(),
  routes: [
    GoRoute(
      path: ':id',
      builder: (context, state) => ListingDetailPage(
        listingId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: 'create',
      builder: (context, state) => const CreateListingPage(),
    ),
    GoRoute(
      path: 'my-sales',
      builder: (context, state) => const SellerDashboardPage(),
    ),
  ],
),
```

## Definition of Done
- [ ] Marketplace tab dans navbar (bride only)
- [ ] Tab index correct selon role
- [ ] Preview section sur home page
- [ ] 3-5 listings recents affiches
- [ ] "See all" navigue vers feed
- [ ] Tap sur card navigue vers detail
- [ ] Professional users ne voient pas le tab
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S15 (marketplace feed page)

## Stories Dependantes
- Aucune
