# TRACKING - EPIC-07-REVIEWS

> Status : 🔵 Draft
> Stories : 0/9 completees
> Derniere MAJ : 2026-01-28

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Systeme d'avis clients (APP-01) |
| - | - |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Table reviews | 🔵 Todo | - | - | - | BLOQUANT pour S02, S03 |
| S02 - Vue pro_ratings | 🔵 Todo | - | - | - | Depend de S01 |
| S03 - RLS policies reviews | 🔵 Todo | - | - | - | Depend de S01 |
| S04 - Entities Dart | 🔵 Todo | - | - | - | Independant, peut paralleler S01-S03 |
| S05 - Repository + Use Cases | 🔵 Todo | - | - | - | Depend de S04 |
| S06 - UI soumission avis | 🔵 Todo | - | - | - | Depend de S05 |
| S07 - UI affichage profil | 🔵 Todo | - | - | - | Depend de S05 |
| S08 - MapFilter.minRating | 🔵 Todo | - | - | - | Independant |
| S09 - Query map filter rating | 🔵 Todo | - | - | - | Depend de S08 et S02 |

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-01-28 | Vue simple (pas materialized) pour pro_ratings | MVP, simplicite, real-time | Performance acceptable pour 50 pros |
| 2026-01-28 | Pas de DELETE policy sur reviews | Integrite des notes, confiance | Avis permanents |
| 2026-01-28 | Contrainte UNIQUE(pro_id, bride_id) | Une bride = un seul avis par pro | Evite manipulation note |
| 2026-01-28 | Rating 1-5 (pas 0-5) | UX standard, pas de note nulle | Check constraint |
| 2026-01-28 | Commentaire optionnel 500 chars max | Balance detail/spam | Validation client + DB |

---

## Ce qui reste pour 100%

### Database (Stories S01-S03)

- [ ] S01: Table reviews avec colonnes id, pro_id, bride_id, rating, comment, timestamps
- [ ] S01: Constraint CHECK rating 1-5
- [ ] S01: Constraint UNIQUE (pro_id, bride_id)
- [ ] S01: Index idx_reviews_pro_id
- [ ] S01: Index idx_reviews_bride_id
- [ ] S01: Trigger updated_at
- [ ] S01: RLS enabled
- [ ] S02: Vue pro_ratings (AVG + COUNT)
- [ ] S03: Policy "Reviews readable by all" (SELECT)
- [ ] S03: Policy "Bride can create review" (INSERT)
- [ ] S03: Policy "Bride can update own review" (UPDATE)

### Flutter Domain (Story S04)

- [ ] S04: Entite Review avec fromJson/toJson
- [ ] S04: Entite ProRating avec fromJson
- [ ] S04: Tests unitaires entities

### Flutter Data (Story S05)

- [ ] S05: Interface ReviewRepository
- [ ] S05: SupabaseReviewRepository implementation
- [ ] S05: getReviewsForPro(proId)
- [ ] S05: getRatingForPro(proId)
- [ ] S05: getRatingsForPros(proIds) batch
- [ ] S05: createReview(proId, rating, comment)
- [ ] S05: updateReview(reviewId, rating, comment)
- [ ] S05: hasReviewedPro(proId)
- [ ] S05: getMyReviewForPro(proId)
- [ ] S05: getMyReviews()
- [ ] S05: Tests unitaires repository

### Flutter UI (Stories S06-S07)

- [ ] S06: Widget StarRatingInput (interactif)
- [ ] S06: Widget StarRatingDisplay (lecture seule)
- [ ] S06: ReviewSubmitSheet (formulaire)
- [ ] S06: Validation rating obligatoire
- [ ] S06: Gestion edit vs create
- [ ] S06: Loading state et error handling
- [ ] S07: ReviewsSection widget
- [ ] S07: ReviewCard widget
- [ ] S07: Integration profil pro existant
- [ ] S07: Affichage "4.5/5 (12 reviews)"
- [ ] S07: Empty state "No reviews yet"
- [ ] S07: Bouton Write/Edit review

### Flutter Map (Stories S08-S09)

- [ ] S08: Champ minRating dans MapFilter
- [ ] S08: copyWith pour minRating
- [ ] S08: hasRatingFilter property
- [ ] S08: Update == et hashCode
- [ ] S09: Section rating dans FilterSheet
- [ ] S09: Slider 1-5 etoiles
- [ ] S09: Modification RPC ou filtrage client
- [ ] S09: Tests integration filtre

### TEST (Transversal)

- [ ] Tests unitaires entities Review, ProRating
- [ ] Tests unitaires repository
- [ ] Tests widgets StarRating
- [ ] Tests integration RLS policies
- [ ] Tests integration map filter
- [ ] flutter analyze --fatal-infos passe
- [ ] Validation sur branche Supabase avant production

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 9 |
| Stories completees | 0 |
| Migrations SQL | 3 (S01, S02, S03) |
| Policies RLS | 3 |
| Fichiers Dart a creer | ~8 |
| Tests a ajouter | ~20 (estimes) |
| Temps estime | 0.5 jour |

---

## Dependances Inter-Stories

```
S01 (table reviews)
  |
  +---> S02 (vue pro_ratings)
  |
  +---> S03 (RLS policies)

S04 (entities) --- Peut paralleler S01-S03
  |
  +---> S05 (repository)
         |
         +---> S06 (UI submit)
         |
         +---> S07 (UI display)

S08 (MapFilter.minRating) --- Independant
  |
  +---> S09 (query filter) --- Depend aussi de S02
```

---

## Dependances Externes

| Dependance | Type | Status |
|------------|------|--------|
| EPIC-06 (Prerequisites) | Soft | Non bloquant, guest role non utilise ici |
| Table profiles | Existe | OK (254 rows) |
| Table professional_details | Existe | OK (51 rows) |
| Map feature | Existe | OK, a modifier pour S08-S09 |
| Design System | Existe | OK, reutiliser LynewedColors, etc. |

---

## Checklist Pre-Production

Avant de merger les migrations en production:

- [ ] Table reviews testee sur branche Supabase
- [ ] Vue pro_ratings retourne donnees correctes
- [ ] RLS policies validees (SELECT all, INSERT bride, UPDATE own)
- [ ] Rollback teste pour chaque migration
- [ ] Entites Dart fonctionnelles avec tests
- [ ] Repository integre avec Supabase
- [ ] Widgets UI fonctionnels
- [ ] Filtre map integre
- [ ] Aucun warning flutter analyze
- [ ] Tests passent (flutter test)
- [ ] Documentation a jour
- [ ] Backup production fait avant migration

---

## Fichiers a Creer/Modifier

### A Creer

| Fichier | Story | Description |
|---------|-------|-------------|
| `lib/features/reviews/domain/entities/review.dart` | S04 | Entite Review |
| `lib/features/reviews/domain/entities/pro_rating.dart` | S04 | Entite ProRating |
| `lib/features/reviews/domain/repositories/review_repository.dart` | S05 | Interface repository |
| `lib/features/reviews/data/repositories/supabase_review_repository.dart` | S05 | Implementation |
| `lib/features/reviews/presentation/widgets/star_rating_input.dart` | S06 | Widget etoiles |
| `lib/features/reviews/presentation/sheets/review_submit_sheet.dart` | S06 | Sheet soumission |
| `lib/features/reviews/presentation/widgets/reviews_section.dart` | S07 | Section profil |
| `lib/features/reviews/reviews.dart` | - | Barrel file |

### A Modifier

| Fichier | Story | Modification |
|---------|-------|--------------|
| `lib/features/map/domain/entities/map_filter.dart` | S08 | Ajouter minRating |
| `lib/features/map/presentation/widgets/filter_sheet.dart` | S09 | Section rating slider |
| `lib/features/map/data/datasources/supabase_map_datasource.dart` | S09 | Filtre rating dans RPC |

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
