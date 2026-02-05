# Story S16: Page detail annonce

## Description
En tant qu'acheteuse, je veux voir tous les details d'une annonce, afin de decider si je veux l'acheter.

## Criteres d'Acceptance (Gherkin)

- [ ] Given an active listing When user taps on it from feed Then detail page should show photo carousel, title, price, description, size, brand, condition, location
- [ ] Given a listing with multiple photos When viewing detail Then photos should be swipeable in a carousel And page indicator should show current position
- [ ] Given the detail page Then these action buttons should be visible: "Contact Seller" (opens chat), "Make Offer" (opens offer modal), "Buy Now" (proceeds to checkout)
- [ ] Given the seller info section Then seller profile picture, name, and "View other listings" link should be displayed
- [ ] Given a dress listing Then sleeve_length should be displayed Given a shoes listing Then sleeve_length should not be shown

---

## Entity Definitions

### ListingEntity
Reuses **ListingEntity** from S14 (see S14-create-listing-form.md for full definition).

### SellerEntity
```dart
/// Represents a marketplace seller's public profile.
///
/// Used for displaying seller info on listing detail pages.
import 'package:flutter/foundation.dart';

@immutable
class SellerEntity {
  const SellerEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.rating,
    required this.listingsCount,
  });

  /// Seller ID (references profiles table).
  final String id;

  /// Display name.
  final String name;

  /// Avatar URL (optional).
  final String? avatarUrl;

  /// Average rating (from reviews, optional).
  final double? rating;

  /// Number of active listings.
  final int listingsCount;

  /// Creates a SellerEntity from Supabase JSON row.
  factory SellerEntity.fromJson(Map<String, dynamic> json) {
    return SellerEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      listingsCount: json['listings_count'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SellerEntity &&
        other.id == id &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.rating == rating &&
        other.listingsCount == listingsCount;
  }

  @override
  int get hashCode => Object.hash(id, name, avatarUrl, rating, listingsCount);

  @override
  String toString() => 'SellerEntity($id, $name)';
}
```

### PhotoEntity
```dart
/// Represents a photo in a listing.
///
/// Used for photo carousel display.
import 'package:flutter/foundation.dart';

@immutable
class PhotoEntity {
  const PhotoEntity({
    required this.id,
    required this.listingId,
    required this.storagePath,
    required this.position,
    required this.url,
  });

  /// Photo ID (UUID).
  final String id;

  /// Listing this photo belongs to.
  final String listingId;

  /// Storage path in Supabase bucket.
  final String storagePath;

  /// Position in carousel (0 = cover).
  final int position;

  /// Public URL for display.
  final String url;

  /// Creates a PhotoEntity from Supabase JSON row.
  factory PhotoEntity.fromJson(Map<String, dynamic> json, {required String publicUrl}) {
    return PhotoEntity(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      storagePath: json['storage_path'] as String,
      position: json['position'] as int,
      url: publicUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoEntity &&
        other.id == id &&
        other.listingId == listingId &&
        other.storagePath == storagePath &&
        other.position == position &&
        other.url == url;
  }

  @override
  int get hashCode => Object.hash(id, listingId, storagePath, position, url);

  @override
  String toString() => 'PhotoEntity($id, position: $position)';
}
```

---

## Repository Interface

Extends **MarketplaceRepository** from S14:

```dart
abstract class MarketplaceRepository {
  // ... (methods from S14 and S15)

  /// Gets a listing by ID with full details.
  ///
  /// Returns null if not found or not accessible.
  /// Includes photos and seller info.
  Future<ListingEntity?> getListingDetail(String listingId);

  /// Gets photos for a listing.
  ///
  /// Returns photos ordered by position (0 = cover).
  Future<List<PhotoEntity>> getListingPhotos(String listingId);

  /// Gets seller public info.
  ///
  /// Returns seller profile with listings count and rating.
  Future<SellerEntity?> getSellerInfo(String sellerId);

  /// Gets other listings by the same seller.
  ///
  /// Excludes the current listing.
  Future<List<ListingEntity>> getSellerOtherListings(String sellerId, String excludeListingId);
}
```

---

## Files to Create

```
CREATE:
- lib/features/marketplace/domain/entities/seller_entity.dart
- lib/features/marketplace/domain/entities/photo_entity.dart
- lib/features/marketplace/presentation/pages/listing_detail_page.dart
- lib/features/marketplace/presentation/widgets/photo_carousel.dart
- lib/features/marketplace/presentation/widgets/listing_info_section.dart
- lib/features/marketplace/presentation/widgets/seller_info_widget.dart
- lib/features/marketplace/presentation/widgets/action_buttons_bar.dart
- lib/features/marketplace/presentation/widgets/detail_row.dart
- test/features/marketplace/domain/entities/seller_entity_test.dart
- test/features/marketplace/domain/entities/photo_entity_test.dart
- test/features/marketplace/presentation/pages/listing_detail_page_test.dart

MODIFY:
- lib/features/marketplace/data/repositories/supabase_marketplace_repository.dart → add getListingDetail(), getListingPhotos(), getSellerInfo()
- lib/features/marketplace/presentation/widgets/listing_card.dart → navigation to detail
```

---

## DI Registration

Same as S14 (MarketplaceRepository already registered).

---

## Routes

```dart
// In routes.dart (already added in S14)
static const String listingDetail = '/marketplace/listing';

// In nav.dart
FFRoute(
  name: 'ListingDetail',
  path: '/marketplace/listing/:id',
  builder: (context, params) => ListingDetailPage(
    listingId: params.pathParameters['id']!,
  ),
),
```

---

## Design System Usage

### Widgets
- **LynewedButton** (action buttons: Contact, Make Offer, Buy Now)
- **LynewedIconButton** (back button, share button, favorite button)
- **LynewedColors** for all colors
- **LynewedTextStyles** for text
- **LynewedSpacing** for spacing

### DetailRow Widget
```dart
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: LynewedSpacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: LynewedColors.gray300),
            SizedBox(width: LynewedSpacing.sm),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Reference
- Copy **full-screen viewer** from `lib/features/my_wedding/presentation/widgets/full_screen_media_viewer.dart`

---

## Screen States

### Loading
```dart
Center(
  child: CircularProgressIndicator(
    color: LynewedColors.primary,
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
        'Failed to load listing',
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
        onPressed: () => _loadListing(),
      ),
    ],
  ),
)
```

### Data
- Photo carousel at top (full width, square).
- Scrollable content below with listing info, seller info, action buttons.

---

## Technical Specifications

### Photo Carousel

```dart
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({
    super.key,
    required this.photos,
    required this.onPhotoTap,
  });

  final List<PhotoEntity> photos;
  final VoidCallback onPhotoTap;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPhotoTap,
      child: Stack(
        children: [
          // Photo PageView
          AspectRatio(
            aspectRatio: 1,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => CachedNetworkImage(
                imageUrl: widget.photos[index].url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: LynewedColors.gray200,
                ),
                errorWidget: (context, url, error) => Container(
                  color: LynewedColors.gray200,
                  child: Icon(
                    Icons.broken_image,
                    color: LynewedColors.gray300,
                    size: 48,
                  ),
                ),
              ),
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
                count: widget.photos.length,
                effect: WormEffect(
                  dotWidth: 8,
                  dotHeight: 8,
                  activeDotColor: LynewedColors.primary,
                  dotColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
```

**Package**: Add `smooth_page_indicator: ^1.2.0` to `pubspec.yaml`.

### Full-Screen Viewer

Reuse `FullScreenMediaViewer` from guest feature:

```dart
// When photo tapped
void _openFullScreenViewer(int initialIndex) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => FullScreenMediaViewer(
        mediaUrls: _photos.map((p) => p.url).toList(),
        initialIndex: initialIndex,
        isVideo: false,
      ),
    ),
  );
}
```

### Action Buttons Bar

```dart
class ActionButtonsBar extends StatelessWidget {
  const ActionButtonsBar({
    super.key,
    required this.onContact,
    required this.onMakeOffer,
    required this.onBuyNow,
    this.contactDisabled = false,
    this.makeOfferDisabled = false,
    this.buyNowDisabled = false,
  });

  final VoidCallback onContact;
  final VoidCallback onMakeOffer;
  final VoidCallback onBuyNow;
  final bool contactDisabled;
  final bool makeOfferDisabled;
  final bool buyNowDisabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(LynewedSpacing.md),
        decoration: BoxDecoration(
          color: LynewedColors.background,
          border: Border(
            top: BorderSide(color: LynewedColors.gray200, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Contact button (icon)
            Tooltip(
              message: contactDisabled ? 'Coming soon' : 'Contact Seller',
              child: LynewedIconButton(
                icon: Icons.chat_bubble_outline,
                onPressed: contactDisabled ? null : onContact,
              ),
            ),
            SizedBox(width: LynewedSpacing.sm),

            // Make Offer (outlined)
            Expanded(
              child: Tooltip(
                message: makeOfferDisabled ? 'Coming soon' : '',
                child: LynewedButton(
                  label: 'Make Offer',
                  variant: ButtonVariant.secondary,
                  onPressed: makeOfferDisabled ? null : onMakeOffer,
                ),
              ),
            ),
            SizedBox(width: LynewedSpacing.sm),

            // Buy Now (filled)
            Expanded(
              child: Tooltip(
                message: buyNowDisabled ? 'Coming soon' : '',
                child: LynewedButton(
                  label: 'Buy Now',
                  onPressed: buyNowDisabled ? null : onBuyNow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Fallbacks for Unimplemented Stories

```dart
// If S18 (chat) not implemented yet
final bool isChatImplemented = false; // Set to true when S18 complete

ActionButtonsBar(
  onContact: () {
    if (isChatImplemented) {
      _openChat();
    } else {
      _showComingSoonToast('Chat feature coming soon');
    }
  },
  contactDisabled: !isChatImplemented,
  // ...
)

// Similarly for S19 (offers) and S20 (checkout)
final bool isOfferImplemented = false;
final bool isCheckoutImplemented = false;
```

### Seller Info Widget

```dart
class SellerInfoWidget extends StatelessWidget {
  const SellerInfoWidget({
    super.key,
    required this.seller,
    required this.onViewOtherListings,
  });

  final SellerEntity seller;
  final VoidCallback onViewOtherListings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(LynewedSpacing.md),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        border: Border.all(color: LynewedColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: seller.avatarUrl != null
                ? CachedNetworkImageProvider(seller.avatarUrl!)
                : null,
            child: seller.avatarUrl == null
                ? Text(
                    seller.name.substring(0, 1).toUpperCase(),
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          SizedBox(width: LynewedSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: LynewedTextStyles.titleSmall,
                ),
                if (seller.rating != null)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: LynewedColors.warning,
                      ),
                      SizedBox(width: 4),
                      Text(
                        seller.rating!.toStringAsFixed(1),
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                Text(
                  '${seller.listingsCount} listings',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // View other listings button
          LynewedButton(
            label: 'View',
            variant: ButtonVariant.text,
            onPressed: onViewOtherListings,
          ),
        ],
      ),
    );
  }
}
```

### Listing Info Section

```dart
class ListingInfoSection extends StatelessWidget {
  const ListingInfoSection({
    super.key,
    required this.listing,
  });

  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          listing.title,
          style: LynewedTextStyles.headlineSmall,
        ),
        SizedBox(height: LynewedSpacing.sm),

        // Price
        Text(
          CurrencyService.format(listing.priceCents),
          style: LynewedTextStyles.headlineMedium.copyWith(
            color: LynewedColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: LynewedSpacing.lg),

        Divider(color: LynewedColors.gray200),
        SizedBox(height: LynewedSpacing.md),

        // Details
        LynewedSectionTitle('Details'),
        SizedBox(height: LynewedSpacing.sm),
        DetailRow(
          icon: Icons.category_outlined,
          label: 'Category',
          value: listing.category.capitalize(),
        ),
        DetailRow(
          icon: Icons.straighten,
          label: 'Size',
          value: listing.size,
        ),
        DetailRow(
          icon: Icons.label_outlined,
          label: 'Brand',
          value: listing.designerBrand ?? 'Not specified',
        ),
        DetailRow(
          icon: Icons.star_outline,
          label: 'Condition',
          value: listing.condition.capitalize(),
        ),
        if (listing.isDress && listing.sleeveLength != null)
          DetailRow(
            icon: Icons.checkroom,
            label: 'Sleeve Length',
            value: listing.sleeveLength!.capitalize(),
          ),

        SizedBox(height: LynewedSpacing.lg),
        Divider(color: LynewedColors.gray200),
        SizedBox(height: LynewedSpacing.md),

        // Description
        if (listing.description != null && listing.description!.isNotEmpty) ...[
          LynewedSectionTitle('Description'),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            listing.description!,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.lg),
          Divider(color: LynewedColors.gray200),
          SizedBox(height: LynewedSpacing.md),
        ],

        // Location
        LynewedSectionTitle('Location'),
        SizedBox(height: LynewedSpacing.sm),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 18,
              color: LynewedColors.gray300,
            ),
            SizedBox(width: LynewedSpacing.sm),
            Text(
              '${listing.city ?? ''}, ${listing.country}',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Share Button

```dart
// Add to AppBar actions
IconButton(
  icon: Icon(Icons.share),
  onPressed: _shareListing,
)

Future<void> _shareListing() async {
  final url = 'https://lynewed.com/marketplace/listing/${widget.listingId}';
  await Share.share(
    'Check out this ${_listing.category} on Lynewed: ${_listing.title} - ${CurrencyService.format(_listing.priceCents)}\n\n$url',
  );
}
```

**Package**: Add `share_plus: ^10.0.0` to `pubspec.yaml`.

### Favorite Button (Future)

```dart
// Add to AppBar actions (placeholder)
IconButton(
  icon: Icon(
    _isFavorited ? Icons.favorite : Icons.favorite_border,
    color: _isFavorited ? LynewedColors.error : null,
  ),
  onPressed: () {
    // TODO: Implement favorites in future story
    _showComingSoonToast('Favorites coming soon');
  },
)
```

---

## Tests Requis

### Entity Tests
```dart
// test/features/marketplace/domain/entities/seller_entity_test.dart

- SellerEntity.fromJson parses all fields correctly
- SellerEntity.fromJson handles null optional fields
- SellerEntity equality (==, hashCode) works correctly

// test/features/marketplace/domain/entities/photo_entity_test.dart

- PhotoEntity.fromJson parses all fields correctly
- PhotoEntity equality (==, hashCode) works correctly
```

### Widget Tests
```dart
// test/features/marketplace/presentation/pages/listing_detail_page_test.dart

- ListingDetailPage renders photo carousel when photos available
- ListingDetailPage shows listing info section with all details
- ListingDetailPage shows seller info widget
- ListingDetailPage shows action buttons bar
- ListingDetailPage navigates to chat when Contact button tapped (if implemented)
- ListingDetailPage shows coming soon toast when Contact button tapped (if not implemented)
- ListingDetailPage shows sleeve_length when listing is dress
- ListingDetailPage hides sleeve_length when listing is shoes
- ListingDetailPage opens full-screen viewer when photo tapped
```

---

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
