# Map Module Status

**Dernière MAJ:** 2025-11-28 18:30  
**Phase Actuelle:** Prêt pour Phase 5 (Wedding)  
**Audit complet:** `docs/audits/MAP_MODULE_AUDIT_2025-11-28.md`

---

## ✅ TRAVAIL TERMINÉ (Phases 1-4)

| Phase | Description | Fichiers clés |
|-------|-------------|---------------|
| 1 | Foundation | `lib/core/design/`, `lib/features/map/` |
| 2 | Filtres & Markers | `filter_sheet.dart`, `marker_icon_generator.dart` |
| 3 | Sheets & Actions | `*_details_sheet.dart`, `map_actions_service.dart` |
| 4 | Enums | `map_marker.dart` (4 valeurs simplifié) |

**Bugs corrigés (2025-11-28):**
- ✅ Alertes expirées → `expires_at > now()` en RPC
- ✅ Tap auteur silencieux → pattern fetch-avant-pop + `this.context`
- ✅ Markers sauteurs → `fl.id` au lieu de `profile_id`

---

## 🔄 TRAVAIL RESTANT (Phases 5-8)

| Phase | Description | Durée | Dépendances |
|-------|-------------|-------|-------------|
| 5 | Système Wedding | 6-8h | Aucune |
| 6 | Système Alertes | 6-8h | Aucune (parallèle 5) |
| 7 | Android | 4-6h | 5-6 recommandé |
| 8 | Documentation | 6-8h | 5-6 terminé |

```
Phase 5 ─────┐
             ├──► Phase 7 ──► Phase 8
Phase 6 ─────┘
```

**Estimation restante:** 22-30h

---

## 📊 MÉTRIQUES MODULE

| Métrique | Valeur |
|----------|--------|
| Fichiers | 33 |
| Lignes code | ~3400 |
| Enums propres | 4 (MapMarkerType, Profession, AlertType, SubscriptionTier) |
| Dépendances FF | ~5 imports (navigation) |

---

## 📁 FICHIERS CLÉS

**Code:**
- `lib/features/map/` - Module complet
- `lib/features/map/presentation/services/map_actions_service.dart` - Actions
- `lib/features/map/domain/entities/` - Entités métier

**Docs:**
- `MAP_REFACTORING_PLAN.md` - Plan détaillé
- `audits/MAP_MODULE_AUDIT_2025-11-28.md` - Audit technique
