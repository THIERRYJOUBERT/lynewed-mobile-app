# Map Feature Module

**Version:** 4.0.0 - FINAL  
**Created:** 2025-11-27  
**Completed:** 2025-12-01  
**Status:** ✅ **100% COMPLET** - Prêt pour Production

---

## 🎉 Module Terminé

Ce module a été entièrement refactorisé en Clean Architecture. Toutes les phases (0-8) sont terminées.

### Comparaison Avant/Après

| Aspect | FlutterFlow (ancien) | Clean Architecture (nouveau) |
|--------|---------------------|------------------------------|
| Lignes de code | 3600+ dispersées | ~4200 organisées |
| Fichiers | 10+ éparpillés | 35 modulaires |
| Testabilité | ❌ 0% | ✅ 100% (63 tests) |
| Duplication | 90% (bride/pro) | 0% (widget unifié) |
| Maintenance | ❌ Difficile | ✅ Facile |
| Design System | ❌ Incohérent | ✅ 100% appliqué |

## 🏗️ Architecture

```
lib/features/map/                    (~3200 lignes)
├── domain/                          (~900 lignes)
│   ├── entities/
│   │   ├── entities.dart            # Barrel export
│   │   ├── map_marker.dart          # Marqueur map
│   │   ├── map_filter.dart          # Filtres
│   │   ├── professional_alert.dart  # Alerte communautaire
│   │   ├── wedding.dart             # Mariage
│   │   ├── professional_details.dart # Détails pro + enums Profession/SubscriptionTier
│   │   ├── alert_details.dart       # Détails alerte + enum AlertType
│   │   └── wedding_details.dart     # Détails mariage
│   ├── repositories/
│   │   └── map_repository.dart      # Interface abstraite
│   ├── usecases/
│   │   └── get_marker_details.dart  # Use cases + MarkerDetailsService
│   └── utils/
│       └── marker_offset.dart       # Offset superposition < 20m
│
├── data/                            (~400 lignes)
│   ├── datasources/
│   │   └── supabase_map_datasource.dart
│   ├── models/
│   │   └── marker_type_mapper.dart  # Compatibilité enum FF
│   └── repositories/
│       └── supabase_map_repository.dart
│
├── presentation/                    (~2000 lignes)
│   ├── state/
│   │   └── map_state.dart           # ChangeNotifier
│   ├── theme/
│   │   └── map_theme.dart           # Couleurs, tailles, z-index
│   ├── services/
│   │   └── marker_icon_generator.dart # Custom markers avec initiales
│   ├── widgets/
│   │   ├── lynewed_map_widget.dart  # Widget unifié bride/pro
│   │   ├── filter_sheet.dart        # Sheet filtres
│   │   └── animated_marker.dart     # Animations fade/scale
│   ├── sheets/
│   │   ├── sheets.dart              # Barrel export
│   │   ├── professional_details_sheet.dart # Sheet pro Material 3
│   │   ├── alert_details_sheet.dart # Sheet alerte Material 3
│   │   └── wedding_details_sheet.dart # Sheet mariage Material 3
│   └── pages/
│       └── map_page.dart            # Page complète avec loader async
│
├── map.dart                         # Barrel export principal
└── README.md
```

## 🚀 Usage

### Import simple

```dart
import 'package:lynewed/features/map/map.dart';
```

### Widget basique

```dart
LynewedMapWidget(
  userRole: 'professional', // ou 'bride'
  onMarkerTap: (marker) {
    // Afficher les détails du marqueur
    showModalBottomSheet(
      context: context,
      builder: (_) => MarkerDetailsSheet(marker: marker),
    );
  },
)
```

### Avec configuration

```dart
LynewedMapWidget(
  userRole: 'bride',
  config: LynewedMapConfig(
    initialCenter: gmaps.LatLng(48.8566, 2.3522),
    initialZoom: 14.0,
    enableMyLocation: true,
  ),
  initialFilter: MapFilter(
    professions: [Profession.photographer, Profession.filmmaker],
    toggles: LayerToggles(
      showPros: true,
      showAlerts: true,
      showWeddings: false,
    ),
  ),
  onMarkersLoaded: (markers) {
    print('${markers.length} markers loaded');
  },
)
```

### Accès au state

```dart
// Depuis un widget enfant
final mapState = context.read<MapState>();

// Mettre à jour les filtres
mapState.updateFilter(
  mapState.filter.copyWith(
    professions: [Profession.photographer],
  ),
);

// Activer/désactiver une couche
mapState.updateToggles(
  mapState.filter.toggles.copyWith(showAlerts: false),
);
```

## 📊 Entités

### MapMarker

```dart
final marker = MapMarker(
  id: 'pro-123',
  type: MapMarkerType.professional,
  position: gmaps.LatLng(48.8566, 2.3522),
  style: MarkerStyle(
    avatarUrl: 'https://...',
    borderColorHex: '#2196F3',
    label: 'John Doe',
  ),
  metadata: {'profession': 'photographer'},
);
```

### MapFilter

```dart
final filter = MapFilter(
  professions: [Profession.photographer],
  budgetMin: 1000,
  budgetMax: 5000,
  currency: 'EUR',
  toggles: LayerToggles.all,
);
```

### MapMarkerType (enum simplifié - 3 valeurs)

```dart
enum MapMarkerType {
  proFixedLocation,    // Position fixe pro (fusion professional + fixedLocation)
  professionalAlert,   // Alerte communautaire
  wedding,             // Mariage (hub central per bride, Phase 5)
}
```

> **Note:** Phase 5 a supprimé `poiPrivate` (concept remplacé par Wedding hub).
> L'ancien enum FlutterFlow (`lib/backend/schema/enums/`) a encore 5 valeurs.
> La compatibilité est assurée par `marker_type_mapper.dart`.

## 🔄 Migration depuis FlutterFlow

### Avant (FlutterFlow)

```dart
// 20+ imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
// ... 18 autres imports

// Widget verbeux
custom_widgets.LynewedInteractiveMap(
  width: double.infinity,
  height: double.infinity,
  command: _model.psMapCommand,
  searchTargetMarker: _model.psSearchTargetMarker,
  filters: _model.layerToggles,
  // ... 15 autres paramètres
)
```

### Après (Clean)

```dart
// 1 import
import 'package:lynewed/features/map/map.dart';

// Widget propre
LynewedMapWidget(
  userRole: 'professional',
  onMarkerTap: _handleMarkerTap,
)
```

## 🧪 Tests

```dart
// Utiliser un mock repository pour les tests
final mockRepo = MockMapRepository();

LynewedMapWidget(
  userRole: 'bride',
  repository: mockRepo,
)
```

## ✅ TOUTES LES PHASES TERMINÉES

### Phase 0: Design System
- [x] Tokens créés (`lib/core/design/`)
- [x] Documentation complète

### Phases 1-4: Foundation
- [x] Clean Architecture implémentée
- [x] FilterSheet refactorisé
- [x] Markers avec avatars (44px)
- [x] MapActionsService

### Phase 5: Wedding System
- [x] Tables `weddings` + `wedding_participants`
- [x] RPCs complets (upsert, delete, get)
- [x] `WeddingCreateSheet` avec AddressSearch
- [x] Système de devises global

### Phase 6: Alert System
- [x] Enum `alert_type` (4 valeurs structurées)
- [x] `AlertCreateSheet` (~650 lignes)
- [x] Dashboard refresh (callbacks + lifecycle)

### Phase 7: Sécurité & Marché
- [x] 7.1: Audit RLS, RPCs sécurisés
- [x] 7.2: Séparation marché indien
- [x] 7.3: UI/UX final (chips, titres, contrôles)

### Phase 8: Documentation & Cleanup
- [x] Code mort supprimé
- [x] Imports nettoyés
- [x] README final

## 🎨 Design System

```dart
// Import unique
import '/core/design/design.dart';

// Tokens utilisés
LynewedColors.primary      // Noir (#000000)
LynewedTextStyles.bodyLarge // Typographie
LynewedSpacing.md          // Espacements
LynewedBorders.cardBorderRadius // Bordures
```

### Composants Standards
- **Chips**: Radius 4px, Padding H12/V8, Noir/Blanc, w300 (unselected) / w500 (selected)
- **Titres Section**: `sectionTitle` (16px, w500)
- **Boutons Map**: Fond noir, icône blanche, w400

## 🔗 Références

- **Rapport Final:** `docs/archive/MAP_REFACTORING_COMPLETE_2025-12-01.md`
- **Design System:** `docs/App/DESIGN_SYSTEM.md`
- **Audit Technique:** `docs/audits/MAP_MODULE_AUDIT_2025-11-28.md`
