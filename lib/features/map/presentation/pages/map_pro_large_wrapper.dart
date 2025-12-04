/// MapProLarge Wrapper - Compatibilité avec navigation FlutterFlow
/// 
/// Ce wrapper maintient la compatibilité avec les routes existantes
/// tout en déléguant à MapPage (nouveau module Clean Architecture).
/// 
/// À terme, ce wrapper pourra être supprimé quand la navigation sera
/// entièrement migrée vers le nouveau système.
library;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '/flutter_flow/lat_lng.dart' as ff;

import 'map_page.dart';

/// Wrapper pour MapProLarge - Compatible avec nav.dart FlutterFlow
class MapProLargeWidget extends StatelessWidget {
  const MapProLargeWidget({
    super.key,
    this.initialCenter,
  });

  /// Accepts both FlutterFlow LatLng and Google Maps LatLng
  final dynamic initialCenter;

  /// Route name pour navigation FlutterFlow
  static String routeName = 'MapProLarge';
  
  /// Route path pour navigation FlutterFlow
  static String routePath = '/mapProLarge';

  /// Convert any LatLng type to Google Maps LatLng
  gmaps.LatLng? _convertToGmapsLatLng(dynamic center) {
    if (center == null) return null;
    
    // Already Google Maps LatLng
    if (center is gmaps.LatLng) return center;
    
    // FlutterFlow LatLng
    if (center is ff.LatLng) {
      return gmaps.LatLng(center.latitude, center.longitude);
    }
    
    // Try duck typing for any object with latitude/longitude
    try {
      final lat = (center as dynamic).latitude as double;
      final lng = (center as dynamic).longitude as double;
      return gmaps.LatLng(lat, lng);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapPage(
      userRole: 'professional',
      config: MapPageConfig(
        initialCenter: _convertToGmapsLatLng(initialCenter),
        showSearchBar: true,
        showFilterButton: true,
        showMyLocationButton: true,
        showLayerToggle: true, // Pro voit les toggles de couches
      ),
    );
  }
}
