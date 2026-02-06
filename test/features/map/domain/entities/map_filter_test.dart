import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/map/domain/entities/entities.dart';

void main() {
  group('MapFilter', () {
    test('defaults should create filter with default values', () {
      const filter = MapFilter.defaults;

      expect(filter.professions, isEmpty);
      expect(filter.budgetMin, isNull);
      expect(filter.budgetMax, isNull);
      expect(filter.toggles.showPros, true);
      expect(filter.toggles.showAlerts, true);
      expect(filter.toggles.showWeddings, true);
    });

    test('hasProfessionFilter should return true when professions set', () {
      const filter = MapFilter(
        professions: [Profession.photographer],
      );

      expect(filter.hasProfessionFilter, true);
    });

    test('hasProfessionFilter should return false when professions empty', () {
      const filter = MapFilter.defaults;

      expect(filter.hasProfessionFilter, false);
    });

    test('hasBudgetFilter should return true when budget set', () {
      const filterMin = MapFilter(budgetMin: 1000);
      const filterMax = MapFilter(budgetMax: 5000);
      const filterBoth = MapFilter(budgetMin: 1000, budgetMax: 5000);

      expect(filterMin.hasBudgetFilter, true);
      expect(filterMax.hasBudgetFilter, true);
      expect(filterBoth.hasBudgetFilter, true);
    });

    test('hasBudgetFilter should return false when no budget set', () {
      const filter = MapFilter.defaults;

      expect(filter.hasBudgetFilter, false);
    });

    test('copyWith should create new instance with updated values', () {
      const original = MapFilter(
        professions: [Profession.photographer],
        budgetMin: 1000,
      );

      final updated = original.copyWith(
        budgetMax: 5000,
      );

      expect(updated.professions, original.professions);
      expect(updated.budgetMin, original.budgetMin);
      expect(updated.budgetMax, 5000);
    });

    test('copyWith should allow clearing values', () {
      const original = MapFilter(
        professions: [Profession.photographer],
        budgetMin: 1000,
      );

      final updated = original.copyWith(
        professions: [],
      );

      expect(updated.professions, isEmpty);
      expect(updated.budgetMin, original.budgetMin);
    });
  });

  group('MapFilter minRating', () {
    test('should have null minRating by default', () {
      const filter = MapFilter();
      expect(filter.minRating, isNull);
      expect(filter.hasRatingFilter, isFalse);
    });

    test('MapFilter.defaults should have null minRating', () {
      const filter = MapFilter.defaults;
      expect(filter.minRating, isNull);
      expect(filter.hasRatingFilter, isFalse);
    });

    test('should accept minRating value', () {
      const filter = MapFilter(minRating: 4.0);
      expect(filter.minRating, 4.0);
      expect(filter.hasRatingFilter, isTrue);
    });

    test('should update minRating with copyWith', () {
      const filter = MapFilter(minRating: 3.0);
      final updated = filter.copyWith(minRating: 4.5);
      expect(updated.minRating, 4.5);
    });

    test('should preserve minRating when copyWith called without it', () {
      const filter = MapFilter(minRating: 3.0);
      final updated = filter.copyWith(budgetMin: 1000);
      expect(updated.minRating, 3.0);
    });

    test('should clear minRating with clearMinRating: true', () {
      const filter = MapFilter(minRating: 4.0);
      final updated = filter.copyWith(clearMinRating: true);
      expect(updated.minRating, isNull);
      expect(updated.hasRatingFilter, isFalse);
    });

    test('should treat 0 as no filter', () {
      const filter = MapFilter(minRating: 0);
      expect(filter.hasRatingFilter, isFalse);
    });

    test('should treat negative values as no filter', () {
      const filter = MapFilter(minRating: -1.0);
      expect(filter.hasRatingFilter, isFalse);
    });

    test('should not be equal when minRating differs', () {
      const filter1 = MapFilter(minRating: 3.0);
      const filter2 = MapFilter(minRating: 4.0);
      expect(filter1, isNot(equals(filter2)));
    });

    test('should be equal when minRating is the same', () {
      const filter1 = MapFilter(minRating: 4.0);
      const filter2 = MapFilter(minRating: 4.0);
      expect(filter1, equals(filter2));
    });

    test('should have different hashCode when minRating differs', () {
      const filter1 = MapFilter(minRating: 3.0);
      const filter2 = MapFilter(minRating: 4.0);
      expect(filter1.hashCode, isNot(equals(filter2.hashCode)));
    });
  });

  group('LayerToggles', () {
    test('should create with default values', () {
      const toggles = LayerToggles();

      expect(toggles.showPros, true);
      expect(toggles.showFixedLocations, true);
      expect(toggles.showAlerts, true);
      expect(toggles.showWeddings, true);
      expect(toggles.showOnlyMyProfession, false);
      expect(toggles.showMarketplace, false);
    });

    test('copyWith should create new instance with updated values', () {
      const original = LayerToggles();

      final updated = original.copyWith(
        showPros: false,
        showAlerts: false,
      );

      expect(updated.showPros, false);
      expect(updated.showAlerts, false);
      expect(updated.showFixedLocations, true); // Unchanged
      expect(updated.showWeddings, true); // Unchanged
    });

    test('should allow individual toggle control', () {
      const toggles = LayerToggles(
        showPros: true,
        showAlerts: false,
        showWeddings: true,
      );

      expect(toggles.showPros, true);
      expect(toggles.showAlerts, false);
      expect(toggles.showWeddings, true);
    });

    test('showMarketplace should default to false', () {
      const toggles = LayerToggles();
      expect(toggles.showMarketplace, false);
    });

    test('copyWith should toggle showMarketplace', () {
      const toggles = LayerToggles();

      final updated = toggles.copyWith(showMarketplace: true);

      expect(updated.showMarketplace, true);
      expect(updated.showPros, true); // Unchanged
      expect(updated.showWeddings, true); // Unchanged
    });

    test('copyWith should preserve showMarketplace when not specified', () {
      const toggles = LayerToggles(showMarketplace: true);

      final updated = toggles.copyWith(showPros: false);

      expect(updated.showMarketplace, true);
      expect(updated.showPros, false);
    });

    test('equality should consider showMarketplace', () {
      const toggles1 = LayerToggles(showMarketplace: true);
      const toggles2 = LayerToggles(showMarketplace: false);
      const toggles3 = LayerToggles(showMarketplace: true);

      expect(toggles1, isNot(equals(toggles2)));
      expect(toggles1, equals(toggles3));
    });

    test('all toggles off should have showMarketplace false', () {
      const toggles = LayerToggles(
        showPros: false,
        showFixedLocations: false,
        showAlerts: false,
        showWeddings: false,
        showMarketplace: false,
      );
      expect(toggles.showMarketplace, false);
      expect(toggles.showPros, false);
    });
  });

  group('MapFilter marketplace fields', () {
    test('defaults should have null marketplace fields', () {
      const filter = MapFilter.defaults;
      expect(filter.marketplaceCategory, isNull);
      expect(filter.marketplaceConditions, isNull);
      expect(filter.marketplaceMinPrice, isNull);
      expect(filter.marketplaceMaxPrice, isNull);
      expect(filter.hasMarketplaceFilter, isFalse);
    });

    test('should accept marketplace category', () {
      const filter = MapFilter(marketplaceCategory: 'dress');
      expect(filter.marketplaceCategory, 'dress');
      expect(filter.hasMarketplaceFilter, isTrue);
    });

    test('should accept marketplace conditions list', () {
      const filter = MapFilter(marketplaceConditions: ['new', 'excellent']);
      expect(filter.marketplaceConditions, ['new', 'excellent']);
      expect(filter.hasMarketplaceFilter, isTrue);
    });

    test('should treat empty conditions as no filter', () {
      const filter = MapFilter(marketplaceConditions: []);
      expect(filter.hasMarketplaceFilter, isFalse);
    });

    test('should accept marketplace price range', () {
      const filter = MapFilter(
        marketplaceMinPrice: 1000,
        marketplaceMaxPrice: 500000,
      );
      expect(filter.marketplaceMinPrice, 1000);
      expect(filter.marketplaceMaxPrice, 500000);
      expect(filter.hasMarketplaceFilter, isTrue);
    });

    test('copyWith should update marketplace category', () {
      const filter = MapFilter.defaults;
      final updated = filter.copyWith(marketplaceCategory: 'shoes');
      expect(updated.marketplaceCategory, 'shoes');
    });

    test('copyWith should clear marketplace category', () {
      const filter = MapFilter(marketplaceCategory: 'dress');
      final cleared = filter.copyWith(clearMarketplaceCategory: true);
      expect(cleared.marketplaceCategory, isNull);
    });

    test('copyWith should update marketplace conditions', () {
      const filter = MapFilter.defaults;
      final updated = filter.copyWith(
        marketplaceConditions: ['new', 'good'],
      );
      expect(updated.marketplaceConditions, ['new', 'good']);
    });

    test('copyWith should clear marketplace conditions', () {
      const filter = MapFilter(marketplaceConditions: ['new']);
      final cleared = filter.copyWith(clearMarketplaceConditions: true);
      expect(cleared.marketplaceConditions, isNull);
    });

    test('copyWith should update marketplace price', () {
      const filter = MapFilter.defaults;
      final updated = filter.copyWith(
        marketplaceMinPrice: 500,
        marketplaceMaxPrice: 10000,
      );
      expect(updated.marketplaceMinPrice, 500);
      expect(updated.marketplaceMaxPrice, 10000);
    });

    test('copyWith should clear marketplace price', () {
      const filter = MapFilter(
        marketplaceMinPrice: 500,
        marketplaceMaxPrice: 10000,
      );
      final cleared = filter.copyWith(clearMarketplacePrice: true);
      expect(cleared.marketplaceMinPrice, isNull);
      expect(cleared.marketplaceMaxPrice, isNull);
    });

    test('copyWith should preserve marketplace fields when not specified', () {
      const filter = MapFilter(
        marketplaceCategory: 'dress',
        marketplaceConditions: ['new'],
        marketplaceMinPrice: 500,
        marketplaceMaxPrice: 10000,
      );
      final updated = filter.copyWith(budgetMin: 1000);
      expect(updated.marketplaceCategory, 'dress');
      expect(updated.marketplaceConditions, ['new']);
      expect(updated.marketplaceMinPrice, 500);
      expect(updated.marketplaceMaxPrice, 10000);
    });

    test('equality should consider marketplace fields', () {
      const filter1 = MapFilter(marketplaceCategory: 'dress');
      const filter2 = MapFilter(marketplaceCategory: 'shoes');
      const filter3 = MapFilter(marketplaceCategory: 'dress');

      expect(filter1, isNot(equals(filter2)));
      expect(filter1, equals(filter3));
    });

    test('hashCode should differ when marketplace fields differ', () {
      const filter1 = MapFilter(marketplaceCategory: 'dress');
      const filter2 = MapFilter(marketplaceCategory: 'shoes');

      expect(filter1.hashCode, isNot(equals(filter2.hashCode)));
    });

    test('equality should consider marketplace conditions', () {
      const filter1 = MapFilter(marketplaceConditions: ['new']);
      const filter2 = MapFilter(marketplaceConditions: ['excellent']);
      const filter3 = MapFilter(marketplaceConditions: ['new']);

      expect(filter1, isNot(equals(filter2)));
      expect(filter1, equals(filter3));
    });

    test('equality should consider marketplace price', () {
      const filter1 = MapFilter(marketplaceMinPrice: 500);
      const filter2 = MapFilter(marketplaceMinPrice: 1000);

      expect(filter1, isNot(equals(filter2)));
    });
  });
}
