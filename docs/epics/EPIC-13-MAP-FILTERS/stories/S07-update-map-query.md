# Story S07: Mettre a jour query map avec nouveaux filtres

## Description
En tant que developpeur, je veux etendre la RPC `map_search_bundle` pour supporter les nouveaux filtres (weddingBookFree, trailerFree, minRating), afin d'appliquer les filtres cote serveur pour de meilleures performances.

## Criteres d'Acceptance (Gherkin)
- [ ] Given a map search with weddingBookFree = TRUE When the RPC map_search_bundle is called Then only professionals with offers_free_wedding_book = TRUE are returned And the filter is applied in SQL (not client-side)
- [ ] Given a map search with trailerFree = TRUE When the RPC map_search_bundle is called Then only professionals with offers_free_trailer = TRUE are returned
- [ ] Given a map search with weddingBookFree = TRUE AND profession = 'photographer' When the RPC map_search_bundle is called Then only photographers offering free wedding book are returned
- [ ] Given a map search with weddingBookFree = NULL When the RPC map_search_bundle is called Then all professionals are returned (wedding book not filtered)
- [ ] Given EPIC-07 reviews table exists And a map search with minRating = 4.0 When the RPC map_search_bundle is called Then only professionals with average_rating >= 4.0 are returned
- [ ] Given 1000 professionals in database When filtering with all new filters enabled Then response time should be < 500ms And no N+1 queries should occur

## Fichiers Concernes
### A Creer
- Migration Supabase: `20260128010003_update_map_search_bundle_filters`

### A Modifier
- `lib/features/map/data/datasources/supabase_map_datasource.dart`
- `test/features/map/data/datasources/supabase_map_datasource_test.dart`

## Notes Techniques

### Migration SQL - Update RPC
```sql
-- Migration: 20260128010003_update_map_search_bundle_filters
-- Description: Add new filter parameters to map_search_bundle RPC

-- Drop existing function to recreate with new parameters
DROP FUNCTION IF EXISTS map_search_bundle(
  -- existing params
);

CREATE OR REPLACE FUNCTION map_search_bundle(
  -- Existing parameters
  p_lat FLOAT DEFAULT NULL,
  p_lng FLOAT DEFAULT NULL,
  p_radius_km FLOAT DEFAULT NULL,
  p_professions TEXT[] DEFAULT NULL,
  p_budget_min NUMERIC DEFAULT NULL,
  p_budget_max NUMERIC DEFAULT NULL,
  p_currency TEXT DEFAULT 'EUR',
  p_country_code TEXT DEFAULT NULL,
  -- NEW parameters for EPIC-13
  p_wedding_book_free BOOLEAN DEFAULT NULL,
  p_trailer_free BOOLEAN DEFAULT NULL,
  p_min_rating NUMERIC DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'professionals', (
      SELECT COALESCE(jsonb_agg(pro_data), '[]'::jsonb)
      FROM (
        SELECT jsonb_build_object(
          'id', pd.id,
          'user_id', pd.user_id,
          'professions', pd.professions,
          'location', ST_AsGeoJSON(pd.location)::jsonb,
          'pricing', pd.pricing,
          'offers_free_wedding_book', pd.offers_free_wedding_book,
          'offers_free_trailer', pd.offers_free_trailer
        ) as pro_data
        FROM professional_details pd
        JOIN profiles p ON p.id = pd.user_id
        WHERE p.is_active = TRUE
          -- Existing filters
          AND (p_professions IS NULL OR pd.professions && p_professions)
          AND (p_budget_min IS NULL OR (pd.pricing->>'base_price')::numeric >= p_budget_min)
          AND (p_budget_max IS NULL OR (pd.pricing->>'base_price')::numeric <= p_budget_max)
          AND (p_country_code IS NULL OR pd.country_code = p_country_code)
          AND (p_radius_km IS NULL OR p_lat IS NULL OR p_lng IS NULL OR
               ST_DWithin(
                 pd.location::geography,
                 ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
                 p_radius_km * 1000
               ))
          -- NEW filters
          AND (p_wedding_book_free IS NULL OR pd.offers_free_wedding_book = p_wedding_book_free)
          AND (p_trailer_free IS NULL OR pd.offers_free_trailer = p_trailer_free)
          -- Rating filter (requires EPIC-07 reviews table)
          AND (p_min_rating IS NULL OR COALESCE(
            (SELECT AVG(rating)::numeric FROM reviews WHERE pro_id = pd.user_id AND status = 'approved'),
            0
          ) >= p_min_rating)
        ORDER BY pd.created_at DESC
        LIMIT 500
      ) subq
    )
  ) INTO result;

  RETURN result;
END;
$$;

-- Add comment
COMMENT ON FUNCTION map_search_bundle IS 'Search professionals on map with filters including special offers (EPIC-13)';
```

### Datasource modification
```dart
// In SupabaseMapDatasource

Future<MapSearchResult> searchMapBundle(MapFilter filter) async {
  final params = <String, dynamic>{
    // Existing params
    'p_lat': filter.center?.latitude,
    'p_lng': filter.center?.longitude,
    'p_radius_km': filter.radiusKm,
    'p_professions': filter.professions.isNotEmpty
        ? filter.professions.map((p) => p.name).toList()
        : null,
    'p_budget_min': filter.budgetMin,
    'p_budget_max': filter.budgetMax,
    'p_currency': filter.currency,
    'p_country_code': filter.countryCode,
    // NEW filter params
    'p_wedding_book_free': filter.weddingBookFree,
    'p_trailer_free': filter.trailerFree,
    'p_min_rating': filter.minRating,
  };

  // Remove null values for cleaner RPC call
  params.removeWhere((key, value) => value == null);

  final response = await _client.rpc('map_search_bundle', params: params);

  return MapSearchResult.fromJson(response as Map<String, dynamic>);
}
```

### Tests a ajouter
```dart
group('SupabaseMapDatasource new filters', () {
  late SupabaseMapDatasource datasource;
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
    datasource = SupabaseMapDatasource(client: mockClient);
  });

  test('passes weddingBookFree to RPC', () async {
    const filter = MapFilter(weddingBookFree: true);

    when(mockClient.rpc(any, params: anyNamed('params')))
        .thenAnswer((_) async => {'professionals': []});

    await datasource.searchMapBundle(filter);

    verify(mockClient.rpc(
      'map_search_bundle',
      params: argThat(
        containsPair('p_wedding_book_free', true),
        named: 'params',
      ),
    ));
  });

  test('passes trailerFree to RPC', () async {
    const filter = MapFilter(trailerFree: true);

    when(mockClient.rpc(any, params: anyNamed('params')))
        .thenAnswer((_) async => {'professionals': []});

    await datasource.searchMapBundle(filter);

    verify(mockClient.rpc(
      'map_search_bundle',
      params: argThat(
        containsPair('p_trailer_free', true),
        named: 'params',
      ),
    ));
  });

  test('passes minRating to RPC', () async {
    const filter = MapFilter(minRating: 4.0);

    when(mockClient.rpc(any, params: anyNamed('params')))
        .thenAnswer((_) async => {'professionals': []});

    await datasource.searchMapBundle(filter);

    verify(mockClient.rpc(
      'map_search_bundle',
      params: argThat(
        containsPair('p_min_rating', 4.0),
        named: 'params',
      ),
    ));
  });

  test('does not pass null filters to RPC', () async {
    const filter = MapFilter(); // All new filters null

    when(mockClient.rpc(any, params: anyNamed('params')))
        .thenAnswer((_) async => {'professionals': []});

    await datasource.searchMapBundle(filter);

    verify(mockClient.rpc(
      'map_search_bundle',
      params: argThat(
        isNot(contains('p_wedding_book_free')),
        named: 'params',
      ),
    ));
  });

  test('combines new filters with existing filters', () async {
    final filter = MapFilter(
      professions: [Profession.photographer],
      weddingBookFree: true,
      minRating: 4.0,
    );

    when(mockClient.rpc(any, params: anyNamed('params')))
        .thenAnswer((_) async => {'professionals': []});

    await datasource.searchMapBundle(filter);

    final params = verify(mockClient.rpc(
      'map_search_bundle',
      params: captureAnyNamed('params'),
    )).captured.single as Map<String, dynamic>;

    expect(params['p_professions'], contains('photographer'));
    expect(params['p_wedding_book_free'], isTrue);
    expect(params['p_min_rating'], 4.0);
  });
});
```

### Performance verification
```sql
-- Run EXPLAIN ANALYZE on the RPC with filters
EXPLAIN ANALYZE
SELECT * FROM map_search_bundle(
  p_wedding_book_free := TRUE,
  p_trailer_free := TRUE,
  p_min_rating := 4.0
);
-- Verify index usage and execution time < 500ms
```

## Definition of Done
- [ ] Criteres valides
- [ ] Migration RPC appliquee
- [ ] Datasource modifie pour passer nouveaux parametres
- [ ] Tests unitaires pour chaque nouveau filtre
- [ ] Tests integration (si applicable)
- [ ] EXPLAIN ANALYZE < 500ms
- [ ] Index utilises (verifier query plan)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Backward compatible (null = pas de filtre)

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (modification RPC production)

## Dependances
- S01 (colonne offers_free_wedding_book)
- S02 (colonne offers_free_trailer)
- S03 (MapFilter etendu)

## Stories Dependantes
- Aucune (story d'integration finale)
