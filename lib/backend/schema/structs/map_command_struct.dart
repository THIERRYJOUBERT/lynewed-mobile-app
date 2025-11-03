// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MapCommandStruct extends BaseStruct {
  MapCommandStruct({
    String? id,
    MapActionType? type,
    LatLng? target,
    List<LatLng>? fitBoundsTo,
  })  : _id = id,
        _type = type,
        _target = target,
        _fitBoundsTo = fitBoundsTo;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "type" field.
  MapActionType? _type;
  MapActionType get type => _type ?? MapActionType.none;
  set type(MapActionType? val) => _type = val;

  bool hasType() => _type != null;

  // "target" field.
  LatLng? _target;
  LatLng? get target => _target;
  set target(LatLng? val) => _target = val;

  bool hasTarget() => _target != null;

  // "fitBoundsTo" field.
  List<LatLng>? _fitBoundsTo;
  List<LatLng> get fitBoundsTo => _fitBoundsTo ?? const [];
  set fitBoundsTo(List<LatLng>? val) => _fitBoundsTo = val;

  void updateFitBoundsTo(Function(List<LatLng>) updateFn) {
    updateFn(_fitBoundsTo ??= []);
  }

  bool hasFitBoundsTo() => _fitBoundsTo != null;

  static MapCommandStruct fromMap(Map<String, dynamic> data) =>
      MapCommandStruct(
        id: data['id'] as String?,
        type: data['type'] is MapActionType
            ? data['type']
            : deserializeEnum<MapActionType>(data['type']),
        target: data['target'] as LatLng?,
        fitBoundsTo: getDataList(data['fitBoundsTo']),
      );

  static MapCommandStruct? maybeFromMap(dynamic data) => data is Map
      ? MapCommandStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'type': _type?.serialize(),
        'target': _target,
        'fitBoundsTo': _fitBoundsTo,
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
        'target': serializeParam(
          _target,
          ParamType.LatLng,
        ),
        'fitBoundsTo': serializeParam(
          _fitBoundsTo,
          ParamType.LatLng,
          isList: true,
        ),
      }.withoutNulls;

  static MapCommandStruct fromSerializableMap(Map<String, dynamic> data) =>
      MapCommandStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        type: deserializeParam<MapActionType>(
          data['type'],
          ParamType.Enum,
          false,
        ),
        target: deserializeParam(
          data['target'],
          ParamType.LatLng,
          false,
        ),
        fitBoundsTo: deserializeParam<LatLng>(
          data['fitBoundsTo'],
          ParamType.LatLng,
          true,
        ),
      );

  @override
  String toString() => 'MapCommandStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is MapCommandStruct &&
        id == other.id &&
        type == other.type &&
        target == other.target &&
        listEquality.equals(fitBoundsTo, other.fitBoundsTo);
  }

  @override
  int get hashCode =>
      const ListEquality().hash([id, type, target, fitBoundsTo]);
}

MapCommandStruct createMapCommandStruct({
  String? id,
  MapActionType? type,
  LatLng? target,
}) =>
    MapCommandStruct(
      id: id,
      type: type,
      target: target,
    );
