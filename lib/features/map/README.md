# Map Feature Module

**Version:** 1.0.0  
**Created:** 2025-11-27  
**Status:** 🚧 En développement (Phase 2)

## 📋 Objectif

Réécriture complète de la fonctionnalité map pour remplacer le code FlutterFlow verbeux et mal structuré.

### Comparaison

| Aspect | FlutterFlow (ancien) | Clean Architecture (nouveau) |
|--------|---------------------|------------------------------|
| Lignes de code | 3600+ | ~1000 |
| Fichiers | 10+ dispersés | Module organisé |
| Testabilité | ❌ Impossible | ✅ 100% testable |
| Duplication | 90% (bride/pro) | 0% (widget unifié) |
| Maintenance | ❌ Difficile | ✅ Facile |

## 🏗️ Architecture

```
lib/features/map/
├── domain/                    # Couche métier (indépendante)
│   ├── entities/
│   │   ├── map_marker.dart    # Marqueur immutable (~130 lignes vs 147)
│   │   ├── map_filter.dart    # Filtres (~180 lignes vs 417)
│   │   ├── professional_alert.dart
│   │   └── wedding.dart       # Remplace wedding_pins + user_pois
│   └── repositories/
│       └── map_repository.dart # Interface abstraite
│
├── data/                      # Couche données
│   ├── datasources/
│   │   └── supabase_map_datasource.dart
│   └── repositories/
│       └── supabase_map_repository.dart
│
├── presentation/              # Couche UI
│   ├── widgets/
│   │   └── lynewed_map_widget.dart  # Widget unifié bride/pro
│   ├── state/
│   │   └── map_state.dart     # ChangeNotifier
│   ├── pages/
│   │   └── map_page.dart      # Page complète (TODO)
│   └── theme/
│       └── map_theme.dart     # Styles (TODO)
│
├── map.dart                   # Barrel export
└── README.md                  # Ce fichier
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
    professions: [Profession.photographer, Profession.videographer],
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

### MapMarkerType (enum nettoyé Phase 1)

```dart
enum MapMarkerType {
  professional,      // Professionnel
  proFixedLocation,  // Position fixe (renommé de fixedLocation)
  professionalAlert, // Alerte communautaire
  wedding,           // Mariage (remplace weddingPin)
  poiPrivate,        // POI privé (deprecated, sera supprimé)
}
```

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

## 📝 TODO Phase 2+

- [ ] Page MapPage complète avec AppBar et filtres
- [ ] Composant FilterSheet réutilisable
- [ ] Composant MarkerDetailsSheet
- [ ] Custom marker icons (avatars)
- [ ] Clustering des marqueurs
- [ ] Theme map (dark mode, styles)
- [ ] Tests unitaires et widget tests
- [ ] Migration progressive des pages existantes

## 🔗 Références

- **Plan de refactorisation:** `docs/MAP_REFACTORING_PLAN.md` v1.7
- **Audit technique:** `docs/audits/MAP_FEATURE_AUDIT.md`
- **Changelog:** `docs/MAP_REFACTORING_README.md`
