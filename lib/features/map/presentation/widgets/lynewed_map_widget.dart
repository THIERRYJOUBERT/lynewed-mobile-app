/// LynewedMap widget - Clean replacement for LynewedInteractiveMap
/// 
/// Unified map widget for both bride and professional users.
/// Replaces 925-line monolithic widget with clean, composable architecture.
library;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/utils/marker_offset.dart';
import '../services/marker_icon_generator.dart';
import '../state/map_state.dart';
import '../../data/repositories/supabase_map_repository.dart';

/// Configuration du widget LynewedMap
class LynewedMapConfig {
  const LynewedMapConfig({
    this.initialCenter,
    this.initialZoom = 12.0,
    this.enableMyLocation = true,
    this.enableZoomControls = true,
    this.mapStyle,
    this.padding = EdgeInsets.zero,
  });

  final gmaps.LatLng? initialCenter;
  final double initialZoom;
  final bool enableMyLocation;
  final bool enableZoomControls;
  final String? mapStyle;
  final EdgeInsets padding;

  /// Config par défaut centrée sur Paris
  static const defaults = LynewedMapConfig();
}

/// Callbacks du widget LynewedMap
typedef OnMarkerTap = void Function(MapMarker marker);
typedef OnMapTap = void Function(gmaps.LatLng position);
typedef OnCameraMove = void Function(gmaps.CameraPosition position);
typedef OnMarkersLoaded = void Function(List<MapMarker> markers);

/// Widget LynewedMap - Unifié bride/pro
/// 
/// Usage:
/// ```dart
/// LynewedMapWidget(
///   userRole: 'professional',
///   config: LynewedMapConfig(initialZoom: 10),
///   onMarkerTap: (marker) => _showMarkerSheet(marker),
/// )
/// ```
class LynewedMapWidget extends StatefulWidget {
  const LynewedMapWidget({
    super.key,
    required this.userRole,
    this.config = const LynewedMapConfig(),
    this.initialFilter,
    this.onMarkerTap,
    this.onMapTap,
    this.onCameraMove,
    this.onMarkersLoaded,
    this.repository,
  });

  /// Rôle utilisateur: 'bride' ou 'professional'
  final String userRole;

  /// Configuration de la map
  final LynewedMapConfig config;

  /// Filtres initiaux
  final MapFilter? initialFilter;

  /// Callback au tap sur un marqueur
  final OnMarkerTap? onMarkerTap;

  /// Callback au tap sur la map (hors marqueur)
  final OnMapTap? onMapTap;

  /// Callback au mouvement de caméra
  final OnCameraMove? onCameraMove;

  /// Callback quand les marqueurs sont chargés
  final OnMarkersLoaded? onMarkersLoaded;

  /// Repository custom (pour tests)
  final MapRepository? repository;

  @override
  State<LynewedMapWidget> createState() => _LynewedMapWidgetState();
}

class _LynewedMapWidgetState extends State<LynewedMapWidget> {
  late MapState _mapState;
  gmaps.GoogleMapController? _mapController;
  late MapRepository _repository;
  late MarkerIconGenerator _iconGenerator;
  final Map<String, gmaps.BitmapDescriptor> _markerIcons = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SupabaseMapRepository();
    _iconGenerator = MarkerIconGenerator();
    _mapState = MapState(
      repository: _repository,
      userRole: widget.userRole,
      initialCenter: widget.config.initialCenter,
      initialZoom: widget.config.initialZoom,
    );

    if (widget.initialFilter != null) {
      _mapState.updateFilter(widget.initialFilter!);
    }

    _mapState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _mapState.removeListener(_onStateChange);
    _mapState.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onStateChange() {
    // Notify parent when markers loaded
    if (_mapState.loadingState == MapLoadingState.loaded) {
      widget.onMarkersLoaded?.call(_mapState.visibleMarkers);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _mapState,
      child: Stack(
        children: [
          // Google Map
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: _mapState.center,
              zoom: _mapState.zoom,
            ),
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            onTap: _onMapTap,
            markers: _buildMarkers(),
            myLocationEnabled: widget.config.enableMyLocation,
            myLocationButtonEnabled: false, // Custom button
            zoomControlsEnabled: widget.config.enableZoomControls,
            mapToolbarEnabled: false,
            padding: widget.config.padding,
            style: widget.config.mapStyle,
          ),

          // Loading indicator
          if (_mapState.isLoading)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: _LoadingIndicator(),
              ),
            ),

          // Error message
          if (_mapState.hasError)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _ErrorBanner(message: _mapState.errorMessage),
            ),

          // Markers count badge
          Positioned(
            top: 16,
            right: 16,
            child: _MarkerCountBadge(count: _mapState.visibleMarkersCount),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(gmaps.GoogleMapController controller) {
    _mapController = controller;
    
    // Apply custom style if provided
    if (widget.config.mapStyle != null) {
      controller.setMapStyle(widget.config.mapStyle);
    }
  }

  void _onCameraMove(gmaps.CameraPosition position) {
    _mapState.onCameraMove(position);
    widget.onCameraMove?.call(position);
  }

  void _onCameraIdle() async {
    final bounds = await _mapController?.getVisibleRegion();
    if (bounds != null) {
      _mapState.onCameraIdle(bounds);
    }
  }

  void _onMapTap(gmaps.LatLng position) {
    _mapState.clearSelection();
    widget.onMapTap?.call(position);
  }

  Set<gmaps.Marker> _buildMarkers() {
    // Apply proximity offset to prevent overlapping markers
    final offsetMarkers = _mapState.visibleMarkers.withProximityOffset(
      config: const MarkerOffsetConfig(
        proximityThresholdMeters: 20.0,
        offsetDistanceMeters: 12.0,
      ),
    );

    return offsetMarkers.map((marker) {
      return gmaps.Marker(
        markerId: gmaps.MarkerId(marker.id),
        position: marker.position,
        onTap: () => _onMarkerTap(marker),
        // Custom icons with avatars
        icon: _getMarkerIcon(marker),
        zIndex: _zIndexForMarkerType(marker.type),
      );
    }).toSet();
  }

  /// Get cached or generate custom marker icon
  gmaps.BitmapDescriptor _getMarkerIcon(MapMarker marker) {
    final cacheKey = _generateIconKey(marker);
    
    if (_markerIcons.containsKey(cacheKey)) {
      return _markerIcons[cacheKey]!;
    }

    // For now, use default icons while async generation loads
    // TODO: Implement async icon generation with loading states
    return gmaps.BitmapDescriptor.defaultMarkerWithHue(
      _hueForMarkerType(marker.type),
    );
  }

  /// Generate unique cache key for marker icon
  String _generateIconKey(MapMarker marker) {
    return '${marker.type.name}|${marker.style.borderColorHex}|${marker.style.avatarUrl}';
  }

  void _onMarkerTap(MapMarker marker) {
    _mapState.selectMarker(marker);
    widget.onMarkerTap?.call(marker);
  }

  double _hueForMarkerType(MapMarkerType type) {
    switch (type) {
      case MapMarkerType.proFixedLocation:
        return gmaps.BitmapDescriptor.hueBlue;
      case MapMarkerType.professionalAlert:
        return gmaps.BitmapDescriptor.hueOrange;
      case MapMarkerType.wedding:
        return gmaps.BitmapDescriptor.hueRose;
      case MapMarkerType.poiPrivate:
        return gmaps.BitmapDescriptor.hueViolet;
    }
  }

  double _zIndexForMarkerType(MapMarkerType type) {
    switch (type) {
      case MapMarkerType.professionalAlert:
        return 5;
      case MapMarkerType.wedding:
        return 4;
      case MapMarkerType.proFixedLocation:
        return 3; // Augmenté car plus de types
      case MapMarkerType.poiPrivate:
        return 1;
    }
  }
}

// --- Sub-widgets ---

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Loading...', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? 'An error occurred',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerCountBadge extends StatelessWidget {
  const _MarkerCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
