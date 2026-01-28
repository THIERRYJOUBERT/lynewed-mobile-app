# EPIC-13-MAP-FILTERS

> Resume : Filtres Map additionnels - Wedding book free, Trailer free, Note minimum, Marketplace markers
> Status : Draft
> Domaine : Map Feature / Presentation / Database
> Cree le : 2026-01-28

---

## Contexte

### Pourquoi cet Epic

La map Lynewed est une feature centrale permettant aux brides de decouvrir des professionnels du mariage. Actuellement, elle offre des filtres par profession et budget. Cet Epic enrichit ces capacites avec :

1. **Nouveaux filtres pro** : Wedding book gratuit, Trailer gratuit
2. **Filtre note minimum** : Filtrer les pros par rating (depend de EPIC-07 reviews)
3. **Nouveau type de marqueur** : Articles marketplace sur la carte
4. **Coherence UI** : Integration transparente avec les filtres existants

### Etat Actuel Verifie (Supabase MCP)

**Table `professional_details` (51 rows)** :
- Colonnes existantes : professions, pricing, location, portfolio
- Colonnes ABSENTES : `offers_free_wedding_book`, `offers_free_trailer`

**MapFilter actuel** :
```dart
class MapFilter {
  final List<Profession> professions;
  final double? budgetMin;
  final double? budgetMax;
  final String currency;
  final LayerToggles toggles;
  // ABSENTS: weddingBookFree, trailerFree, minRating
}
```

**MapMarkerType actuel** :
```dart
enum MapMarkerType {
  proFixedLocation,
  professionalAlert,
  wedding,
  // ABSENT: marketplaceItem
}
```

**Decision D-13 (PRD)** : Les Guests n'ont PAS acces a la map.

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| **Supabase Database** | Ajout colonnes `offers_free_wedding_book`, `offers_free_trailer` |
| **Flutter Map Feature** | Extension MapFilter, MapMarkerType, FilterSheet UI |
| **RPC map_search_bundle** | Modification pour appliquer nouveaux filtres |
| **EPIC-07 Dependency** | Le filtre minRating necessite la table `reviews` |

---

## Architecture Cible

```
+-----------------------------------------------------------------------------+
|                        MAP FILTERS - ARCHITECTURE CIBLE                      |
|                                                                              |
|  FILTER SHEET UI                                                             |
|  +-----------------------------------------------------------------------+  |
|  |  FILTRES                                                              |  |
|  |                                                                       |  |
|  |  Profession : [Photographer] [Filmmaker] [Planner] ...               |  |
|  |                                                                       |  |
|  |  Budget : |--------[====]--------|  EUR 500 - EUR 5000               |  |
|  |                                                                       |  |
|  |  Note minimum :                                                       |  |
|  |  [*] [**] [***] [****] [*****]  4 etoiles minimum                    |  |
|  |                                                                       |  |
|  |  Offres speciales :                                                   |  |
|  |  [ ] Wedding book gratuit                                            |  |
|  |  [ ] Trailer gratuit                                                 |  |
|  |                                                                       |  |
|  |  Afficher sur la carte :                                             |  |
|  |  [x] Pros  [x] Alerts  [x] Weddings  [ ] Marketplace                 |  |
|  |                                                                       |  |
|  |  [        APPLIQUER LES FILTRES        ]                             |  |
|  +-----------------------------------------------------------------------+  |
|                                                                              |
|  MAP MARKERS                                                                 |
|  +-----------------------------------------------------------------------+  |
|  |  proFixedLocation  : Circle with avatar (existing)                    |  |
|  |  professionalAlert : Red bell icon (existing)                         |  |
|  |  wedding           : Pink diamond icon (existing)                     |  |
|  |  marketplaceItem   : NEW - Dress/Shoes icon (purple/pink)            |  |
|  +-----------------------------------------------------------------------+  |
|                                                                              |
|  DATABASE EXTENSION                                                          |
|  +-----------------------------------------------------------------------+  |
|  |  professional_details                                                 |  |
|  |  + offers_free_wedding_book BOOLEAN DEFAULT FALSE                     |  |
|  |  + offers_free_trailer BOOLEAN DEFAULT FALSE                          |  |
|  +-----------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------+
```

---

## UI Mockup - Filter Sheet

```
+-----------------------------------------------+
|  [=] FILTRES                        [Reset]   |
+-----------------------------------------------+
|                                               |
|  Filter by profession                         |
|  +-------------------------------------------+
|  | [Photographer] [Filmmaker] [Planner]      |
|  | [Makeup] [Florist] [Venue] [+12]          |
|  +-------------------------------------------+
|                                               |
|  Budget range                                 |
|  +-------------------------------------------+
|  | EUR 0          [====|====]       EUR 10K  |
|  +-------------------------------------------+
|                                               |
|  Note minimum (depends on EPIC-07)            |
|  +-------------------------------------------+
|  | [1*] [2*] [3*] [4*] [5*]    4+ selected  |
|  +-------------------------------------------+
|                                               |
|  Offres speciales                             |
|  +-------------------------------------------+
|  | [ ] Wedding book offert                   |
|  | [ ] Trailer offert                        |
|  +-------------------------------------------+
|                                               |
|  Layers                                       |
|  +-------------------------------------------+
|  | [x] Pros  [x] Alerts  [x] Weddings        |
|  | [ ] Marketplace                           |
|  +-------------------------------------------+
|                                               |
|  +-------------------------------------------+
|  |         [  APPLIQUER FILTRES  ]           |
|  +-------------------------------------------+
+-----------------------------------------------+
```

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source PRD | Complexite |
|---|-------|---------|------|---------------|------------|------------|
| S01 | Ajouter colonne offers_free_wedding_book | DB | - | Migration, default FALSE, pas de RLS change | US-07.1 | S |
| S02 | Ajouter colonne offers_free_trailer | DB | - | Migration, default FALSE, pas de RLS change | US-07.2 | S |
| S03 | Etendre MapFilter avec nouveaux champs | Domain | S01,S02 | weddingBookFree, trailerFree, minRating nullable | US-07.1,2,4 | S |
| S04 | Ajouter marketplaceItem a MapMarkerType | Domain | - | Enum value, backward compatible | US-07.3 | S |
| S05 | Creer icone marqueur marketplace | Presentation | S04 | Style coherent, dress/shoes icon | US-07.3 | S |
| S06 | Mettre a jour FilterSheet UI | Presentation | S03 | Checkboxes, rating slider, UX coherente | US-07.1,2,4 | M |
| S07 | Mettre a jour query map avec nouveaux filtres | Data | S03 | RPC modifie, filtres optionnels | US-07.1,2,4 | M |
| S08 | Tap marqueur marketplace ouvre details | Presentation | S04,S05 | Navigation vers listing, sheet details | US-07.5 | M |
| S09 | Verifier que guests n'ont pas acces map | Tests | - | Decision D-13 respectee, test unitaire | PRD D-13 | S |

---

## Detail des Stories

### S01 : Ajouter colonne offers_free_wedding_book

**Criteres cles** :
- Colonne `offers_free_wedding_book` BOOLEAN DEFAULT FALSE ajoutee a `professional_details`
- Migration reversible avec rollback
- Aucune modification RLS (table existante, policies OK)
- 0 impact sur les 51 pros existants (default FALSE)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 9 (APP-07), US-07.1

**Complexite** : S (Small) - Migration simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Wedding book free filter column

  Scenario: Adding offers_free_wedding_book column
    Given the professional_details table exists with 51 rows
    When the migration add_offers_free_wedding_book is applied
    Then professional_details should have column offers_free_wedding_book of type BOOLEAN
    And offers_free_wedding_book should default to FALSE
    And all existing 51 rows should have offers_free_wedding_book = FALSE

  Scenario: Column allows NULL values
    Given the offers_free_wedding_book column exists
    When a professional updates their profile
    Then they can set offers_free_wedding_book to TRUE, FALSE, or NULL
    And NULL should be treated as FALSE in filter logic

  Scenario: Rollback is possible
    Given the migration has been applied
    When the rollback is executed
    Then the offers_free_wedding_book column should be removed
    And no data should be lost from other columns
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128010001_add_offers_free_wedding_book
-- Description: Add wedding book free filter column to professional_details

ALTER TABLE professional_details
  ADD COLUMN IF NOT EXISTS offers_free_wedding_book BOOLEAN DEFAULT FALSE;

-- Create index for filter queries
CREATE INDEX IF NOT EXISTS idx_pro_details_wedding_book
  ON professional_details(offers_free_wedding_book)
  WHERE offers_free_wedding_book = TRUE;

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'professional_details' AND column_name = 'offers_free_wedding_book'
  ) THEN
    RAISE EXCEPTION 'Migration failed: offers_free_wedding_book column not created';
  END IF;
END $$;

-- Comment
COMMENT ON COLUMN professional_details.offers_free_wedding_book IS 'Professional offers a free wedding book/album (APP-07)';
```

**Rollback** :
```sql
-- Rollback: 20260128010001_add_offers_free_wedding_book
DROP INDEX IF EXISTS idx_pro_details_wedding_book;
ALTER TABLE professional_details DROP COLUMN IF EXISTS offers_free_wedding_book;
```

---

### S02 : Ajouter colonne offers_free_trailer

**Criteres cles** :
- Colonne `offers_free_trailer` BOOLEAN DEFAULT FALSE ajoutee a `professional_details`
- Migration reversible avec rollback
- Aucune modification RLS (table existante, policies OK)
- 0 impact sur les 51 pros existants (default FALSE)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 9 (APP-07), US-07.2

**Complexite** : S (Small) - Migration simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Trailer free filter column

  Scenario: Adding offers_free_trailer column
    Given the professional_details table exists with 51 rows
    When the migration add_offers_free_trailer is applied
    Then professional_details should have column offers_free_trailer of type BOOLEAN
    And offers_free_trailer should default to FALSE
    And all existing 51 rows should have offers_free_trailer = FALSE

  Scenario: Column allows NULL values
    Given the offers_free_trailer column exists
    When a professional updates their profile
    Then they can set offers_free_trailer to TRUE, FALSE, or NULL
    And NULL should be treated as FALSE in filter logic

  Scenario: Rollback is possible
    Given the migration has been applied
    When the rollback is executed
    Then the offers_free_trailer column should be removed
    And no data should be lost from other columns
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128010002_add_offers_free_trailer
-- Description: Add trailer free filter column to professional_details

ALTER TABLE professional_details
  ADD COLUMN IF NOT EXISTS offers_free_trailer BOOLEAN DEFAULT FALSE;

-- Create index for filter queries
CREATE INDEX IF NOT EXISTS idx_pro_details_trailer
  ON professional_details(offers_free_trailer)
  WHERE offers_free_trailer = TRUE;

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'professional_details' AND column_name = 'offers_free_trailer'
  ) THEN
    RAISE EXCEPTION 'Migration failed: offers_free_trailer column not created';
  END IF;
END $$;

-- Comment
COMMENT ON COLUMN professional_details.offers_free_trailer IS 'Professional offers a free wedding trailer video (APP-07)';
```

**Rollback** :
```sql
-- Rollback: 20260128010002_add_offers_free_trailer
DROP INDEX IF EXISTS idx_pro_details_trailer;
ALTER TABLE professional_details DROP COLUMN IF EXISTS offers_free_trailer;
```

---

### S03 : Etendre MapFilter avec nouveaux champs

**Criteres cles** :
- `MapFilter` etendu avec `weddingBookFree`, `trailerFree`, `minRating`
- Tous les champs nullable (null = pas de filtre)
- `LayerToggles` etendu avec `showMarketplace`
- Backward compatible (defaults preservent comportement existant)
- Tests unitaires mis a jour

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 9 (APP-07), US-07.1, US-07.2, US-07.4

**Complexite** : S (Small) - Modification entite Dart

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Extended MapFilter entity

  Scenario: MapFilter supports wedding book filter
    Given a MapFilter instance
    When weddingBookFree is set to TRUE
    Then only professionals with offers_free_wedding_book = TRUE should match
    When weddingBookFree is NULL
    Then all professionals should match regardless of wedding book offer

  Scenario: MapFilter supports trailer filter
    Given a MapFilter instance
    When trailerFree is set to TRUE
    Then only professionals with offers_free_trailer = TRUE should match
    When trailerFree is NULL
    Then all professionals should match regardless of trailer offer

  Scenario: MapFilter supports minimum rating filter
    Given a MapFilter instance with minRating = 4.0
    When filtering professionals
    Then only professionals with average_rating >= 4.0 should match
    When minRating is NULL
    Then all professionals should match regardless of rating

  Scenario: LayerToggles includes marketplace
    Given a LayerToggles instance
    When showMarketplace is TRUE
    Then marketplace items should be visible on map
    When showMarketplace is FALSE (default)
    Then marketplace items should be hidden

  Scenario: Backward compatibility
    Given an existing MapFilter.defaults
    When the updated code is deployed
    Then weddingBookFree should be NULL
    And trailerFree should be NULL
    And minRating should be NULL
    And showMarketplace should be FALSE
    And existing filter behavior should be unchanged
```

**Details techniques** :

**Fichiers a modifier** :
- `lib/features/map/domain/entities/map_filter.dart`

**Modification MapFilter** :
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

  // Update copyWith...
}
```

**Modification LayerToggles** :
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

**Tests** :
- `test/features/map/domain/entities/map_filter_test.dart` - Ajouter tests pour nouveaux champs

---

### S04 : Ajouter marketplaceItem a MapMarkerType

**Criteres cles** :
- Nouvelle valeur `marketplaceItem` dans enum `MapMarkerType`
- Backward compatible (switch/case existants gerent le nouveau type)
- Documentation enum mise a jour

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 9 (APP-07), US-07.3

**Complexite** : S (Small) - Modification enum

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace marker type

  Scenario: MapMarkerType includes marketplaceItem
    Given the MapMarkerType enum
    When checking available values
    Then marketplaceItem should be a valid value
    And it should be distinct from proFixedLocation, professionalAlert, wedding

  Scenario: Existing code handles new type gracefully
    Given code using switch on MapMarkerType
    When a marketplaceItem marker is encountered
    Then no runtime error should occur
    And a default/fallback behavior should apply until fully implemented

  Scenario: Marker creation with marketplace type
    Given a marketplace listing with location
    When creating a MapMarker
    Then MapMarker should accept type: MapMarkerType.marketplaceItem
    And marker should have appropriate metadata (listing_id, category, price)
```

**Details techniques** :

**Fichiers a modifier** :
- `lib/features/map/domain/entities/map_marker.dart`

**Modification enum** :
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

---

### S05 : Creer icone marqueur marketplace

**Criteres cles** :
- Nouvelle methode `_createMarketplaceIcon` dans `MarkerIconGenerator`
- Icone coherente avec le design system (cercle avec icone centrale)
- Couleur distincte (suggestion: violet/magenta pour se distinguer)
- Icone differente selon categorie (dress vs shoes) via metadata

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 9 (APP-07), US-07.3

**Complexite** : S (Small) - Extension generateur icones

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace marker icon

  Scenario: Icon generation for marketplace item
    Given a MapMarker with type marketplaceItem
    When generateIcon is called
    Then a BitmapDescriptor should be returned
    And the icon should be visually distinct from other marker types

  Scenario: Icon matches design system
    Given the Lynewed design system
    When creating marketplace icon
    Then it should use consistent size (44px display)
    And it should have shadow effect
    And it should have colored border

  Scenario: Different icons for dress vs shoes
    Given a marketplace marker with category 'dress'
    When generateIcon is called
    Then a dress-style icon should be rendered

    Given a marketplace marker with category 'shoes'
    When generateIcon is called
    Then a shoes-style icon should be rendered

  Scenario: Icon caching works
    Given a marketplace marker
    When generateIcon is called twice with same parameters
    Then cached icon should be returned
    And no redundant image generation should occur
```

**Details techniques** :

**Fichiers a modifier** :
- `lib/features/map/presentation/services/marker_icon_generator.dart`
- `lib/features/map/presentation/theme/map_theme.dart`

**Nouvelle methode** :
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

**Map theme colors** :
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

---

### S06 : Mettre a jour FilterSheet UI

**Criteres cles** :
- Section "Offres speciales" avec 2 checkboxes
- Section "Note minimum" avec slider 1-5 (disabled si EPIC-07 pas deploye)
- Section "Layers" avec toggle marketplace
- Coherence UI avec sections existantes (professions, budget)
- Reset efface les nouveaux filtres aussi

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 9 (APP-07), US-07.1, US-07.2, US-07.4

**Complexite** : M (Medium) - UI changes significatifs

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Updated FilterSheet UI

  Scenario: Special offers section displayed
    Given the FilterSheet is opened
    When the user scrolls to the "Special offers" section
    Then a checkbox "Wedding book free" should be visible
    And a checkbox "Trailer free" should be visible
    And both checkboxes should be unchecked by default

  Scenario: Toggling wedding book filter
    Given the FilterSheet is opened
    When the user checks "Wedding book free"
    Then the filter state should update weddingBookFree = true
    When the user unchecks "Wedding book free"
    Then the filter state should update weddingBookFree = null

  Scenario: Minimum rating section (requires EPIC-07)
    Given EPIC-07 reviews feature is deployed
    When the FilterSheet is opened
    Then a "Minimum rating" section should be visible
    And a slider or star selector (1-5) should allow selection

  Scenario: Minimum rating section (EPIC-07 not deployed)
    Given EPIC-07 reviews feature is NOT deployed
    When the FilterSheet is opened
    Then the "Minimum rating" section should be hidden OR disabled
    And a tooltip "Coming soon" may be shown

  Scenario: Marketplace layer toggle
    Given the FilterSheet is opened
    When the user enables "Marketplace" in layers
    Then filter.toggles.showMarketplace should be TRUE
    And marketplace items should appear on map

  Scenario: Reset clears new filters
    Given the user has set weddingBookFree=true, minRating=4
    When the user taps "Reset"
    Then weddingBookFree should be null
    And trailerFree should be null
    And minRating should be null
    And showMarketplace should be false
```

**Details techniques** :

**Fichiers a modifier** :
- `lib/features/map/presentation/widgets/filter_sheet.dart`

**Nouvelles sections** :
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

**Rating slider widget** :
```dart
Widget _buildRatingSlider() {
  // TODO: Enable when EPIC-07 deployed
  final isEnabled = false; // Feature flag

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

---

### S07 : Mettre a jour query map avec nouveaux filtres

**Criteres cles** :
- RPC `map_search_bundle` etendu pour supporter nouveaux filtres
- Filtres appliques cote serveur (performance)
- Filtres optionnels (null = pas de filtre)
- Join avec `reviews` pour minRating (si EPIC-07 deploye)
- Tests de performance : filtres ne ralentissent pas la map

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 9 (APP-07)

**Complexite** : M (Medium) - Modification RPC

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Map query with new filters

  Scenario: Wedding book filter applied server-side
    Given a map search with weddingBookFree = TRUE
    When the RPC map_search_bundle is called
    Then only professionals with offers_free_wedding_book = TRUE are returned
    And the filter is applied in SQL (not client-side)

  Scenario: Trailer filter applied server-side
    Given a map search with trailerFree = TRUE
    When the RPC map_search_bundle is called
    Then only professionals with offers_free_trailer = TRUE are returned

  Scenario: Combined filters work
    Given a map search with weddingBookFree = TRUE AND profession = 'photographer'
    When the RPC map_search_bundle is called
    Then only photographers offering free wedding book are returned

  Scenario: Null filters return all results
    Given a map search with weddingBookFree = NULL
    When the RPC map_search_bundle is called
    Then all professionals are returned (wedding book not filtered)

  Scenario: Rating filter (requires EPIC-07)
    Given EPIC-07 reviews table exists
    And a map search with minRating = 4.0
    When the RPC map_search_bundle is called
    Then only professionals with average_rating >= 4.0 are returned

  Scenario: Performance is acceptable
    Given 1000 professionals in database
    When filtering with all new filters enabled
    Then response time should be < 500ms
    And no N+1 queries should occur
```

**Details techniques** :

**Fichiers a modifier** :
- `lib/features/map/data/datasources/supabase_map_datasource.dart`
- RPC SQL function `map_search_bundle` (via migration)

**RPC modification** :
```sql
-- Extend map_search_bundle function parameters
-- Add: p_wedding_book_free BOOLEAN DEFAULT NULL
-- Add: p_trailer_free BOOLEAN DEFAULT NULL
-- Add: p_min_rating NUMERIC DEFAULT NULL

-- In WHERE clause, add:
AND (p_wedding_book_free IS NULL OR pd.offers_free_wedding_book = p_wedding_book_free)
AND (p_trailer_free IS NULL OR pd.offers_free_trailer = p_trailer_free)
AND (p_min_rating IS NULL OR COALESCE(
  (SELECT AVG(rating) FROM reviews WHERE pro_id = pd.user_id), 0
) >= p_min_rating)
```

**Datasource modification** :
```dart
// In searchMapBundle method, pass new filter params
final params = {
  // existing params...
  'p_wedding_book_free': filter.weddingBookFree,
  'p_trailer_free': filter.trailerFree,
  'p_min_rating': filter.minRating,
};
```

---

### S08 : Tap marqueur marketplace ouvre details

**Criteres cles** :
- Tap sur marqueur `marketplaceItem` ouvre sheet de details
- Sheet affiche : photo, titre, prix, categorie, vendeur
- Bouton "Voir l'annonce" navigue vers page listing complete
- Coherence avec sheets existantes (alert_details_sheet, wedding_details_sheet)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 9 (APP-07), US-07.5

**Complexite** : M (Medium) - Nouvelle sheet + navigation

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace marker tap interaction

  Scenario: Tapping marketplace marker opens sheet
    Given a marketplace item marker is visible on map
    When the user taps the marker
    Then a bottom sheet should open
    And the sheet should display item details

  Scenario: Sheet displays item information
    Given the marketplace details sheet is open
    Then the item photo should be displayed
    And the item title should be displayed
    And the item price should be displayed (formatted with currency)
    And the item category (dress/shoes) should be displayed
    And the seller name should be displayed

  Scenario: "View listing" navigates to full page
    Given the marketplace details sheet is open
    When the user taps "View listing"
    Then the app should navigate to the marketplace listing page
    And the sheet should close

  Scenario: Sheet styling matches design system
    Given the marketplace details sheet is open
    Then it should use LynewedColors and LynewedTextStyles
    And it should have drag handle
    And it should match styling of other map sheets
```

**Details techniques** :

**Nouveaux fichiers** :
- `lib/features/map/presentation/sheets/marketplace_details_sheet.dart`
- `lib/features/map/domain/entities/marketplace_item.dart` (simple entity)

**Sheet structure** :
```dart
class MarketplaceDetailsSheet extends StatelessWidget {
  const MarketplaceDetailsSheet({
    super.key,
    required this.item,
    required this.onViewListing,
  });

  final MarketplaceItemSummary item;
  final VoidCallback onViewListing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          _buildHandle(),

          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.thumbnailUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(item.title, style: LynewedTextStyles.titleLarge),

          // Price
          Text(
            '${item.currency} ${item.price}',
            style: LynewedTextStyles.titleMedium.copyWith(
              color: LynewedColors.primary,
            ),
          ),

          // Category chip
          Chip(label: Text(item.category)),

          // Seller
          Text('Sold by ${item.sellerName}'),

          const SizedBox(height: 16),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewListing,
              style: LynewedComponentStyles.primaryButton(),
              child: const Text('View listing'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### S09 : Verifier que guests n'ont pas acces map

**Criteres cles** :
- Decision D-13 respectee : Guests ne peuvent pas acceder a la map
- Test unitaire verifiant l'acces selon role
- Navigation bloquee si role = guest
- Message explicatif si tentative d'acces

**Source** : MISSION-01-EVOLUTIONS-2026.md Decision D-13

**Complexite** : S (Small) - Test + verification existante

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guests cannot access map

  Scenario: Guest role blocked from map
    Given a user with role = 'guest'
    When the user attempts to navigate to the map page
    Then the navigation should be blocked
    And an appropriate message should be shown

  Scenario: Bride role can access map
    Given a user with role = 'bride'
    When the user navigates to the map page
    Then the map should be displayed normally

  Scenario: Pro role can access map
    Given a user with role = 'professional'
    When the user navigates to the map page
    Then the map should be displayed normally

  Scenario: Map icon not shown to guests
    Given a user with role = 'guest'
    When viewing the navigation bar
    Then the map icon should NOT be visible
    Or the map tab should be disabled
```

**Details techniques** :

**Fichiers a verifier/modifier** :
- `lib/features/map/presentation/pages/map_page.dart` - Add role check
- Navigation configuration - Ensure map not in guest navbar

**Test file** :
- `test/features/map/presentation/pages/map_page_access_test.dart`

```dart
void main() {
  group('Map Page Access Control', () {
    test('should block access for guest role', () {
      // Verify navigation guard blocks guest
      expect(canAccessMap(role: 'guest'), isFalse);
    });

    test('should allow access for bride role', () {
      expect(canAccessMap(role: 'bride'), isTrue);
    });

    test('should allow access for professional role', () {
      expect(canAccessMap(role: 'professional'), isTrue);
    });
  });
}
```

---

## Dependances

### Dependances Internes

| Story | Depend de | Raison |
|-------|-----------|--------|
| S03 | S01, S02 | MapFilter doit connaitre les colonnes DB |
| S05 | S04 | Icone necessite le type enum |
| S06 | S03 | UI utilise MapFilter etendu |
| S07 | S03 | Query utilise MapFilter etendu |
| S08 | S04, S05 | Sheet necessite marqueur + icone |

### Dependances Externes

| Dependance | Epic | Impact |
|------------|------|--------|
| **EPIC-07 (Reviews)** | Table `reviews` | minRating filter non fonctionnel sans |
| **EPIC-14 (Marketplace)** | Table `marketplace_listings` | Marqueurs marketplace sans donnees |

**Strategie** : Implementer S01-S09 meme si EPIC-07/14 pas deployes. Les filtres rating et marketplace seront "no-op" jusqu'au deploiement des dependances.

---

## Feature Flags Implementation

Les filtres dépendants d'autres Epics sont contrôlés par feature flags :

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

// Usage in FilterSheetWidget:
if (FeatureFlags.showRatingFilter) {
  // Show rating slider
} else {
  // Show "Coming soon" or hide entirely
}
```

**Processus d'activation** :
1. Déployer EPIC-07 → Mettre `enableMinRatingFilter = true`
2. Déployer EPIC-14 → Mettre `enableMarketplaceMarkers = true`
3. Faire un build et release

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| EPIC-07 pas deploye | MOYEN - minRating inutilisable | Feature flag `enableMinRatingFilter`, section UI disabled |
| EPIC-14 pas deploye | MOYEN - marketplace markers vides | Feature flag `enableMarketplaceMarkers`, toggle off par defaut |
| Performance RPC degradee | MOYEN - map lente | Index sur nouvelles colonnes, EXPLAIN ANALYZE |
| UI filter sheet trop longue | FAIBLE - UX degradee | Sections collapsibles si necessaire |
| Backward compatibility | MOYEN - crash ancienne version | Default values null/false preservent comportement |

---

## Ordre d'Execution Recommande

```
Phase 1 : Database (parallelisable)
├── S01 : offers_free_wedding_book column
└── S02 : offers_free_trailer column

Phase 2 : Domain Layer (sequentiel)
├── S04 : MapMarkerType enum
└── S03 : MapFilter extension (after S01, S02)

Phase 3 : Presentation Layer (parallelisable)
├── S05 : Marketplace icon
├── S06 : FilterSheet UI (after S03)
└── S09 : Guest access verification

Phase 4 : Integration (sequentiel)
├── S07 : RPC query modification (after S03)
└── S08 : Marketplace details sheet (after S04, S05)
```

---

## References PRD

| Section PRD | Contenu utilise |
|-------------|-----------------|
| Section 9 (APP-07) | User Stories US-07.1 a US-07.5 |
| Section 9 UI Mockup | Filter sheet layout |
| Decision D-13 | Guests n'ont pas acces a la map |
| Section 10 (APP-08) | Marketplace listings (dependance future) |
| Section 3 (APP-01) | Reviews table (dependance future) |

---

## Prochaine Etape

Apres validation de cet Epic:
1. Executer `/create-story EPIC-13` pour decomposer en stories individuelles
2. Executer S01, S02 (migrations DB) sur branche dev Supabase
3. Implementer S03, S04 (domain layer)
4. Implementer S05, S06 (presentation layer)
5. Deployer et tester
6. Activer minRating quand EPIC-07 deploye
7. Activer marketplace markers quand EPIC-14 deploye
