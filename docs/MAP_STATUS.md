# Map Module Status

**Dernière MAJ:** 2025-11-29 10:50  
**Phase Actuelle:** ✅ Phase 6 Terminée - Prêt pour Phase 7 (Android Tests)  
**Plan détaillé:** `docs/MAP_REFACTORING_PLAN.md`

---

## ✅ TRAVAIL TERMINÉ (Phases 1-6)

| Phase | Description | Fichiers clés |
|-------|-------------|---------------|
| 1 | Foundation | `lib/core/design/`, `lib/features/map/` |
| 2 | Filtres & Markers | `filter_sheet.dart`, `marker_icon_generator.dart` |
| 3 | Sheets & Actions | `*_details_sheet.dart`, `map_actions_service.dart` |
| 4 | Enums | `map_marker.dart` (4→3 valeurs) |
| 5 | **Wedding System** | `weddings` table, `wedding_create_sheet.dart` |
| 6 | **Alert System** | `alert_type` enum, `alert_create_sheet.dart` |

**Phase 6 - Complétée (2025-11-29):**
- ✅ Enum `alert_type` créé (4 valeurs: backup_needed, gear_emergency, team_member, emergency_help)
- ✅ Colonnes ajoutées: `alert_type`, `event_date`, `profession_needed`
- ✅ RPCs: `create_alert`, `update_alert`, `delete_alert`, `get_my_alerts`
- ✅ `search_map_bundle` mis à jour pour retourner `alertType`
- ✅ `AlertCreateSheet` (600 lignes) avec Design System
- ✅ Dashboard: Real-time refresh via callbacks + lifecycle observers
- ✅ Intégration dans MapPage (FAB pour pros)
- ⚠️ Note: `didChangeDependencies` peut déclencher excessivement (limitation connue)

---

## 🔄 TRAVAIL RESTANT (Phases 7-8)

| Phase | Description | Durée | Status |
|-------|-------------|-------|--------|
| 7 | Android Tests | 4-6h | 🔴 PRIORITÉ |
| 8 | Documentation Finale | 6-8h | 🟡 MOYENNE |

```
Phase 6 (Alertes) ✅ ──► Phase 7 (Android) ──► Phase 8 (Docs)
```

**Estimation restante:** 10-14h (Phases 7-8)

---

## 📊 MÉTRIQUES MODULE

| Métrique | Valeur |
|----------|--------|
| Fichiers | 35 |
| Lignes code | ~4200 |
| Enums propres | 4 (MapMarkerType, Profession, SubscriptionTier, AlertType) |
| Dépendances FF | ~5 imports (navigation) |
| Tests unitaires | 63/63 passants |

---

## 📁 FICHIERS CLÉS

**Code:**
- `lib/features/map/` - Module complet
- `lib/features/map/presentation/sheets/wedding_create_sheet.dart` - Création mariage
- `lib/features/map/presentation/sheets/alert_create_sheet.dart` - Création alerte
- `lib/features/map/data/datasources/supabase_map_datasource.dart` - RPCs wedding + alerts

**Backend:**
- Table `weddings` - Hub central per bride
- Table `wedding_participants` - Pros confirmés
- RPC `search_map_bundle` - Retourne type 'wedding'

**Docs:**
- `MAP_REFACTORING_PLAN.md` - Plan détaillé
- `audits/MAP_MODULE_AUDIT_2025-11-28.md` - Audit technique
