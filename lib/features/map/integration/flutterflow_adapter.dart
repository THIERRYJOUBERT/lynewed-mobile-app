/// FlutterFlow Integration Adapter for Map Module
/// 
/// This adapter bridges the new Clean Architecture map module with
/// existing FlutterFlow components (sheets, actions, state).
/// 
/// Usage:
/// ```dart
/// FlutterFlowMapAdapter(
///   userRole: FFAppState().currentUserRole,
///   initialCenter: widget.initialCenter,
///   onMarkerTap: (marker) => _handleMarkerTap(context, marker),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

// FlutterFlow imports
import '/backend/schema/enums/enums.dart' as ff_enums;
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';

// New map module imports
import '../domain/entities/entities.dart';
import '../data/models/marker_type_mapper.dart';
import '../presentation/widgets/lynewed_map_widget.dart';
import '../presentation/theme/map_theme.dart';

/// Callback types for FlutterFlow integration
typedef FFMarkerTapCallback = Future<void> Function(MapMarkerStruct marker);
typedef FFDataLoadedCallback = void Function(MapdatabundleStruct data);

/// Adapter widget that wraps the new LynewedMapWidget
/// and provides FlutterFlow-compatible interface
class FlutterFlowMapAdapter extends StatefulWidget {
  const FlutterFlowMapAdapter({
    super.key,
    required this.userRole,
    this.initialCenter,
    this.initialZoom = 12.0,
    this.filters,
    this.onMarkerTap,
    this.onDataLoaded,
    this.enableMyLocation = true,
  });

  /// User role ('bride' or 'professional')
  final String userRole;

  /// Initial map center (FlutterFlow LatLng)
  final LatLng? initialCenter;

  /// Initial zoom level
  final double initialZoom;

  /// FlutterFlow QueryFilters
  final QueryFiltersStruct? filters;

  /// Callback when marker is tapped (FlutterFlow struct)
  final FFMarkerTapCallback? onMarkerTap;

  /// Callback when data is loaded
  final FFDataLoadedCallback? onDataLoaded;

  /// Enable my location layer
  final bool enableMyLocation;

  @override
  State<FlutterFlowMapAdapter> createState() => _FlutterFlowMapAdapterState();
}

class _FlutterFlowMapAdapterState extends State<FlutterFlowMapAdapter> {
  /// Convert FlutterFlow filters to new MapFilter
  MapFilter _convertFilters(QueryFiltersStruct? ffFilters) {
    if (ffFilters == null) return MapFilter.defaults;

    return MapFilter(
      professions: _convertProfessions(ffFilters.selectedProfessionsList),
      budgetMin: ffFilters.budgetMin,
      budgetMax: ffFilters.budgetMax,
      currency: ffFilters.currency ?? 'EUR',
      radiusKm: ffFilters.radiusKm,
      toggles: LayerToggles(
        showPros: ffFilters.showPros ?? true,
        showFixedLocations: ffFilters.showFixedLocations ?? true,
        showAlerts: ffFilters.showProAlerts ?? true,
        showWeddings: ffFilters.showWeddingPins ?? true,
        showOnlyMyProfession: ffFilters.showOnlyMyProfessionPins ?? false,
      ),
    );
  }

  /// Convert FlutterFlow professions to new Profession enum
  List<Profession> _convertProfessions(List<String>? ffProfessions) {
    if (ffProfessions == null || ffProfessions.isEmpty) return [];
    
    return ffProfessions
        .map((p) => Profession.values.firstWhere(
              (e) => e.name.toUpperCase() == p.toUpperCase(),
              orElse: () => Profession.photographer,
            ))
        .toList();
  }

  /// Convert new MapMarker to FlutterFlow MapMarkerStruct
  MapMarkerStruct _convertToFFMarker(MapMarker marker) {
    return MapMarkerStruct(
      id: marker.id,
      type: toFlutterFlowType(marker.type),
      latitude: marker.position.latitude,
      longitude: marker.position.longitude,
      label: marker.style.label,
      avatarUrl: marker.style.avatarUrl,
    );
  }

  /// Handle marker tap and convert to FlutterFlow callback
  void _onMarkerTap(MapMarker marker) {
    if (widget.onMarkerTap != null) {
      final ffMarker = _convertToFFMarker(marker);
      widget.onMarkerTap!(ffMarker);
    }
  }

  /// Convert FlutterFlow LatLng to Google Maps LatLng
  gmaps.LatLng? _convertCenter(LatLng? ffLatLng) {
    if (ffLatLng == null) return null;
    return gmaps.LatLng(ffLatLng.latitude, ffLatLng.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return LynewedMapWidget(
      userRole: widget.userRole,
      config: LynewedMapConfig(
        initialCenter: _convertCenter(widget.initialCenter),
        initialZoom: widget.initialZoom,
        enableMyLocation: widget.enableMyLocation,
        enableZoomControls: true,
      ),
      initialFilter: _convertFilters(widget.filters),
      onMarkerTap: _onMarkerTap,
    );
  }
}

/// Extension to easily show FlutterFlow sheets from new markers
extension MapMarkerSheetExtension on MapMarker {
  /// Show appropriate FlutterFlow sheet based on marker type
  Future<void> showDetailsSheet(BuildContext context) async {
    // This will be implemented by the consuming page
    // using the existing FlutterFlow sheet widgets
  }
}

/// Helper class to bridge map data between systems
class MapDataBridge {
  /// Convert new MapSearchResult to FlutterFlow MapdatabundleStruct
  static MapdatabundleStruct toFFBundle(MapSearchResult result) {
    final markers = <MapMarkerStruct>[];
    
    // Convert all markers
    for (final marker in result.allMarkers) {
      markers.add(MapMarkerStruct(
        id: marker.id,
        type: toFlutterFlowType(marker.type),
        latitude: marker.position.latitude,
        longitude: marker.position.longitude,
        label: marker.style.label,
        avatarUrl: marker.style.avatarUrl,
      ));
    }

    return MapdatabundleStruct(
      markers: markers,
      weddingPins: [], // TODO: Convert weddings if needed
      debugStats: 'Converted from new module: ${markers.length} markers',
    );
  }

  /// Convert FlutterFlow MapMarkerStruct to new MapMarker
  static MapMarker? fromFFMarker(MapMarkerStruct? ffMarker) {
    if (ffMarker == null) return null;

    return MapMarker(
      id: ffMarker.id ?? '',
      type: fromFlutterFlowType(ffMarker.type ?? ff_enums.MapMarkerType.professional),
      position: gmaps.LatLng(
        ffMarker.latitude ?? 0,
        ffMarker.longitude ?? 0,
      ),
      style: MarkerStyle(
        label: ffMarker.label,
        avatarUrl: ffMarker.avatarUrl,
      ),
    );
  }
}
