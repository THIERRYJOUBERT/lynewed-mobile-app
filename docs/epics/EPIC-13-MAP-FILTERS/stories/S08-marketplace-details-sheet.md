# Story S08: Tap marqueur marketplace ouvre details

## Description
En tant que utilisateur (bride), je veux pouvoir tapper sur un marqueur marketplace sur la carte et voir les details de l'article, afin de decouvrir les annonces disponibles pres de moi.

## Criteres d'Acceptance (Gherkin)
- [ ] Given a marketplace item marker is visible on map When the user taps the marker Then a bottom sheet should open And the sheet should display item details
- [ ] Given the marketplace details sheet is open Then the item photo should be displayed And the item title should be displayed And the item price should be displayed (formatted with currency) And the item category (dress/shoes) should be displayed And the seller name should be displayed
- [ ] Given the marketplace details sheet is open When the user taps "View listing" Then the app should navigate to the marketplace listing page And the sheet should close
- [ ] Given the marketplace details sheet is open Then it should use LynewedColors and LynewedTextStyles And it should have drag handle And it should match styling of other map sheets

## Fichiers Concernes
### A Creer
- `lib/features/map/presentation/sheets/marketplace_details_sheet.dart`
- `lib/features/map/domain/entities/marketplace_item_summary.dart`
- `test/features/map/presentation/sheets/marketplace_details_sheet_test.dart`

### A Modifier
- `lib/features/map/presentation/widgets/map_marker_layer.dart` (handle tap)
- `lib/features/map/presentation/pages/map_page.dart` (show sheet)

## Notes Techniques

### Entity MarketplaceItemSummary
```dart
// lib/features/map/domain/entities/marketplace_item_summary.dart

import 'package:equatable/equatable.dart';

/// Summary of a marketplace item for display on map sheet.
/// Full details are in EPIC-14 marketplace feature.
class MarketplaceItemSummary extends Equatable {
  const MarketplaceItemSummary({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.category,
    required this.thumbnailUrl,
    required this.sellerName,
    this.sellerId,
  });

  final String id;
  final String title;
  final double price;
  final String currency;
  final String category; // 'dress' or 'shoes'
  final String thumbnailUrl;
  final String sellerName;
  final String? sellerId;

  /// Create from marker metadata
  factory MarketplaceItemSummary.fromMarkerMetadata(Map<String, dynamic> metadata) {
    return MarketplaceItemSummary(
      id: metadata['listing_id'] as String,
      title: metadata['title'] as String? ?? 'Marketplace item',
      price: (metadata['price'] as num?)?.toDouble() ?? 0.0,
      currency: metadata['currency'] as String? ?? 'EUR',
      category: metadata['category'] as String? ?? 'dress',
      thumbnailUrl: metadata['thumbnail_url'] as String? ?? '',
      sellerName: metadata['seller_name'] as String? ?? 'Unknown seller',
      sellerId: metadata['seller_id'] as String?,
    );
  }

  /// Formatted price string
  String get formattedPrice => '$currency ${price.toStringAsFixed(0)}';

  /// Display category name
  String get categoryDisplayName {
    switch (category) {
      case 'dress':
        return 'Wedding Dress';
      case 'shoes':
        return 'Wedding Shoes';
      default:
        return category;
    }
  }

  @override
  List<Object?> get props => [id, title, price, currency, category, thumbnailUrl, sellerName, sellerId];
}
```

### Sheet widget
```dart
// lib/features/map/presentation/sheets/marketplace_details_sheet.dart

import 'package:flutter/material.dart';
import 'package:lynewed/core/design_system/lynewed_colors.dart';
import 'package:lynewed/core/design_system/lynewed_text_styles.dart';
import 'package:lynewed/core/design_system/lynewed_borders.dart';
import 'package:lynewed/core/design_system/lynewed_component_styles.dart';
import 'package:lynewed/features/map/domain/entities/marketplace_item_summary.dart';

class MarketplaceDetailsSheet extends StatelessWidget {
  const MarketplaceDetailsSheet({
    super.key,
    required this.item,
    required this.onViewListing,
    this.onClose,
  });

  final MarketplaceItemSummary item;
  final VoidCallback onViewListing;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LynewedColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.thumbnailUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: LynewedColors.gray100,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            item.title,
            style: LynewedTextStyles.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Price
          Text(
            item.formattedPrice,
            style: LynewedTextStyles.titleMedium.copyWith(
              color: LynewedColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Category chip
          Chip(
            label: Text(item.categoryDisplayName),
            backgroundColor: LynewedColors.primaryLight,
            labelStyle: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          // Seller
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: LynewedColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Sold by ${item.sellerName}',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewListing,
              style: LynewedComponentStyles.primaryButton(),
              child: const Text('View listing'),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Handle tap in MapMarkerLayer
```dart
// In MapMarkerLayer onMarkerTap handler

void _onMarkerTap(MapMarker marker) {
  switch (marker.type) {
    case MapMarkerType.proFixedLocation:
      _showProDetailsSheet(marker);
    case MapMarkerType.professionalAlert:
      _showAlertDetailsSheet(marker);
    case MapMarkerType.wedding:
      _showWeddingDetailsSheet(marker);
    case MapMarkerType.marketplaceItem:
      _showMarketplaceDetailsSheet(marker); // NEW
  }
}

void _showMarketplaceDetailsSheet(MapMarker marker) {
  final item = MarketplaceItemSummary.fromMarkerMetadata(marker.metadata);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MarketplaceDetailsSheet(
      item: item,
      onViewListing: () {
        Navigator.pop(context); // Close sheet
        // Navigate to marketplace listing page (EPIC-14)
        context.push('/marketplace/listing/${item.id}');
      },
    ),
  );
}
```

### Tests
```dart
group('MarketplaceDetailsSheet', () {
  testWidgets('displays item information', (tester) async {
    const item = MarketplaceItemSummary(
      id: 'test_1',
      title: 'Beautiful Wedding Dress',
      price: 500,
      currency: 'EUR',
      category: 'dress',
      thumbnailUrl: 'https://example.com/dress.jpg',
      sellerName: 'Marie Dupont',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarketplaceDetailsSheet(
            item: item,
            onViewListing: () {},
          ),
        ),
      ),
    );

    expect(find.text('Beautiful Wedding Dress'), findsOneWidget);
    expect(find.text('EUR 500'), findsOneWidget);
    expect(find.text('Wedding Dress'), findsOneWidget); // category chip
    expect(find.text('Sold by Marie Dupont'), findsOneWidget);
    expect(find.text('View listing'), findsOneWidget);
  });

  testWidgets('calls onViewListing when button tapped', (tester) async {
    var tapped = false;
    const item = MarketplaceItemSummary(
      id: 'test_1',
      title: 'Test Dress',
      price: 500,
      currency: 'EUR',
      category: 'dress',
      thumbnailUrl: '',
      sellerName: 'Test Seller',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarketplaceDetailsSheet(
            item: item,
            onViewListing: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('View listing'));
    expect(tapped, isTrue);
  });

  testWidgets('handles missing thumbnail gracefully', (tester) async {
    const item = MarketplaceItemSummary(
      id: 'test_1',
      title: 'Test',
      price: 100,
      currency: 'EUR',
      category: 'dress',
      thumbnailUrl: '', // Empty URL
      sellerName: 'Seller',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarketplaceDetailsSheet(
            item: item,
            onViewListing: () {},
          ),
        ),
      ),
    );

    // Should not crash, should show placeholder
    expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
  });
});

group('MarketplaceItemSummary', () {
  test('creates from marker metadata', () {
    final metadata = {
      'listing_id': '123',
      'title': 'Vintage Dress',
      'price': 750.0,
      'currency': 'EUR',
      'category': 'dress',
      'thumbnail_url': 'https://example.com/img.jpg',
      'seller_name': 'Sophie Martin',
    };

    final item = MarketplaceItemSummary.fromMarkerMetadata(metadata);

    expect(item.id, '123');
    expect(item.title, 'Vintage Dress');
    expect(item.price, 750.0);
    expect(item.formattedPrice, 'EUR 750');
    expect(item.categoryDisplayName, 'Wedding Dress');
  });

  test('handles missing metadata with defaults', () {
    final metadata = <String, dynamic>{'listing_id': '456'};

    final item = MarketplaceItemSummary.fromMarkerMetadata(metadata);

    expect(item.id, '456');
    expect(item.title, 'Marketplace item');
    expect(item.price, 0.0);
    expect(item.sellerName, 'Unknown seller');
  });
});
```

## Definition of Done
- [ ] Criteres valides
- [ ] Entity MarketplaceItemSummary creee
- [ ] Sheet widget cree avec design system
- [ ] Tap handler ajoute dans MapMarkerLayer
- [ ] Navigation vers listing (placeholder route si EPIC-14 pas pret)
- [ ] Tests unitaires pour entity
- [ ] Tests widget pour sheet
- [ ] Error handling pour image manquante
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S04 (MapMarkerType.marketplaceItem)
- S05 (Icone marketplace)

## Stories Dependantes
- EPIC-14 (Marketplace) - fournira la route complete vers le listing
