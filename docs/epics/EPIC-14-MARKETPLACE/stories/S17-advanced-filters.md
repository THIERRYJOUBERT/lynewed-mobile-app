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

---

## Entity Definitions

### ListingFilter

```dart
/// Represents active filters for marketplace listings.
///
/// Immutable data class for filter state.
import 'package:flutter/foundation.dart';

@immutable
class ListingFilter {
  const ListingFilter({
    this.category,
    this.minPriceCents,
    this.maxPriceCents,
    this.sizes,
    this.brands,
    this.conditions,
    this.country,
    this.radiusKm,
    this.latitude,
    this.longitude,
  });

  /// Category filter: 'dress', 'shoes', or null for all.
  final String? category;

  /// Minimum price in cents.
  final int? minPriceCents;

  /// Maximum price in cents.
  final int? maxPriceCents;

  /// Selected sizes (dress: 'XS', 'S', etc.; shoes: '35', '36', etc.).
  final List<String>? sizes;

  /// Selected brands.
  final List<String>? brands;

  /// Selected conditions: 'new', 'excellent', 'good', 'fair'.
  final List<String>? conditions;

  /// Country filter.
  final String? country;

  /// Radius in kilometers for location-based filtering.
  final double? radiusKm;

  /// User's latitude (for radius filtering).
  final double? latitude;

  /// User's longitude (for radius filtering).
  final double? longitude;

  /// Whether any filters are active.
  bool get hasActiveFilters =>
      category != null ||
      minPriceCents != null ||
      maxPriceCents != null ||
      (sizes != null && sizes!.isNotEmpty) ||
      (brands != null && brands!.isNotEmpty) ||
      (conditions != null && conditions!.isNotEmpty) ||
      country != null ||
      radiusKm != null;

  /// Count of active filters (for badge).
  int get activeFilterCount {
    int count = 0;
    if (category != null) count++;
    if (minPriceCents != null || maxPriceCents != null) count++;
    if (sizes != null && sizes!.isNotEmpty) count++;
    if (brands != null && brands!.isNotEmpty) count++;
    if (conditions != null && conditions!.isNotEmpty) count++;
    if (country != null) count++;
    return count;
  }

  /// Creates an empty filter.
  const ListingFilter.empty()
      : category = null,
        minPriceCents = null,
        maxPriceCents = null,
        sizes = null,
        brands = null,
        conditions = null,
        country = null,
        radiusKm = null,
        latitude = null,
        longitude = null;

  /// Creates a copy with updated fields.
  ListingFilter copyWith({
    String? category,
    int? minPriceCents,
    int? maxPriceCents,
    List<String>? sizes,
    List<String>? brands,
    List<String>? conditions,
    String? country,
    double? radiusKm,
    double? latitude,
    double? longitude,
    bool clearCategory = false,
    bool clearPriceRange = false,
    bool clearSizes = false,
    bool clearBrands = false,
    bool clearConditions = false,
    bool clearLocation = false,
  }) {
    return ListingFilter(
      category: clearCategory ? null : (category ?? this.category),
      minPriceCents: clearPriceRange ? null : (minPriceCents ?? this.minPriceCents),
      maxPriceCents: clearPriceRange ? null : (maxPriceCents ?? this.maxPriceCents),
      sizes: clearSizes ? null : (sizes ?? this.sizes),
      brands: clearBrands ? null : (brands ?? this.brands),
      conditions: clearConditions ? null : (conditions ?? this.conditions),
      country: clearLocation ? null : (country ?? this.country),
      radiusKm: clearLocation ? null : (radiusKm ?? this.radiusKm),
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListingFilter &&
        other.category == category &&
        other.minPriceCents == minPriceCents &&
        other.maxPriceCents == maxPriceCents &&
        _listEquals(other.sizes, sizes) &&
        _listEquals(other.brands, brands) &&
        _listEquals(other.conditions, conditions) &&
        other.country == country &&
        other.radiusKm == radiusKm &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  bool _listEquals(List? a, List? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        category,
        minPriceCents,
        maxPriceCents,
        sizes,
        brands,
        conditions,
        country,
        radiusKm,
        latitude,
        longitude,
      );

  @override
  String toString() => 'ListingFilter($activeFilterCount active)';
}
```

---

## Repository Interface

Extends **MarketplaceRepository** from S14:

```dart
abstract class MarketplaceRepository {
  // ... (methods from S14, S15, S16)

  /// Gets filtered listings with pagination.
  ///
  /// Returns listings matching ALL filter criteria (AND logic).
  Future<List<ListingEntity>> getFilteredListings({
    required ListingFilter filter,
    int page = 0,
    int pageSize = 20,
  });

  /// Gets count of listings matching filter (for preview).
  ///
  /// Returns count without pagination. Max timeout 3 seconds.
  Future<int> getFilteredListingsCount(ListingFilter filter);

  /// Gets listings within radius using PostGIS.
  ///
  /// Uses RPC function `listings_within_radius`.
  /// Returns listings ordered by distance (nearest first).
  Future<List<ListingEntity>> getListingsWithinRadius({
    required double latitude,
    required double longitude,
    required double radiusKm,
    ListingFilter? filter,
  });
}
```

---

## Files to Create

```
CREATE:
- lib/features/marketplace/domain/entities/listing_filter.dart
- lib/features/marketplace/presentation/widgets/filter_sheet.dart
- lib/features/marketplace/presentation/widgets/price_range_slider.dart
- lib/features/marketplace/presentation/widgets/size_filter_widget.dart
- lib/features/marketplace/presentation/widgets/brand_filter_widget.dart
- lib/features/marketplace/presentation/widgets/condition_filter_widget.dart
- lib/features/marketplace/presentation/widgets/location_filter_widget.dart
- lib/features/marketplace/presentation/widgets/filter_badge_chips.dart
- test/features/marketplace/domain/entities/listing_filter_test.dart
- test/features/marketplace/presentation/widgets/filter_sheet_test.dart

MODIFY:
- lib/features/marketplace/presentation/pages/marketplace_feed_page.dart → add filter button, show filter badges
- lib/features/marketplace/data/repositories/supabase_marketplace_repository.dart → add getFilteredListings(), getFilteredListingsCount()
```

---

## DI Registration

Same as S14 (MarketplaceRepository already registered).

---

## Routes

No new routes (filter sheet is a modal).

---

## Design System Usage

### Widgets
- **LynewedSheet** (filter sheet base)
- **LynewedRangeSlider** (price range)
- **LynewedSlider** (radius)
- **LynewedChip** (filter chips, filter badges)
- **LynewedSectionTitle** (section headers)
- **LynewedButton** (Apply button, Clear all button)
- **LynewedTextField** (brand autocomplete)
- **LynewedIconButton** (close sheet)

### Colors
- **LynewedColors.primary** (selected state)
- **LynewedColors.gray200** (unselected state, borders)
- **LynewedColors.textPrimary** (labels)
- **LynewedColors.textSecondary** (hints, counts)

### Spacing
- **LynewedSpacing.lg (24px)** between sections
- **LynewedSpacing.md (16px)** padding
- **LynewedSpacing.sm (8px)** between chips

### Reference
- Copy **sheet pattern** from `lib/features/my_wedding/presentation/widgets/create_album_sheet.dart`

---

## Screen States

### Filter Sheet

```dart
DraggableScrollableSheet(
  initialChildSize: 0.9,
  minChildSize: 0.5,
  maxChildSize: 0.95,
  builder: (context, scrollController) => LynewedSheet(
    title: 'Filters',
    onClose: () => Navigator.pop(context),
    bottomAction: LynewedButton(
      label: 'Apply ($previewCount results)',
      onPressed: _applyFilters,
    ),
    child: SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clear all button
          Align(
            alignment: Alignment.centerRight,
            child: LynewedButton(
              label: 'Clear all',
              variant: ButtonVariant.text,
              onPressed: _clearAllFilters,
            ),
          ),
          SizedBox(height: LynewedSpacing.md),

          // Category section
          _buildCategorySection(),
          SizedBox(height: LynewedSpacing.lg),

          // Price range section
          _buildPriceRangeSection(),
          SizedBox(height: LynewedSpacing.lg),

          // Size section
          _buildSizeSection(),
          SizedBox(height: LynewedSpacing.lg),

          // Brand section
          _buildBrandSection(),
          SizedBox(height: LynewedSpacing.lg),

          // Condition section
          _buildConditionSection(),
          SizedBox(height: LynewedSpacing.lg),

          // Location section
          _buildLocationSection(),
        ],
      ),
    ),
  ),
)
```

### Filter Badges (on Feed)

```dart
// Show active filters as chips below category chips
if (_currentFilter.hasActiveFilters)
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: [
        if (_currentFilter.category != null)
          _buildFilterBadge(
            label: _currentFilter.category!.capitalize(),
            onRemove: () => _removeFilter('category'),
          ),
        if (_currentFilter.minPriceCents != null || _currentFilter.maxPriceCents != null)
          _buildFilterBadge(
            label: '${_currentFilter.minPriceCents ?? 0} - ${_currentFilter.maxPriceCents ?? 'Any'}',
            onRemove: () => _removeFilter('price'),
          ),
        // ... other filter badges
        LynewedButton(
          label: 'Clear all',
          variant: ButtonVariant.text,
          size: ButtonSize.small,
          onPressed: _clearAllFilters,
        ),
      ],
    ),
  )

Widget _buildFilterBadge({required String label, required VoidCallback onRemove}) {
  return Container(
    margin: EdgeInsets.only(right: LynewedSpacing.sm),
    child: LynewedChip(
      label: label,
      isSelected: true,
      onDelete: onRemove,
    ),
  );
}
```

---

## Technical Specifications

### PostGIS for Radius Filtering

Create RPC function in Supabase:

```sql
-- In S01 migration or separate migration
CREATE OR REPLACE FUNCTION listings_within_radius(
  lat double precision,
  lng double precision,
  radius_km double precision
)
RETURNS SETOF marketplace_listings AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM marketplace_listings
  WHERE status = 'active'
    AND ST_DWithin(
      ST_MakePoint(longitude, latitude)::geography,
      ST_MakePoint(lng, lat)::geography,
      radius_km * 1000 -- Convert km to meters
    )
  ORDER BY
    ST_Distance(
      ST_MakePoint(longitude, latitude)::geography,
      ST_MakePoint(lng, lat)::geography
    );
END;
$$ LANGUAGE plpgsql;
```

Call from repository:

```dart
@override
Future<List<ListingEntity>> getListingsWithinRadius({
  required double latitude,
  required double longitude,
  required double radiusKm,
  ListingFilter? filter,
}) async {
  final response = await _supabase.rpc(
    'listings_within_radius',
    params: {
      'lat': latitude,
      'lng': longitude,
      'radius_km': radiusKm,
    },
  ).timeout(const Duration(seconds: 3));

  return (response as List)
    .map((json) => ListingEntity.fromJson(json))
    .toList();
}
```

### Preview Count with Debounce

```dart
Timer? _previewDebounceTimer;
int _previewCount = 0;
bool _isLoadingPreview = false;

void _updatePreviewCount() {
  _previewDebounceTimer?.cancel();
  _previewDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
    if (!mounted) return;

    setState(() => _isLoadingPreview = true);

    try {
      final count = await ref
          .read(marketplaceRepositoryProvider)
          .getFilteredListingsCount(_currentFilter)
          .timeout(const Duration(seconds: 3));

      if (mounted) {
        setState(() {
          _previewCount = count;
          _isLoadingPreview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _previewCount = 0;
          _isLoadingPreview = false;
        });
      }
    }
  });
}

// Call on every filter change
void _onFilterChanged(ListingFilter newFilter) {
  setState(() => _currentFilter = newFilter);
  _updatePreviewCount();
}
```

### Size Filter (Conditional on Category)

```dart
class SizeFilterWidget extends StatelessWidget {
  const SizeFilterWidget({
    super.key,
    required this.category,
    required this.selectedSizes,
    required this.onChanged,
  });

  final String? category;
  final List<String>? selectedSizes;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final sizes = category == 'dress'
        ? dressSizes
        : category == 'shoes'
            ? shoeSizes
            : <SizeOption>[];

    if (sizes.isEmpty) {
      return Text(
        'Select a category first',
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.textSecondary,
        ),
      );
    }

    return Wrap(
      spacing: LynewedSpacing.sm,
      runSpacing: LynewedSpacing.sm,
      children: sizes.map((size) {
        final isSelected = selectedSizes?.contains(size.value) ?? false;
        return LynewedChip(
          label: size.label,
          isSelected: isSelected,
          onTap: () {
            final newSizes = List<String>.from(selectedSizes ?? []);
            if (isSelected) {
              newSizes.remove(size.value);
            } else {
              newSizes.add(size.value);
            }
            onChanged(newSizes);
          },
        );
      }).toList(),
    );
  }
}
```

### Brand Autocomplete + Custom Entry

```dart
class BrandFilterWidget extends StatefulWidget {
  const BrandFilterWidget({
    super.key,
    required this.category,
    required this.selectedBrands,
    required this.onChanged,
  });

  final String? category;
  final List<String>? selectedBrands;
  final ValueChanged<List<String>> onChanged;

  @override
  State<BrandFilterWidget> createState() => _BrandFilterWidgetState();
}

class _BrandFilterWidgetState extends State<BrandFilterWidget> {
  late List<String> _availableBrands;

  @override
  void initState() {
    super.initState();
    _updateAvailableBrands();
  }

  @override
  void didUpdateWidget(BrandFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _updateAvailableBrands();
    }
  }

  void _updateAvailableBrands() {
    _availableBrands = widget.category == 'dress'
        ? popularWeddingDressBrands
        : widget.category == 'shoes'
            ? popularBridalShoeBrands
            : [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Autocomplete
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _availableBrands.where((brand) =>
                brand.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (brand) {
            final newBrands = List<String>.from(widget.selectedBrands ?? []);
            if (!newBrands.contains(brand)) {
              newBrands.add(brand);
              widget.onChanged(newBrands);
            }
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return LynewedTextField(
              controller: controller,
              focusNode: focusNode,
              hintText: 'Search brands...',
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  final newBrands = List<String>.from(widget.selectedBrands ?? []);
                  if (!newBrands.contains(value)) {
                    newBrands.add(value);
                    widget.onChanged(newBrands);
                  }
                  controller.clear();
                }
              },
            );
          },
        ),
        SizedBox(height: LynewedSpacing.sm),

        // Selected brands
        if (widget.selectedBrands != null && widget.selectedBrands!.isNotEmpty)
          Wrap(
            spacing: LynewedSpacing.sm,
            runSpacing: LynewedSpacing.sm,
            children: widget.selectedBrands!.map((brand) {
              return LynewedChip(
                label: brand,
                isSelected: true,
                onDelete: () {
                  final newBrands = List<String>.from(widget.selectedBrands!);
                  newBrands.remove(brand);
                  widget.onChanged(newBrands);
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}
```

### Location Filter (Country + Radius)

```dart
class LocationFilterWidget extends StatelessWidget {
  const LocationFilterWidget({
    super.key,
    required this.country,
    required this.radiusKm,
    required this.onCountryChanged,
    required this.onRadiusChanged,
  });

  final String? country;
  final double? radiusKm;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<double?> onRadiusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country dropdown
        LynewedSectionTitle('Country'),
        SizedBox(height: LynewedSpacing.sm),
        DropdownButtonFormField<String>(
          value: country,
          decoration: InputDecoration(
            hintText: 'Select country',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: _countries.map((c) {
            return DropdownMenuItem(value: c, child: Text(c));
          }).toList(),
          onChanged: onCountryChanged,
        ),
        SizedBox(height: LynewedSpacing.lg),

        // Radius slider
        LynewedSectionTitle('Radius: ${radiusKm?.toInt() ?? 50} km'),
        SizedBox(height: LynewedSpacing.sm),
        LynewedSlider(
          value: radiusKm ?? 50,
          min: 0,
          max: 100,
          divisions: 10,
          onChanged: onRadiusChanged,
        ),
      ],
    );
  }

  static const _countries = [
    'France',
    'United States',
    'United Kingdom',
    'Germany',
    'Italy',
    'Spain',
    // ... add more countries
  ];
}
```

### Supabase Query with Filters

```dart
@override
Future<List<ListingEntity>> getFilteredListings({
  required ListingFilter filter,
  int page = 0,
  int pageSize = 20,
}) async {
  var query = _supabase
      .from('marketplace_listings')
      .select('*, photos:marketplace_photos(storage_path, position)')
      .eq('status', 'active')
      .order('created_at', ascending: false)
      .range(page * pageSize, (page + 1) * pageSize - 1);

  // Apply filters
  if (filter.category != null) {
    query = query.eq('category', filter.category);
  }
  if (filter.minPriceCents != null) {
    query = query.gte('price_cents', filter.minPriceCents);
  }
  if (filter.maxPriceCents != null) {
    query = query.lte('price_cents', filter.maxPriceCents);
  }
  if (filter.sizes != null && filter.sizes!.isNotEmpty) {
    query = query.in_('size', filter.sizes!);
  }
  if (filter.brands != null && filter.brands!.isNotEmpty) {
    query = query.in_('designer_brand', filter.brands!);
  }
  if (filter.conditions != null && filter.conditions!.isNotEmpty) {
    query = query.in_('condition', filter.conditions!);
  }
  if (filter.country != null) {
    query = query.eq('country', filter.country);
  }

  final response = await query;

  // If radius filter, apply PostGIS filtering
  if (filter.radiusKm != null && filter.latitude != null && filter.longitude != null) {
    return getListingsWithinRadius(
      latitude: filter.latitude!,
      longitude: filter.longitude!,
      radiusKm: filter.radiusKm!,
      filter: filter,
    );
  }

  return (response as List)
      .map((json) => ListingEntity.fromJson(json))
      .toList();
}

@override
Future<int> getFilteredListingsCount(ListingFilter filter) async {
  var query = _supabase
      .from('marketplace_listings')
      .select('id', const FetchOptions(count: CountOption.exact))
      .eq('status', 'active');

  // Apply same filters as getFilteredListings
  if (filter.category != null) {
    query = query.eq('category', filter.category);
  }
  if (filter.minPriceCents != null) {
    query = query.gte('price_cents', filter.minPriceCents);
  }
  if (filter.maxPriceCents != null) {
    query = query.lte('price_cents', filter.maxPriceCents);
  }
  if (filter.sizes != null && filter.sizes!.isNotEmpty) {
    query = query.in_('size', filter.sizes!);
  }
  if (filter.brands != null && filter.brands!.isNotEmpty) {
    query = query.in_('designer_brand', filter.brands!);
  }
  if (filter.conditions != null && filter.conditions!.isNotEmpty) {
    query = query.in_('condition', filter.conditions!);
  }
  if (filter.country != null) {
    query = query.eq('country', filter.country);
  }

  final response = await query.count();
  return response.count;
}
```

---

## Tests Requis

### Entity Tests
```dart
// test/features/marketplace/domain/entities/listing_filter_test.dart

- ListingFilter.empty creates empty filter
- ListingFilter.hasActiveFilters returns false when empty
- ListingFilter.hasActiveFilters returns true when filters set
- ListingFilter.activeFilterCount returns correct count
- ListingFilter.copyWith preserves unchanged fields
- ListingFilter.copyWith clears fields when clear flags set
- ListingFilter equality (==, hashCode) works correctly
```

### Widget Tests
```dart
// test/features/marketplace/presentation/widgets/filter_sheet_test.dart

- FilterSheet renders all filter sections
- FilterSheet updates preview count when filters change
- FilterSheet debounces preview count updates (500ms)
- FilterSheet applies filters when Apply button tapped
- FilterSheet clears all filters when Clear all tapped
- FilterSheet closes when Close button tapped
- SizeFilterWidget shows dress sizes when category is dress
- SizeFilterWidget shows shoe sizes when category is shoes
- SizeFilterWidget shows "Select category first" when no category
- BrandFilterWidget allows custom brand entry
- LocationFilterWidget shows country dropdown and radius slider
```

### Repository Tests
```dart
// test/features/marketplace/data/repositories/supabase_marketplace_repository_test.dart

- getFilteredListings filters by category correctly
- getFilteredListings filters by price range correctly
- getFilteredListings filters by sizes correctly
- getFilteredListings filters by brands correctly
- getFilteredListings filters by conditions correctly
- getFilteredListings filters by country correctly
- getFilteredListings combines multiple filters with AND logic
- getFilteredListingsCount returns correct count
- getFilteredListingsCount times out after 3 seconds
- getListingsWithinRadius uses PostGIS RPC function
- getListingsWithinRadius orders by distance
```

---

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
