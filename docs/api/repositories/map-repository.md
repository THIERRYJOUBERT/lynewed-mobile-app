# MapRepository

**Location:** `lib/features/map/domain/repositories/map_repository.dart`
**Implementation:** `lib/features/map/data/repositories/map_repository_impl.dart`

---

## Description

Repository pour les opérations liées à la carte interactive. Gère les marqueurs (professionnels, alertes, mariages), les filtres de recherche et les requêtes géospatiales via PostGIS.

---

## Interface

```dart
abstract class MapRepository {
  Future<MapSearchResult> searchMarkers({
    required LatLngBounds bounds,
    required MapFilter filter,
    required String userRole,
    double zoomLevel = 12.0,
  });

  Future<Map<String, dynamic>?> getProfessionalDetails(String professionalId);
  Future<ProfessionalAlert?> getAlertDetails(String alertId);
  Future<Wedding?> getWeddingDetails(String weddingId);

  Future<ProfessionalAlert> saveAlert(ProfessionalAlert alert);
  Future<void> deleteAlert(String alertId);

  Future<Wedding> saveWedding(Wedding wedding);
  Future<Wedding?> getCurrentUserWedding();

  Stream<List<ProfessionalAlert>> watchAlerts(LatLngBounds bounds);

  void dispose();
}
```

---

## Classes de Support

### MapSearchResult

```dart
class MapSearchResult {
  final List<MapMarker> professionals;
  final List<MapMarker> fixedLocations;
  final List<MapMarker> alerts;
  final List<MapMarker> weddings;
  final int totalCount;
  final bool hasMore;

  List<MapMarker> get allMarkers => [
    ...professionals,
    ...fixedLocations,
    ...alerts,
    ...weddings,
  ];
}
```

### MapFilter

Filtres de recherche pour la carte (professions, budget, toggles actifs).

---

## Méthodes

### `searchMarkers()`

Recherche les marqueurs dans une zone géographique avec filtres.

**Paramètres:**
- `bounds` (LatLngBounds): Zone géographique visible
- `filter` (MapFilter): Filtres actifs (professions, budget, toggles)
- `userRole` (String): Rôle de l'utilisateur (`bride`/`professional`)
- `zoomLevel` (double): Niveau de zoom pour adapter les limites

**Retour:** `Future<MapSearchResult>`

**Exemple:**
```dart
final result = await repository.searchMarkers(
  bounds: LatLngBounds(
    southwest: LatLng(48.8, 2.2),
    northeast: LatLng(48.9, 2.4),
  ),
  filter: MapFilter(
    professions: ['PHOTOGRAPHER', 'FILMMAKER'],
    budgetMin: 1000,
    budgetMax: 5000,
  ),
  userRole: 'bride',
  zoomLevel: 14.0,
);

for (final marker in result.allMarkers) {
  print('${marker.type}: ${marker.id}');
}
```

---

### `getProfessionalDetails()`

Récupère les détails complets d'un professionnel.

**Paramètres:**
- `professionalId` (String): ID du profil professionnel

**Retour:** `Future<Map<String, dynamic>?>`

**Exemple:**
```dart
final details = await repository.getProfessionalDetails('uuid-xxx');
if (details != null) {
  print('Business: ${details['business_name']}');
  print('Budget: ${details['budget_min']} - ${details['budget_max']}');
}
```

---

### `saveAlert()`

Crée ou met à jour une alerte professionnelle.

**Paramètres:**
- `alert` (ProfessionalAlert): Données de l'alerte

**Retour:** `Future<ProfessionalAlert>`

**Exemple:**
```dart
final alert = ProfessionalAlert(
  title: 'Recherche photographe',
  message: 'Besoin urgent pour mariage samedi',
  radiusKm: 50,
  durationHours: 24,
  locationCoords: LatLng(48.8566, 2.3522),
);

final saved = await repository.saveAlert(alert);
print('Alert created: ${saved.id}');
```

---

### `watchAlerts()`

Stream temps réel des alertes dans une zone.

**Paramètres:**
- `bounds` (LatLngBounds): Zone géographique à surveiller

**Retour:** `Stream<List<ProfessionalAlert>>`

**Exemple:**
```dart
repository.watchAlerts(bounds).listen((alerts) {
  print('${alerts.length} alertes actives');
  for (final alert in alerts) {
    print('- ${alert.title}');
  }
});
```

---

## Utilisation avec Cubit

```dart
class MapCubit extends Cubit<MapState> {
  final MapRepository _repository;

  MapCubit(this._repository) : super(MapState.initial());

  Future<void> loadMarkers(LatLngBounds bounds) async {
    emit(state.copyWith(loading: true));

    final result = await _repository.searchMarkers(
      bounds: bounds,
      filter: state.filter,
      userRole: currentUser.role,
      zoomLevel: state.zoomLevel,
    );

    emit(state.copyWith(
      markers: result.allMarkers,
      loading: false,
    ));
  }

  Future<void> selectMarker(MapMarker marker) async {
    final details = await _repository.getProfessionalDetails(marker.id);
    emit(state.copyWith(selectedDetails: details));
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
```

---

## Notes

- Les requêtes utilisent PostGIS pour les calculs géospatiaux côté serveur
- Le nombre de résultats est adapté au niveau de zoom (moins de résultats = zoom arrière)
- Les alertes expirent automatiquement après `durationHours`
- Appeler `dispose()` pour nettoyer les subscriptions realtime
