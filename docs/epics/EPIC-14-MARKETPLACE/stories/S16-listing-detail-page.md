# Story S16: Page detail annonce

## Description
En tant qu'acheteuse, je veux voir tous les details d'une annonce, afin de decider si je veux l'acheter.

## Criteres d'Acceptance (Gherkin)

- [ ] Given an active listing When user taps on it from feed Then detail page should show photo carousel, title, price, description, size, brand, condition, location
- [ ] Given a listing with multiple photos When viewing detail Then photos should be swipeable in a carousel And page indicator should show current position
- [ ] Given the detail page Then these action buttons should be visible: "Contact Seller" (opens chat), "Make Offer" (opens offer modal), "Buy Now" (proceeds to checkout)
- [ ] Given the seller info section Then seller profile picture, name, and "View other listings" link should be displayed
- [ ] Given a dress listing Then sleeve_length should be displayed Given a shoes listing Then sleeve_length should not be shown

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/pages/listing_detail_page.dart` - Detail page
- `lib/features/marketplace/presentation/widgets/photo_carousel.dart` - Photo carousel
- `lib/features/marketplace/presentation/widgets/listing_info_section.dart` - Info display
- `lib/features/marketplace/presentation/widgets/seller_info_widget.dart` - Seller preview
- `lib/features/marketplace/presentation/widgets/action_buttons_bar.dart` - Bottom action bar
- `lib/features/marketplace/domain/usecases/get_listing_detail.dart` - Use case

### A Modifier
- `lib/features/marketplace/presentation/widgets/listing_card.dart` - Navigation to detail

## Notes Techniques

### Page Structure
```dart
class ListingDetailPage extends ConsumerWidget {
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return Scaffold(
      body: listingAsync.when(
        data: (listing) => CustomScrollView(
          slivers: [
            // Photo carousel in SliverAppBar
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.width, // Square
              flexibleSpace: PhotoCarousel(photos: listing.photos),
              pinned: true,
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListingInfoSection(listing: listing),
                    const SizedBox(height: 16),
                    SellerInfoWidget(sellerId: listing.sellerId),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorWidget(error: e),
      ),
      bottomNavigationBar: ActionButtonsBar(
        onContact: () => _openChat(context, listing),
        onMakeOffer: () => _openOfferModal(context, listing),
        onBuyNow: () => _proceedToCheckout(context, listing),
      ),
    );
  }
}
```

### Photo Carousel
```dart
class PhotoCarousel extends StatefulWidget {
  final List<PhotoEntity> photos;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: photos.length,
          itemBuilder: (context, index) => CachedNetworkImage(
            imageUrl: photos[index].url,
            fit: BoxFit.cover,
          ),
        ),
        // Page indicator
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: photos.length,
            ),
          ),
        ),
      ],
    );
  }
}
```

### Listing Info Section
```dart
class ListingInfoSection extends StatelessWidget {
  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(listing.title, style: Theme.of(context).textTheme.headlineSmall),

        // Price
        Text('\$${listing.priceFormatted}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const Divider(),

        // Details
        _DetailRow(label: 'Category', value: listing.category.capitalize()),
        _DetailRow(label: 'Size', value: listing.size),
        _DetailRow(label: 'Brand', value: listing.designerBrand ?? 'Not specified'),
        _DetailRow(label: 'Condition', value: listing.condition.capitalize()),
        if (listing.category == 'dress')
          _DetailRow(label: 'Sleeve Length', value: listing.sleeveLength),

        const Divider(),

        // Description
        Text('Description', style: Theme.of(context).textTheme.titleMedium),
        Text(listing.description ?? 'No description'),

        const Divider(),

        // Location
        Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            Text('${listing.city}, ${listing.country}'),
          ],
        ),
      ],
    );
  }
}
```

### Action Buttons Bar
```dart
class ActionButtonsBar extends StatelessWidget {
  final VoidCallback onContact;
  final VoidCallback onMakeOffer;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(...)],
        ),
        child: Row(
          children: [
            // Contact button (icon)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: onContact,
            ),
            const SizedBox(width: 8),

            // Make Offer (outlined)
            Expanded(
              child: OutlinedButton(
                onPressed: onMakeOffer,
                child: const Text('Make Offer'),
              ),
            ),
            const SizedBox(width: 8),

            // Buy Now (filled)
            Expanded(
              child: FilledButton(
                onPressed: onBuyNow,
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Definition of Done
- [ ] Detail page complete
- [ ] Photo carousel avec swipe et indicator
- [ ] Toutes les infos affichees
- [ ] Seller info section
- [ ] 3 action buttons fonctionnels
- [ ] Navigation vers chat, offre, checkout
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S01 (marketplace_listings)
- S02 (marketplace_photos)

## Stories Dependantes
- S18 (chat - "Contact Seller")
- S19 (offres - "Make Offer")
- S20 (achat - "Buy Now")
