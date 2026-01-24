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

  group('LayerToggles', () {
    test('should create with default values', () {
      const toggles = LayerToggles();

      expect(toggles.showPros, true);
      expect(toggles.showFixedLocations, true);
      expect(toggles.showAlerts, true);
      expect(toggles.showWeddings, true);
      expect(toggles.showOnlyMyProfession, false);
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
  });
}
