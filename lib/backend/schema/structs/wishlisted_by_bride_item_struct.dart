// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WishlistedByBrideItemStruct extends BaseStruct {
  WishlistedByBrideItemStruct({
    String? brideProfileId,
    String? fullName,
    String? avatarUrl,
    DateTime? addedAt,
  })  : _brideProfileId = brideProfileId,
        _fullName = fullName,
        _avatarUrl = avatarUrl,
        _addedAt = addedAt;

  // "brideProfileId" field.
  String? _brideProfileId;
  String get brideProfileId => _brideProfileId ?? '';
  set brideProfileId(String? val) => _brideProfileId = val;

  bool hasBrideProfileId() => _brideProfileId != null;

  // "fullName" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  set avatarUrl(String? val) => _avatarUrl = val;

  bool hasAvatarUrl() => _avatarUrl != null;

  // "addedAt" field.
  DateTime? _addedAt;
  DateTime? get addedAt => _addedAt;
  set addedAt(DateTime? val) => _addedAt = val;

  bool hasAddedAt() => _addedAt != null;

  static WishlistedByBrideItemStruct fromMap(Map<String, dynamic> data) =>
      WishlistedByBrideItemStruct(
        brideProfileId: data['brideProfileId'] as String?,
        fullName: data['fullName'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        addedAt: data['addedAt'] as DateTime?,
      );

  static WishlistedByBrideItemStruct? maybeFromMap(dynamic data) => data is Map
      ? WishlistedByBrideItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'brideProfileId': _brideProfileId,
        'fullName': _fullName,
        'avatarUrl': _avatarUrl,
        'addedAt': _addedAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'brideProfileId': serializeParam(
          _brideProfileId,
          ParamType.String,
        ),
        'fullName': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'avatarUrl': serializeParam(
          _avatarUrl,
          ParamType.String,
        ),
        'addedAt': serializeParam(
          _addedAt,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static WishlistedByBrideItemStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      WishlistedByBrideItemStruct(
        brideProfileId: deserializeParam(
          data['brideProfileId'],
          ParamType.String,
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
        addedAt: deserializeParam(
          data['addedAt'],
          ParamType.DateTime,
          false,
        ),
      );

  @override
  String toString() => 'WishlistedByBrideItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is WishlistedByBrideItemStruct &&
        brideProfileId == other.brideProfileId &&
        fullName == other.fullName &&
        avatarUrl == other.avatarUrl &&
        addedAt == other.addedAt;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([brideProfileId, fullName, avatarUrl, addedAt]);
}

WishlistedByBrideItemStruct createWishlistedByBrideItemStruct({
  String? brideProfileId,
  String? fullName,
  String? avatarUrl,
  DateTime? addedAt,
}) =>
    WishlistedByBrideItemStruct(
      brideProfileId: brideProfileId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      addedAt: addedAt,
    );
