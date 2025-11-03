// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PublicProfileStruct extends BaseStruct {
  PublicProfileStruct({
    String? id,
    UserRole? role,
    String? fullName,
    String? avatarUrl,
  })  : _id = id,
        _role = role,
        _fullName = fullName,
        _avatarUrl = avatarUrl;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "role" field.
  UserRole? _role;
  UserRole get role => _role ?? UserRole.bride;
  set role(UserRole? val) => _role = val;

  bool hasRole() => _role != null;

  // "fullName" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl =>
      _avatarUrl ??
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png';
  set avatarUrl(String? val) => _avatarUrl = val;

  bool hasAvatarUrl() => _avatarUrl != null;

  static PublicProfileStruct fromMap(Map<String, dynamic> data) =>
      PublicProfileStruct(
        id: data['id'] as String?,
        role: data['role'] is UserRole
            ? data['role']
            : deserializeEnum<UserRole>(data['role']),
        fullName: data['fullName'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
      );

  static PublicProfileStruct? maybeFromMap(dynamic data) => data is Map
      ? PublicProfileStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'role': _role?.serialize(),
        'fullName': _fullName,
        'avatarUrl': _avatarUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'role': serializeParam(
          _role,
          ParamType.Enum,
        ),
        'fullName': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'avatarUrl': serializeParam(
          _avatarUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static PublicProfileStruct fromSerializableMap(Map<String, dynamic> data) =>
      PublicProfileStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        role: deserializeParam<UserRole>(
          data['role'],
          ParamType.Enum,
          false,
        ),
        fullName: deserializeParam(
          data['fullName'],
          ParamType.String,
          false,
        ),
        avatarUrl: deserializeParam(
          data['avatarUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'PublicProfileStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PublicProfileStruct &&
        id == other.id &&
        role == other.role &&
        fullName == other.fullName &&
        avatarUrl == other.avatarUrl;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([id, role, fullName, avatarUrl]);
}

PublicProfileStruct createPublicProfileStruct({
  String? id,
  UserRole? role,
  String? fullName,
  String? avatarUrl,
}) =>
    PublicProfileStruct(
      id: id,
      role: role,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
