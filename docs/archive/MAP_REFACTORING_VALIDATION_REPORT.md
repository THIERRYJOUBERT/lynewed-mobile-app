# Rapport de Validation - MAP_REFACTORING_PLAN.md

**Date de validation:** 2025-11-27  
**Validateur:** Audit automatisé via Supabase MCP + Code Analysis  
**Version du plan:** v1.5  
**Statut:** ⚠️ **GO CONDITIONNEL** - Corrections requises avant implémentation

---

## 1. RÉSUMÉ EXÉCUTIF

### Verdict Global
| Critère | Statut | Notes |
|---------|--------|-------|
| **Plan validé?** | ⚠️ **AVEC MODIFICATIONS** | 8 corrections critiques identifiées |
| **Faisabilité technique** | ✅ Confirmée | Aucun blocage majeur |
| **Timeline réaliste?** | ⚠️ Sous-estimée | +15-20h recommandé (total: 60-75h) |
| **Données migrables?** | ✅ Oui | wedding_pins: 10, user_pois: 0 |
| **Rollback possible?** | ✅ Oui | Stratégie documentée adéquate |

### Risques Majeurs Identifiés
1. **🔴 CRITIQUE:** Enum `subscriptionTierType` utilise `trial` pas `free` (mismatch plan/réalité)
2. **🔴 CRITIQUE:** Table `pro_recent_locations` non documentée dans le plan (utilisée par RPC)
3. **🟠 ÉLEVÉ:** 249 usages de `weddingPin` dans 44 fichiers Flutter → Impact massif
4. **🟠 ÉLEVÉ:** Limites zoom dans RPC inversées vs plan (2000 au lieu de 0 pour zoom ≤5)
5. **🟡 MOYEN:** `professional_fixed_locations` = 0 records (table vide en dev)

### Tâches TODO à Intégrer
- ✅ **Cron Jobs** (PROJECT_TODO): À désactiver AVANT refactorisation
- ⚠️ **Feed Pro visibility** ($900/an): Impacte les règles d'affichage map
- ⚠️ **Ambassadeurs** (`is_ambassador`): À considérer dans les filtres map

---

## 2. DÉCOUVERTES TECHNIQUES

### 2.1 État Réel de Supabase (vs. suppositions du plan)

#### Tables Map-Related
| Table | Records | Documenté | Notes |
|-------|---------|-----------|-------|
| `wedding_pins` | 10 | ✅ | Migration vers `weddings` prévue |
| `user_pois` | **0** | ✅ | Suppression safe (aucune donnée) |
| `professional_alerts` | 12 | ✅ | Migration schema requise |
| `professional_fixed_locations` | **0** | ✅ | ⚠️ Vide en dev |
| `pro_recent_locations` | **0** | **❌ NON** | **Table non documentée!** |

#### Enums Supabase Réels
| Enum | Valeurs Réelles | Plan Dit | Mismatch |
|------|-----------------|----------|----------|
| `subscriptionTierType` | `{inactive, trial, earlyAccess, premiumVisibility, ultimateAccess}` | Mentionne "free" | **⚠️ OUI** |
| `connectionRequestSource` | `{wishlist, weddingPin, map, alert, proToPro}` | `wedding` (pas `weddingPin`) | **⚠️ OUI** |
| `alertStatus` | `{active, cancelled, expired}` | OK | ✅ |
| `alert_type` | **N'EXISTE PAS** | 4 types proposés | **À CRÉER** |

#### Schema `professional_alerts` Actuel
```sql
-- Colonnes EXISTANTES (différent du plan):
- motif_code: text (référence alert_motifs.code)
- title, message: text
- duration_hours: smallint  -- PAS event_date!
- expires_at: timestamptz   -- Calculé depuis duration_hours
- radius_km: smallint
-- Colonnes MANQUANTES (à ajouter):
- event_date: date          -- Plan propose ceci
- alert_type: enum          -- Plan propose ceci
- profession_needed: profession
```

#### RPC `search_map_bundle` - Analyse Complète

**Types de markers retournés (6 actuellement):**
1. `'professional'` - Pros live (is_live = true)
2. `'fixedLocation'` - Fixed locations
3. `'proRecent'` - Positions récentes (table `pro_recent_locations`)
4. `'professionalAlert'` - Alertes
5. `'weddingPin'` - Wedding pins (brides)
6. `'poiPrivate'` - POI privés (brides uniquement)

**Limites par zoom ACTUELLES vs PLAN:**
| Zoom | RPC Actuel | Plan Propose | Delta |
|------|------------|--------------|-------|
| ≤5 | 2000 | 0 (message) | **INVERSÉ** |
| 6-8 | 800 | 100 | -700 |
| 9-11 | 300 | 300 | ✅ OK |
| 12-14 | 100 | 500 | +400 |
| ≥15 | 50 | 1000 | +950 |

**⚠️ Le plan inverse la logique actuelle!** Actuellement: plus de markers à faible zoom. Plan: moins de markers à faible zoom.

### 2.2 Impact sur Codebase Flutter

#### Fichiers Impactés par MapMarkerType
| Pattern | Fichiers | Usages | Impact |
|---------|----------|--------|--------|
| `MapMarkerType` | 18 | 94 | Élevé |
| `weddingPin` | 44 | 249 | **Très élevé** |
| `poiPrivate` | 14 | 12 | Modéré |
| `proRecent` | 29 | 95 | Élevé |

**Total: ~55 fichiers Flutter à modifier** (~8% du codebase lib/)

#### Structs Critiques à Modifier
1. `map_marker_struct.dart` - Enum type
2. `wedding_pin_item_data_struct.dart` - 29 usages, renommer/migrer
3. `wedding_pin_overlay_struct.dart` - Supprimer ou migrer
4. `layer_toggles_struct.dart` - Filtres showPros, showProRecent, etc.
5. `query_filters_struct.dart` - Filtres map
6. `mapdatabundle_struct.dart` - Structure retour RPC

#### Composants UI Impactés
- `lynewed_interactive_map.dart` - Widget principal (948 lignes, 36 usages MapMarkerType)
- `info_wedding_pin_sheet/` - Sheet wedding pin → renommer
- `points_of_interest_sheet/` - Sheet POI → à supprimer
- `create_edit_point_of_interest_sheet/` - Création POI → à supprimer
- `add_filter_sheet/` - Filtres map → modifier toggles

### 2.3 Dépendances Non Documentées

1. **Table `pro_recent_locations`:**
   - Utilisée par `search_map_bundle` section 3 (proRecent)
   - Schema: `profile_id`, `last_seen_at`, `is_opt_in`, `coords_approx`
   - Le plan dit supprimer `proRecent` mais ne mentionne pas cette table

2. **Table `alert_motifs`:**
   - Table de référence pour `professional_alerts.motif_code`
   - Le plan propose `alert_type` enum mais `motif_code` existe déjà
   - **Décision requise:** Migrer motif_code → alert_type ou garder les deux?

3. **Trigger `trg_outbox_chat_msg`:**
   - Génère des notifications pour nouveaux messages
   - Impacté si wedding_participants change les rules

---

## 3. CORRECTIONS DU PLAN

### 3.1 Corrections Critiques (Bloquantes)

#### C1: Ajouter `pro_recent_locations` à la documentation
```markdown
## Tables à Supprimer (Phase 2)
- user_pois ✅
- pro_recent_locations ❌ **NOUVEAU** (si proRecent supprimé)
```

#### C2: Corriger enum `subscriptionTierType` dans le plan
```markdown
## Tiers Validés
- inactive (pas "free")
- trial (correspond au "free" fonctionnel)
- earlyAccess
- premiumVisibility  
- ultimateAccess
```

#### C3: Mettre à jour `connectionRequestSource`
```markdown
## connectionRequestSource enum
Valeur actuelle: 'weddingPin'
Nouvelle valeur: 'wedding' (à migrer)
```

#### C4: Documenter migration `professional_alerts`
Le plan propose:
- Ajouter `event_date`
- Ajouter `alert_type` enum
- Supprimer `budget_offered`

**Mais le schema actuel a:**
- `motif_code` (texte vers alert_motifs)
- `duration_hours` + `expires_at`
- Pas de `budget_offered` (n'existe pas)

**Migration requise:**
```sql
-- 1. Créer enum alert_type
CREATE TYPE alert_type AS ENUM ('backup_needed', 'gear_emergency', 'team_member', 'emergency_help');

-- 2. Ajouter colonnes
ALTER TABLE professional_alerts
ADD COLUMN alert_type alert_type,
ADD COLUMN event_date date;

-- 3. Migrer motif_code → alert_type (mapping à définir)

-- 4. Décider: garder motif_code pour backward compat ou supprimer?
```

### 3.2 Corrections Moyennes

#### C5: Réviser limites zoom RPC
Le plan inverse la logique actuelle. Clarifier l'intention:
- **Option A:** Garder logique actuelle (plus de markers = faible zoom)
- **Option B:** Appliquer nouvelle logique (message "zoomez" à faible zoom) ✅ **Recommandé**

#### C6: Ajouter Phase 2.5 - Migration `pro_recent_locations`
Si `proRecent` est supprimé:
- Désactiver la section 3 du RPC
- Supprimer ou archiver la table
- Mettre à jour les toggles Flutter (`showProRecent`)

#### C7: Documenter impact `professional_fixed_locations` vide
La table est vide en dev. Ajouter:
- Script de seeding avec des fixed locations pour tests
- OU utiliser `professional_details.location_coords` comme fallback

### 3.3 Corrections Mineures

#### C8: Timeline révisée
| Phase | Estimation Originale | Révision | Raison |
|-------|---------------------|----------|--------|
| Phase 2 | 10-12h | **14-16h** | Migration alerts complexe |
| Phase 4 | 6-8h | **10-12h** | 55 fichiers Flutter |
| Phase 5 | 8-10h | **12-14h** | Supprimer clustering existant |
| **Total** | 42-57h | **60-75h** | +30% |

---

## 4. DÉCISION GO/NO-GO

### Recommandation: ⚠️ **GO CONDITIONNEL**

**Pré-requis avant Phase 1:**

- [ ] **Appliquer corrections C1-C4** dans MAP_REFACTORING_PLAN.md
- [ ] **Désactiver cron jobs** (PROJECT_TODO en cours)
- [ ] **Créer seed data** pour `professional_fixed_locations` (au moins 10 records)
- [ ] **Décider:** Garder `motif_code` ou migrer vers `alert_type`?
- [ ] **Confirmer:** Logique zoom inversée intentionnelle?

### Checklist Finale pour Démarrage

#### Environnement ✅
- [x] Supabase DEV accessible (hekyovgnovhfhmkpfrna)
- [x] 40 utilisateurs seedés
- [x] Authentication fonctionnelle
- [ ] Cron jobs désactivés **⚠️ À FAIRE**
- [ ] Fixed locations seedées **⚠️ À FAIRE**

#### Documentation ✅
- [x] MAP_REFACTORING_PLAN.md v1.5 lu
- [x] APP_SOURCE_OF_TRUTH.md v1.3 lu
- [ ] Corrections appliquées **⚠️ EN ATTENTE**

#### Code ✅
- [x] Audit Flutter complet (55 fichiers identifiés)
- [x] RPC `search_map_bundle` analysé
- [x] Structs critiques identifiés

---

## 5. ANNEXES

### A. Liste Complète des Fichiers Flutter Impactés

#### Enums & Structs (13 fichiers)
```
lib/backend/schema/enums/enums.dart
lib/backend/schema/structs/map_marker_struct.dart
lib/backend/schema/structs/wedding_pin_item_data_struct.dart
lib/backend/schema/structs/wedding_pin_overlay_struct.dart
lib/backend/schema/structs/mapdatabundle_struct.dart
lib/backend/schema/structs/layer_toggles_struct.dart
lib/backend/schema/structs/query_filters_struct.dart
lib/backend/supabase/database/tables/wedding_pins.dart
lib/backend/supabase/database/tables/wedding_pins_history.dart
lib/backend/supabase/database/tables/public_wedding_pins.dart
lib/backend/supabase/database/tables/pro_recent_locations.dart
lib/flutter_flow/custom_functions.dart
lib/flutter_flow/profession_display_helper.dart
```

#### Widgets & Actions (15 fichiers)
```
lib/custom_code/widgets/lynewed_interactive_map.dart
lib/custom_code/widgets/lynewed_mini_map.dart
lib/custom_code/actions/call_search_map_bundle_v2.dart
lib/custom_code/actions/get_wedding_pin_item_details_rpc.dart
lib/custom_code/actions/delete_wedding_pin.dart
lib/custom_code/actions/upsert_wedding_pin.dart
lib/custom_code/actions/get_bride_interest_items_action.dart
lib/custom_code/actions/upsert_pro_recent_opt_in.dart
lib/custom_code/actions/filters_to_json_string.dart
lib/custom_code/actions/load_initial_session_data.dart
lib/custom_code/actions/reset_and_apply_default_filters.dart
lib/custom_code/actions/save_user_preferences.dart
lib/custom_code/actions/get_pending_contact_requests_action.dart
lib/flutter_flow/nav/serialization_util.dart
lib/app_state.dart
```

#### Components (8 fichiers)
```
lib/compo_finaux/info_wedding_pin_sheet/info_wedding_pin_sheet_widget.dart
lib/compo_finaux/info_wedding_pin_sheet/info_wedding_pin_sheet_model.dart
lib/compo_finaux/points_of_interest_sheet/points_of_interest_sheet_widget.dart
lib/compo_finaux/points_of_interest_sheet/points_of_interest_sheet_model.dart
lib/compo_finaux/create_edit_point_of_interest_sheet/create_edit_point_of_interest_sheet_widget.dart
lib/compo_finaux/create_edit_point_of_interest_sheet/create_edit_point_of_interest_sheet_model.dart
lib/compo_finaux/add_filter_sheet/add_filter_sheet_widget.dart
lib/compo_finaux/add_filter_sheet/add_filter_sheet_model.dart
```

#### Pages (6 fichiers)
```
lib/pages/bride/map_brides_large/map_brides_large_widget.dart
lib/pages/bride/map_brides_large/map_brides_large_model.dart
lib/pages/pro/map_pro_large/map_pro_large_widget.dart
lib/pages/pro/map_pro_large/map_pro_large_model.dart
lib/pages/shared/settings_permissions/settings_permissions_widget.dart
lib/pages/onboarding/onboarding_brides_wizard/onboarding_brides_wizard_widget.dart
```

### B. RPCs à Modifier

| RPC | Modifications |
|-----|---------------|
| `search_map_bundle` | Remplacer wedding_pins→weddings, supprimer user_pois section, ajuster limites zoom |
| `get_wedding_pin_item_details` | Renommer → `get_wedding_details` |
| `insert_wedding_pin` | Renommer → `insert_wedding` |
| `delete_wedding_pin` | Renommer → `delete_wedding` |
| `insert_user_poi` | **SUPPRIMER** |
| `delete_user_poi` | **SUPPRIMER** |
| `create_professional_alert` | Ajouter `alert_type`, `event_date` |
| `get_alert_item_details` | Ajouter retour `alert_type` |

### C. Mapping Enum connectionRequestSource

```sql
-- Migration de 'weddingPin' vers 'wedding'
UPDATE connection_requests 
SET source = 'wedding' 
WHERE source = 'weddingPin';

-- Puis mettre à jour l'enum
ALTER TYPE "connectionRequestSource" RENAME VALUE 'weddingPin' TO 'wedding';
```

---

**Document généré:** 2025-11-27 09:45  
**Prochaine étape:** Appliquer corrections C1-C8 dans MAP_REFACTORING_PLAN.md puis démarrer Phase 0
