// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReplayGuestItemStruct extends BaseStruct {
  ReplayGuestItemStruct({
    String? guestId,
    String? fullName,
    String? profession,
    String? avatarUrl,
  })  : _guestId = guestId,
        _fullName = fullName,
        _profession = profession,
        _avatarUrl = avatarUrl;

  // "guestId" field.
  String? _guestId;
  String get guestId => _guestId ?? '';
  set guestId(String? val) => _guestId = val;

  bool hasGuestId() => _guestId != null;

  // "fullName" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "profession" field.
  String? _profession;
  String get profession => _profession ?? '';
  set profession(String? val) => _profession = val;

  bool hasProfession() => _profession != null;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  set avatarUrl(String? val) => _avatarUrl = val;

  bool hasAvatarUrl() => _avatarUrl != null;

  static ReplayGuestItemStruct fromMap(Map<String, dynamic> data) =>
      ReplayGuestItemStruct(
        guestId: data['guestId'] as String?,
        fullName: data['fullName'] as String?,
        profession: data['profession'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
      );

  static ReplayGuestItemStruct? maybeFromMap(dynamic data) => data is Map
      ? ReplayGuestItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'guestId': _guestId,
        'fullName': _fullName,
        'profession': _profession,
        'avatarUrl': _avatarUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'guestId': serializeParam(
          _guestId,
          ParamType.String,
        ),
        'fullName': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'profession': serializeParam(
          _profession,
          ParamType.String,
        ),
        'avatarUrl': serializeParam(
          _avatarUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static ReplayGuestItemStruct fromSerializableMap(Map<String, dynamic> data) =>
      ReplayGuestItemStruct(
        guestId: deserializeParam(
          data['guestId'],
          ParamType.String,
          false,
        ),
        fullName: deserializeParam(
          data['fullName'],
          ParamType.String,
          false,
        ),
        profession: deserializeParam(
          data['profession'],
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
  String toString() => 'ReplayGuestItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ReplayGuestItemStruct &&
        guestId == other.guestId &&
        fullName == other.fullName &&
        profession == other.profession &&
        avatarUrl == other.avatarUrl;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([guestId, fullName, profession, avatarUrl]);
}

ReplayGuestItemStruct createReplayGuestItemStruct({
  String? guestId,
  String? fullName,
  String? profession,
  String? avatarUrl,
}) =>
    ReplayGuestItemStruct(
      guestId: guestId,
      fullName: fullName,
      profession: profession,
      avatarUrl: avatarUrl,
    );
