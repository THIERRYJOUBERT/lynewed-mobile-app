/// ListingFilter entity - Filter criteria for marketplace listings.
///
/// Immutable data class representing the current filter state.
/// All fields are optional; null means "not filtered".
library;

import 'package:flutter/foundation.dart';

/// Represents active filters for marketplace listings.
///
/// All fields are optional. A null value means no filter is applied
/// for that dimension. Lists must be non-empty to count as active.
@immutable
class ListingFilter {
  /// Creates a listing filter with optional criteria.
  const ListingFilter({
    this.category,
    this.minPriceCents,
    this.maxPriceCents,
    this.sizes,
    this.brands,
    this.conditions,
    this.country,
  });

  /// Creates an empty filter with all fields null.
  const ListingFilter.empty()
      : category = null,
        minPriceCents = null,
        maxPriceCents = null,
        sizes = null,
        brands = null,
        conditions = null,
        country = null;

  /// Category filter: 'dress', 'shoes', or null for all.
  final String? category;

  /// Minimum price in cents (inclusive).
  final int? minPriceCents;

  /// Maximum price in cents (inclusive).
  final int? maxPriceCents;

  /// Selected sizes (dress: 'XS', 'S', etc.; shoes: '35', '36', etc.).
  final List<String>? sizes;

  /// Selected brands (designer names).
  final List<String>? brands;

  /// Selected conditions: 'new', 'excellent', 'good', 'fair'.
  final List<String>? conditions;

  /// Country name filter.
  final String? country;

  /// Whether any filters are currently active.
  bool get hasActiveFilters =>
      category != null ||
      minPriceCents != null ||
      maxPriceCents != null ||
      (sizes != null && sizes!.isNotEmpty) ||
      (brands != null && brands!.isNotEmpty) ||
      (conditions != null && conditions!.isNotEmpty) ||
      country != null;

  /// Count of active filter dimensions (for badge display).
  ///
  /// Price range counts as 1 even if both min and max are set.
  int get activeFilterCount {
    var count = 0;
    if (category != null) count++;
    if (minPriceCents != null || maxPriceCents != null) count++;
    if (sizes != null && sizes!.isNotEmpty) count++;
    if (brands != null && brands!.isNotEmpty) count++;
    if (conditions != null && conditions!.isNotEmpty) count++;
    if (country != null) count++;
    return count;
  }

  /// Creates a copy with updated fields.
  ///
  /// Use clear flags to explicitly set a field to null.
  /// Clear flags take priority over new values.
  ListingFilter copyWith({
    String? category,
    int? minPriceCents,
    int? maxPriceCents,
    List<String>? sizes,
    List<String>? brands,
    List<String>? conditions,
    String? country,
    bool clearCategory = false,
    bool clearPriceRange = false,
    bool clearSizes = false,
    bool clearBrands = false,
    bool clearConditions = false,
    bool clearCountry = false,
  }) {
    return ListingFilter(
      category: clearCategory ? null : (category ?? this.category),
      minPriceCents:
          clearPriceRange ? null : (minPriceCents ?? this.minPriceCents),
      maxPriceCents:
          clearPriceRange ? null : (maxPriceCents ?? this.maxPriceCents),
      sizes: clearSizes ? null : (sizes ?? this.sizes),
      brands: clearBrands ? null : (brands ?? this.brands),
      conditions: clearConditions ? null : (conditions ?? this.conditions),
      country: clearCountry ? null : (country ?? this.country),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListingFilter &&
        other.category == category &&
        other.minPriceCents == minPriceCents &&
        other.maxPriceCents == maxPriceCents &&
        listEquals(other.sizes, sizes) &&
        listEquals(other.brands, brands) &&
        listEquals(other.conditions, conditions) &&
        other.country == country;
  }

  @override
  int get hashCode => Object.hash(
        category,
        minPriceCents,
        maxPriceCents,
        sizes != null ? Object.hashAll(sizes!) : null,
        brands != null ? Object.hashAll(brands!) : null,
        conditions != null ? Object.hashAll(conditions!) : null,
        country,
      );

  @override
  String toString() => 'ListingFilter($activeFilterCount active)';
}
