/// LynewedMap widget - Clean replacement for LynewedInteractiveMap
/// 
/// Unified map widget for both bride and professional users.
/// Replaces 925-line monolithic widget with clean, composable architecture.
library;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';

import '/core/design/design.dart';
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

/// Callback pour récupérer le GoogleMapController
typedef OnMapControllerReady = void Function(gmaps.GoogleMapController controller);

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
    this.onMapControllerReady,
    this.repository,
    this.externalMapState,
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

  /// Callback quand le GoogleMapController est prêt
  final OnMapControllerReady? onMapControllerReady;

  /// Repository custom (pour tests)
  final MapRepository? repository;

  /// MapState externe (si fourni, on utilise celui-ci au lieu d'en créer un)
  final MapState? externalMapState;

  @override
  State<LynewedMapWidget> createState() => _LynewedMapWidgetState();
}

class _LynewedMapWidgetState extends State<LynewedMapWidget> {
  MapState? _ownMapState;  // Only created if externalMapState is null
  gmaps.GoogleMapController? _mapController;
  late MapRepository _repository;
  late MarkerIconGenerator _iconGenerator;
  final Map<String, gmaps.BitmapDescriptor> _markerIcons = {};
  bool _mounted = true;

  /// Get the active MapState (external or own)
  MapState get _mapState => widget.externalMapState ?? _ownMapState!;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SupabaseMapRepository();
    _iconGenerator = MarkerIconGenerator();
    
    // Only create own MapState if no external one provided
    if (widget.externalMapState == null) {
      _ownMapState = MapState(
        repository: _repository,
        userRole: widget.userRole,
        initialCenter: widget.config.initialCenter,
        initialZoom: widget.config.initialZoom,
      );

      if (widget.initialFilter != null) {
        _ownMapState!.updateFilter(widget.initialFilter!);
      }
    }

    _mapState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _mounted = false;
    _mapState.removeListener(_onStateChange);
    // Only dispose own MapState, not external
    _ownMapState?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (!_mounted) return;
    // Notify parent when markers loaded
    if (_mapState.loadingState == MapLoadingState.loaded) {
      widget.onMarkersLoaded?.call(_mapState.visibleMarkers);
      // Generate custom icons for all visible markers
      _generateMarkersIcons();
    }
    setState(() {});
  }

  /// Pre-generate custom circle icons for all visible markers
  /// Generate at 144px (48*3) for crisp Retina display, displayed at 48px
  Future<void> _generateMarkersIcons() async {
    final markers = _mapState.visibleMarkers;
    if (markers.isEmpty) return;
    
    // Generate all icons in parallel for speed
    final futures = <Future<void>>[];
    
    for (final marker in markers) {
      final cacheKey = _generateIconKey(marker);
      if (!_markerIcons.containsKey(cacheKey)) {
        futures.add(_generateSingleIcon(marker, cacheKey));
      }
    }
    
    // Wait for all icons to be generated
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
    
    // Rebuild with custom icons
    if (_mounted) setState(() {});
  }
  
  Future<void> _generateSingleIcon(MapMarker marker, String cacheKey) async {
    try {
      // Generate at 144px (48 * 3) for crisp rendering, displayed at 48px
      final icon = await _iconGenerator.generateIcon(marker, size: 144.0);
      if (_mounted) {
        _markerIcons[cacheKey] = icon;
      }
    } catch (e) {
      debugPrint('[LynewedMapWidget._generateMarkerIcon] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // If using external MapState, don't wrap in Provider (parent already provides it)
    final child = Stack(
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
          mapType: _mapState.mapType,
          myLocationEnabled: widget.config.enableMyLocation,
          myLocationButtonEnabled: false, // Custom button
          zoomControlsEnabled: false, // Custom zoom controls
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
      ],
    );

    // Only wrap in Provider if we created our own MapState
    return widget.externalMapState != null 
        ? child 
        : ChangeNotifierProvider.value(value: _mapState, child: child);
  }

  void _onMapCreated(gmaps.GoogleMapController controller) {
    _mapController = controller;
    // Note: Map style is now applied via GoogleMap.style property (line 222)
    // Notify parent that controller is ready
    widget.onMapControllerReady?.call(controller);
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

    // Only show markers that have their custom icon ready (no default pins)
    return offsetMarkers
        .where((marker) => _markerIcons.containsKey(_generateIconKey(marker)))
        .map((marker) {
      return gmaps.Marker(
        markerId: gmaps.MarkerId(marker.id),
        position: marker.position,
        onTap: () => _onMarkerTap(marker),
        icon: _markerIcons[_generateIconKey(marker)]!,
        zIndexInt: _zIndexForMarkerType(marker.type),
      );
    }).toSet();
  }

  /// Generate unique cache key for marker icon
  String _generateIconKey(MapMarker marker) {
    return '${marker.type.name}|${marker.style.borderColorHex}|${marker.style.avatarUrl}|${marker.style.label}';
  }

  void _onMarkerTap(MapMarker marker) {
    _mapState.selectMarker(marker);
    widget.onMarkerTap?.call(marker);
  }

  int _zIndexForMarkerType(MapMarkerType type) {
    switch (type) {
      case MapMarkerType.professionalAlert:
        return 5;
      case MapMarkerType.wedding:
        return 4;
      case MapMarkerType.proFixedLocation:
        return 3;
    }
  }
}

// --- Sub-widgets ---

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LynewedSpacing.lg,
        vertical: LynewedSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: LynewedColors.primary.withValues(alpha: 0.1),
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
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: LynewedColors.primary,
            ),
          ),
          LynewedGap.horizontalSm,
          Text(
            'Loading...',
            style: LynewedTextStyles.labelLarge,
          ),
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
      padding: LynewedSpacing.allMd,
      decoration: BoxDecoration(
        color: LynewedColors.error.withValues(alpha: 0.1),
        borderRadius: LynewedBorders.borderRadiusMd,
        border: Border.all(color: LynewedColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: LynewedColors.error,
            size: 20,
          ),
          LynewedGap.horizontalSm,
          Expanded(
            child: Text(
              message ?? 'An error occurred',
              style: LynewedTextStyles.labelLarge.copyWith(
                color: LynewedColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

