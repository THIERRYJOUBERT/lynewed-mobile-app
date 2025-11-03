// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatRoomHeaderStruct extends BaseStruct {
  ChatRoomHeaderStruct({
    RoomType? roomType,
    String? otherProfileId,
    String? otherFullName,
    String? otherAvatarUrl,
    UserRole? otherRole,
    String? publicTitle,
    String? publicCoverUrl,
    UserRole? audienceRole,
  })  : _roomType = roomType,
        _otherProfileId = otherProfileId,
        _otherFullName = otherFullName,
        _otherAvatarUrl = otherAvatarUrl,
        _otherRole = otherRole,
        _publicTitle = publicTitle,
        _publicCoverUrl = publicCoverUrl,
        _audienceRole = audienceRole;

  // "roomType" field.
  RoomType? _roomType;
  RoomType? get roomType => _roomType;
  set roomType(RoomType? val) => _roomType = val;

  bool hasRoomType() => _roomType != null;

  // "otherProfileId" field.
  String? _otherProfileId;
  String get otherProfileId => _otherProfileId ?? '';
  set otherProfileId(String? val) => _otherProfileId = val;

  bool hasOtherProfileId() => _otherProfileId != null;

  // "otherFullName" field.
  String? _otherFullName;
  String get otherFullName => _otherFullName ?? '';
  set otherFullName(String? val) => _otherFullName = val;

  bool hasOtherFullName() => _otherFullName != null;

  // "otherAvatarUrl" field.
  String? _otherAvatarUrl;
  String get otherAvatarUrl => _otherAvatarUrl ?? '';
  set otherAvatarUrl(String? val) => _otherAvatarUrl = val;

  bool hasOtherAvatarUrl() => _otherAvatarUrl != null;

  // "otherRole" field.
  UserRole? _otherRole;
  UserRole? get otherRole => _otherRole;
  set otherRole(UserRole? val) => _otherRole = val;

  bool hasOtherRole() => _otherRole != null;

  // "publicTitle" field.
  String? _publicTitle;
  String get publicTitle => _publicTitle ?? '';
  set publicTitle(String? val) => _publicTitle = val;

  bool hasPublicTitle() => _publicTitle != null;

  // "publicCoverUrl" field.
  String? _publicCoverUrl;
  String get publicCoverUrl => _publicCoverUrl ?? '';
  set publicCoverUrl(String? val) => _publicCoverUrl = val;

  bool hasPublicCoverUrl() => _publicCoverUrl != null;

  // "audienceRole" field.
  UserRole? _audienceRole;
  UserRole? get audienceRole => _audienceRole;
  set audienceRole(UserRole? val) => _audienceRole = val;

  bool hasAudienceRole() => _audienceRole != null;

  static ChatRoomHeaderStruct fromMap(Map<String, dynamic> data) =>
      ChatRoomHeaderStruct(
        roomType: data['roomType'] is RoomType
            ? data['roomType']
            : deserializeEnum<RoomType>(data['roomType']),
        otherProfileId: data['otherProfileId'] as String?,
        otherFullName: data['otherFullName'] as String?,
        otherAvatarUrl: data['otherAvatarUrl'] as String?,
        otherRole: data['otherRole'] is UserRole
            ? data['otherRole']
            : deserializeEnum<UserRole>(data['otherRole']),
        publicTitle: data['publicTitle'] as String?,
        publicCoverUrl: data['publicCoverUrl'] as String?,
        audienceRole: data['audienceRole'] is UserRole
            ? data['audienceRole']
            : deserializeEnum<UserRole>(data['audienceRole']),
      );

  static ChatRoomHeaderStruct? maybeFromMap(dynamic data) => data is Map
      ? ChatRoomHeaderStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'roomType': _roomType?.serialize(),
        'otherProfileId': _otherProfileId,
        'otherFullName': _otherFullName,
        'otherAvatarUrl': _otherAvatarUrl,
        'otherRole': _otherRole?.serialize(),
        'publicTitle': _publicTitle,
        'publicCoverUrl': _publicCoverUrl,
        'audienceRole': _audienceRole?.serialize(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'roomType': serializeParam(
          _roomType,
          ParamType.Enum,
        ),
        'otherProfileId': serializeParam(
          _otherProfileId,
          ParamType.String,
        ),
        'otherFullName': serializeParam(
          _otherFullName,
          ParamType.String,
        ),
        'otherAvatarUrl': serializeParam(
          _otherAvatarUrl,
          ParamType.String,
        ),
        'otherRole': serializeParam(
          _otherRole,
          ParamType.Enum,
        ),
        'publicTitle': serializeParam(
          _publicTitle,
          ParamType.String,
        ),
        'publicCoverUrl': serializeParam(
          _publicCoverUrl,
          ParamType.String,
        ),
        'audienceRole': serializeParam(
          _audienceRole,
          ParamType.Enum,
        ),
      }.withoutNulls;

  static ChatRoomHeaderStruct fromSerializableMap(Map<String, dynamic> data) =>
      ChatRoomHeaderStruct(
        roomType: deserializeParam<RoomType>(
          data['roomType'],
          ParamType.Enum,
          false,
        ),
        otherProfileId: deserializeParam(
          data['otherProfileId'],
          ParamType.String,
          false,
        ),
        otherFullName: deserializeParam(
          data['otherFullName'],
          ParamType.String,
          false,
        ),
        otherAvatarUrl: deserializeParam(
          data['otherAvatarUrl'],
          ParamType.String,
          false,
        ),
        otherRole: deserializeParam<UserRole>(
          data['otherRole'],
          ParamType.Enum,
          false,
        ),
        publicTitle: deserializeParam(
          data['publicTitle'],
          ParamType.String,
          false,
        ),
        publicCoverUrl: deserializeParam(
          data['publicCoverUrl'],
          ParamType.String,
          false,
        ),
        audienceRole: deserializeParam<UserRole>(
          data['audienceRole'],
          ParamType.Enum,
          false,
        ),
      );

  @override
  String toString() => 'ChatRoomHeaderStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChatRoomHeaderStruct &&
        roomType == other.roomType &&
        otherProfileId == other.otherProfileId &&
        otherFullName == other.otherFullName &&
        otherAvatarUrl == other.otherAvatarUrl &&
        otherRole == other.otherRole &&
        publicTitle == other.publicTitle &&
        publicCoverUrl == other.publicCoverUrl &&
        audienceRole == other.audienceRole;
  }

  @override
  int get hashCode => const ListEquality().hash([
        roomType,
        otherProfileId,
        otherFullName,
        otherAvatarUrl,
        otherRole,
        publicTitle,
        publicCoverUrl,
        audienceRole
      ]);
}

ChatRoomHeaderStruct createChatRoomHeaderStruct({
  RoomType? roomType,
  String? otherProfileId,
  String? otherFullName,
  String? otherAvatarUrl,
  UserRole? otherRole,
  String? publicTitle,
  String? publicCoverUrl,
  UserRole? audienceRole,
}) =>
    ChatRoomHeaderStruct(
      roomType: roomType,
      otherProfileId: otherProfileId,
      otherFullName: otherFullName,
      otherAvatarUrl: otherAvatarUrl,
      otherRole: otherRole,
      publicTitle: publicTitle,
      publicCoverUrl: publicCoverUrl,
      audienceRole: audienceRole,
    );
