# Story S04: Ajouter marketplaceItem a MapMarkerType

## Description
En tant que developpeur, je veux ajouter la valeur `marketplaceItem` a l'enum `MapMarkerType`, afin de pouvoir representer les articles marketplace sur la carte.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the MapMarkerType enum When checking available values Then marketplaceItem should be a valid value And it should be distinct from proFixedLocation, professionalAlert, wedding
- [ ] Given code using switch on MapMarkerType When a marketplaceItem marker is encountered Then no runtime error should occur And a default/fallback behavior should apply until fully implemented
- [ ] Given a marketplace listing with location When creating a MapMarker Then MapMarker should accept type: MapMarkerType.marketplaceItem And marker should have appropriate metadata (listing_id, category, price)

## Fichiers Concernes
### A Creer
- Aucun

### A Modifier
- `lib/features/map/domain/entities/map_marker.dart` (enum MapMarkerType)
- `test/features/map/domain/entities/map_marker_test.dart` (tests)

## Notes Techniques

### Modification enum
```dart
/// Types de marqueurs sur la map
enum MapMarkerType {
  /// Position fixe d'un professionnel
  proFixedLocation,

  /// Alerte communautaire d'un professionnel
  professionalAlert,

  /// Mariage visible sur la map
  wedding,

  /// Article marketplace (robe/chaussures) - NEW APP-07
  marketplaceItem,
}
```

### Backward compatibility
Tous les switch/case existants doivent gerer le nouveau type. Verifier:
- `MarkerIconGenerator.generateIcon()` - ajouter case ou default
- `MapMarkerLayer` - gerer le nouveau type
- Autres usages de MapMarkerType

### Metadata pour marketplace
```dart
// Exemple de creation de marqueur marketplace
final marker = MapMarker(
  id: 'marketplace_123',
  type: MapMarkerType.marketplaceItem,
  position: LatLng(48.8566, 2.3522),
  metadata: {
    'listing_id': '123',
    'category': 'dress', // ou 'shoes'
    'price': 500.0,
    'currency': 'EUR',
    'title': 'Robe de mariee vintage',
    'thumbnail_url': 'https://...',
  },
);
```

### Tests a ajouter
```dart
group('MapMarkerType', () {
  test('marketplaceItem is a valid type', () {
    expect(MapMarkerType.values, contains(MapMarkerType.marketplaceItem));
  });

  test('all types are distinct', () {
    final types = MapMarkerType.values.toSet();
    expect(types.length, equals(MapMarkerType.values.length));
  });
});

group('MapMarker with marketplaceItem', () {
  test('can create marketplace marker', () {
    final marker = MapMarker(
      id: 'test_marketplace_1',
      type: MapMarkerType.marketplaceItem,
      position: const LatLng(48.8566, 2.3522),
      metadata: {'listing_id': '123', 'category': 'dress'},
    );
    expect(marker.type, MapMarkerType.marketplaceItem);
    expect(marker.metadata['category'], 'dress');
  });

  test('marketplace marker supports all required metadata', () {
    final marker = MapMarker(
      id: 'test_marketplace_2',
      type: MapMarkerType.marketplaceItem,
      position: const LatLng(48.8566, 2.3522),
      metadata: {
        'listing_id': '456',
        'category': 'shoes',
        'price': 250.0,
        'currency': 'EUR',
        'title': 'Chaussures de mariee',
        'thumbnail_url': 'https://example.com/shoes.jpg',
      },
    );
    expect(marker.metadata['listing_id'], '456');
    expect(marker.metadata['price'], 250.0);
    expect(marker.metadata['thumbnail_url'], isNotNull);
  });
});
```

## Definition of Done
- [ ] Criteres valides
- [ ] Valeur marketplaceItem ajoutee a enum
- [ ] Tests unitaires pour nouveau type
- [ ] Tous les switch/case existants geres (pas de crash)
- [ ] Documentation enum mise a jour
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 1
**Complexite** : Faible
**Risque** : Faible

## Dependances
- Aucune

## Stories Dependantes
- S05 (Creer icone marqueur marketplace) - necessite le type enum
- S08 (Tap marqueur marketplace) - necessite le type enum
