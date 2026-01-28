# Story S06: Mettre a jour FilterSheet UI

## Description
En tant que utilisateur (bride), je veux voir les nouvelles options de filtrage dans le panneau de filtres de la carte, afin de pouvoir filtrer les professionnels par offres speciales et note minimum.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the FilterSheet is opened When the user scrolls to the "Special offers" section Then a checkbox "Wedding book free" should be visible And a checkbox "Trailer free" should be visible And both checkboxes should be unchecked by default
- [ ] Given the FilterSheet is opened When the user checks "Wedding book free" Then the filter state should update weddingBookFree = true When the user unchecks "Wedding book free" Then the filter state should update weddingBookFree = null
- [ ] Given EPIC-07 reviews feature is deployed When the FilterSheet is opened Then a "Minimum rating" section should be visible And a slider or star selector (1-5) should allow selection
- [ ] Given EPIC-07 reviews feature is NOT deployed When the FilterSheet is opened Then the "Minimum rating" section should be hidden OR disabled And a tooltip "Coming soon" may be shown
- [ ] Given the FilterSheet is opened When the user enables "Marketplace" in layers Then filter.toggles.showMarketplace should be TRUE And marketplace items should appear on map
- [ ] Given the user has set weddingBookFree=true, minRating=4 When the user taps "Reset" Then weddingBookFree, trailerFree, minRating should be null And showMarketplace should be false

## Fichiers Concernes
### A Creer
- `lib/core/config/feature_flags.dart` (si non existant)

### A Modifier
- `lib/features/map/presentation/widgets/filter_sheet.dart`
- `test/features/map/presentation/widgets/filter_sheet_test.dart`

## Notes Techniques

### Feature Flags
```dart
// lib/core/config/feature_flags.dart

/// Feature flags for gradual rollout
class FeatureFlags {
  /// minRating filter - requires EPIC-07 (Reviews) to be deployed
  /// Set to true when reviews table exists and has data
  static const bool enableMinRatingFilter = false; // TODO: Set to true after EPIC-07

  /// Marketplace markers on map - requires EPIC-14 (Marketplace)
  /// Set to true when marketplace_listings table exists
  static const bool enableMarketplaceMarkers = false; // TODO: Set to true after EPIC-14

  /// Check if minRating should be shown in UI
  static bool get showRatingFilter => enableMinRatingFilter;

  /// Check if marketplace toggle should be shown
  static bool get showMarketplaceToggle => enableMarketplaceMarkers;
}
```

### Nouvelles sections dans FilterSheet
```dart
// Add after budget section
if (widget.userRole == 'bride') ...[
  LynewedGap.verticalXxl,
  _buildSection(
    title: 'Minimum rating',
    child: _buildRatingSlider(),
  ),
],

LynewedGap.verticalXxl,
_buildSection(
  title: 'Special offers',
  child: _buildSpecialOffersCheckboxes(),
),

LynewedGap.verticalXxl,
_buildSection(
  title: 'Show on map',
  child: _buildLayerToggles(),
),
```

### Rating slider widget
```dart
Widget _buildRatingSlider() {
  final isEnabled = FeatureFlags.showRatingFilter;

  return Opacity(
    opacity: isEnabled ? 1.0 : 0.5,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = (_filter.minRating ?? 0) >= rating;
            return GestureDetector(
              onTap: isEnabled ? () {
                setState(() {
                  _filter = _filter.copyWith(
                    minRating: rating.toDouble(),
                  );
                });
              } : null,
              child: Icon(
                isSelected ? Icons.star : Icons.star_border,
                color: isSelected ? Colors.amber : LynewedColors.gray400,
                size: 32,
              ),
            );
          }),
        ),
        if (!isEnabled)
          Text(
            'Coming soon',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
      ],
    ),
  );
}
```

### Special offers checkboxes
```dart
Widget _buildSpecialOffersCheckboxes() {
  return Column(
    children: [
      CheckboxListTile(
        title: const Text('Wedding book free'),
        subtitle: const Text('Pro offers a free wedding album'),
        value: _filter.weddingBookFree ?? false,
        onChanged: (value) {
          setState(() {
            _filter = _filter.copyWith(
              weddingBookFree: value == true ? true : null,
            );
          });
        },
      ),
      CheckboxListTile(
        title: const Text('Trailer free'),
        subtitle: const Text('Pro offers a free wedding trailer'),
        value: _filter.trailerFree ?? false,
        onChanged: (value) {
          setState(() {
            _filter = _filter.copyWith(
              trailerFree: value == true ? true : null,
            );
          });
        },
      ),
    ],
  );
}
```

### Layer toggles update
```dart
Widget _buildLayerToggles() {
  return Column(
    children: [
      // Existing toggles...
      SwitchListTile(
        title: const Text('Pros'),
        value: _filter.toggles.showPros,
        onChanged: (value) => _updateToggle(showPros: value),
      ),
      SwitchListTile(
        title: const Text('Alerts'),
        value: _filter.toggles.showAlerts,
        onChanged: (value) => _updateToggle(showAlerts: value),
      ),
      SwitchListTile(
        title: const Text('Weddings'),
        value: _filter.toggles.showWeddings,
        onChanged: (value) => _updateToggle(showWeddings: value),
      ),
      // NEW - Marketplace toggle
      if (FeatureFlags.showMarketplaceToggle)
        SwitchListTile(
          title: const Text('Marketplace'),
          subtitle: const Text('Show items for sale'),
          value: _filter.toggles.showMarketplace,
          onChanged: (value) => _updateToggle(showMarketplace: value),
        ),
    ],
  );
}
```

### Reset method update
```dart
void _resetFilters() {
  setState(() {
    _filter = MapFilter(
      toggles: const LayerToggles(), // All defaults
    );
    // This resets:
    // - weddingBookFree = null
    // - trailerFree = null
    // - minRating = null
    // - showMarketplace = false
  });
}
```

### Tests a ajouter
```dart
group('FilterSheet new sections', () {
  testWidgets('shows special offers section', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FilterSheet(filter: const MapFilter())),
    );
    expect(find.text('Special offers'), findsOneWidget);
    expect(find.text('Wedding book free'), findsOneWidget);
    expect(find.text('Trailer free'), findsOneWidget);
  });

  testWidgets('wedding book checkbox updates filter', (tester) async {
    MapFilter? resultFilter;
    await tester.pumpWidget(
      MaterialApp(
        home: FilterSheet(
          filter: const MapFilter(),
          onFilterChanged: (f) => resultFilter = f,
        ),
      ),
    );
    await tester.tap(find.text('Wedding book free'));
    await tester.pump();
    expect(resultFilter?.weddingBookFree, isTrue);
  });

  testWidgets('rating section disabled when feature flag off', (tester) async {
    // With FeatureFlags.enableMinRatingFilter = false
    await tester.pumpWidget(
      MaterialApp(home: FilterSheet(filter: const MapFilter())),
    );
    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('reset clears new filters', (tester) async {
    MapFilter? resultFilter;
    await tester.pumpWidget(
      MaterialApp(
        home: FilterSheet(
          filter: const MapFilter(weddingBookFree: true, minRating: 4.0),
          onFilterChanged: (f) => resultFilter = f,
        ),
      ),
    );
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(resultFilter?.weddingBookFree, isNull);
    expect(resultFilter?.minRating, isNull);
  });
});
```

## Definition of Done
- [ ] Criteres valides
- [ ] Section "Special offers" avec checkboxes
- [ ] Section "Minimum rating" avec feature flag
- [ ] Toggle marketplace dans layers
- [ ] Reset efface tous les nouveaux filtres
- [ ] Feature flags implementes
- [ ] Tests unitaires
- [ ] Tests widget
- [ ] `flutter analyze --fatal-infos` passe
- [ ] UI coherente avec design system existant

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S03 (MapFilter etendu) - necessite les nouveaux champs

## Stories Dependantes
- Aucune directement (integration avec S07 pour fonctionnalite complete)
