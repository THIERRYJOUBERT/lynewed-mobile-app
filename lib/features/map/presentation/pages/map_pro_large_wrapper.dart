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

import 'map_page.dart';

/// Wrapper pour MapProLarge - Compatible avec nav.dart FlutterFlow
class MapProLargeWidget extends StatelessWidget {
  const MapProLargeWidget({
    super.key,
    this.initialCenter,
  });

  final gmaps.LatLng? initialCenter;

  /// Route name pour navigation FlutterFlow
  static String routeName = 'MapProLarge';
  
  /// Route path pour navigation FlutterFlow
  static String routePath = '/mapProLarge';

  @override
  Widget build(BuildContext context) {
    return MapPage(
      userRole: 'professional',
      config: MapPageConfig(
        initialCenter: initialCenter,
        showSearchBar: true,
        showFilterButton: true,
        showMyLocationButton: true,
        showLayerToggle: true, // Pro voit les toggles de couches
      ),
    );
  }
}
