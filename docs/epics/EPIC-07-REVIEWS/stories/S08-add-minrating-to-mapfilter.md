# Story S08: Add minRating to MapFilter

## Description
En tant que developpeur Flutter, je veux ajouter le champ `minRating` a l'entite `MapFilter`, afin de permettre le filtrage des professionnels par note minimum sur la carte.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the MapFilter entity When creating a MapFilter with minRating: 4.0 Then minRating should be accessible and equal to 4.0
- [ ] Given a MapFilter without minRating specified When accessing minRating Then it should be null (no filter)
- [ ] Given a MapFilter with minRating: 3.0 When calling copyWith(minRating: 4.5) Then the new filter should have minRating: 4.5
- [ ] Given two MapFilters with same properties but different minRating When comparing them Then they should not be equal
- [ ] Given MapFilter.defaults When checking minRating Then it should be null
- [ ] Given a MapFilter with minRating: 4.0 When checking hasRatingFilter Then it should return true
- [ ] Given a MapFilter without minRating When checking hasRatingFilter Then it should return false
- [ ] Given a MapFilter with minRating: 0 When checking hasRatingFilter Then it should return false (0 means no filter)

## Fichiers Concernes
### A Creer
- Aucun

### A Modifier
- `lib/features/map/domain/entities/map_filter.dart`
- `test/features/map/domain/entities/map_filter_test.dart`

## Notes Techniques

### Changes to MapFilter
```dart
@immutable
class MapFilter {
  const MapFilter({
    // ... existing fields
    this.minRating, // NEW
  });

  // ... existing fields

  /// Minimum rating to filter professionals (1.0 - 5.0)
  /// null = no rating filter
  final double? minRating;

  /// Check if a rating filter is active
  bool get hasRatingFilter => minRating != null && minRating! > 0;

  // Update copyWith
  MapFilter copyWith({
    // ... existing params
    double? minRating,
  }) {
    return MapFilter(
      // ... existing fields
      minRating: minRating ?? this.minRating,
    );
  }

  // Update copyWith to allow clearing minRating
  MapFilter copyWithClearRating() {
    return MapFilter(
      // ... existing fields
      minRating: null,
    );
  }

  // Update == operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapFilter &&
        // ... existing comparisons
        other.minRating == minRating;
  }

  // Update hashCode
  @override
  int get hashCode => Object.hash(
    // ... existing fields
    minRating,
  );
}
```

### Test Cases
```dart
group('MapFilter minRating', () {
  test('should have null minRating by default', () {
    const filter = MapFilter();
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

  test('should treat 0 as no filter', () {
    const filter = MapFilter(minRating: 0);
    expect(filter.hasRatingFilter, isFalse);
  });

  test('should not be equal when minRating differs', () {
    const filter1 = MapFilter(minRating: 3.0);
    const filter2 = MapFilter(minRating: 4.0);
    expect(filter1, isNot(equals(filter2)));
  });
});
```

## Definition of Done
- [ ] MapFilter.minRating field ajoute (double?, nullable)
- [ ] MapFilter.hasRatingFilter getter ajoute
- [ ] copyWith mis a jour pour minRating
- [ ] == operator mis a jour
- [ ] hashCode mis a jour
- [ ] Tests unitaires pour tous les cas
- [ ] `flutter test` passe
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- Aucune (independant des stories DB)

## Stories Dependantes
- S09: Map filter query (uses minRating field)
- EPIC-13 (Map Filters): Uses minRating for advanced filtering
