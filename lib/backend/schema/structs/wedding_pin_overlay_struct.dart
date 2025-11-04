// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WeddingPinOverlayStruct extends BaseStruct {
  WeddingPinOverlayStruct({
    String? id,
    LatLng? center,
    int? radiusKm,
  })  : _id = id,
        _center = center,
        _radiusKm = radiusKm;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "center" field.
  LatLng? _center;
  LatLng? get center => _center;
  set center(LatLng? val) => _center = val;

  bool hasCenter() => _center != null;

  // "radiusKm" field.
  int? _radiusKm;
  int get radiusKm => _radiusKm ?? 0;
  set radiusKm(int? val) => _radiusKm = val;

  void incrementRadiusKm(int amount) => radiusKm = radiusKm + amount;

  bool hasRadiusKm() => _radiusKm != null;

  static WeddingPinOverlayStruct fromMap(Map<String, dynamic> data) =>
      WeddingPinOverlayStruct(
        id: data['id'] as String?,
        center: data['center'] as LatLng?,
        radiusKm: castToType<int>(data['radiusKm']),
      );

  static WeddingPinOverlayStruct? maybeFromMap(dynamic data) => data is Map
      ? WeddingPinOverlayStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'center': _center,
        'radiusKm': _radiusKm,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'center': serializeParam(
          _center,
          ParamType.LatLng,
        ),
        'radiusKm': serializeParam(
          _radiusKm,
          ParamType.int,
        ),
      }.withoutNulls;

  static WeddingPinOverlayStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      WeddingPinOverlayStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        center: deserializeParam(
          data['center'],
          ParamType.LatLng,
          false,
        ),
        radiusKm: deserializeParam(
          data['radiusKm'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'WeddingPinOverlayStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is WeddingPinOverlayStruct &&
        id == other.id &&
        center == other.center &&
        radiusKm == other.radiusKm;
  }

  @override
  int get hashCode => const ListEquality().hash([id, center, radiusKm]);
}

WeddingPinOverlayStruct createWeddingPinOverlayStruct({
  String? id,
  LatLng? center,
  int? radiusKm,
}) =>
    WeddingPinOverlayStruct(
      id: id,
      center: center,
      radiusKm: radiusKm,
    );
