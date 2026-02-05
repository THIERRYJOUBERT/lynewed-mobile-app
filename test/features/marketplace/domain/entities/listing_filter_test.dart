/// Tests for ListingFilter entity.
///
/// Verifies creation, computed properties, copyWith with clear flags,
/// equality, and toString.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/listing_filter.dart';

void main() {
  group('ListingFilter', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('empty constructor creates filter with all null fields', () {
        const filter = ListingFilter.empty();

        expect(filter.category, isNull);
        expect(filter.minPriceCents, isNull);
        expect(filter.maxPriceCents, isNull);
        expect(filter.sizes, isNull);
        expect(filter.brands, isNull);
        expect(filter.conditions, isNull);
        expect(filter.country, isNull);
      });

      test('should create filter with all fields set', () {
        const filter = ListingFilter(
          category: 'dress',
          minPriceCents: 10000,
          maxPriceCents: 50000,
          sizes: ['S', 'M'],
          brands: ['Vera Wang'],
          conditions: ['new', 'excellent'],
          country: 'France',
        );

        expect(filter.category, 'dress');
        expect(filter.minPriceCents, 10000);
        expect(filter.maxPriceCents, 50000);
        expect(filter.sizes, ['S', 'M']);
        expect(filter.brands, ['Vera Wang']);
        expect(filter.conditions, ['new', 'excellent']);
        expect(filter.country, 'France');
      });

      test('should create filter with partial fields', () {
        const filter = ListingFilter(
          category: 'shoes',
          minPriceCents: 5000,
        );

        expect(filter.category, 'shoes');
        expect(filter.minPriceCents, 5000);
        expect(filter.maxPriceCents, isNull);
        expect(filter.sizes, isNull);
        expect(filter.brands, isNull);
        expect(filter.conditions, isNull);
        expect(filter.country, isNull);
      });
    });

    // ==============================================================
    // HAS ACTIVE FILTERS TESTS
    // ==============================================================

    group('hasActiveFilters', () {
      test('returns false when empty', () {
        const filter = ListingFilter.empty();
        expect(filter.hasActiveFilters, isFalse);
      });

      test('returns true when category is set', () {
        const filter = ListingFilter(category: 'dress');
        expect(filter.hasActiveFilters, isTrue);
      });

      test('returns true when minPriceCents is set', () {
        const filter = ListingFilter(minPriceCents: 1000);
        expect(filter.hasActiveFilters, isTrue);
      });

      test('returns true when maxPriceCents is set', () {
        const filter = ListingFilter(maxPriceCents: 50000);
        expect(filter.hasActiveFilters, isTrue);
      });

      test('returns true when sizes is non-empty', () {
        const filter = ListingFilter(sizes: ['S', 'M']);
        expect(filter.hasActiveFilters, isTrue);
      });

      test('returns false when sizes is empty list', () {
        const filter = ListingFilter(sizes: []);
        expect(filter.hasActiveFilters, isFalse);
      });

      test('returns true when brands is non-empty', () {
        const filter = ListingFilter(brands: ['Vera Wang']);
        expect(filter.hasActiveFilters, isTrue);
      });

      test('returns false when brands is empty list', () {
        const filter = ListingFilter(brands: []);
        expect(filter.hasActiveFilters, isFalse);
      });

      test('returns true when conditions is non-empty', () {
        const filter = ListingFilter(conditions: ['new']);
        expect(filter.hasActiveFilters, isTrue);
      });

      test('returns false when conditions is empty list', () {
        const filter = ListingFilter(conditions: []);
        expect(filter.hasActiveFilters, isFalse);
      });

      test('returns true when country is set', () {
        const filter = ListingFilter(country: 'France');
        expect(filter.hasActiveFilters, isTrue);
      });
    });

    // ==============================================================
    // ACTIVE FILTER COUNT TESTS
    // ==============================================================

    group('activeFilterCount', () {
      test('returns 0 when empty', () {
        const filter = ListingFilter.empty();
        expect(filter.activeFilterCount, 0);
      });

      test('returns 1 for single category filter', () {
        const filter = ListingFilter(category: 'dress');
        expect(filter.activeFilterCount, 1);
      });

      test('returns 1 for price range with only min', () {
        const filter = ListingFilter(minPriceCents: 1000);
        expect(filter.activeFilterCount, 1);
      });

      test('returns 1 for price range with only max', () {
        const filter = ListingFilter(maxPriceCents: 50000);
        expect(filter.activeFilterCount, 1);
      });

      test('returns 1 for price range with both min and max', () {
        const filter = ListingFilter(
          minPriceCents: 1000,
          maxPriceCents: 50000,
        );
        expect(filter.activeFilterCount, 1);
      });

      test('returns correct count for all filters active', () {
        const filter = ListingFilter(
          category: 'dress',
          minPriceCents: 1000,
          maxPriceCents: 50000,
          sizes: ['S'],
          brands: ['Vera Wang'],
          conditions: ['new'],
          country: 'France',
        );
        expect(filter.activeFilterCount, 6);
      });

      test('does not count empty lists as active', () {
        const filter = ListingFilter(
          category: 'dress',
          sizes: [],
          brands: [],
          conditions: [],
        );
        expect(filter.activeFilterCount, 1);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('preserves unchanged fields', () {
        const original = ListingFilter(
          category: 'dress',
          minPriceCents: 1000,
          country: 'France',
        );

        final updated = original.copyWith(country: 'Spain');

        expect(updated.category, 'dress');
        expect(updated.minPriceCents, 1000);
        expect(updated.country, 'Spain');
      });

      test('updates category', () {
        const original = ListingFilter(category: 'dress');
        final updated = original.copyWith(category: 'shoes');
        expect(updated.category, 'shoes');
      });

      test('updates price range', () {
        const original = ListingFilter.empty();
        final updated = original.copyWith(
          minPriceCents: 5000,
          maxPriceCents: 20000,
        );
        expect(updated.minPriceCents, 5000);
        expect(updated.maxPriceCents, 20000);
      });

      test('updates sizes', () {
        const original = ListingFilter.empty();
        final updated = original.copyWith(sizes: ['S', 'M', 'L']);
        expect(updated.sizes, ['S', 'M', 'L']);
      });

      test('updates brands', () {
        const original = ListingFilter.empty();
        final updated = original.copyWith(brands: ['Vera Wang', 'Pronovias']);
        expect(updated.brands, ['Vera Wang', 'Pronovias']);
      });

      test('updates conditions', () {
        const original = ListingFilter.empty();
        final updated = original.copyWith(conditions: ['new', 'excellent']);
        expect(updated.conditions, ['new', 'excellent']);
      });

      test('clears category when clearCategory is true', () {
        const original = ListingFilter(category: 'dress');
        final updated = original.copyWith(clearCategory: true);
        expect(updated.category, isNull);
      });

      test('clears price range when clearPriceRange is true', () {
        const original = ListingFilter(
          minPriceCents: 1000,
          maxPriceCents: 50000,
        );
        final updated = original.copyWith(clearPriceRange: true);
        expect(updated.minPriceCents, isNull);
        expect(updated.maxPriceCents, isNull);
      });

      test('clears sizes when clearSizes is true', () {
        const original = ListingFilter(sizes: ['S', 'M']);
        final updated = original.copyWith(clearSizes: true);
        expect(updated.sizes, isNull);
      });

      test('clears brands when clearBrands is true', () {
        const original = ListingFilter(brands: ['Vera Wang']);
        final updated = original.copyWith(clearBrands: true);
        expect(updated.brands, isNull);
      });

      test('clears conditions when clearConditions is true', () {
        const original = ListingFilter(conditions: ['new']);
        final updated = original.copyWith(clearConditions: true);
        expect(updated.conditions, isNull);
      });

      test('clears country when clearCountry is true', () {
        const original = ListingFilter(country: 'France');
        final updated = original.copyWith(clearCountry: true);
        expect(updated.country, isNull);
      });

      test('clear flag takes priority over new value', () {
        const original = ListingFilter(category: 'dress');
        final updated = original.copyWith(
          category: 'shoes',
          clearCategory: true,
        );
        expect(updated.category, isNull);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('two empty filters are equal', () {
        const filter1 = ListingFilter.empty();
        const filter2 = ListingFilter.empty();
        expect(filter1, equals(filter2));
        expect(filter1.hashCode, equals(filter2.hashCode));
      });

      test('filters with same fields are equal', () {
        const filter1 = ListingFilter(
          category: 'dress',
          minPriceCents: 1000,
          sizes: ['S', 'M'],
          brands: ['Vera Wang'],
          conditions: ['new'],
          country: 'France',
        );
        const filter2 = ListingFilter(
          category: 'dress',
          minPriceCents: 1000,
          sizes: ['S', 'M'],
          brands: ['Vera Wang'],
          conditions: ['new'],
          country: 'France',
        );
        expect(filter1, equals(filter2));
        expect(filter1.hashCode, equals(filter2.hashCode));
      });

      test('filters with different categories are not equal', () {
        const filter1 = ListingFilter(category: 'dress');
        const filter2 = ListingFilter(category: 'shoes');
        expect(filter1, isNot(equals(filter2)));
      });

      test('filters with different sizes are not equal', () {
        const filter1 = ListingFilter(sizes: ['S']);
        const filter2 = ListingFilter(sizes: ['M']);
        expect(filter1, isNot(equals(filter2)));
      });

      test('filter is equal to itself', () {
        const filter = ListingFilter(category: 'dress');
        expect(filter, equals(filter));
      });

      test('filter is not equal to non-ListingFilter object', () {
        const filter = ListingFilter(category: 'dress');
        final Object other = 'not a filter';
        expect(filter == other, isFalse);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('shows active filter count', () {
        const filter = ListingFilter(
          category: 'dress',
          minPriceCents: 1000,
          country: 'France',
        );
        expect(filter.toString(), 'ListingFilter(3 active)');
      });

      test('shows 0 active for empty filter', () {
        const filter = ListingFilter.empty();
        expect(filter.toString(), 'ListingFilter(0 active)');
      });
    });
  });
}
