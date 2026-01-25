import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/feed_filter.dart';

void main() {
  group('FeedFilter', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create FeedFilter with default values', () {
        const filter = FeedFilter();

        expect(filter.professions, isEmpty);
        expect(filter.locationQuery, isNull);
        expect(filter.sortBy, FeedSortBy.recent);
      });

      test('should create FeedFilter with all fields', () {
        const filter = FeedFilter(
          professions: ['photographer', 'videographer'],
          locationQuery: 'Paris',
          sortBy: FeedSortBy.popular,
        );

        expect(filter.professions, ['photographer', 'videographer']);
        expect(filter.locationQuery, 'Paris');
        expect(filter.sortBy, FeedSortBy.popular);
      });

      test('should create FeedFilter with single profession', () {
        const filter = FeedFilter(
          professions: ['florist'],
        );

        expect(filter.professions, ['florist']);
        expect(filter.professions, hasLength(1));
      });
    });

    // ==============================================================
    // COMPUTED PROPERTIES
    // ==============================================================

    group('computed properties', () {
      test('hasFilters should return false when all defaults', () {
        const filter = FeedFilter();

        expect(filter.hasFilters, false);
      });

      test('hasFilters should return true when professions set', () {
        const filter = FeedFilter(
          professions: ['photographer'],
        );

        expect(filter.hasFilters, true);
      });

      test('hasFilters should return true when locationQuery set', () {
        const filter = FeedFilter(
          locationQuery: 'Paris',
        );

        expect(filter.hasFilters, true);
      });

      test('hasFilters should return true when sortBy is not recent', () {
        const filter = FeedFilter(
          sortBy: FeedSortBy.popular,
        );

        expect(filter.hasFilters, true);
      });

      test('hasFilters should return false for empty professions and null location', () {
        const filter = FeedFilter(
          professions: [],
          locationQuery: null,
          sortBy: FeedSortBy.recent,
        );

        expect(filter.hasFilters, false);
      });

      test('hasFilters should return false for empty string location', () {
        const filter = FeedFilter(
          professions: [],
          locationQuery: '',
          sortBy: FeedSortBy.recent,
        );

        expect(filter.hasFilters, false);
      });

      test('activeFilterCount should return 0 when no filters active', () {
        const filter = FeedFilter();

        expect(filter.activeFilterCount, 0);
      });

      test('activeFilterCount should count professions correctly', () {
        const filter = FeedFilter(
          professions: ['photographer', 'videographer', 'florist'],
        );

        expect(filter.activeFilterCount, 3);
      });

      test('activeFilterCount should include location when set', () {
        const filter = FeedFilter(
          professions: ['photographer'],
          locationQuery: 'Paris',
        );

        expect(filter.activeFilterCount, 2);
      });

      test('activeFilterCount should include sortBy when not recent', () {
        const filter = FeedFilter(
          sortBy: FeedSortBy.popular,
        );

        expect(filter.activeFilterCount, 1);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        const original = FeedFilter(
          professions: ['photographer'],
          locationQuery: 'Paris',
          sortBy: FeedSortBy.popular,
        );

        final copied = original.copyWith(locationQuery: 'Lyon');

        expect(copied.professions, ['photographer']);
        expect(copied.locationQuery, 'Lyon');
        expect(copied.sortBy, FeedSortBy.popular);
      });

      test('should update professions', () {
        const original = FeedFilter(
          professions: ['photographer'],
        );

        final copied = original.copyWith(
          professions: ['videographer', 'florist'],
        );

        expect(copied.professions, ['videographer', 'florist']);
      });

      test('should update sortBy', () {
        const original = FeedFilter(
          sortBy: FeedSortBy.recent,
        );

        final copied = original.copyWith(sortBy: FeedSortBy.alphabetical);

        expect(copied.sortBy, FeedSortBy.alphabetical);
      });

      test('should clear location with clearLocation flag', () {
        const original = FeedFilter(
          locationQuery: 'Paris',
        );

        final copied = original.copyWith(clearLocation: true);

        expect(copied.locationQuery, isNull);
      });

      test('should not modify original', () {
        const original = FeedFilter(
          professions: ['photographer'],
        );

        original.copyWith(professions: ['videographer']);

        expect(original.professions, ['photographer']);
      });
    });

    // ==============================================================
    // ADDPROFESSION / REMOVEPROFESSION TESTS
    // ==============================================================

    group('addProfession', () {
      test('should add profession to empty list', () {
        const filter = FeedFilter();

        final updated = filter.addProfession('photographer');

        expect(updated.professions, ['photographer']);
      });

      test('should add profession to existing list', () {
        const filter = FeedFilter(
          professions: ['photographer'],
        );

        final updated = filter.addProfession('videographer');

        expect(updated.professions, ['photographer', 'videographer']);
      });

      test('should not add duplicate profession', () {
        const filter = FeedFilter(
          professions: ['photographer'],
        );

        final updated = filter.addProfession('photographer');

        expect(updated.professions, ['photographer']);
      });
    });

    group('removeProfession', () {
      test('should remove profession from list', () {
        const filter = FeedFilter(
          professions: ['photographer', 'videographer'],
        );

        final updated = filter.removeProfession('photographer');

        expect(updated.professions, ['videographer']);
      });

      test('should handle removing non-existent profession', () {
        const filter = FeedFilter(
          professions: ['photographer'],
        );

        final updated = filter.removeProfession('florist');

        expect(updated.professions, ['photographer']);
      });

      test('should return empty list when removing last profession', () {
        const filter = FeedFilter(
          professions: ['photographer'],
        );

        final updated = filter.removeProfession('photographer');

        expect(updated.professions, isEmpty);
      });
    });

    // ==============================================================
    // TOGGLEPROFESSION TEST
    // ==============================================================

    group('toggleProfession', () {
      test('should add profession when not present', () {
        const filter = FeedFilter();

        final updated = filter.toggleProfession('photographer');

        expect(updated.professions, contains('photographer'));
      });

      test('should remove profession when already present', () {
        const filter = FeedFilter(
          professions: ['photographer'],
        );

        final updated = filter.toggleProfession('photographer');

        expect(updated.professions, isNot(contains('photographer')));
      });
    });

    // ==============================================================
    // RESET TEST
    // ==============================================================

    group('reset', () {
      test('should reset all filters to default', () {
        const filter = FeedFilter(
          professions: ['photographer', 'videographer'],
          locationQuery: 'Paris',
          sortBy: FeedSortBy.popular,
        );

        final reset = filter.reset();

        expect(reset.professions, isEmpty);
        expect(reset.locationQuery, isNull);
        expect(reset.sortBy, FeedSortBy.recent);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields match', () {
        const filter1 = FeedFilter(
          professions: ['photographer'],
          locationQuery: 'Paris',
          sortBy: FeedSortBy.popular,
        );
        const filter2 = FeedFilter(
          professions: ['photographer'],
          locationQuery: 'Paris',
          sortBy: FeedSortBy.popular,
        );

        expect(filter1, equals(filter2));
        expect(filter1.hashCode, equals(filter2.hashCode));
      });

      test('should not be equal when professions differ', () {
        const filter1 = FeedFilter(
          professions: ['photographer'],
        );
        const filter2 = FeedFilter(
          professions: ['videographer'],
        );

        expect(filter1, isNot(equals(filter2)));
      });

      test('should not be equal when locationQuery differs', () {
        const filter1 = FeedFilter(
          locationQuery: 'Paris',
        );
        const filter2 = FeedFilter(
          locationQuery: 'Lyon',
        );

        expect(filter1, isNot(equals(filter2)));
      });

      test('should not be equal when sortBy differs', () {
        const filter1 = FeedFilter(
          sortBy: FeedSortBy.recent,
        );
        const filter2 = FeedFilter(
          sortBy: FeedSortBy.popular,
        );

        expect(filter1, isNot(equals(filter2)));
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const filter = FeedFilter(
          professions: ['photographer'],
          locationQuery: 'Paris',
          sortBy: FeedSortBy.popular,
        );

        final result = filter.toString();

        expect(result, contains('photographer'));
        expect(result, contains('Paris'));
        expect(result, contains('popular'));
      });
    });
  });

  // ==============================================================
  // FEEDSORTBY ENUM TESTS
  // ==============================================================

  group('FeedSortBy', () {
    test('should have all expected values', () {
      expect(FeedSortBy.values, contains(FeedSortBy.recent));
      expect(FeedSortBy.values, contains(FeedSortBy.popular));
      expect(FeedSortBy.values, contains(FeedSortBy.alphabetical));
      expect(FeedSortBy.values.length, 3);
    });

    test('displayName should return correct values', () {
      expect(FeedSortBy.recent.displayName, 'Most recent');
      expect(FeedSortBy.popular.displayName, 'Most popular');
      expect(FeedSortBy.alphabetical.displayName, 'A to Z');
    });
  });
}
