# Story S03: Etendre MapFilter avec nouveaux champs

## Description
En tant que developpeur, je veux etendre l'entite `MapFilter` avec les champs `weddingBookFree`, `trailerFree` et `minRating`, afin de supporter les nouveaux filtres dans la couche domain.

## Criteres d'Acceptance (Gherkin)
- [ ] Given a MapFilter instance When weddingBookFree is set to TRUE Then only professionals with offers_free_wedding_book = TRUE should match When weddingBookFree is NULL Then all professionals should match regardless of wedding book offer
- [ ] Given a MapFilter instance When trailerFree is set to TRUE Then only professionals with offers_free_trailer = TRUE should match When trailerFree is NULL Then all professionals should match regardless of trailer offer
- [ ] Given a MapFilter instance with minRating = 4.0 When filtering professionals Then only professionals with average_rating >= 4.0 should match When minRating is NULL Then all professionals should match regardless of rating
- [ ] Given a LayerToggles instance When showMarketplace is TRUE Then marketplace items should be visible on map When showMarketplace is FALSE (default) Then marketplace items should be hidden
- [ ] Given an existing MapFilter.defaults When the updated code is deployed Then weddingBookFree, trailerFree, minRating should be NULL And showMarketplace should be FALSE And existing filter behavior should be unchanged

## Fichiers Concernes
### A Creer
- Aucun

### A Modifier
- `lib/features/map/domain/entities/map_filter.dart` (MapFilter + LayerToggles)
- `test/features/map/domain/entities/map_filter_test.dart` (tests)

## Notes Techniques

### Modification MapFilter
```dart
@immutable
class MapFilter {
  const MapFilter({
    this.professions = const [],
    this.budgetMin,
    this.budgetMax,
    this.currency = 'EUR',
    this.center,
    this.radiusKm,
    this.countryCode,
    this.toggles = const LayerToggles(),
    // NEW FIELDS
    this.weddingBookFree,
    this.trailerFree,
    this.minRating,
  });

  // Existing fields...

  /// Filter pros offering free wedding book (null = no filter)
  final bool? weddingBookFree;

  /// Filter pros offering free trailer (null = no filter)
  final bool? trailerFree;

  /// Minimum rating filter 1.0-5.0 (null = no filter)
  /// Requires EPIC-07 reviews table
  final double? minRating;

  /// Checks if special offers filter is active
  bool get hasSpecialOffersFilter =>
      weddingBookFree == true || trailerFree == true;

  /// Checks if rating filter is active
  bool get hasRatingFilter => minRating != null && minRating! > 0;

  // Update copyWith, ==, hashCode...
}
```

### Modification LayerToggles
```dart
@immutable
class LayerToggles {
  const LayerToggles({
    this.showPros = true,
    this.showFixedLocations = true,
    this.showAlerts = true,
    this.showWeddings = true,
    this.showOnlyMyProfession = false,
    this.showMarketplace = false, // NEW - default off
  });

  // Existing fields...

  /// Show marketplace items on map (APP-07)
  final bool showMarketplace;

  // Update copyWith, ==, hashCode...
}
```

### Tests a ajouter
```dart
group('MapFilter new fields', () {
  test('weddingBookFree defaults to null', () {
    const filter = MapFilter();
    expect(filter.weddingBookFree, isNull);
  });

  test('trailerFree defaults to null', () {
    const filter = MapFilter();
    expect(filter.trailerFree, isNull);
  });

  test('minRating defaults to null', () {
    const filter = MapFilter();
    expect(filter.minRating, isNull);
  });

  test('hasSpecialOffersFilter returns true when weddingBookFree is true', () {
    const filter = MapFilter(weddingBookFree: true);
    expect(filter.hasSpecialOffersFilter, isTrue);
  });

  test('hasRatingFilter returns true when minRating is set', () {
    const filter = MapFilter(minRating: 4.0);
    expect(filter.hasRatingFilter, isTrue);
  });

  test('copyWith preserves new fields', () {
    const original = MapFilter(weddingBookFree: true, minRating: 3.5);
    final copy = original.copyWith(trailerFree: true);
    expect(copy.weddingBookFree, isTrue);
    expect(copy.trailerFree, isTrue);
    expect(copy.minRating, 3.5);
  });
});

group('LayerToggles', () {
  test('showMarketplace defaults to false', () {
    const toggles = LayerToggles();
    expect(toggles.showMarketplace, isFalse);
  });

  test('copyWith updates showMarketplace', () {
    const toggles = LayerToggles();
    final updated = toggles.copyWith(showMarketplace: true);
    expect(updated.showMarketplace, isTrue);
  });
});
```

## Definition of Done
- [ ] Criteres valides
- [ ] Tests unitaires pour weddingBookFree, trailerFree, minRating
- [ ] Tests unitaires pour showMarketplace dans LayerToggles
- [ ] Tests unitaires pour hasSpecialOffersFilter, hasRatingFilter
- [ ] Tests unitaires pour copyWith avec nouveaux champs
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Backward compatibility verifiee (defaults preservent comportement)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01 (offers_free_wedding_book column) - pour coherence semantique
- S02 (offers_free_trailer column) - pour coherence semantique

## Stories Dependantes
- S06 (FilterSheet UI) - utilise MapFilter etendu
- S07 (Query map) - utilise MapFilter etendu
