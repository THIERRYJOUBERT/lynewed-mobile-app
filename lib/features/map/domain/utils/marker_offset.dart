/// Marker offset utilities for handling overlapping markers
/// 
/// Applies circular offset for markers that are too close to each other
/// to ensure all markers remain individually tappable.
library;

import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../entities/map_marker.dart';

/// Configuration for marker offset calculations
class MarkerOffsetConfig {
  const MarkerOffsetConfig({
    this.proximityThresholdMeters = 20.0,
    this.offsetDistanceMeters = 12.0,
  });

  /// Distance threshold to consider markers as overlapping
  final double proximityThresholdMeters;

  /// Distance to offset overlapping markers
  final double offsetDistanceMeters;

  /// Convert meters to degrees (approximate)
  double get metersToDegrees => proximityThresholdMeters / 111320.0;
  double get offsetToDegrees => offsetDistanceMeters / 111320.0;
}

/// Applies circular offset to overlapping markers
/// 
/// Algorithm:
/// 1. Group markers that are within proximity threshold
/// 2. For each group > 1 marker:
///    - Keep first marker at original position
///    - Apply circular offset to additional markers
/// 
/// Returns a new list with adjusted positions
List<T> applyProximityOffset<T>(
  List<T> markers,
  gmaps.LatLng Function(T) getPosition,
  T Function(T, gmaps.LatLng) updatePosition, {
  MarkerOffsetConfig config = const MarkerOffsetConfig(),
}) {
  if (markers.length <= 1) return markers;

  final result = <T>[];
  final processed = <int>{};

  for (int i = 0; i < markers.length; i++) {
    if (processed.contains(i)) continue;

    final marker = markers[i];
    final position = getPosition(marker);
    
    // Find all markers close to this one
    final closeMarkers = <int>[];
    closeMarkers.add(i);

    for (int j = i + 1; j < markers.length; j++) {
      if (processed.contains(j)) continue;
      
      final otherPosition = getPosition(markers[j]);
      if (_areMarkersClose(position, otherPosition, config)) {
        closeMarkers.add(j);
      }
    }

    // Apply offset if we have overlapping markers
    if (closeMarkers.length > 1) {
      for (int k = 0; k < closeMarkers.length; k++) {
        final index = closeMarkers[k];
        final originalMarker = markers[index];
        final originalPosition = getPosition(originalMarker);

        if (k == 0) {
          // First marker stays at original position
          result.add(originalMarker);
        } else {
          // Apply circular offset
          final offsetPosition = _applyCircularOffset(
            originalPosition,
            k,
            closeMarkers.length,
            config,
          );
          result.add(updatePosition(originalMarker, offsetPosition));
        }
        
        processed.add(index);
      }
    } else {
      // No overlap, keep original
      result.add(marker);
      processed.add(i);
    }
  }

  return result;
}

/// Checks if two markers are within proximity threshold
bool _areMarkersClose(
  gmaps.LatLng a,
  gmaps.LatLng b,
  MarkerOffsetConfig config,
) {
  final latDiff = (a.latitude - b.latitude).abs();
  final lngDiff = (a.longitude - b.longitude).abs();
  
  return latDiff < config.metersToDegrees && lngDiff < config.metersToDegrees;
}

/// Applies circular offset to a marker position
gmaps.LatLng _applyCircularOffset(
  gmaps.LatLng original,
  int index,
  int totalAtLocation,
  MarkerOffsetConfig config,
) {
  if (totalAtLocation <= 1) return original;

  final angle = (2 * pi * index) / totalAtLocation;
  final offsetDegrees = config.offsetToDegrees;

  return gmaps.LatLng(
    original.latitude + offsetDegrees * cos(angle),
    original.longitude + offsetDegrees * sin(angle),
  );
}

/// Extension for easy offset application on MapMarker
extension MapMarkerOffset on List<MapMarker> {
  /// Apply proximity offset to a list of markers
  List<MapMarker> withProximityOffset({
    MarkerOffsetConfig config = const MarkerOffsetConfig(),
  }) {
    if (isEmpty) return this;
    
    return applyProximityOffset<MapMarker>(
      this,
      (marker) => marker.position,
      (marker, newPosition) => marker.copyWith(position: newPosition),
      config: config,
    );
  }
}
