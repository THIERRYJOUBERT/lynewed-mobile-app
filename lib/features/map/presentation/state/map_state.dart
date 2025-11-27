/// Map state management
/// 
/// Simple ChangeNotifier-based state for map feature.
/// Can be migrated to Bloc/Riverpod later if needed.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../domain/entities/entities.dart';
import '../../domain/repositories/map_repository.dart';

/// État de chargement
enum MapLoadingState {
  initial,
  loading,
  loaded,
  error,
}

/// État de la map
class MapState extends ChangeNotifier {
  MapState({
    required MapRepository repository,
    required String userRole,
    gmaps.LatLng? initialCenter,
    double initialZoom = 12.0,
  })  : _repository = repository,
        _userRole = userRole,
        _center = initialCenter ?? const gmaps.LatLng(48.8566, 2.3522),
        _zoom = initialZoom;

  final MapRepository _repository;
  final String _userRole;

  // --- État ---
  
  MapLoadingState _loadingState = MapLoadingState.initial;
  MapLoadingState get loadingState => _loadingState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MapSearchResult _searchResult = MapSearchResult.empty;
  MapSearchResult get searchResult => _searchResult;

  MapFilter _filter = MapFilter.defaults;
  MapFilter get filter => _filter;

  gmaps.LatLng _center;
  gmaps.LatLng get center => _center;

  double _zoom;
  double get zoom => _zoom;

  gmaps.LatLngBounds? _visibleBounds;
  gmaps.LatLngBounds? get visibleBounds => _visibleBounds;

  MapMarker? _selectedMarker;
  MapMarker? get selectedMarker => _selectedMarker;

  // Debounce timer pour éviter trop d'appels
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 300);

  // --- Actions ---

  /// Met à jour les bounds visibles et charge les marqueurs
  void onCameraMove(gmaps.CameraPosition position) {
    _center = position.target;
    _zoom = position.zoom;
    // Ne pas notifier ici pour éviter les rebuilds pendant le mouvement
  }

  /// Appelé quand le mouvement de caméra est terminé
  void onCameraIdle(gmaps.LatLngBounds bounds) {
    _visibleBounds = bounds;
    _debouncedSearch();
  }

  /// Met à jour les filtres et relance la recherche
  void updateFilter(MapFilter newFilter) {
    if (_filter == newFilter) return;
    _filter = newFilter;
    notifyListeners();
    _debouncedSearch();
  }

  /// Met à jour les toggles de couches
  void updateToggles(LayerToggles toggles) {
    updateFilter(_filter.copyWith(toggles: toggles));
  }

  /// Sélectionne un marqueur
  void selectMarker(MapMarker? marker) {
    if (_selectedMarker == marker) return;
    _selectedMarker = marker;
    notifyListeners();
  }

  /// Désélectionne le marqueur courant
  void clearSelection() {
    selectMarker(null);
  }

  /// Force le rechargement des données
  Future<void> refresh() async {
    if (_visibleBounds == null) return;
    await _loadMarkers();
  }

  /// Recherche avec debounce
  void _debouncedSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (_visibleBounds != null) {
        _loadMarkers();
      }
    });
  }

  /// Charge les marqueurs depuis le repository
  Future<void> _loadMarkers() async {
    if (_visibleBounds == null) return;

    _loadingState = MapLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResult = await _repository.searchMarkers(
        bounds: _visibleBounds!,
        filter: _filter,
        userRole: _userRole,
        zoomLevel: _zoom,
      );
      _loadingState = MapLoadingState.loaded;
    } catch (e) {
      _loadingState = MapLoadingState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // --- Getters dérivés ---

  /// Tous les marqueurs filtrés par les toggles
  List<MapMarker> get visibleMarkers {
    final markers = <MapMarker>[];
    
    if (_filter.toggles.showPros) {
      markers.addAll(_searchResult.professionals);
    }
    if (_filter.toggles.showFixedLocations) {
      markers.addAll(_searchResult.fixedLocations);
    }
    if (_filter.toggles.showAlerts) {
      markers.addAll(_searchResult.alerts);
    }
    if (_filter.toggles.showWeddings) {
      markers.addAll(_searchResult.weddings);
    }
    
    return markers;
  }

  /// Nombre total de marqueurs visibles
  int get visibleMarkersCount => visibleMarkers.length;

  /// Est en chargement
  bool get isLoading => _loadingState == MapLoadingState.loading;

  /// A des erreurs
  bool get hasError => _loadingState == MapLoadingState.error;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
