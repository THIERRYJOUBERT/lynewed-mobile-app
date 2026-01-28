# TRACKING - EPIC-13: Map Filters Additionnels

## Vue d'Ensemble

| Metrique | Valeur |
|----------|--------|
| **Total Stories** | 9 |
| **Completees** | 0 |
| **En Cours** | 0 |
| **Bloquees** | 0 |
| **Progression** | 0% |

### Metriques de Validation
| Metrique | Objectif | Resultat |
|----------|----------|----------|
| `flutter analyze` | 0 warnings | - |
| `flutter test` | 100% pass | - |
| Performance RPC | < 500ms | - |
| Nouveaux tests | +20 minimum | - |

---

## Progression par Phase

### Phase 1 : Database (Stories S01-S02)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S01 | Ajouter colonne offers_free_wedding_book | PENDING | - | - | - |
| S02 | Ajouter colonne offers_free_trailer | PENDING | - | - | - |

**Progression Phase 1** : 0/2 (0%)

---

### Phase 2 : Domain Layer (Stories S03-S04)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S03 | Etendre MapFilter avec nouveaux champs | PENDING | - | - | - |
| S04 | Ajouter marketplaceItem a MapMarkerType | PENDING | - | - | - |

**Progression Phase 2** : 0/2 (0%)

---

### Phase 3 : Presentation Layer (Stories S05-S06, S09)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S05 | Creer icone marqueur marketplace | PENDING | - | - | - |
| S06 | Mettre a jour FilterSheet UI | PENDING | - | - | - |
| S09 | Verifier que guests n'ont pas acces map | PENDING | - | - | - |

**Progression Phase 3** : 0/3 (0%)

---

### Phase 4 : Integration (Stories S07-S08)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S07 | Mettre a jour query map avec nouveaux filtres | PENDING | - | - | - |
| S08 | Tap marqueur marketplace ouvre details | PENDING | - | - | - |

**Progression Phase 4** : 0/2 (0%)

---

## Blockers Actifs

| ID | Description | Story Impactee | Date Identifie | Responsable |
|----|-------------|----------------|----------------|-------------|
| - | - | - | - | - |

---

## Dependances Externes

| Dependance | Epic | Status | Impact sur EPIC-13 |
|------------|------|--------|-------------------|
| Table `reviews` | EPIC-07 | PENDING | S03, S06, S07 : minRating disabled |
| Table `marketplace_listings` | EPIC-14 | PENDING | S08 : markers sans donnees |

**Note** : EPIC-13 peut etre implemente meme si EPIC-07/14 ne sont pas deployes. Les fonctionnalites dependantes seront en mode "feature flag" (disabled).

---

## Decisions Techniques

| Date | Decision | Justification | Stories Impactees |
|------|----------|---------------|-------------------|
| 2026-01-28 | minRating disabled par defaut (feature flag) | EPIC-07 non deploye | S03, S06, S07 |
| 2026-01-28 | showMarketplace = false par defaut | EPIC-14 non deploye | S03, S06, S08 |
| 2026-01-28 | Couleur marketplace = purple (#7B1FA2) | Distinction visuelle des autres markers | S05 |
| 2026-01-28 | Index partiels sur colonnes boolean | Performance: evite scan si filtre false | S01, S02 |

---

## Metriques de Qualite

### Tests
| Metrique | Objectif | Actuel |
|----------|----------|--------|
| Nouveaux tests S03 | 10+ | - |
| Nouveaux tests S06 | 5+ | - |
| Nouveaux tests S09 | 3+ | - |
| Tests regression | 0 fail | - |

### Code
| Metrique | Objectif | Actuel |
|----------|----------|--------|
| Warnings flutter analyze | 0 | - |
| Lignes modifiees | < 500 | - |
| Fichiers modifies | < 15 | - |

### Performance
| Metrique | Objectif | Actuel |
|----------|----------|--------|
| RPC map_search_bundle | < 500ms | - |
| Filter sheet render | < 100ms | - |
| Icon generation (cached) | < 10ms | - |

---

## Fichiers Modifies

### Domain Layer
| Fichier | Story | Status |
|---------|-------|--------|
| `lib/features/map/domain/entities/map_filter.dart` | S03 | PENDING |
| `lib/features/map/domain/entities/map_marker.dart` | S04 | PENDING |

### Presentation Layer
| Fichier | Story | Status |
|---------|-------|--------|
| `lib/features/map/presentation/widgets/filter_sheet.dart` | S06 | PENDING |
| `lib/features/map/presentation/services/marker_icon_generator.dart` | S05 | PENDING |
| `lib/features/map/presentation/theme/map_theme.dart` | S05 | PENDING |
| `lib/features/map/presentation/sheets/marketplace_details_sheet.dart` | S08 | CREATE |

### Data Layer
| Fichier | Story | Status |
|---------|-------|--------|
| `lib/features/map/data/datasources/supabase_map_datasource.dart` | S07 | PENDING |

### Database (Supabase)
| Migration | Story | Status |
|-----------|-------|--------|
| `20260128010001_add_offers_free_wedding_book` | S01 | PENDING |
| `20260128010002_add_offers_free_trailer` | S02 | PENDING |
| `map_search_bundle` RPC modification | S07 | PENDING |

---

## Tests a Creer

| Fichier Test | Story | Cas de Test |
|--------------|-------|-------------|
| `map_filter_test.dart` | S03 | weddingBookFree, trailerFree, minRating, showMarketplace |
| `marker_icon_generator_test.dart` | S05 | marketplaceItem icon generation |
| `filter_sheet_test.dart` | S06 | New UI sections, reset behavior |
| `map_page_access_test.dart` | S09 | Guest role blocked |

---

## Journal des Mises a Jour

| Date | Mise a Jour | Auteur |
|------|-------------|--------|
| 2026-01-28 | Creation de l'Epic et structure initiale | PM |

---

## Prochaines Actions

1. [ ] Valider l'Epic avec l'equipe
2. [ ] Creer branche Supabase dev pour migrations S01, S02
3. [ ] Commencer par S01 : Migration offers_free_wedding_book
4. [ ] Commencer par S02 : Migration offers_free_trailer
5. [ ] Implementer S03, S04 en parallele
6. [ ] Implementer S05, S06 en parallele
7. [ ] Tester integration complete
8. [ ] Verifier performance RPC
9. [ ] Merge en production

---

## Notes

### Feature Flags

Le filtre `minRating` et le toggle `showMarketplace` sont volontairement en mode "feature flag" :

```dart
// Dans filter_sheet.dart
final isRatingFilterEnabled = false; // TODO: Enable when EPIC-07 deployed
final isMarketplaceEnabled = false;  // TODO: Enable when EPIC-14 deployed
```

Ces flags seront actives quand les Epics dependants seront deployes.

### Backward Compatibility

Tous les nouveaux champs ont des valeurs par defaut qui preservent le comportement existant :
- `weddingBookFree = null` -> pas de filtre
- `trailerFree = null` -> pas de filtre
- `minRating = null` -> pas de filtre
- `showMarketplace = false` -> layer off

---

**Epic Status**: DRAFT
**Date de creation**: 2026-01-28
**Estimation**: 1 jour
