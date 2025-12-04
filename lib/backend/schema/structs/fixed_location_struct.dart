// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Fixed location struct with id, label, and coordinates
/// 
/// Represents a professional's fixed location with:
/// - id: Unique identifier from backend
/// - label: Human-readable address (e.g., "15 Rue de Rivoli, 75001 Paris")
/// - latitude/longitude: Coordinates for map display
/// 
/// Backend format (from get_pro_item_details RPC):
/// ```json
/// {
///   "id": "uuid-location-1",
///   "label": "15 Rue de Rivoli, 75001 Paris, France",
///   "type": "Point",
///   "coordinates": [2.3522, 48.8566]
/// }
/// ```
class FixedLocationStruct extends BaseStruct {
  FixedLocationStruct({
    String? id,
    String? label,
    double? latitude,
    double? longitude,
  })  : _id = id,
        _label = label,
        _latitude = latitude,
        _longitude = longitude;

  // "id" field - unique identifier from backend
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;
  bool hasId() => _id != null;

  // "label" field - human-readable address
  String? _label;
  String get label => _label ?? '';
  set label(String? val) => _label = val;
  bool hasLabel() => _label != null;

  // "latitude" field
  double? _latitude;
  double get latitude => _latitude ?? 0.0;
  set latitude(double? val) => _latitude = val;
  bool hasLatitude() => _latitude != null;

  // "longitude" field
  double? _longitude;
  double get longitude => _longitude ?? 0.0;
  set longitude(double? val) => _longitude = val;
  bool hasLongitude() => _longitude != null;

  /// Convert to LatLng for backward compatibility
  /// Used by existing code that expects List<LatLng>
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// Check if coordinates are valid
  bool get hasValidCoordinates =>
      _latitude != null &&
      _longitude != null &&
      _latitude != 0.0 &&
      _longitude != 0.0;

  /// Factory from GeoJSON format (backend response)
  /// 
  /// Handles both formats:
  /// - New format: { id, label, type, coordinates }
  /// - Legacy format: { type, coordinates } (no id/label)
  static FixedLocationStruct? fromGeoJson(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    try {
      // Extract coordinates from GeoJSON Point format
      double? lat;
      double? lng;

      if (data['type'] == 'Point' && data['coordinates'] is List) {
        final coords = data['coordinates'] as List;
        if (coords.length >= 2) {
          lng = (coords[0] as num).toDouble(); // GeoJSON: [lng, lat]
          lat = (coords[1] as num).toDouble();
        }
      }

      if (lat == null || lng == null) return null;

      return FixedLocationStruct(
        id: data['id']?.toString(),
        label: data['label']?.toString(),
        latitude: lat,
        longitude: lng,
      );
    } catch (_) {
      return null;
    }
  }

  static FixedLocationStruct fromMap(Map<String, dynamic> data) =>
      FixedLocationStruct(
        id: data['id'] as String?,
        label: data['label'] as String?,
        latitude: castToType<double>(data['latitude']),
        longitude: castToType<double>(data['longitude']),
      );

  static FixedLocationStruct? maybeFromMap(dynamic data) => data is Map
      ? FixedLocationStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'label': _label,
        'latitude': _latitude,
        'longitude': _longitude,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(_id, ParamType.String),
        'label': serializeParam(_label, ParamType.String),
        'latitude': serializeParam(_latitude, ParamType.double),
        'longitude': serializeParam(_longitude, ParamType.double),
      }.withoutNulls;

  static FixedLocationStruct fromSerializableMap(Map<String, dynamic> data) =>
      FixedLocationStruct(
        id: deserializeParam(data['id'], ParamType.String, false),
        label: deserializeParam(data['label'], ParamType.String, false),
        latitude: deserializeParam(data['latitude'], ParamType.double, false),
        longitude: deserializeParam(data['longitude'], ParamType.double, false),
      );

  @override
  String toString() => 'FixedLocationStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is FixedLocationStruct &&
        id == other.id &&
        label == other.label &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode => const ListEquality().hash([id, label, latitude, longitude]);
}

/// Helper function to create a FixedLocationStruct
FixedLocationStruct createFixedLocationStruct({
  String? id,
  String? label,
  double? latitude,
  double? longitude,
}) =>
    FixedLocationStruct(
      id: id,
      label: label,
      latitude: latitude,
      longitude: longitude,
    );
