// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ViewportinfoStruct extends BaseStruct {
  ViewportinfoStruct({
    double? centerLat,
    double? centerLng,
    double? radiusKm,
    double? neLat,
    double? neLng,
    double? swLat,
    double? swLng,
    double? zoom,
  })  : _centerLat = centerLat,
        _centerLng = centerLng,
        _radiusKm = radiusKm,
        _neLat = neLat,
        _neLng = neLng,
        _swLat = swLat,
        _swLng = swLng,
        _zoom = zoom;

  // "centerLat" field.
  double? _centerLat;
  double get centerLat => _centerLat ?? 0.0;
  set centerLat(double? val) => _centerLat = val;

  void incrementCenterLat(double amount) => centerLat = centerLat + amount;

  bool hasCenterLat() => _centerLat != null;

  // "centerLng" field.
  double? _centerLng;
  double get centerLng => _centerLng ?? 0.0;
  set centerLng(double? val) => _centerLng = val;

  void incrementCenterLng(double amount) => centerLng = centerLng + amount;

  bool hasCenterLng() => _centerLng != null;

  // "radiusKm" field.
  double? _radiusKm;
  double get radiusKm => _radiusKm ?? 0.0;
  set radiusKm(double? val) => _radiusKm = val;

  void incrementRadiusKm(double amount) => radiusKm = radiusKm + amount;

  bool hasRadiusKm() => _radiusKm != null;

  // "neLat" field.
  double? _neLat;
  double get neLat => _neLat ?? 0.0;
  set neLat(double? val) => _neLat = val;

  void incrementNeLat(double amount) => neLat = neLat + amount;

  bool hasNeLat() => _neLat != null;

  // "neLng" field.
  double? _neLng;
  double get neLng => _neLng ?? 0.0;
  set neLng(double? val) => _neLng = val;

  void incrementNeLng(double amount) => neLng = neLng + amount;

  bool hasNeLng() => _neLng != null;

  // "swLat" field.
  double? _swLat;
  double get swLat => _swLat ?? 0.0;
  set swLat(double? val) => _swLat = val;

  void incrementSwLat(double amount) => swLat = swLat + amount;

  bool hasSwLat() => _swLat != null;

  // "swLng" field.
  double? _swLng;
  double get swLng => _swLng ?? 0.0;
  set swLng(double? val) => _swLng = val;

  void incrementSwLng(double amount) => swLng = swLng + amount;

  bool hasSwLng() => _swLng != null;

  // "zoom" field.
  double? _zoom;
  double get zoom => _zoom ?? 0.0;
  set zoom(double? val) => _zoom = val;

  void incrementZoom(double amount) => zoom = zoom + amount;

  bool hasZoom() => _zoom != null;

  static ViewportinfoStruct fromMap(Map<String, dynamic> data) =>
      ViewportinfoStruct(
        centerLat: castToType<double>(data['centerLat']),
        centerLng: castToType<double>(data['centerLng']),
        radiusKm: castToType<double>(data['radiusKm']),
        neLat: castToType<double>(data['neLat']),
        neLng: castToType<double>(data['neLng']),
        swLat: castToType<double>(data['swLat']),
        swLng: castToType<double>(data['swLng']),
        zoom: castToType<double>(data['zoom']),
      );

  static ViewportinfoStruct? maybeFromMap(dynamic data) => data is Map
      ? ViewportinfoStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'centerLat': _centerLat,
        'centerLng': _centerLng,
        'radiusKm': _radiusKm,
        'neLat': _neLat,
        'neLng': _neLng,
        'swLat': _swLat,
        'swLng': _swLng,
        'zoom': _zoom,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'centerLat': serializeParam(
          _centerLat,
          ParamType.double,
        ),
        'centerLng': serializeParam(
          _centerLng,
          ParamType.double,
        ),
        'radiusKm': serializeParam(
          _radiusKm,
          ParamType.double,
        ),
        'neLat': serializeParam(
          _neLat,
          ParamType.double,
        ),
        'neLng': serializeParam(
          _neLng,
          ParamType.double,
        ),
        'swLat': serializeParam(
          _swLat,
          ParamType.double,
        ),
        'swLng': serializeParam(
          _swLng,
          ParamType.double,
        ),
        'zoom': serializeParam(
          _zoom,
          ParamType.double,
        ),
      }.withoutNulls;

  static ViewportinfoStruct fromSerializableMap(Map<String, dynamic> data) =>
      ViewportinfoStruct(
        centerLat: deserializeParam(
          data['centerLat'],
          ParamType.double,
          false,
        ),
        centerLng: deserializeParam(
          data['centerLng'],
          ParamType.double,
          false,
        ),
        radiusKm: deserializeParam(
          data['radiusKm'],
          ParamType.double,
          false,
        ),
        neLat: deserializeParam(
          data['neLat'],
          ParamType.double,
          false,
        ),
        neLng: deserializeParam(
          data['neLng'],
          ParamType.double,
          false,
        ),
        swLat: deserializeParam(
          data['swLat'],
          ParamType.double,
          false,
        ),
        swLng: deserializeParam(
          data['swLng'],
          ParamType.double,
          false,
        ),
        zoom: deserializeParam(
          data['zoom'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'ViewportinfoStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ViewportinfoStruct &&
        centerLat == other.centerLat &&
        centerLng == other.centerLng &&
        radiusKm == other.radiusKm &&
        neLat == other.neLat &&
        neLng == other.neLng &&
        swLat == other.swLat &&
        swLng == other.swLng &&
        zoom == other.zoom;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([centerLat, centerLng, radiusKm, neLat, neLng, swLat, swLng, zoom]);
}

ViewportinfoStruct createViewportinfoStruct({
  double? centerLat,
  double? centerLng,
  double? radiusKm,
  double? neLat,
  double? neLng,
  double? swLat,
  double? swLng,
  double? zoom,
}) =>
    ViewportinfoStruct(
      centerLat: centerLat,
      centerLng: centerLng,
      radiusKm: radiusKm,
      neLat: neLat,
      neLng: neLng,
      swLat: swLat,
      swLng: swLng,
      zoom: zoom,
    );
