/// FlutterFlow Integration Adapter for Map Module
/// 
/// DEPRECATED: This adapter is being phased out as we migrate away from FlutterFlow.
/// Use LynewedMapWidget directly instead.
/// 
/// Phase 5: Simplified to avoid compilation errors with changing FF structures.
library;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

// New map module imports
import '../domain/entities/entities.dart';
import '../presentation/widgets/lynewed_map_widget.dart';

/// Callback types for integration
typedef MarkerTapCallback = void Function(MapMarker marker);

/// Simplified adapter widget that wraps the new LynewedMapWidget
/// 
/// DEPRECATED: Use LynewedMapWidget directly for new code.
@Deprecated('Use LynewedMapWidget directly. This adapter will be removed.')
class FlutterFlowMapAdapter extends StatelessWidget {
  const FlutterFlowMapAdapter({
    super.key,
    required this.userRole,
    this.initialCenter,
    this.initialZoom = 12.0,
    this.onMarkerTap,
    this.enableMyLocation = true,
  });

  /// User role ('bride' or 'professional')
  final String userRole;

  /// Initial map center (Google Maps LatLng)
  final gmaps.LatLng? initialCenter;

  /// Initial zoom level
  final double initialZoom;

  /// Callback when marker is tapped
  final MarkerTapCallback? onMarkerTap;

  /// Enable my location layer
  final bool enableMyLocation;

  @override
  Widget build(BuildContext context) {
    return LynewedMapWidget(
      userRole: userRole,
      config: LynewedMapConfig(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        enableMyLocation: enableMyLocation,
        enableZoomControls: true,
      ),
      onMarkerTap: onMarkerTap,
    );
  }
}

/// Extension to easily show sheets from markers
extension MapMarkerSheetExtension on MapMarker {
  /// Show appropriate sheet based on marker type
  Future<void> showDetailsSheet(BuildContext context) async {
    // Implemented by the consuming page using new sheet widgets
  }
}
