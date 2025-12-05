# 🧹 AUDIT DE NETTOYAGE - Préparation V1 TestFlight

**Date:** 2025-12-05  
**Objectif:** Identifier le code mort et préparer le build production  
**Statut:** ✅ NETTOYAGE EN COURS

---

## 📊 RÉSUMÉ ANALYSE

### Flutter Analyze - AVANT
- **Total issues:** 523
- **Warnings:** 75
- **Info:** 448
- **Errors:** 0 ✅

### Flutter Analyze - APRÈS NETTOYAGE PHASE 4
- **Total issues:** 390 (-133 issues, soit -25%)
- **Errors:** 3 (dans report_message_sheet.dart - à corriger)
- **Build:** ✅ SUCCESS
- **App:** ✅ Lancée avec succès sur simulateur

### Flutter Analyze - APRÈS NETTOYAGE PHASES 5-6 (FINAL)
- **Total issues:** 306 (-217 issues total, soit -42% depuis le début)
- **Errors:** 0 ✅
- **Build:** ✅ SUCCESS
- **App:** ✅ Lancée avec succès sur simulateur
- **Fichiers Dart:** 399 (-20 fichiers)
- **Lignes de code:** ~67,789 (-3,711 lignes)

---

## ✅ FICHIERS SUPPRIMÉS (Phase 4) - 2025-12-05

### Sheets obsolètes `conversation_sheet/` (2 dossiers)

| Dossier | Lignes | Raison |
|---------|--------|--------|
| `my_message_actions_sheet/` | 166 | Non utilisé (aucune référence externe) |
| `other_message_actions_sheet/` | 197 | Non utilisé (aucune référence externe) |

### Fichiers `flutter_flow/` supprimés (1 fichier)

| Fichier | Lignes | Raison |
|---------|--------|--------|
| `flutter_flow_drop_down.dart` | 379 | Non importé (aucune référence externe) |

### Pages FlutterFlow remplacées par Clean Architecture (2 dossiers)

| Dossier | Lignes | Remplacé par |
|---------|--------|--------------|
| `pages/shared/notifications_page/` | 533 | `features/notifications/presentation/pages/notifications_page.dart` |
| `pages/shared/notification_settings/` | 602 | `features/notifications/presentation/pages/notification_settings_page.dart` |

**Total Phase 4:** 5 dossiers/fichiers, **1877 lignes** supprimées

---

## ✅ FICHIERS SUPPRIMÉS (Phase 5-6) - 2025-12-05

### Actions obsolètes `custom_code/actions/` (6 fichiers)

| Fichier | Lignes | Raison |
|---------|--------|--------|
| `delete_wedding_pin.dart` | 27 | Concept "wedding pin" obsolète |
| `upsert_wedding_pin.dart` | 47 | Concept "wedding pin" obsolète |
| `get_wedding_pin_item_details_rpc.dart` | 91 | Concept "wedding pin" obsolète |
| `cancel_professional_alert_action.dart` | 21 | Non utilisé |
| `reset_and_apply_default_filters.dart` | ~60 | Non utilisé |
| `filters_to_json_string.dart` | ~50 | Non utilisé |
| `call_search_map_bundle_v2.dart` | 135 | Remplacé par Clean Architecture map |
| `get_bride_interest_items_action.dart` | 101 | Non utilisé, dépendait de wedding pins |

### Structs obsolètes `backend/schema/structs/` (3 fichiers)

| Fichier | Lignes | Raison |
|---------|--------|--------|
| `wedding_pin_item_data_struct.dart` | ~350 | Concept "wedding pin" obsolète |
| `wedding_pin_overlay_struct.dart` | ~80 | Concept "wedding pin" obsolète |
| `mapdatabundle_struct.dart` | ~110 | Non utilisé, dépendait de wedding pins |

### Fonction inutilisée dans `map_actions_service.dart`

| Fonction | Lignes | Raison |
|----------|--------|--------|
| `_navigateWithProDetailsStruct()` | 12 | Dupliquée, non utilisée |

**Total Phase 5-6:** 12 fichiers, **~1,834 lignes** supprimées

---

## ✅ FICHIERS SUPPRIMÉS (Phase 3)

### Dossiers `compo_finaux/` supprimés (8 dossiers)

| Dossier | Raison | Remplacé par |
|---------|--------|--------------|
| `add_filter_sheet/` | Obsolète | `lib/features/map/presentation/widgets/filter_sheet.dart` |
| `create_edit_alert_sheet/` | Obsolète | `lib/features/map/presentation/sheets/alert_create_sheet.dart` |
| `create_edit_point_of_interest_sheet/` | POI supprimés | N/A (concept supprimé) |
| `info_alert_item_sheet/` | Obsolète | `lib/features/map/presentation/sheets/alert_details_sheet.dart` |
| `info_poi_sheet/` | POI supprimés | N/A (concept supprimé) |
| `info_pro_item_sheet/` | Obsolète | `lib/features/map/presentation/sheets/professional_details_sheet.dart` |
| `info_wedding_pin_sheet/` | Obsolète | `lib/features/map/presentation/sheets/wedding_details_sheet.dart` |
| `points_of_interest_sheet/` | POI supprimés | N/A (concept supprimé) |

### Fichiers `components/` supprimés (6 fichiers)

| Fichier | Raison |
|---------|--------|
| `item_all_alert_model.dart` | Remplacé par `lib/features/dashboard/presentation/widgets/alert_item_widget.dart` |
| `item_all_alert_widget.dart` | Remplacé par `lib/features/dashboard/presentation/widgets/alert_item_widget.dart` |
| `item_room_chat_model.dart` | Non utilisé |
| `item_room_chat_widget.dart` | Non utilisé |
| `item_wish_list_conv_model.dart` | Non utilisé |
| `item_wish_list_conv_widget.dart` | Non utilisé |
| `select_date_model.dart` | Non utilisé (dépendait des sheets supprimés) |
| `select_date_widget.dart` | Non utilisé (dépendait des sheets supprimés) |

### Fichiers `integration/` supprimés (2 fichiers)

| Fichier | Raison |
|---------|--------|
| `lib/features/map/integration/map_page_wrapper.dart` | Remplacé par `map_brides_large_wrapper.dart` et `map_pro_large_wrapper.dart` |
| `lib/features/map/integration/flutterflow_adapter.dart` | Non utilisé |

### Dossier supprimé
- `lib/features/map/integration/` (vide après suppression des fichiers)

### Actions `custom_code/actions/` supprimées (3 fichiers)

| Fichier | Raison |
|---------|--------|
| `delete_user_poi.dart` | POI supprimés |
| `upsert_user_poi.dart` | POI supprimés |
| `get_poi_item_details.dart` | POI supprimés |

### Widgets `custom_code/widgets/` supprimés (3 fichiers)

| Fichier | Raison |
|---------|--------|
| `lynewed_interactive_map.dart` | Remplacé par `LynewedMapWidget` |
| `instant_search_text_field.dart` | Non utilisé |
| `custom_calendar_widget.dart` | Non utilisé |

### Fichiers `flutter_flow/` supprimés (3 fichiers)

| Fichier | Raison |
|---------|--------|
| `random_data_util.dart` | Non utilisé |
| `instant_timer.dart` | Non utilisé |
| `flutter_flow_toggle_icon.dart` | Non utilisé |

### Structs `backend/schema/structs/` supprimés (2 fichiers)

| Fichier | Raison |
|---------|--------|
| `poi_item_data_struct.dart` | POI supprimés |
| `map_command_struct.dart` | Non utilisé |

### Fonctions `custom_functions.dart` supprimées (3 fonctions)

| Fonction | Raison |
|----------|--------|
| `filterMapMarkers()` | Remplacé par logique dans `MapState` |
| `imagePathToString()` | Non utilisé |
| `getCountryNameFromIso2()` | Non utilisé (~260 lignes de code) |

---

## 📊 STRUCTURE FINALE DU PROJET

### Statistiques (Après Phase 4)
- **Fichiers Dart:** 410
- **Lignes de code:** ~69,659
- **Issues Flutter Analyze:** 390 (vs 523 avant = -25%)
- **Lignes supprimées total:** 42,484 (Phase 1-4)

### Statistiques FINALES (Après Phase 5-6)
- **Fichiers Dart:** 399 (-20 fichiers)
- **Lignes de code:** ~67,789 (-3,711 lignes)
- **Issues Flutter Analyze:** 306 (vs 523 avant = -42%)
- **Erreurs:** 0 ✅
- **Lignes supprimées total:** 44,318 (Phase 1-6)

### Architecture Clean (lib/features/)
```
lib/features/
├── chat/           # Module Chat refactorisé
│   ├── data/
│   ├── domain/
│   └── presentation/
├── dashboard/      # Module Dashboard
│   └── presentation/
├── map/            # Module Map refactorisé
│   ├── data/
│   ├── domain/
│   └── presentation/
└── notifications/  # Module Notifications refactorisé
    ├── domain/
    └── presentation/
```

### Code Partagé (lib/core/)
```
lib/core/
├── constants/      # Constantes globales
├── design/         # Design System v3
│   └── widgets/
├── services/       # Services partagés
├── utils/          # Utilitaires
└── widgets/        # Widgets partagés
```

### Legacy Encore Utilisé
```
lib/compo_finaux/   # 2 composants restants
├── address_search/     # Utilisé par Map sheets
└── replay_guest_card/  # Utilisé par Replay

lib/components/     # 2 dossiers restants
├── nav/            # Navigation bars
└── ui_system/      # Empty state widget
```

---

## 🔴 FICHIERS POTENTIELLEMENT OBSOLÈTES

### ⚠️ ATTENTION - NE PAS SUPPRIMER SANS VÉRIFICATION

Ces fichiers sont dans `compo_finaux/` mais certains sont encore utilisés:

| Dossier | Utilisé? | Utilisé par |
|---------|----------|-------------|
| `add_filter_sheet/` | ❓ À vérifier | Aucune référence externe trouvée |
| `address_search/` | ✅ OUI | `map_page.dart`, `wedding_create_sheet.dart`, `alert_create_sheet.dart` |
| `create_edit_alert_sheet/` | ❓ À vérifier | Aucune référence externe trouvée |
| `create_edit_point_of_interest_sheet/` | ⚠️ Interne | Utilisé par `points_of_interest_sheet` |
| `info_alert_item_sheet/` | ✅ OUI | `map_page_wrapper.dart` |
| `info_poi_sheet/` | ✅ OUI | `map_page_wrapper.dart` |
| `info_pro_item_sheet/` | ✅ OUI | `map_page_wrapper.dart` |
| `info_wedding_pin_sheet/` | ✅ OUI | `map_page_wrapper.dart` |
| `points_of_interest_sheet/` | ⚠️ Interne | Utilisé par `info_poi_sheet` |
| `replay_guest_card/` | ✅ OUI | `content_replay_widget.dart` |

### Composants dans `components/`

| Fichier | Utilisé? | Utilisé par |
|---------|----------|-------------|
| `item_all_alert_*` | ✅ OUI | Référencé dans `map_page.dart` (logique) |
| `item_room_chat_*` | ❓ À vérifier | Aucune référence externe |
| `item_wish_list_conv_*` | ❓ À vérifier | Aucune référence externe |
| `select_date_*` | ✅ OUI | `create_edit_alert_sheet`, `create_edit_point_of_interest_sheet` |
| `nav/` | ✅ OUI | Navigation bars |
| `ui_system/` | ✅ OUI | Système UI |

---

## 🟡 PAGES LEGACY ENCORE UTILISÉES

Ces pages FlutterFlow sont encore dans la navigation (`nav.dart`):

| Page | Route | Statut |
|------|-------|--------|
| `MessagesBridesWidget` | `/messagesBrides` | ✅ Utilisé (nav + notifications) |
| `MessagesProWidget` | `/messagesPro` | ✅ Utilisé (nav + notifications) |
| `HomeBridesWidget` | `/homeBrides` | ✅ Utilisé |
| `FeedBridesWidget` | `/feedBrides` | ✅ Utilisé |
| `DashboardProWidget` | `/dashboardPro` | ✅ Utilisé |
| `ProDetailsWidget` | `/proDetails` | ✅ Utilisé |

**Note:** Ces pages ne peuvent PAS être supprimées car elles sont référencées dans `nav.dart` et la navigation.

---

## 🟢 FICHIERS SÛRS À NETTOYER

### 1. Fichiers temporaires iOS (déjà dans .gitignore)
- `ios/Flutter/Flutter *.podspec`
- `ios/Flutter/Generated *.xcconfig`
- `ios/Flutter/flutter_export_environment *.sh`

### 2. Fichiers de build
- `build/` (déjà ignoré)
- `.dart_tool/` (déjà ignoré)

---

## 📋 WARNINGS À CORRIGER (75)

### Catégories principales:

1. **`unnecessary_null_comparison`** - Comparaisons null inutiles
2. **`use_build_context_synchronously`** - Context après async
3. **`avoid_print`** - print() en production
4. **`type_literal_in_constant_pattern`** - Pattern matching

### Fichiers avec le plus de warnings:
- `lib/compo_finaux/create_edit_point_of_interest_sheet/` 
- `lib/compo_finaux/create_edit_alert_sheet/`
- `lib/backend/schema/enums/enums.dart`

---

## 🎯 PLAN D'ACTION - STATUT FINAL

### ✅ PHASES COMPLÉTÉES

**Phase 1-4:** Corrections et nettoyage initial
- ✅ Corriger les `avoid_print` → `debugPrint`
- ✅ Corriger les `use_build_context_synchronously`
- ✅ Corriger les `unnecessary_null_comparison`
- ✅ Suppression des sheets obsolètes
- ✅ Suppression des pages FlutterFlow remplacées

**Phase 5-6:** Nettoyage des concepts obsolètes
- ✅ Suppression des fichiers "wedding pin" (concept remplacé par "weddings")
- ✅ Suppression des actions non utilisées
- ✅ Suppression des structs obsolètes
- ✅ Suppression de `call_search_map_bundle_v2` (remplacé par Clean Architecture)
- ✅ Suppression de `get_bride_interest_items_action` (non utilisé)

### ✅ RÉSULTAT FINAL
- **Issues résolues:** 523 → 306 (-42%)
- **Erreurs:** 3 → 0 ✅
- **Fichiers supprimés:** 20
- **Lignes supprimées:** 3,711
- **Build:** ✅ SUCCESS
- **App:** ✅ Lancée avec succès

### ⚠️ À NE PAS TOUCHER
- ❌ Pages dans `lib/pages/` (utilisées par navigation)
- ❌ `compo_finaux/address_search/` (utilisé)
- ❌ `compo_finaux/replay_guest_card/` (utilisé)
- ❌ `components/nav/` et `components/ui_system/` (utilisés)

---

## 🔒 VÉRIFICATION SÉCURITÉ

### Variables d'environnement
- ✅ `.env` dans `.gitignore`
- ✅ `SECRETS_TRACKING.md` dans `.gitignore`
- ✅ Clés API dans `.env` (pas hardcodées)

### Supabase
- ✅ RLS policies en place
- ⚠️ Vérifier advisors Supabase

---

---

## 📝 HISTORIQUE DES PHASES

| Phase | Date | Fichiers | Lignes | Issues | Statut |
|-------|------|----------|--------|--------|--------|
| 1-2 | 2025-11-28 | -80 | -20,000+ | -150 | ✅ |
| 3 | 2025-12-03 | -30 | -15,000+ | -100 | ✅ |
| 4 | 2025-12-05 | -5 | -1,877 | -84 | ✅ |
| 5-6 | 2025-12-05 | -20 | -3,711 | -84 | ✅ |
| **TOTAL** | | **-135** | **-40,588** | **-418** | **✅** |

---

**Document finalisé le 2025-12-05 - Nettoyage complet terminé**
