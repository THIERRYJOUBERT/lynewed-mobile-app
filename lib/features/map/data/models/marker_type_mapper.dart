/// Mapper between new MapMarkerType and legacy FlutterFlow enum
/// 
/// Provides compatibility layer during migration from FlutterFlow code.
library;

import '/backend/schema/enums/enums.dart' as ff;
import '../../domain/entities/map_marker.dart';

/// Convertit le nouveau enum vers l'ancien (FlutterFlow)
ff.MapMarkerType toFlutterFlowType(MapMarkerType type) {
  switch (type) {
    case MapMarkerType.professional:
      return ff.MapMarkerType.professional;
    case MapMarkerType.proFixedLocation:
      return ff.MapMarkerType.proFixedLocation;
    case MapMarkerType.professionalAlert:
      return ff.MapMarkerType.professionalAlert;
    case MapMarkerType.wedding:
      return ff.MapMarkerType.weddingPin; // Mapping wedding → weddingPin
    case MapMarkerType.poiPrivate:
      return ff.MapMarkerType.poiPrivate;
  }
}

/// Convertit l'ancien enum (FlutterFlow) vers le nouveau
MapMarkerType fromFlutterFlowType(ff.MapMarkerType type) {
  switch (type) {
    case ff.MapMarkerType.professional:
      return MapMarkerType.professional;
    case ff.MapMarkerType.proFixedLocation:
      return MapMarkerType.proFixedLocation;
    case ff.MapMarkerType.professionalAlert:
      return MapMarkerType.professionalAlert;
    case ff.MapMarkerType.weddingPin:
      return MapMarkerType.wedding; // Mapping weddingPin → wedding
    case ff.MapMarkerType.poiPrivate:
      return MapMarkerType.poiPrivate;
  }
}

/// Convertit une string Supabase vers le nouveau enum
MapMarkerType? markerTypeFromString(String? value) {
  if (value == null) return null;
  switch (value.toLowerCase()) {
    case 'professional':
      return MapMarkerType.professional;
    case 'profixedlocation':
    case 'pro_fixed_location':
    case 'fixedlocation':
    case 'fixed_location':
      return MapMarkerType.proFixedLocation;
    case 'professionalalert':
    case 'professional_alert':
    case 'alert':
      return MapMarkerType.professionalAlert;
    case 'wedding':
    case 'weddingpin':
    case 'wedding_pin':
      return MapMarkerType.wedding;
    case 'poiprivate':
    case 'poi_private':
    case 'poi':
      return MapMarkerType.poiPrivate;
    default:
      return null;
  }
}
