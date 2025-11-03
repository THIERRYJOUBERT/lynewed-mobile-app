// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MapMarkerStruct extends BaseStruct {
  MapMarkerStruct({
    String? id,
    MapMarkerType? type,
    LatLng? position,
    MarkerStyleInfoStruct? styleInfo,
  })  : _id = id,
        _type = type,
        _position = position,
        _styleInfo = styleInfo;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "type" field.
  MapMarkerType? _type;
  MapMarkerType? get type => _type;
  set type(MapMarkerType? val) => _type = val;

  bool hasType() => _type != null;

  // "position" field.
  LatLng? _position;
  LatLng? get position => _position;
  set position(LatLng? val) => _position = val;

  bool hasPosition() => _position != null;

  // "styleInfo" field.
  MarkerStyleInfoStruct? _styleInfo;
  MarkerStyleInfoStruct get styleInfo => _styleInfo ?? MarkerStyleInfoStruct();
  set styleInfo(MarkerStyleInfoStruct? val) => _styleInfo = val;

  void updateStyleInfo(Function(MarkerStyleInfoStruct) updateFn) {
    updateFn(_styleInfo ??= MarkerStyleInfoStruct());
  }

  bool hasStyleInfo() => _styleInfo != null;

  static MapMarkerStruct fromMap(Map<String, dynamic> data) => MapMarkerStruct(
        id: data['id'] as String?,
        type: data['type'] is MapMarkerType
            ? data['type']
            : deserializeEnum<MapMarkerType>(data['type']),
        position: data['position'] as LatLng?,
        styleInfo: data['styleInfo'] is MarkerStyleInfoStruct
            ? data['styleInfo']
            : MarkerStyleInfoStruct.maybeFromMap(data['styleInfo']),
      );

  static MapMarkerStruct? maybeFromMap(dynamic data) => data is Map
      ? MapMarkerStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'type': _type?.serialize(),
        'position': _position,
        'styleInfo': _styleInfo?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'type': serializeParam(
          _type,
          ParamType.Enum,
        ),
        'position': serializeParam(
          _position,
          ParamType.LatLng,
        ),
        'styleInfo': serializeParam(
          _styleInfo,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static MapMarkerStruct fromSerializableMap(Map<String, dynamic> data) =>
      MapMarkerStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        type: deserializeParam<MapMarkerType>(
          data['type'],
          ParamType.Enum,
          false,
        ),
        position: deserializeParam(
          data['position'],
          ParamType.LatLng,
          false,
        ),
        styleInfo: deserializeStructParam(
          data['styleInfo'],
          ParamType.DataStruct,
          false,
          structBuilder: MarkerStyleInfoStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'MapMarkerStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MapMarkerStruct &&
        id == other.id &&
        type == other.type &&
        position == other.position &&
        styleInfo == other.styleInfo;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([id, type, position, styleInfo]);
}

MapMarkerStruct createMapMarkerStruct({
  String? id,
  MapMarkerType? type,
  LatLng? position,
  MarkerStyleInfoStruct? styleInfo,
}) =>
    MapMarkerStruct(
      id: id,
      type: type,
      position: position,
      styleInfo: styleInfo ?? MarkerStyleInfoStruct(),
    );
