# EPIC-07-REVIEWS - TRACKING

> **Status** : 🟢 EN COURS
> **Derniere MAJ** : 2026-01-29
> **Branche** : `fix/project-cleanup`

---

## Progress Overview

| Story | Status | Date | Notes |
|-------|--------|------|-------|
| S01 - Table reviews | ✅ DONE | 2026-01-28 | Migration appliquee production |
| S02 - Vue pro_ratings | ✅ DONE | 2026-01-28 | Vue creee avec AVG/COUNT |
| S03 - RLS policies | ✅ DONE | 2026-01-28 | 3 policies (SELECT/INSERT/UPDATE) |
| S04 - Entities Dart | ✅ DONE | 2026-01-28 | Review + ProRating entities |
| S05 - ReviewRepository | ✅ DONE | 2026-01-28 | SupabaseReviewRepository + DI |
| S06 - UI soumission | ✅ DONE | 2026-01-29 | ReviewSubmitSheet fonctionnel |
| S07 - UI affichage | ✅ DONE | 2026-01-29 | ReviewsSection + integration |
| S08 - MapFilter.minRating | ✅ DONE | 2026-01-29 | Field + copyWith fix (clearMinRating) |
| S09 - Query map filter | ✅ DONE | 2026-01-29 | RPC modifiee server-side |

**Progress: 9/9 stories (100%)**

---

## Session 2026-01-29

### Travail effectue

#### 1. Fix bug "Any rating" non re-selectionnable
- **Probleme** : `copyWith(minRating: null)` ne fonctionnait pas a cause de `??` operator
- **Solution** : Ajout de `clearMinRating` boolean parameter dans `MapFilter.copyWith()`
- **Fichier** : [map_filter.dart](lib/features/map/domain/entities/map_filter.dart):148

#### 2. Ajout option "5 stars" aux rating chips
- **Fichier** : [rating_filter_chips.dart](lib/features/reviews/presentation/widgets/rating_filter_chips.dart):21-27
- Options: 5 stars, 4+ stars, 3+ stars, 2+ stars, 1+ stars

#### 3. Filtre rating server-side dans RPC `search_map_bundle`
- **Migration Supabase** : `add_rating_filter_to_search_map_bundle`
- **Changements** :
  - Ajout `v_min_rating` extraction du JSON filters
  - LEFT JOIN sur `pro_ratings` view
  - Filter condition: `AND (v_min_rating IS NULL OR rat.average_rating >= v_min_rating)`
- **Client Flutter** : [supabase_map_datasource.dart](lib/features/map/data/datasources/supabase_map_datasource.dart):66 - `'minRating': filter.minRating?.toString()`

#### 4. ReviewSubmitSheet depuis la Map
- **Probleme** : `_handleWriteReview` naviguait vers ProDetailsPage au lieu d'ouvrir le sheet
- **Solution** : Ouverture directe de `ReviewSubmitSheet` avec callback `createReview`
- **Fichier** : [map_page.dart](lib/features/map/presentation/pages/map_page.dart):1152-1184

#### 5. Section Reviews dans ProDetailsPage
- **Ajout** :
  - Imports: ReviewRepository, ReviewsSection, ReviewSubmitSheet, ProRating, Review
  - Variables: `_proRating`, `_reviews`, `_myReview`, `_isLoadingReviews`
  - Methodes: `_loadReviews()`, `_handleWriteReview()`, `_canWriteReview` getter
  - Widget: `ReviewsSection` dans le body
- **Fichier** : [pro_details_page.dart](lib/features/profile/presentation/pages/pro_details_page.dart):112-195, 242-251

#### 6. Fermeture automatique du sheet apres soumission
- **Probleme** : Le sheet restait ouvert apres soumission d'un avis
- **Solution** : Ajout de `Navigator.of(context).pop()` dans `_handleSubmit()` apres succes
- **Fichier** : [review_submit_sheet.dart](lib/features/reviews/presentation/sheets/review_submit_sheet.dart):84-86
- **Impact** : map_page.dart et pro_details_page.dart - suppression des `navigator.pop()` redondants

### Tests manuels effectues

| Test | Resultat |
|------|----------|
| Creer review via MCP (Tom Berthet 5 stars) | ✅ OK |
| Affichage review sur ProfessionalDetailsSheet | ✅ OK |
| Rating visible sur fiche pro (4.5/5 - 1 review) | ✅ OK |
| Ouverture ReviewSubmitSheet depuis map | ✅ OK |
| Filtre rating server-side | ✅ OK (a confirmer user) |
| Fermeture auto sheet apres soumission | ✅ OK |
| Section Reviews sur ProDetailsPage | ⏳ A tester (code pret) |

### Build status

```
flutter analyze: No issues found!
```

---

## Decisions techniques

### D-07-01: Filtrage rating server-side vs client-side
- **Decision** : Server-side dans RPC `search_map_bundle`
- **Raison** : Performance, moins de data transferees, coherence avec autres filtres
- **Date** : 2026-01-29

### D-07-02: clearMinRating parameter
- **Decision** : Ajouter boolean `clearMinRating` a `MapFilter.copyWith()`
- **Raison** : Dart `??` operator empeche d'assigner `null` via copyWith
- **Pattern** : Utilise pour tous les champs nullable qui doivent pouvoir etre reset
- **Date** : 2026-01-29

---

## Fichiers modifies (session 2026-01-29)

| Fichier | Type | Description |
|---------|------|-------------|
| `map_filter.dart` | Edit | clearMinRating param |
| `rating_filter_chips.dart` | Edit | Option "5 stars" |
| `supabase_map_datasource.dart` | Edit | minRating dans filters RPC |
| `map_page.dart` | Edit | _handleWriteReview ouvre sheet |
| `pro_details_page.dart` | Edit | Section Reviews complete |
| `review_submit_sheet.dart` | Edit | Fermeture auto apres succes |
| `rating_filter_chips_test.dart` | Edit | Test "5 stars" |

---

## Issues resolues

### Issue: "Any rating" non re-selectionnable
- **Symptome** : Une fois un rating selectionne, impossible de revenir a "Any rating"
- **Cause racine** : `copyWith(minRating: value)` avec `value = null` ne reset pas car `??`
- **Fix** : `copyWith(clearMinRating: true)` dans filter_sheet.dart
- **Commit** : (a faire)

### Issue: "No reviews yet" malgre review existante
- **Symptome** : Tom Berthet avait un review mais "No reviews yet" affiche
- **Cause racine** : ProfessionalDetailsSheet recevait `averageRating`/`reviewCount` mais pas passes par map_page.dart
- **Fix** : Ajout `_loadDetails()` qui fetch ratings via ReviewRepository
- **Commit** : (a faire)

### Issue: Filtre rating ne filtre pas sur la map
- **Symptome** : Selection "5 stars" mais tous les pros affiches
- **Cause racine** : Filtre minRating pas passe a la RPC server-side
- **Fix** : Migration RPC + passage minRating dans filters
- **Commit** : (a faire)

---

## Prochaines etapes

1. ✅ ~~Filtre rating server-side~~ DONE
2. ✅ ~~ReviewSubmitSheet depuis map~~ DONE
3. ✅ ~~Section Reviews dans ProDetailsPage~~ DONE
4. ✅ ~~Fermeture auto sheet apres soumission~~ DONE
5. [ ] **Rebuild iOS pour tester les dernieres modifications**
6. [ ] Test manuel complet par user
7. [ ] Commit + PR si valide

---

## References

- **Epic** : [EPIC-07-REVIEWS.md](EPIC-07-REVIEWS.md)
- **PRD** : [MISSION-01-EVOLUTIONS-2026.md](../../specs/MISSION-01-EVOLUTIONS-2026.md) Section 4 (APP-01)
- **Supabase Project** : `hekyovgnovhfhmkpfrna`
