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

### Flutter Analyze - APRÈS NETTOYAGE FINAL
- **Total issues:** 389 (-134 issues, soit -26%)
- **Errors:** 0 ✅
- **Build:** ✅ SUCCESS
- **App:** ✅ Lancée avec succès sur simulateur

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

### Statistiques
- **Fichiers Dart:** 419
- **Lignes de code:** ~71,500
- **Issues Flutter Analyze:** 389 (vs 523 avant = -26%)

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

## 🎯 PLAN D'ACTION RECOMMANDÉ

### Phase 1: Corrections Sûres (FAIRE)
1. ✅ Corriger les `avoid_print` → `debugPrint`
2. ✅ Corriger les `use_build_context_synchronously`
3. ✅ Corriger les `unnecessary_null_comparison`

### Phase 2: Nettoyage Prudent (AVEC PRÉCAUTION)
1. ⚠️ Vérifier si `add_filter_sheet` est utilisé quelque part
2. ⚠️ Vérifier si `create_edit_alert_sheet` est utilisé
3. ⚠️ Vérifier `item_room_chat_*` et `item_wish_list_conv_*`

### Phase 3: NE PAS TOUCHER
- ❌ Pages dans `lib/pages/` (utilisées par navigation)
- ❌ `compo_finaux/address_search/` (utilisé)
- ❌ `compo_finaux/info_*_sheet/` (utilisés par map_page_wrapper)
- ❌ `compo_finaux/replay_guest_card/` (utilisé)

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

**Document créé pour traçabilité avant nettoyage**
