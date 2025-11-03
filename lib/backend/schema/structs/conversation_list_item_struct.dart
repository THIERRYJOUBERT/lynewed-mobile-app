// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ConversationListItemStruct extends BaseStruct {
  ConversationListItemStruct({
    String? roomId,
    RoomType? roomType,
    ConversationStatus? conversationStatus,
    int? unreadCount,
    MessageType? lastMessageType,
    String? lastMessageText,
    DateTime? lastMessageAt,
    String? otherProfileId,
    String? otherFullName,
    String? otherAvatarUrl,
    UserRole? otherRole,
    String? publicTitle,
    String? publicCoverUrl,
    UserRole? audienceRole,
  })  : _roomId = roomId,
        _roomType = roomType,
        _conversationStatus = conversationStatus,
        _unreadCount = unreadCount,
        _lastMessageType = lastMessageType,
        _lastMessageText = lastMessageText,
        _lastMessageAt = lastMessageAt,
        _otherProfileId = otherProfileId,
        _otherFullName = otherFullName,
        _otherAvatarUrl = otherAvatarUrl,
        _otherRole = otherRole,
        _publicTitle = publicTitle,
        _publicCoverUrl = publicCoverUrl,
        _audienceRole = audienceRole;

  // "roomId" field.
  String? _roomId;
  String get roomId => _roomId ?? '';
  set roomId(String? val) => _roomId = val;

  bool hasRoomId() => _roomId != null;

  // "roomType" field.
  RoomType? _roomType;
  RoomType? get roomType => _roomType;
  set roomType(RoomType? val) => _roomType = val;

  bool hasRoomType() => _roomType != null;

  // "conversationStatus" field.
  ConversationStatus? _conversationStatus;
  ConversationStatus? get conversationStatus => _conversationStatus;
  set conversationStatus(ConversationStatus? val) => _conversationStatus = val;

  bool hasConversationStatus() => _conversationStatus != null;

  // "unreadCount" field.
  int? _unreadCount;
  int get unreadCount => _unreadCount ?? 0;
  set unreadCount(int? val) => _unreadCount = val;

  void incrementUnreadCount(int amount) => unreadCount = unreadCount + amount;

  bool hasUnreadCount() => _unreadCount != null;

  // "lastMessageType" field.
  MessageType? _lastMessageType;
  MessageType? get lastMessageType => _lastMessageType;
  set lastMessageType(MessageType? val) => _lastMessageType = val;

  bool hasLastMessageType() => _lastMessageType != null;

  // "lastMessageText" field.
  String? _lastMessageText;
  String get lastMessageText => _lastMessageText ?? '';
  set lastMessageText(String? val) => _lastMessageText = val;

  bool hasLastMessageText() => _lastMessageText != null;

  // "lastMessageAt" field.
  DateTime? _lastMessageAt;
  DateTime? get lastMessageAt => _lastMessageAt;
  set lastMessageAt(DateTime? val) => _lastMessageAt = val;

  bool hasLastMessageAt() => _lastMessageAt != null;

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

  static ConversationListItemStruct fromMap(Map<String, dynamic> data) =>
      ConversationListItemStruct(
        roomId: data['roomId'] as String?,
        roomType: data['roomType'] is RoomType
            ? data['roomType']
            : deserializeEnum<RoomType>(data['roomType']),
        conversationStatus: data['conversationStatus'] is ConversationStatus
            ? data['conversationStatus']
            : deserializeEnum<ConversationStatus>(data['conversationStatus']),
        unreadCount: castToType<int>(data['unreadCount']),
        lastMessageType: data['lastMessageType'] is MessageType
            ? data['lastMessageType']
            : deserializeEnum<MessageType>(data['lastMessageType']),
        lastMessageText: data['lastMessageText'] as String?,
        lastMessageAt: data['lastMessageAt'] as DateTime?,
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

  static ConversationListItemStruct? maybeFromMap(dynamic data) => data is Map
      ? ConversationListItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'roomId': _roomId,
        'roomType': _roomType?.serialize(),
        'conversationStatus': _conversationStatus?.serialize(),
        'unreadCount': _unreadCount,
        'lastMessageType': _lastMessageType?.serialize(),
        'lastMessageText': _lastMessageText,
        'lastMessageAt': _lastMessageAt,
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
        'roomId': serializeParam(
          _roomId,
          ParamType.String,
        ),
        'roomType': serializeParam(
          _roomType,
          ParamType.Enum,
        ),
        'conversationStatus': serializeParam(
          _conversationStatus,
          ParamType.Enum,
        ),
        'unreadCount': serializeParam(
          _unreadCount,
          ParamType.int,
        ),
        'lastMessageType': serializeParam(
          _lastMessageType,
          ParamType.Enum,
        ),
        'lastMessageText': serializeParam(
          _lastMessageText,
          ParamType.String,
        ),
        'lastMessageAt': serializeParam(
          _lastMessageAt,
          ParamType.DateTime,
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

  static ConversationListItemStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ConversationListItemStruct(
        roomId: deserializeParam(
          data['roomId'],
          ParamType.String,
          false,
        ),
        roomType: deserializeParam<RoomType>(
          data['roomType'],
          ParamType.Enum,
          false,
        ),
        conversationStatus: deserializeParam<ConversationStatus>(
          data['conversationStatus'],
          ParamType.Enum,
          false,
        ),
        unreadCount: deserializeParam(
          data['unreadCount'],
          ParamType.int,
          false,
        ),
        lastMessageType: deserializeParam<MessageType>(
          data['lastMessageType'],
          ParamType.Enum,
          false,
        ),
        lastMessageText: deserializeParam(
          data['lastMessageText'],
          ParamType.String,
          false,
        ),
        lastMessageAt: deserializeParam(
          data['lastMessageAt'],
          ParamType.DateTime,
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
  String toString() => 'ConversationListItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ConversationListItemStruct &&
        roomId == other.roomId &&
        roomType == other.roomType &&
        conversationStatus == other.conversationStatus &&
        unreadCount == other.unreadCount &&
        lastMessageType == other.lastMessageType &&
        lastMessageText == other.lastMessageText &&
        lastMessageAt == other.lastMessageAt &&
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
        roomId,
        roomType,
        conversationStatus,
        unreadCount,
        lastMessageType,
        lastMessageText,
        lastMessageAt,
        otherProfileId,
        otherFullName,
        otherAvatarUrl,
        otherRole,
        publicTitle,
        publicCoverUrl,
        audienceRole
      ]);
}

ConversationListItemStruct createConversationListItemStruct({
  String? roomId,
  RoomType? roomType,
  ConversationStatus? conversationStatus,
  int? unreadCount,
  MessageType? lastMessageType,
  String? lastMessageText,
  DateTime? lastMessageAt,
  String? otherProfileId,
  String? otherFullName,
  String? otherAvatarUrl,
  UserRole? otherRole,
  String? publicTitle,
  String? publicCoverUrl,
  UserRole? audienceRole,
}) =>
    ConversationListItemStruct(
      roomId: roomId,
      roomType: roomType,
      conversationStatus: conversationStatus,
      unreadCount: unreadCount,
      lastMessageType: lastMessageType,
      lastMessageText: lastMessageText,
      lastMessageAt: lastMessageAt,
      otherProfileId: otherProfileId,
      otherFullName: otherFullName,
      otherAvatarUrl: otherAvatarUrl,
      otherRole: otherRole,
      publicTitle: publicTitle,
      publicCoverUrl: publicCoverUrl,
      audienceRole: audienceRole,
    );
