# Story S25: Page "Mes ventes" vendeur

## Description
En tant que vendeur, je veux voir toutes mes annonces et ventes, afin de gerer mon activite marketplace.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a seller with listings When they open "My Sales" Then all their listings should display And grouped by status: active, reserved, sold, draft
- [ ] Given a seller with completed sales Then total earnings should display And 10% commission should be shown And net payout should be calculated
- [ ] Given a listing in "My Sales" When seller taps on it Then they can edit (if draft/active) or view details
- [ ] Given a listing with pending offers When seller views it Then offer count badge should be visible
- [ ] Given a reserved transaction When seller views it Then "Generate Label" action should be prominent

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/pages/seller_dashboard_page.dart` - Main dashboard
- `lib/features/marketplace/presentation/widgets/seller_stats_widget.dart` - Stats overview
- `lib/features/marketplace/presentation/widgets/seller_listing_card.dart` - Listing card (seller view)
- `lib/features/marketplace/presentation/widgets/earnings_widget.dart` - Earnings display
- `lib/features/marketplace/domain/usecases/get_seller_listings.dart` - Use case
- `lib/features/marketplace/domain/usecases/get_seller_stats.dart` - Use case

### A Modifier
- `lib/features/marketplace/presentation/pages/marketplace_page.dart` - Add navigation to dashboard
- `lib/features/profile/presentation/pages/profile_page.dart` - Add "My Sales" link

## Notes Techniques

### Dashboard Page Structure
```dart
class SellerDashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(sellerStatsProvider);
    final listingsAsync = ref.watch(sellerListingsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Sales'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Sold'),
              Tab(text: 'Reserved'),
              Tab(text: 'Drafts'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToCreateListing(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Stats summary
            statsAsync.when(
              data: (stats) => SellerStatsWidget(stats: stats),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Listings by status
            Expanded(
              child: TabBarView(
                children: [
                  _ListingsList(status: 'active'),
                  _ListingsList(status: 'sold'),
                  _ListingsList(status: 'reserved'),
                  _ListingsList(status: 'draft'),
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

### Seller Stats Widget
```dart
class SellerStatsWidget extends StatelessWidget {
  final SellerStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Earnings row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Total Sales',
                  value: '\$${stats.totalSalesFormatted}',
                  icon: Icons.attach_money,
                ),
                _StatItem(
                  label: 'Commission (10%)',
                  value: '-\$${stats.totalCommissionFormatted}',
                  icon: Icons.percent,
                  color: Colors.red,
                ),
                _StatItem(
                  label: 'Net Earnings',
                  value: '\$${stats.netEarningsFormatted}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
              ],
            ),

            const Divider(),

            // Listings count row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CountItem(label: 'Active', count: stats.activeCount),
                _CountItem(label: 'Sold', count: stats.soldCount),
                _CountItem(label: 'Reserved', count: stats.reservedCount),
                _CountItem(label: 'Drafts', count: stats.draftCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Seller Listing Card
```dart
class SellerListingCard extends StatelessWidget {
  final ListingEntity listing;
  final int? pendingOffersCount;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: CachedNetworkImage(
                  imageUrl: listing.coverPhotoUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('\$${listing.priceFormatted}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    // Status badge
                    Row(
                      children: [
                        Chip(
                          label: Text(listing.status.toUpperCase()),
                          backgroundColor: _getStatusColor(listing.status),
                        ),

                        // Offers badge
                        if (pendingOffersCount != null && pendingOffersCount! > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Badge(
                              label: Text('$pendingOffersCount offers'),
                              backgroundColor: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              onSelected: (action) {
                switch (action) {
                  case 'edit':
                    onEdit?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (_) => [
                if (listing.status == 'draft' || listing.status == 'active')
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Stats Provider
```dart
final sellerStatsProvider = FutureProvider<SellerStats>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) throw Exception('Not authenticated');

  // Get listings counts by status
  final listings = await supabase
    .from('marketplace_listings')
    .select('status')
    .eq('seller_id', userId);

  // Get completed transactions for earnings
  final transactions = await supabase
    .from('marketplace_transactions')
    .select('item_price_cents, platform_fee_cents, seller_payout_cents')
    .eq('seller_id', userId)
    .eq('status', 'completed');

  return SellerStats(
    activeCount: listings.where((l) => l['status'] == 'active').length,
    soldCount: listings.where((l) => l['status'] == 'sold').length,
    reservedCount: listings.where((l) => l['status'] == 'reserved').length,
    draftCount: listings.where((l) => l['status'] == 'draft').length,
    totalSalesCents: transactions.fold(0, (sum, t) => sum + t['item_price_cents']),
    totalCommissionCents: transactions.fold(0, (sum, t) => sum + t['platform_fee_cents']),
    netEarningsCents: transactions.fold(0, (sum, t) => sum + t['seller_payout_cents']),
  );
});
```

## Definition of Done
- [ ] Dashboard page avec tabs par status
- [ ] Stats widget (earnings, counts)
- [ ] Listing cards avec actions
- [ ] Pending offers badge
- [ ] Navigation vers edit/detail
- [ ] Navigation vers transaction (si reserved)
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S01 (marketplace_listings)
- S04 (marketplace_transactions - pour earnings)

## Stories Dependantes
- Aucune
