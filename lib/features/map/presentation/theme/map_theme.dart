/// Map theme configuration
/// 
/// Centralized styling for map markers, colors, and visual elements.
library;

import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// Configuration des couleurs par type de marqueur
class MapMarkerColors {
  MapMarkerColors._();

  // Professionals
  static const professional = Color(0xFF2196F3); // Blue
  static const proFixedLocation = Color(0xFF4CAF50); // Green

  // Alerts
  static const alert = Color(0xFFFF5722); // Deep Orange
  static const alertBackupNeeded = Color(0xFFFF9800); // Orange
  static const alertGearEmergency = Color(0xFFF44336); // Red
  static const alertTeamMember = Color(0xFF9C27B0); // Purple
  static const alertEmergencyHelp = Color(0xFFE91E63); // Pink

  // Wedding
  static const wedding = Color(0xFFE91E63); // Pink
  static const weddingVisible = Color(0xFFD81B60); // Dark Pink

  // POI (deprecated)
  static const poiPrivate = Color(0xFF9C27B0); // Purple

  /// Couleur par type de marqueur
  static Color forMarkerType(MapMarkerType type) {
    switch (type) {
      case MapMarkerType.proFixedLocation:
        return proFixedLocation;
      case MapMarkerType.professionalAlert:
        return alert;
      case MapMarkerType.wedding:
        return wedding;
      case MapMarkerType.poiPrivate:
        return poiPrivate;
    }
  }

  /// Couleur par type d'alerte
  static Color forAlertType(AlertType type) {
    switch (type) {
      case AlertType.backupNeeded:
        return alertBackupNeeded;
      case AlertType.gearEmergency:
        return alertGearEmergency;
      case AlertType.teamMember:
        return alertTeamMember;
      case AlertType.emergencyHelp:
        return alertEmergencyHelp;
      case AlertType.other:
        return alert;
    }
  }

  /// Couleur par profession
  static Color forProfession(Profession profession) {
    switch (profession) {
      case Profession.photographer:
        return const Color(0xFF2196F3); // Blue
      case Profession.videographer:
        return const Color(0xFF9C27B0); // Purple
      case Profession.weddingPlanner:
        return const Color(0xFF4CAF50); // Green
      case Profession.venue:
        return const Color(0xFFFF9800); // Orange
      case Profession.caterer:
        return const Color(0xFF795548); // Brown
      case Profession.dj:
        return const Color(0xFFE91E63); // Pink
      case Profession.florist:
        return const Color(0xFF8BC34A); // Light Green
      case Profession.makeupArtist:
        return const Color(0xFFEC407A); // Pink 400
      case Profession.hairStylist:
        return const Color(0xFFFF4081); // Pink Accent
      case Profession.officiant:
        return const Color(0xFF673AB7); // Deep Purple
      case Profession.rentals:
        return const Color(0xFF00BCD4); // Cyan
      case Profession.transportation:
        return const Color(0xFF607D8B); // Blue Grey
      case Profession.stationery:
        return const Color(0xFFFFEB3B); // Yellow
      case Profession.cake:
        return const Color(0xFFFFCDD2); // Pink 100
      case Profession.jewelry:
        return const Color(0xFFFFD700); // Gold
      case Profession.attire:
        return const Color(0xFF9E9E9E); // Grey
      case Profession.musician:
        return const Color(0xFF3F51B5); // Indigo
      case Profession.other:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }
}

/// Configuration des tailles de marqueurs
class MapMarkerSizes {
  MapMarkerSizes._();

  // Tailles par défaut
  static const double defaultSize = 40.0;
  static const double smallSize = 32.0;
  static const double largeSize = 56.0;

  // Tailles par type
  static const double professional = 44.0;
  static const double proFixedLocation = 40.0;
  static const double alert = 48.0;
  static const double wedding = 44.0;
  static const double poi = 36.0;

  /// Taille par type de marqueur
  static double forMarkerType(MapMarkerType type) {
    switch (type) {
      case MapMarkerType.proFixedLocation:
        return proFixedLocation;
      case MapMarkerType.professionalAlert:
        return alert;
      case MapMarkerType.wedding:
        return wedding;
      case MapMarkerType.poiPrivate:
        return poi;
    }
  }

  /// Taille adaptée au zoom
  static double forZoom(double zoom, MapMarkerType type) {
    final baseSize = forMarkerType(type);
    
    // Scale: 24px at zoom 5, 56px at zoom 18
    final scale = (zoom - 5) / 13; // 0 to 1
    final clampedScale = scale.clamp(0.0, 1.0);
    
    return baseSize * (0.6 + 0.4 * clampedScale);
  }
}

/// Z-index par type de marqueur (ordre d'affichage)
class MapMarkerZIndex {
  MapMarkerZIndex._();

  static const double alert = 5.0;
  static const double wedding = 4.0;
  static const double professional = 3.0;
  static const double proFixedLocation = 2.0;
  static const double poi = 1.0;

  /// Z-index par type
  static double forMarkerType(MapMarkerType type) {
    switch (type) {
      case MapMarkerType.professionalAlert:
        return alert;
      case MapMarkerType.wedding:
        return wedding;
      case MapMarkerType.proFixedLocation:
        return proFixedLocation;
      case MapMarkerType.poiPrivate:
        return poi;
    }
  }
}

/// Styles de map Google Maps
class MapStyles {
  MapStyles._();

  /// Style par défaut (clair)
  static const String light = '''
[
  {
    "featureType": "poi",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  }
]
''';

  /// Style sombre
  static const String dark = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#746855"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#38414e"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#17263c"}]
  }
]
''';

  /// Style minimaliste
  static const String minimal = '''
[
  {
    "featureType": "all",
    "elementType": "labels",
    "stylers": [{"visibility": "simplified"}]
  },
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "transit",
    "stylers": [{"visibility": "off"}]
  }
]
''';
}

/// Extension pour faciliter l'accès aux couleurs
extension MapMarkerTypeColors on MapMarkerType {
  Color get color => MapMarkerColors.forMarkerType(this);
  double get size => MapMarkerSizes.forMarkerType(this);
  double get zIndex => MapMarkerZIndex.forMarkerType(this);
}

extension ProfessionColors on Profession {
  Color get color => MapMarkerColors.forProfession(this);
}

extension AlertTypeColors on AlertType {
  Color get color => MapMarkerColors.forAlertType(this);
}
