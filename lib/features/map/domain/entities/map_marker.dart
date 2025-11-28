/// Map marker entity - Clean replacement for MapMarkerStruct
/// 
/// Replaces FlutterFlow's verbose 147-line MapMarkerStruct with a clean,
/// immutable data class using modern Dart patterns.
library;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Types de marqueurs sur la map
/// 
/// Enum final après refactorisation Phase 5 (8→3 valeurs):
/// - Supprimés: user, proRecent, searchTarget, professional, poiPrivate
/// - Fusionné: professional + fixedLocation → proFixedLocation
/// - Remplacé: weddingPin → wedding (hub central per bride)
/// - Source unique: professional_fixed_locations (plus de professional_details.location_coords)
enum MapMarkerType {
  /// Position fixe d'un professionnel (depuis professional_fixed_locations uniquement)
  /// Remplace l'ancien professional + fixedLocation
  proFixedLocation,
  
  /// Alerte communautaire d'un professionnel
  professionalAlert,
  
  /// Mariage visible sur la map (hub central per bride)
  /// Phase 5: Remplace weddingPin, utilise nouvelle table `weddings`
  wedding,
}

/// Style visuel d'un marqueur
@immutable
class MarkerStyle {
  const MarkerStyle({
    this.avatarUrl,
    this.borderColorHex,
    this.label,
    this.iconAsset,
    this.profileId,
  });

  final String? avatarUrl;
  final String? borderColorHex;
  final String? label;
  final String? iconAsset;
  /// ID du profil associé (pour la navigation si marker.id != profile.id)
  final String? profileId;

  MarkerStyle copyWith({
    String? avatarUrl,
    String? borderColorHex,
    String? label,
    String? iconAsset,
    String? profileId,
  }) {
    return MarkerStyle(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      borderColorHex: borderColorHex ?? this.borderColorHex,
      label: label ?? this.label,
      iconAsset: iconAsset ?? this.iconAsset,
      profileId: profileId ?? this.profileId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkerStyle &&
        other.avatarUrl == avatarUrl &&
        other.borderColorHex == borderColorHex &&
        other.label == label &&
        other.iconAsset == iconAsset &&
        other.profileId == profileId;
  }

  @override
  int get hashCode => Object.hash(avatarUrl, borderColorHex, label, iconAsset, profileId);
}

/// Marqueur de map immutable et léger
/// 
/// Remplace MapMarkerStruct (147 lignes) par une classe de ~80 lignes
/// avec support natif pour Google Maps.
@immutable
class MapMarker {
  const MapMarker({
    required this.id,
    required this.type,
    required this.position,
    this.style = const MarkerStyle(),
    this.metadata = const {},
  });

  /// Identifiant unique (UUID du pro, de l'alerte, ou du mariage)
  final String id;

  /// Type de marqueur détermine l'affichage et le comportement au tap
  final MapMarkerType type;

  /// Position GPS
  final gmaps.LatLng position;

  /// Style visuel (avatar, couleur bordure, label)
  final MarkerStyle style;

  /// Métadonnées additionnelles (profession, nom, etc.)
  final Map<String, dynamic> metadata;

  /// Conversion vers LatLng FlutterFlow pour compatibilité
  /// TODO: Supprimer quand migration complète
  // LatLng get ffLatLng => LatLng(position.latitude, position.longitude);

  MapMarker copyWith({
    String? id,
    MapMarkerType? type,
    gmaps.LatLng? position,
    MarkerStyle? style,
    Map<String, dynamic>? metadata,
  }) {
    return MapMarker(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      style: style ?? this.style,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapMarker &&
        other.id == id &&
        other.type == type &&
        other.position == position &&
        other.style == style &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(id, type, position, style, metadata);

  @override
  String toString() => 'MapMarker($id, $type, ${position.latitude},${position.longitude})';
}
