/// Mapper between new MapMarkerType and legacy FlutterFlow enum
/// 
/// Provides compatibility layer during migration from FlutterFlow code.
library;

import '/backend/schema/enums/enums.dart' as ff;
import '../../domain/entities/map_marker.dart';

/// Convertit le nouveau enum vers l'ancien (FlutterFlow)
/// Note: professional FF est mappé vers proFixedLocation (fusion)
ff.MapMarkerType toFlutterFlowType(MapMarkerType type) {
  switch (type) {
    case MapMarkerType.proFixedLocation:
      return ff.MapMarkerType.proFixedLocation;
    case MapMarkerType.professionalAlert:
      return ff.MapMarkerType.professionalAlert;
    case MapMarkerType.wedding:
      return ff.MapMarkerType.weddingPin; // Mapping wedding → weddingPin
    case MapMarkerType.marketplaceItem:
      // EPIC-13 APP-07: Marketplace items - no FF equivalent, fallback
      return ff.MapMarkerType.proFixedLocation;
  }
}

/// Convertit l'ancien enum (FlutterFlow) vers le nouveau
/// Note: professional FF est mappé vers proFixedLocation (fusion)
/// Phase 5: poiPrivate removed, maps to proFixedLocation as fallback
MapMarkerType fromFlutterFlowType(ff.MapMarkerType type) {
  switch (type) {
    case ff.MapMarkerType.professional:
      return MapMarkerType.proFixedLocation; // Fusionné → proFixedLocation
    case ff.MapMarkerType.proFixedLocation:
      return MapMarkerType.proFixedLocation;
    case ff.MapMarkerType.professionalAlert:
      return MapMarkerType.professionalAlert;
    case ff.MapMarkerType.weddingPin:
      return MapMarkerType.wedding; // Mapping weddingPin → wedding
    case ff.MapMarkerType.poiPrivate:
      return MapMarkerType.proFixedLocation; // Deprecated, fallback
  }
}

/// Convertit une string Supabase vers le nouveau enum
/// Note: 'professional' est mappé vers proFixedLocation (fusion)
/// Phase 5: poiPrivate removed from enum
MapMarkerType? markerTypeFromString(String? value) {
  if (value == null) return null;
  switch (value.toLowerCase()) {
    case 'professional':
    case 'profixedlocation':
    case 'pro_fixed_location':
    case 'fixedlocation':
    case 'fixed_location':
      return MapMarkerType.proFixedLocation; // Tout vers proFixedLocation
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
      return null; // Deprecated, no longer supported
    case 'marketplaceitem':
    case 'marketplace_item':
    case 'marketplace':
      return MapMarkerType.marketplaceItem; // EPIC-13 APP-07
    default:
      return null;
  }
}
