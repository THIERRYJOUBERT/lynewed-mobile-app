// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PoiItemDataStruct extends BaseStruct {
  PoiItemDataStruct({
    String? poiId,
    String? label,
    DateTime? createdAt,
  })  : _poiId = poiId,
        _label = label,
        _createdAt = createdAt;

  // "poiId" field.
  String? _poiId;
  String get poiId => _poiId ?? '';
  set poiId(String? val) => _poiId = val;

  bool hasPoiId() => _poiId != null;

  // "label" field.
  String? _label;
  String get label => _label ?? '';
  set label(String? val) => _label = val;

  bool hasLabel() => _label != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  static PoiItemDataStruct fromMap(Map<String, dynamic> data) =>
      PoiItemDataStruct(
        poiId: data['poiId'] as String?,
        label: data['label'] as String?,
        createdAt: data['createdAt'] as DateTime?,
      );

  static PoiItemDataStruct? maybeFromMap(dynamic data) => data is Map
      ? PoiItemDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'poiId': _poiId,
        'label': _label,
        'createdAt': _createdAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'poiId': serializeParam(
          _poiId,
          ParamType.String,
        ),
        'label': serializeParam(
          _label,
          ParamType.String,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static PoiItemDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      PoiItemDataStruct(
        poiId: deserializeParam(
          data['poiId'],
          ParamType.String,
          false,
        ),
        label: deserializeParam(
          data['label'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
      );

  @override
  String toString() => 'PoiItemDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PoiItemDataStruct &&
        poiId == other.poiId &&
        label == other.label &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode => const ListEquality().hash([poiId, label, createdAt]);
}

PoiItemDataStruct createPoiItemDataStruct({
  String? poiId,
  String? label,
  DateTime? createdAt,
}) =>
    PoiItemDataStruct(
      poiId: poiId,
      label: label,
      createdAt: createdAt,
    );
