# Story S17: Systeme de filtres avances

## Description
En tant qu'acheteuse, je veux filtrer les annonces par plusieurs criteres, afin de trouver exactement ce que je cherche.

## Criteres d'Acceptance (Gherkin)

- [ ] Given mixed listings When filtering by category='dress' Then only dresses should show When filtering by category='shoes' Then only shoes should show
- [ ] Given listings with various prices When setting price range 100-500 USD Then only listings in that range should show
- [ ] Given listings worldwide When filtering by country='France' and radius=50km Then only French listings within radius should show
- [ ] Given many listings When applying multiple filters Then results should match ALL criteria (AND logic)
- [ ] Given active filters When user taps "Clear all" Then all filters should reset And full listing feed should display
- [ ] Given the filter sheet When user selects filters Then count of matching results should preview before applying

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/widgets/filter_sheet.dart` - Bottom sheet avec filtres
- `lib/features/marketplace/presentation/widgets/price_range_slider.dart` - Slider prix
- `lib/features/marketplace/presentation/widgets/size_filter_widget.dart` - Selection tailles
- `lib/features/marketplace/presentation/widgets/brand_filter_widget.dart` - Autocomplete marques
- `lib/features/marketplace/presentation/widgets/condition_filter_widget.dart` - Checkboxes condition
- `lib/features/marketplace/presentation/widgets/location_filter_widget.dart` - Pays + rayon
- `lib/features/marketplace/data/brands_data.dart` - Liste marques populaires
- `lib/features/marketplace/domain/entities/listing_filter.dart` - Filter entity
- `lib/features/marketplace/domain/usecases/filter_listings.dart` - Use case

### A Modifier
- `lib/features/marketplace/presentation/pages/marketplace_feed_page.dart` - Integrate filter button
- `lib/features/marketplace/data/repositories/listing_repository_impl.dart` - Add filtered query

## Notes Techniques

### Filter Entity
```dart
class ListingFilter {
  final String? category;
  final int? minPriceCents;
  final int? maxPriceCents;
  final List<String>? sizes;
  final List<String>? brands;
  final List<String>? conditions;
  final String? country;
  final double? radiusKm;
  final double? latitude;
  final double? longitude;

  ListingFilter copyWith({...});

  bool get hasActiveFilters => category != null ||
    minPriceCents != null ||
    maxPriceCents != null ||
    (sizes?.isNotEmpty ?? false) ||
    // ... etc
}
```

### Filter Sheet
```dart
class FilterSheet extends StatefulWidget {
  final ListingFilter initialFilter;
  final Function(ListingFilter) onApply;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Header with "Filters" title and "Clear all" button
            _FilterHeader(onClearAll: _clearAll),

            // Category filter (Dress / Shoes)
            _CategorySection(),

            // Price range
            PriceRangeSlider(
              min: 0,
              max: 5000,
              values: RangeValues(_filter.minPriceCents / 100, _filter.maxPriceCents / 100),
              onChanged: _updatePriceRange,
            ),

            // Size filter (depends on category)
            SizeFilterWidget(
              category: _filter.category,
              selectedSizes: _filter.sizes,
              onChanged: _updateSizes,
            ),

            // Brand filter
            BrandFilterWidget(
              category: _filter.category,
              selectedBrands: _filter.brands,
              onChanged: _updateBrands,
            ),

            // Condition filter
            ConditionFilterWidget(
              selectedConditions: _filter.conditions,
              onChanged: _updateConditions,
            ),

            // Location filter
            LocationFilterWidget(
              country: _filter.country,
              radiusKm: _filter.radiusKm,
              onChanged: _updateLocation,
            ),

            // Apply button with preview count
            _ApplyButton(
              resultCount: _previewCount,
              onApply: () => widget.onApply(_filter),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Size Guide Data
```dart
// lib/features/marketplace/data/sizes_data.dart

const dressSizes = [
  SizeOption(value: 'XS', label: 'XS (EU 32-34 / US 0-2)'),
  SizeOption(value: 'S', label: 'S (EU 36-38 / US 4-6)'),
  SizeOption(value: 'M', label: 'M (EU 40-42 / US 8-10)'),
  SizeOption(value: 'L', label: 'L (EU 44-46 / US 12-14)'),
  SizeOption(value: 'XL', label: 'XL (EU 48-50 / US 16-18)'),
];

const shoeSizes = [
  SizeOption(value: '35', label: '35 (US 4 / UK 2.5)'),
  SizeOption(value: '36', label: '36 (US 5 / UK 3.5)'),
  SizeOption(value: '37', label: '37 (US 6 / UK 4.5)'),
  SizeOption(value: '38', label: '38 (US 7 / UK 5.5)'),
  SizeOption(value: '39', label: '39 (US 8 / UK 6.5)'),
  SizeOption(value: '40', label: '40 (US 9 / UK 7.5)'),
  SizeOption(value: '41', label: '41 (US 10 / UK 8.5)'),
  SizeOption(value: '42', label: '42 (US 11 / UK 9.5)'),
];
```

### Brand Data
```dart
// lib/features/marketplace/data/brands_data.dart

const popularWeddingDressBrands = [
  'Vera Wang', 'Monique Lhuillier', 'Oscar de la Renta',
  'Carolina Herrera', 'Marchesa', 'Elie Saab', 'Zuhair Murad',
  'Pronovias', 'Rosa Clara', 'Maggie Sottero', 'Allure Bridals',
  'Mori Lee', 'Justin Alexander', 'Stella York', 'Essense of Australia',
  'David\'s Bridal', 'BHLDN', 'Delphine Manivet', 'Laure de Sagazan',
  'Other / Unknown',
];

const popularBridalShoeBrands = [
  'Jimmy Choo', 'Manolo Blahnik', 'Badgley Mischka', 'Bella Belle',
  'Rachel Simpson', 'Charlotte Mills', 'Emmy London', 'Freya Rose',
  'Stuart Weitzman', 'Louboutin', 'Aquazzura', 'Other / Unknown',
];
```

### Supabase Query with Filters
```dart
Future<List<ListingEntity>> getFilteredListings(ListingFilter filter) async {
  var query = supabase
    .from('marketplace_listings')
    .select('*, photos:marketplace_photos(*)')
    .eq('status', 'active');

  if (filter.category != null) {
    query = query.eq('category', filter.category);
  }
  if (filter.minPriceCents != null) {
    query = query.gte('price_cents', filter.minPriceCents);
  }
  if (filter.maxPriceCents != null) {
    query = query.lte('price_cents', filter.maxPriceCents);
  }
  if (filter.sizes?.isNotEmpty ?? false) {
    query = query.in_('size', filter.sizes!);
  }
  if (filter.conditions?.isNotEmpty ?? false) {
    query = query.in_('condition', filter.conditions!);
  }
  if (filter.country != null) {
    query = query.eq('country', filter.country);
  }
  // Note: Radius filter may need PostGIS or client-side filtering

  return (await query).map((json) => ListingEntity.fromJson(json)).toList();
}
```

## Definition of Done
- [ ] Filter sheet UI complete
- [ ] Category filter
- [ ] Price range slider
- [ ] Size filter (with guide)
- [ ] Brand autocomplete filter
- [ ] Condition checkboxes
- [ ] Location filter (country + radius)
- [ ] Preview count before apply
- [ ] Clear all button
- [ ] Applied filters visible on feed
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S15 (feed page - integration)

## Stories Dependantes
- Aucune
