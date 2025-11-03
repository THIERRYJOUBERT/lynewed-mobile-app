// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MarkerStyleInfoStruct extends BaseStruct {
  MarkerStyleInfoStruct({
    String? avatarUrl,
    String? borderColorHex,
    bool? isOwn,
  })  : _avatarUrl = avatarUrl,
        _borderColorHex = borderColorHex,
        _isOwn = isOwn;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  set avatarUrl(String? val) => _avatarUrl = val;

  bool hasAvatarUrl() => _avatarUrl != null;

  // "borderColorHex" field.
  String? _borderColorHex;
  String get borderColorHex => _borderColorHex ?? '';
  set borderColorHex(String? val) => _borderColorHex = val;

  bool hasBorderColorHex() => _borderColorHex != null;

  // "isOwn" field.
  bool? _isOwn;
  bool get isOwn => _isOwn ?? false;
  set isOwn(bool? val) => _isOwn = val;

  bool hasIsOwn() => _isOwn != null;

  static MarkerStyleInfoStruct fromMap(Map<String, dynamic> data) =>
      MarkerStyleInfoStruct(
        avatarUrl: data['avatarUrl'] as String?,
        borderColorHex: data['borderColorHex'] as String?,
        isOwn: data['isOwn'] as bool?,
      );

  static MarkerStyleInfoStruct? maybeFromMap(dynamic data) => data is Map
      ? MarkerStyleInfoStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'avatarUrl': _avatarUrl,
        'borderColorHex': _borderColorHex,
        'isOwn': _isOwn,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'avatarUrl': serializeParam(
          _avatarUrl,
          ParamType.String,
        ),
        'borderColorHex': serializeParam(
          _borderColorHex,
          ParamType.String,
        ),
        'isOwn': serializeParam(
          _isOwn,
          ParamType.bool,
        ),
      }.withoutNulls;

  static MarkerStyleInfoStruct fromSerializableMap(Map<String, dynamic> data) =>
      MarkerStyleInfoStruct(
        avatarUrl: deserializeParam(
          data['avatarUrl'],
          ParamType.String,
          false,
        ),
        borderColorHex: deserializeParam(
          data['borderColorHex'],
          ParamType.String,
          false,
        ),
        isOwn: deserializeParam(
          data['isOwn'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'MarkerStyleInfoStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MarkerStyleInfoStruct &&
        avatarUrl == other.avatarUrl &&
        borderColorHex == other.borderColorHex &&
        isOwn == other.isOwn;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([avatarUrl, borderColorHex, isOwn]);
}

MarkerStyleInfoStruct createMarkerStyleInfoStruct({
  String? avatarUrl,
  String? borderColorHex,
  bool? isOwn,
}) =>
    MarkerStyleInfoStruct(
      avatarUrl: avatarUrl,
      borderColorHex: borderColorHex,
      isOwn: isOwn,
    );
