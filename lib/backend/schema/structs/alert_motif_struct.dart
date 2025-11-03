// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AlertMotifStruct extends BaseStruct {
  AlertMotifStruct({
    String? code,
    String? name,
  })  : _code = code,
        _name = name;

  // "code" field.
  String? _code;
  String get code => _code ?? '';
  set code(String? val) => _code = val;

  bool hasCode() => _code != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  static AlertMotifStruct fromMap(Map<String, dynamic> data) =>
      AlertMotifStruct(
        code: data['code'] as String?,
        name: data['name'] as String?,
      );

  static AlertMotifStruct? maybeFromMap(dynamic data) => data is Map
      ? AlertMotifStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'code': _code,
        'name': _name,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'code': serializeParam(
          _code,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
      }.withoutNulls;

  static AlertMotifStruct fromSerializableMap(Map<String, dynamic> data) =>
      AlertMotifStruct(
        code: deserializeParam(
          data['code'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'AlertMotifStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AlertMotifStruct &&
        code == other.code &&
        name == other.name;
  }

  @override
  int get hashCode => const ListEquality().hash([code, name]);
}

AlertMotifStruct createAlertMotifStruct({
  String? code,
  String? name,
}) =>
    AlertMotifStruct(
      code: code,
      name: name,
    );
