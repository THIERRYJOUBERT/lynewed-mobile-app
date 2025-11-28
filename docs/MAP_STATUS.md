# Map Module Status

**Dernière MAJ:** 2025-11-28 20:30  
**Phase Actuelle:** ✅ Phases 5.1-5.2 Terminées - Prêt pour Phase 6 (Alertes)  
**Plan détaillé:** `docs/MAP_REFACTORING_PLAN.md`

---

## ✅ TRAVAIL TERMINÉ (Phases 1-5 base)

| Phase | Description | Fichiers clés |
|-------|-------------|---------------|
| 1 | Foundation | `lib/core/design/`, `lib/features/map/` |
| 2 | Filtres & Markers | `filter_sheet.dart`, `marker_icon_generator.dart` |
| 3 | Sheets & Actions | `*_details_sheet.dart`, `map_actions_service.dart` |
| 4 | Enums | `map_marker.dart` (4→3 valeurs) |
| 5 | **Wedding System** | `weddings` table, `wedding_create_sheet.dart` |

**Phase 5 base - Complétée (2025-11-28):**
- ✅ Tables `weddings` + `wedding_participants` créées
- ✅ Tables `wedding_pins` + `wedding_pins_history` supprimées
- ✅ RPCs: `get_wedding_details`, `upsert_wedding`, `get_my_wedding`, `delete_my_wedding`
- ✅ `WeddingCreateSheet` (722 lignes) avec Design System
- ✅ Cache invalidation fonctionnel

---

## 🔄 TRAVAIL RESTANT (Phases 5.1 → 8)

| Phase | Description | Durée | Status |
|-------|-------------|-------|--------|
| 5.1 | Wedding UI (AddressSearch + Validation) | 4-6h | ✅ FAIT |
| 5.2 | Design System Cohérence (Chips noir) | 2-3h | ✅ FAIT |
| 6 | Système Alertes (4 types) | 6-8h | 🔴 PRIORITÉ |
| 7 | Android Tests | 4-6h | 🟡 MOYENNE |
| 8 | Documentation Finale | 6-8h | 🟡 MOYENNE |

```
Phase 5.1 (Wedding UI) ────┐
                           ├──► Phase 6 (Alertes) ──► Phase 7 (Android) ──► Phase 8 (Docs)
Phase 5.2 (Design System) ─┘
```

**Estimation restante:** 16-22h (Phases 6-8)

---

## 📊 MÉTRIQUES MODULE

| Métrique | Valeur |
|----------|--------|
| Fichiers | 34 (+1 wedding_create_sheet) |
| Lignes code | ~3600 |
| Enums propres | 3 (MapMarkerType, Profession, SubscriptionTier) |
| Dépendances FF | ~5 imports (navigation) |

---

## 📁 FICHIERS CLÉS

**Code:**
- `lib/features/map/` - Module complet
- `lib/features/map/presentation/sheets/wedding_create_sheet.dart` - Création mariage
- `lib/features/map/data/datasources/supabase_map_datasource.dart` - RPCs wedding

**Backend:**
- Table `weddings` - Hub central per bride
- Table `wedding_participants` - Pros confirmés
- RPC `search_map_bundle` - Retourne type 'wedding'

**Docs:**
- `MAP_REFACTORING_PLAN.md` - Plan détaillé
- `audits/MAP_MODULE_AUDIT_2025-11-28.md` - Audit technique
