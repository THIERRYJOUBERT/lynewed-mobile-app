# Story S09: Update map query to filter by rating

## Description
En tant que mariee, je veux pouvoir filtrer les professionnels par note minimum sur la carte, afin de ne voir que les prestataires les mieux notes.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the filter sheet is open When viewing the filters Then a "Minimum rating" slider should be visible And it should range from 0 (any) to 5 stars
- [ ] Given the filter sheet is open When setting minimum rating to 4.0 And applying filters Then only professionals with average_rating >= 4.0 should be shown on the map
- [ ] Given default MapFilter When loading map markers Then all professionals should be shown regardless of rating
- [ ] Given minRating filter is set to 3.0 And pro-A has no reviews (not in pro_ratings view) When loading map markers Then pro-A should NOT be shown (no rating = excluded when filtering)
- [ ] Given 50 professionals on the map And 30 have rating >= 4.0 When setting minRating to 4.0 Then only 30 markers should be displayed
- [ ] Given minRating filter was set to 4.5 When clearing the rating filter (reset to 0/null) Then all professionals should be shown again
- [ ] Given the filter sheet is open When minRating is 0 Then "Any rating" label should be displayed
- [ ] Given the filter sheet is open When minRating is 4.0 Then "4.0+ stars" label should be displayed

## Fichiers Concernes
### A Creer
- `lib/features/reviews/presentation/widgets/rating_filter_slider.dart`
- `test/features/reviews/presentation/widgets/rating_filter_slider_test.dart`

### A Modifier
- `lib/features/map/presentation/widgets/filter_sheet.dart` (add rating slider section)
- `lib/features/map/data/datasources/supabase_map_datasource.dart` (add rating filter to query)
- `supabase/functions/search_map_bundle/index.ts` (optional: RPC modification)

## Notes Techniques

### Option 1: Client-side filtering (recommended for MVP)
Filter markers after fetching, using batch rating lookup:

```dart
// In SupabaseMapDatasource
Future<MapSearchResult> searchMapBundle({
  required MapFilter filter,
  // ... other params
}) async {
  // Existing RPC call
  final response = await _client.rpc('search_map_bundle', params: {...});

  // If rating filter is active, filter client-side
  if (filter.hasRatingFilter) {
    final markers = response['markers'] as List;
    final proIds = markers.map((m) => m['pro_id'] as String).toList();

    // Batch fetch ratings
    final ratings = await _reviewRepository.getRatingsForPros(proIds);

    // Filter markers
    final filteredMarkers = markers.where((m) {
      final proId = m['pro_id'] as String;
      final rating = ratings[proId];
      if (rating == null) return false; // No reviews = excluded
      return rating.averageRating >= filter.minRating!;
    }).toList();

    response['markers'] = filteredMarkers;
  }

  return MapSearchResult.fromJson(response);
}
```

### Option 2: Server-side filtering (better for scale)
Modify RPC to accept minRating parameter:

```sql
-- Add to search_map_bundle WHERE clause
AND (
  p_filters->>'minRating' IS NULL
  OR EXISTS (
    SELECT 1 FROM pro_ratings pr
    WHERE pr.pro_id = profiles.id
    AND pr.average_rating >= (p_filters->>'minRating')::NUMERIC
  )
)
```

### RatingFilterSlider Widget
```dart
class RatingFilterSlider extends StatelessWidget {
  const RatingFilterSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double? value; // null = any rating
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Minimum rating', style: LynewedTextStyles.labelMedium),
            Text(
              value != null && value! > 0
                  ? '${value!.toStringAsFixed(1)}+ stars'
                  : 'Any rating',
              style: LynewedTextStyles.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: LynewedSpacing.sm),
        Row(
          children: [
            StarRatingDisplay(
              rating: value ?? 0,
              starSize: 20,
              showValue: false,
            ),
            Expanded(
              child: Slider(
                value: value ?? 0,
                min: 0,
                max: 5,
                divisions: 10, // 0.5 increments
                onChanged: (v) => onChanged(v > 0 ? v : null),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

### FilterSheet Integration
```dart
// In _FilterSheetState
double? _minRating;

@override
void initState() {
  super.initState();
  _minRating = widget.initialFilter.minRating;
}

// In build method, add section:
_buildSection(
  title: 'Rating',
  child: RatingFilterSlider(
    value: _minRating,
    onChanged: (value) {
      setState(() => _minRating = value);
    },
  ),
),

// In _applyFilters:
final filter = widget.initialFilter.copyWith(
  // ... existing filters
  minRating: _minRating,
);
```

## Definition of Done
- [ ] RatingFilterSlider widget cree
- [ ] FilterSheet integre le slider de note
- [ ] Filtrage fonctionne (client-side ou server-side)
- [ ] Pros sans avis exclus quand filtre actif
- [ ] Label "Any rating" / "X.X+ stars" correct
- [ ] Reset du filtre fonctionne
- [ ] Nombre de marqueurs mis a jour apres filtrage
- [ ] Tests widget pour RatingFilterSlider
- [ ] Tests integration pour le filtrage
- [ ] `flutter test` passe
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (integration avec map existante)

## Dependances
- S02: View pro_ratings must exist (for rating lookup)
- S05: Repository getRatingsForPros method
- S06: StarRatingDisplay widget
- S08: MapFilter.minRating field

## Stories Dependantes
- EPIC-13 (Map Filters): Builds upon this rating filter foundation
