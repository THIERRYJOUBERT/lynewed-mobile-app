# AUDIT MODULE MAP - 2025-11-28

**Objectif:** Vérifier l'état réel du module map refactorisé et s'assurer que la documentation est à jour.

---

## 📊 STRUCTURE DU MODULE (33 fichiers)

```
lib/features/map/                        (~3400 lignes)
├── domain/                              (~900 lignes)
│   ├── entities/
│   │   ├── entities.dart                # Barrel export
│   │   ├── map_marker.dart              # ✅ MapMarker + MapMarkerType (4 valeurs)
│   │   ├── map_filter.dart              # ✅ MapFilter + LayerToggles
│   │   ├── professional_details.dart    # ✅ ProfessionalDetails + Profession (14) + SubscriptionTier
│   │   ├── alert_details.dart           # ✅ AlertDetails + AlertType (5 valeurs préparées)
│   │   ├── wedding_details.dart         # ✅ WeddingDetails
│   │   ├── professional_alert.dart      # Entité alerte
│   │   └── wedding.dart                 # Entité wedding
│   ├── repositories/
│   │   └── map_repository.dart          # ✅ Interface abstraite
│   ├── usecases/
│   │   └── get_marker_details.dart      # ✅ MarkerDetailsService
│   └── utils/
│       └── marker_offset.dart           # ✅ Offset superposition < 20m
│
├── data/                                (~400 lignes)
│   ├── datasources/
│   │   └── supabase_map_datasource.dart # ✅ Appels RPC search_map_bundle
│   ├── models/
│   │   └── marker_type_mapper.dart      # ✅ Compatibilité FF enum
│   └── repositories/
│       └── supabase_map_repository.dart # ✅ Implémentation repository
│
├── presentation/                        (~2100 lignes)
│   ├── state/
│   │   └── map_state.dart               # ✅ ChangeNotifier + cache accumulatif
│   ├── theme/
│   │   └── map_theme.dart               # ✅ Couleurs, tailles, z-index
│   ├── services/
│   │   ├── marker_icon_generator.dart   # ✅ Génération icônes custom + cache
│   │   └── map_actions_service.dart     # ✅ Navigation, favoris, suppression
│   ├── widgets/
│   │   ├── lynewed_map_widget.dart      # ✅ Widget unifié bride/pro
│   │   ├── filter_sheet.dart            # ✅ Filtres professions, budget
│   │   ├── animated_marker.dart         # ✅ Animations fade/scale
│   │   └── marker_details_sheet.dart    # Sheet générique
│   ├── sheets/
│   │   ├── sheets.dart                  # Barrel export
│   │   ├── professional_details_sheet.dart # ✅ Design System
│   │   ├── alert_details_sheet.dart     # ✅ Design System
│   │   └── wedding_details_sheet.dart   # ✅ Design System
│   └── pages/
│       ├── map_page.dart                # ✅ Page complète unifiée
│       ├── map_brides_large_wrapper.dart # Wrapper legacy
│       └── map_pro_large_wrapper.dart   # Wrapper legacy
│
├── integration/
│   ├── flutterflow_adapter.dart         # Adapteur compatibilité
│   └── map_page_wrapper.dart            # Wrapper navigation
│
├── map.dart                             # Barrel export principal
└── README.md                            # ⚠️ À METTRE À JOUR
```

---

## 🔢 ENUMS - ÉTAT ACTUEL

### 1. MapMarkerType (Nouveau module)
**Fichier:** `lib/features/map/domain/entities/map_marker.dart`
```dart
enum MapMarkerType {
  proFixedLocation,    // ✅ Position fixe pro
  professionalAlert,   // ✅ Alerte
  wedding,             // ✅ Mariage (renommé de weddingPin)
  @Deprecated('Sera supprimé')
  poiPrivate,          // ⚠️ Deprecated
}
```
**Statut:** ✅ 4 valeurs (3 actives + 1 deprecated)

### 2. MapMarkerType (Legacy FlutterFlow)
**Fichier:** `lib/backend/schema/enums/enums.dart`
```dart
enum MapMarkerType {
  professional,        // ⚠️ Existe encore (mappé vers proFixedLocation)
  proFixedLocation,
  professionalAlert,
  weddingPin,          // ⚠️ Nom legacy (mappé vers wedding)
  poiPrivate,
}
```
**Statut:** ⚠️ 5 valeurs - Compatibilité assurée par `marker_type_mapper.dart`

### 3. Profession (14 valeurs)
**Fichier:** `lib/features/map/domain/entities/professional_details.dart`
```dart
enum Profession {
  photographer, filmmaker, planner, makeup, hairdresser,
  designer, bridalDesigner, venue, bridalShop, florist,
  photoMovie, makeupArtist, eventDesigner, other
}
```
**Statut:** ✅ Aligné avec backend Supabase

### 4. AlertType (5 valeurs - Préparé Phase 6)
**Fichier:** `lib/features/map/domain/entities/alert_details.dart`
```dart
enum AlertType {
  backupNeeded,     // Remplaçant pour date
  gearEmergency,    // Location matériel
  teamMember,       // Second shooter
  emergencyHelp,    // Urgence événement
  other             // Autre
}
```
**Statut:** ✅ Préparé pour Phase 6 (pas encore utilisé en backend)

### 5. SubscriptionTier (4 valeurs)
**Fichier:** `lib/features/map/domain/entities/professional_details.dart`
```dart
enum SubscriptionTier {
  trial,     // Gratuit
  early,     // Early Access
  premium,   // Premium
  ultimate   // Ultimate
}
```
**Statut:** ✅ Aligné avec backend

---

## 🔧 SERVICES CRÉÉS

### 1. MapActionsService
**Fichier:** `lib/features/map/presentation/services/map_actions_service.dart`
**Fonctions:**
- `navigateToProProfile()` - Navigation vers ProDetailsWidget ✅
- `navigateToBrideProfile()` - Placeholder (pas de page bride) ⚠️
- `navigateToAuthorProfile()` - Navigation depuis alerte ✅ CORRIGÉ
- `navigateToContact()` - Navigation chat ⚠️ À REVOIR
- `toggleFavorite()` - Ajout/retrait favoris ✅
- `deleteAlert()` - Suppression alerte ✅
- `navigateToHelpAlert()` - Aide alerte ✅

### 2. MarkerIconGenerator
**Fichier:** `lib/features/map/presentation/services/marker_icon_generator.dart`
**Fonctions:**
- Génération icônes 44px (Retina 144px)
- Cache icônes pour performance
- Styles: cercle avatar (pros), rouge (alertes), rose (weddings)

### 3. MarkerDetailsService
**Fichier:** `lib/features/map/domain/usecases/get_marker_details.dart`
**Fonctions:**
- Récupération détails via RPC
- Parsing JSON vers entités
- Cache local pour performance

---

## ⚠️ DÉPENDANCES FLUTTERFLOW RESTANTES

| Fichier | Import FlutterFlow | Raison |
|---------|-------------------|--------|
| `map_page.dart` | `/compo_finaux/address_search/address_search_widget.dart` | Recherche adresse |
| `map_page.dart` | `/backend/schema/structs/index.dart` | ProDetailsStruct |
| `map_page.dart` | `/custom_code/actions/index.dart` | getProItemDetailsAction |
| `map_page.dart` | `/flutter_flow/flutter_flow_util.dart` | serializeParam |
| `map_page.dart` | `/index.dart` | ProDetailsWidget, ChatDetailsWidget |
| `map_actions_service.dart` | Idem | Navigation legacy |

**Impact:** Ces dépendances sont nécessaires pour la navigation vers les pages FlutterFlow existantes. Elles seront éliminées quand toute l'app sera refactorisée.

---

## 🐛 BUGS CORRIGÉS (Session 2025-11-28)

### Bug #1: Alertes expirées visibles
- **Cause:** RPC `search_map_bundle` ne filtrait pas `expires_at`
- **Fix:** Ajout `AND a.expires_at > now()` en backend
- **Fichier modifié:** Directement en Supabase (pas de migration locale)

### Bug #2: Tap auteur alerte silencieux
- **Cause:** Context Flutter invalidé après `Navigator.pop()` async
- **Fix:** Pattern `ItemAllAlertWidget` (fetch avant pop, navigation avec `this.context`)
- **Fichiers modifiés:**
  - `map_page.dart` (ligne ~1194-1233)
  - `map_actions_service.dart` (ligne ~82-192)
  - `alert_details_sheet.dart` (structure Material/InkWell)

### Bug #3: Markers "sauteurs" entre villes
- **Cause:** Conflit d'IDs dans RPC (profile_id au lieu de fl.id)
- **Fix:** RPC modifié + ajout `profileId` dans `MarkerStyle`
- **Fichiers modifiés:**
  - Backend Supabase (RPC)
  - `map_marker.dart` (MarkerStyle.profileId)
  - `supabase_map_datasource.dart` (parsing)

---

## 📋 VALIDATION PHASES 1-4

| Phase | Description | Fichiers | Statut |
|-------|-------------|----------|--------|
| 1 | Foundation | `lib/core/design/`, structure map/ | ✅ |
| 2 | Filtres | `filter_sheet.dart`, chips map_page | ✅ |
| 2 | Markers | `marker_icon_generator.dart`, cache | ✅ |
| 3 | Sheets | `*_details_sheet.dart` (3 fichiers) | ✅ |
| 3 | Actions | `map_actions_service.dart` | ✅ |
| 4 | Enums | `map_marker.dart` (nouveau module) | ✅ |

---

## 🔄 PHASES RESTANTES (5-8) - ANALYSE

### Phase 5: Système Wedding (6-8h)
**Prérequis:** Aucun
**Tâches:**
1. Créer tables `weddings` + `wedding_participants`
2. Migrer données `wedding_pins`
3. Mettre à jour RPC `search_map_bundle`
4. Créer sheet création wedding
5. Supprimer `poiPrivate` de l'enum

**Impact fichiers:**
- Backend: Migration SQL, RPC
- Frontend: `wedding_details.dart`, `wedding_details_sheet.dart`

### Phase 6: Système Alertes (6-8h)
**Prérequis:** Aucun (peut être fait en parallèle de Phase 5)
**Tâches:**
1. Créer enum `alert_type` en backend
2. Mettre à jour table `professional_alerts`
3. Implémenter expiration auto (cron/trigger)
4. Créer sheet création alerte
5. Connecter FABs map_page

**Impact fichiers:**
- Backend: Migration SQL, RPC, cron job
- Frontend: `alert_details.dart` (AlertType déjà préparé), nouveau sheet

### Phase 7: Android (4-6h)
**Prérequis:** Phases 5-6 recommandées avant
**Tâches:**
1. Tests émulateur Android
2. Optimisations plateforme
3. Vérifier permissions
4. Tests performances

**Note:** Peut être fait en parallèle de Phase 8

### Phase 8: Documentation & Séparation (6-8h)
**Prérequis:** Phases 5-6 terminées
**Tâches:**
1. Mettre à jour README.md du module
2. Documenter architecture
3. Créer guide handover
4. Tests complets

---

## 📝 RECOMMANDATIONS

### 1. Mettre à jour README.md du module
Le README actuel est obsolète (montre `professional` dans l'enum).

### 2. Ordre optimal des phases
```
Phase 5 (Wedding) ─────┐
                       ├──► Phase 7 (Android) ──► Phase 8 (Docs)
Phase 6 (Alertes) ─────┘
```
Phases 5 et 6 peuvent être faites en parallèle.

### 3. Migrations SQL à créer
Les changements RPC ont été faits directement en Supabase. Pour traçabilité:
- Créer fichier de migration pour `expires_at` filter
- Créer fichier de migration pour `fl.id` fix

### 4. Dépendances FF à éliminer progressivement
Quand d'autres modules seront refactorisés, éliminer:
- `AddressSearchWidget` → Créer composant propre
- `ProDetailsStruct` → Utiliser `ProfessionalDetails`
- `ProDetailsWidget` → Créer page propre

---

## ✅ CONCLUSION

**État du module:** Phases 1-4 complétées et fonctionnelles
**Qualité du code:** Clean Architecture respectée
**Dépendances FF:** Minimales (navigation uniquement)
**Documentation:** À mettre à jour (README.md obsolète)
**Prochaine étape:** Phase 5 (Wedding) ou Phase 6 (Alertes)
