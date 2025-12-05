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
    String userMarket = 'GLOBAL',
  })  : _repository = repository,
        _userRole = userRole,
        _userMarket = userMarket,
        _center = initialCenter ?? const gmaps.LatLng(48.8566, 2.3522),
        _zoom = initialZoom;

  final MapRepository _repository;
  final String _userRole;
  String _userMarket;
  String get userMarket => _userMarket;
  
  void updateUserMarket(String market) {
    _userMarket = market;
    notifyListeners();
  }

  // --- État ---
  
  MapLoadingState _loadingState = MapLoadingState.initial;
  MapLoadingState get loadingState => _loadingState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MapSearchResult _searchResult = MapSearchResult.empty;
  MapSearchResult get searchResult => _searchResult;

  MapFilter _filter = MapFilter.defaults;
  MapFilter get filter => _filter;
  
  // Cache accumulatif de tous les markers chargés
  // Key: marker.id, Value: marker
  // Les markers sont accumulés au fil des pans/zooms
  // Note: _professionalsCache is deprecated - all pros are in _fixedLocationsCache now
  final Map<String, MapMarker> _fixedLocationsCache = {};
  final Map<String, MapMarker> _alertsCache = {};
  final Map<String, MapMarker> _weddingsCache = {};

  gmaps.LatLng _center;
  gmaps.LatLng get center => _center;

  double _zoom;
  double get zoom => _zoom;

  gmaps.LatLngBounds? _visibleBounds;
  gmaps.LatLngBounds? get visibleBounds => _visibleBounds;

  MapMarker? _selectedMarker;
  MapMarker? get selectedMarker => _selectedMarker;

  gmaps.MapType _mapType = gmaps.MapType.normal;
  gmaps.MapType get mapType => _mapType;

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
    final boundsChanged = _visibleBounds != bounds;
    _visibleBounds = bounds;
    
    // Notify to update markersInView count even if no new data loaded
    if (boundsChanged) {
      notifyListeners();
    }
    
    _debouncedSearch();
  }

  /// Met à jour les filtres et relance la recherche
  /// Si les filtres de contenu changent (professions, budget), vide le cache
  void updateFilter(MapFilter newFilter) {
    if (_filter == newFilter) return;
    
    // Check if content filters changed (not just toggles)
    final contentFiltersChanged = 
        _filter.professions != newFilter.professions ||
        _filter.budgetMin != newFilter.budgetMin ||
        _filter.budgetMax != newFilter.budgetMax;
    
    _filter = newFilter;
    
    // Clear cache if content filters changed (need fresh data from backend)
    if (contentFiltersChanged) {
      clearMarkersCache();
    }
    
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

  /// Zoom in
  void zoomIn() {
    _zoom = (_zoom + 1).clamp(1.0, 21.0);
    notifyListeners();
  }

  /// Zoom out
  void zoomOut() {
    _zoom = (_zoom - 1).clamp(1.0, 21.0);
    notifyListeners();
  }

  /// Change le type de map
  void setMapType(gmaps.MapType type) {
    if (_mapType == type) return;
    _mapType = type;
    notifyListeners();
  }

  /// Force le rechargement des données (vide le cache)
  Future<void> refresh() async {
    if (_visibleBounds == null) return;
    clearMarkersCache();
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
  /// Les markers sont ACCUMULÉS dans le cache (pas remplacés)
  /// pour éviter les disparitions lors des pans/zooms
  Future<void> _loadMarkers() async {
    if (_visibleBounds == null) return;

    _loadingState = MapLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.searchMarkers(
        bounds: _visibleBounds!,
        filter: _filter,
        userRole: _userRole,
        zoomLevel: _zoom,
      );
      
      // ACCUMULATE markers in cache (don't replace)
      // This prevents markers from disappearing during pan/zoom
      // Note: professionals list is now empty - all pros are in fixedLocations
      for (final m in result.fixedLocations) {
        _fixedLocationsCache[m.id] = m;
      }
      for (final m in result.alerts) {
        _alertsCache[m.id] = m;
      }
      for (final m in result.weddings) {
        _weddingsCache[m.id] = m;
      }
      
      // Update searchResult with FULL cache contents
      _searchResult = MapSearchResult(
        professionals: const [], // Empty - all pros in fixedLocations
        fixedLocations: _fixedLocationsCache.values.toList(),
        alerts: _alertsCache.values.toList(),
        weddings: _weddingsCache.values.toList(),
        totalCount: _fixedLocationsCache.length + 
                   _alertsCache.length + 
                   _weddingsCache.length,
      );
      
      _loadingState = MapLoadingState.loaded;
    } catch (e) {
      _loadingState = MapLoadingState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }
  
  /// Vide le cache des markers (appelé lors d'un changement de filtres significatif)
  void clearMarkersCache() {
    _fixedLocationsCache.clear();
    _alertsCache.clear();
    _weddingsCache.clear();
    _searchResult = MapSearchResult.empty;
    notifyListeners();
  }

  // --- Getters dérivés ---

  /// Tous les marqueurs filtrés par les toggles (from cache)
  /// Note: showPros and showFixedLocations are now merged - both control fixedLocations
  /// (RPC returns all pro markers as fixedLocation type)
  List<MapMarker> get visibleMarkers {
    final markers = <MapMarker>[];
    
    // showPros OR showFixedLocations controls pro markers (they're the same now)
    if (_filter.toggles.showPros || _filter.toggles.showFixedLocations) {
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
  
  /// Markers visibles dans les bounds actuels de la map (pas tout le cache)
  List<MapMarker> get markersInView {
    if (_visibleBounds == null) return visibleMarkers;
    
    return visibleMarkers.where((marker) {
      return _visibleBounds!.contains(marker.position);
    }).toList();
  }

  /// Nombre de marqueurs visibles dans les bounds actuels
  int get visibleMarkersCount => markersInView.length;

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
