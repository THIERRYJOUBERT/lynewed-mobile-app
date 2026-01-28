# Story S05: Creer icone marqueur marketplace

## Description
En tant que developpeur, je veux creer une icone de marqueur pour les articles marketplace, afin d'afficher visuellement les annonces sur la carte avec un style coherent.

## Criteres d'Acceptance (Gherkin)
- [ ] Given a MapMarker with type marketplaceItem When generateIcon is called Then a BitmapDescriptor should be returned And the icon should be visually distinct from other marker types
- [ ] Given the Lynewed design system When creating marketplace icon Then it should use consistent size (44px display) And it should have shadow effect And it should have colored border
- [ ] Given a marketplace marker with category 'dress' When generateIcon is called Then a dress-style icon should be rendered
- [ ] Given a marketplace marker with category 'shoes' When generateIcon is called Then a shoes-style icon should be rendered
- [ ] Given a marketplace marker When generateIcon is called twice with same parameters Then cached icon should be returned And no redundant image generation should occur

## Fichiers Concernes
### A Creer
- Aucun

### A Modifier
- `lib/features/map/presentation/services/marker_icon_generator.dart`
- `lib/features/map/presentation/theme/map_theme.dart` (couleur)
- `test/features/map/presentation/services/marker_icon_generator_test.dart` (tests)

## Notes Techniques

### Nouvelle methode dans MarkerIconGenerator
```dart
// In MarkerIconGenerator
Future<gmaps.BitmapDescriptor> _createMarketplaceIcon(MapMarker marker, double size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final center = Offset(size / 2, size / 2);
  final radius = size / 2 - _config.borderWidth;

  // Shadow
  _drawShadow(canvas, center, size);

  // Purple/magenta background
  final bgPaint = Paint()
    ..color = const Color(0xFFE1BEE7) // Purple 100
    ..style = PaintingStyle.fill;
  canvas.drawCircle(center, radius, bgPaint);

  // Icon based on category (dress or shoes)
  final category = marker.metadata['category'] as String? ?? 'dress';
  final icon = category == 'shoes'
      ? Icons.shopping_bag_outlined  // Shoes icon
      : Icons.checkroom_outlined;     // Dress icon

  _drawFlutterIcon(canvas, center, radius * 0.6, icon, const Color(0xFF7B1FA2));

  // Purple border
  final borderPaint = Paint()
    ..color = const Color(0xFF7B1FA2) // Purple 700
    ..style = PaintingStyle.stroke
    ..strokeWidth = _config.borderWidth;
  canvas.drawCircle(center, radius, borderPaint);

  return _finishIcon(recorder, size);
}
```

### Modification generateIcon switch
```dart
Future<gmaps.BitmapDescriptor> generateIcon(MapMarker marker) async {
  // Check cache first
  final cacheKey = _buildCacheKey(marker);
  if (_cache.containsKey(cacheKey)) {
    return _cache[cacheKey]!;
  }

  final size = _config.markerSize * _devicePixelRatio;

  gmaps.BitmapDescriptor icon;
  switch (marker.type) {
    case MapMarkerType.proFixedLocation:
      icon = await _createProIcon(marker, size);
    case MapMarkerType.professionalAlert:
      icon = await _createAlertIcon(marker, size);
    case MapMarkerType.wedding:
      icon = await _createWeddingIcon(marker, size);
    case MapMarkerType.marketplaceItem:
      icon = await _createMarketplaceIcon(marker, size); // NEW
  }

  _cache[cacheKey] = icon;
  return icon;
}
```

### Map theme colors
```dart
// In map_theme.dart
static Color forMarkerType(MapMarkerType type) {
  switch (type) {
    case MapMarkerType.proFixedLocation:
      return const Color(0xFF4CAF50); // Green
    case MapMarkerType.professionalAlert:
      return const Color(0xFFE53935); // Red
    case MapMarkerType.wedding:
      return const Color(0xFFE91E63); // Pink
    case MapMarkerType.marketplaceItem:
      return const Color(0xFF7B1FA2); // Purple - NEW
  }
}
```

### Tests a ajouter
```dart
group('Marketplace icon generation', () {
  late MarkerIconGenerator generator;

  setUp(() {
    generator = MarkerIconGenerator(config: MarkerIconConfig.defaults());
  });

  test('generates icon for marketplace marker', () async {
    final marker = MapMarker(
      id: 'test_1',
      type: MapMarkerType.marketplaceItem,
      position: const LatLng(48.8566, 2.3522),
      metadata: {'category': 'dress'},
    );
    final icon = await generator.generateIcon(marker);
    expect(icon, isNotNull);
  });

  test('generates different icon for dress vs shoes', () async {
    final dressMarker = MapMarker(
      id: 'test_dress',
      type: MapMarkerType.marketplaceItem,
      position: const LatLng(48.8566, 2.3522),
      metadata: {'category': 'dress'},
    );
    final shoesMarker = MapMarker(
      id: 'test_shoes',
      type: MapMarkerType.marketplaceItem,
      position: const LatLng(48.8566, 2.3522),
      metadata: {'category': 'shoes'},
    );
    // Both should generate without error
    final dressIcon = await generator.generateIcon(dressMarker);
    final shoesIcon = await generator.generateIcon(shoesMarker);
    expect(dressIcon, isNotNull);
    expect(shoesIcon, isNotNull);
  });

  test('caches marketplace icons', () async {
    final marker = MapMarker(
      id: 'test_cache',
      type: MapMarkerType.marketplaceItem,
      position: const LatLng(48.8566, 2.3522),
      metadata: {'category': 'dress'},
    );
    final icon1 = await generator.generateIcon(marker);
    final icon2 = await generator.generateIcon(marker);
    expect(identical(icon1, icon2), isTrue);
  });
});

group('MapMarkerTheme', () {
  test('returns purple for marketplace marker', () {
    final color = MapMarkerTheme.forMarkerType(MapMarkerType.marketplaceItem);
    expect(color, const Color(0xFF7B1FA2));
  });
});
```

## Definition of Done
- [ ] Criteres valides
- [ ] Methode _createMarketplaceIcon implementee
- [ ] Switch case ajoute dans generateIcon
- [ ] Couleur ajoutee dans MapMarkerTheme
- [ ] Tests unitaires pour generation d'icone
- [ ] Tests unitaires pour cache
- [ ] Tests pour dress vs shoes categories
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Style visuel coherent avec design system

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S04 (MapMarkerType.marketplaceItem) - necessite le type enum

## Stories Dependantes
- S08 (Tap marqueur marketplace) - utilise l'icone generee
