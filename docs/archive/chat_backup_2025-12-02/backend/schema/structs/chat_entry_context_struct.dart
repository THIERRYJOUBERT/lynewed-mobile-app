// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatEntryContextStruct extends BaseStruct {
  ChatEntryContextStruct({
    ChatEntryStatus? status,
    String? roomId,
    String? requestId,
    bool? isPublic,
    String? otherProfileId,
    String? otherFullName,
    String? otherAvatarUrl,
    UserRole? otherRole,
    bool? isRoomEmpty,
    bool? firstMessageTextOnly,
    bool? limitToSingleInitialMessage,
    bool? viewerIsReviewer,
    ConversationStatus? conversationStatus,
    String? reason,
  })  : _status = status,
        _roomId = roomId,
        _requestId = requestId,
        _isPublic = isPublic,
        _otherProfileId = otherProfileId,
        _otherFullName = otherFullName,
        _otherAvatarUrl = otherAvatarUrl,
        _otherRole = otherRole,
        _isRoomEmpty = isRoomEmpty,
        _firstMessageTextOnly = firstMessageTextOnly,
        _limitToSingleInitialMessage = limitToSingleInitialMessage,
        _viewerIsReviewer = viewerIsReviewer,
        _conversationStatus = conversationStatus,
        _reason = reason;

  // "status" field.
  ChatEntryStatus? _status;
  ChatEntryStatus? get status => _status;
  set status(ChatEntryStatus? val) => _status = val;

  bool hasStatus() => _status != null;

  // "roomId" field.
  String? _roomId;
  String get roomId => _roomId ?? '';
  set roomId(String? val) => _roomId = val;

  bool hasRoomId() => _roomId != null;

  // "requestId" field.
  String? _requestId;
  String get requestId => _requestId ?? '';
  set requestId(String? val) => _requestId = val;

  bool hasRequestId() => _requestId != null;

  // "isPublic" field.
  bool? _isPublic;
  bool get isPublic => _isPublic ?? false;
  set isPublic(bool? val) => _isPublic = val;

  bool hasIsPublic() => _isPublic != null;

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

  // "isRoomEmpty" field.
  bool? _isRoomEmpty;
  bool get isRoomEmpty => _isRoomEmpty ?? false;
  set isRoomEmpty(bool? val) => _isRoomEmpty = val;

  bool hasIsRoomEmpty() => _isRoomEmpty != null;

  // "firstMessageTextOnly" field.
  bool? _firstMessageTextOnly;
  bool get firstMessageTextOnly => _firstMessageTextOnly ?? false;
  set firstMessageTextOnly(bool? val) => _firstMessageTextOnly = val;

  bool hasFirstMessageTextOnly() => _firstMessageTextOnly != null;

  // "limitToSingleInitialMessage" field.
  bool? _limitToSingleInitialMessage;
  bool get limitToSingleInitialMessage => _limitToSingleInitialMessage ?? false;
  set limitToSingleInitialMessage(bool? val) =>
      _limitToSingleInitialMessage = val;

  bool hasLimitToSingleInitialMessage() => _limitToSingleInitialMessage != null;

  // "viewerIsReviewer" field.
  bool? _viewerIsReviewer;
  bool get viewerIsReviewer => _viewerIsReviewer ?? false;
  set viewerIsReviewer(bool? val) => _viewerIsReviewer = val;

  bool hasViewerIsReviewer() => _viewerIsReviewer != null;

  // "conversationStatus" field.
  ConversationStatus? _conversationStatus;
  ConversationStatus? get conversationStatus => _conversationStatus;
  set conversationStatus(ConversationStatus? val) => _conversationStatus = val;

  bool hasConversationStatus() => _conversationStatus != null;

  // "reason" field.
  String? _reason;
  String get reason => _reason ?? '';
  set reason(String? val) => _reason = val;

  bool hasReason() => _reason != null;

  static ChatEntryContextStruct fromMap(Map<String, dynamic> data) =>
      ChatEntryContextStruct(
        status: data['status'] is ChatEntryStatus
            ? data['status']
            : deserializeEnum<ChatEntryStatus>(data['status']),
        roomId: data['roomId'] as String?,
        requestId: data['requestId'] as String?,
        isPublic: data['isPublic'] as bool?,
        otherProfileId: data['otherProfileId'] as String?,
        otherFullName: data['otherFullName'] as String?,
        otherAvatarUrl: data['otherAvatarUrl'] as String?,
        otherRole: data['otherRole'] is UserRole
            ? data['otherRole']
            : deserializeEnum<UserRole>(data['otherRole']),
        isRoomEmpty: data['isRoomEmpty'] as bool?,
        firstMessageTextOnly: data['firstMessageTextOnly'] as bool?,
        limitToSingleInitialMessage:
            data['limitToSingleInitialMessage'] as bool?,
        viewerIsReviewer: data['viewerIsReviewer'] as bool?,
        conversationStatus: data['conversationStatus'] is ConversationStatus
            ? data['conversationStatus']
            : deserializeEnum<ConversationStatus>(data['conversationStatus']),
        reason: data['reason'] as String?,
      );

  static ChatEntryContextStruct? maybeFromMap(dynamic data) => data is Map
      ? ChatEntryContextStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'status': _status?.serialize(),
        'roomId': _roomId,
        'requestId': _requestId,
        'isPublic': _isPublic,
        'otherProfileId': _otherProfileId,
        'otherFullName': _otherFullName,
        'otherAvatarUrl': _otherAvatarUrl,
        'otherRole': _otherRole?.serialize(),
        'isRoomEmpty': _isRoomEmpty,
        'firstMessageTextOnly': _firstMessageTextOnly,
        'limitToSingleInitialMessage': _limitToSingleInitialMessage,
        'viewerIsReviewer': _viewerIsReviewer,
        'conversationStatus': _conversationStatus?.serialize(),
        'reason': _reason,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'status': serializeParam(
          _status,
          ParamType.Enum,
        ),
        'roomId': serializeParam(
          _roomId,
          ParamType.String,
        ),
        'requestId': serializeParam(
          _requestId,
          ParamType.String,
        ),
        'isPublic': serializeParam(
          _isPublic,
          ParamType.bool,
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
        'isRoomEmpty': serializeParam(
          _isRoomEmpty,
          ParamType.bool,
        ),
        'firstMessageTextOnly': serializeParam(
          _firstMessageTextOnly,
          ParamType.bool,
        ),
        'limitToSingleInitialMessage': serializeParam(
          _limitToSingleInitialMessage,
          ParamType.bool,
        ),
        'viewerIsReviewer': serializeParam(
          _viewerIsReviewer,
          ParamType.bool,
        ),
        'conversationStatus': serializeParam(
          _conversationStatus,
          ParamType.Enum,
        ),
        'reason': serializeParam(
          _reason,
          ParamType.String,
        ),
      }.withoutNulls;

  static ChatEntryContextStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ChatEntryContextStruct(
        status: deserializeParam<ChatEntryStatus>(
          data['status'],
          ParamType.Enum,
          false,
        ),
        roomId: deserializeParam(
          data['roomId'],
          ParamType.String,
          false,
        ),
        requestId: deserializeParam(
          data['requestId'],
          ParamType.String,
          false,
        ),
        isPublic: deserializeParam(
          data['isPublic'],
          ParamType.bool,
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
        isRoomEmpty: deserializeParam(
          data['isRoomEmpty'],
          ParamType.bool,
          false,
        ),
        firstMessageTextOnly: deserializeParam(
          data['firstMessageTextOnly'],
          ParamType.bool,
          false,
        ),
        limitToSingleInitialMessage: deserializeParam(
          data['limitToSingleInitialMessage'],
          ParamType.bool,
          false,
        ),
        viewerIsReviewer: deserializeParam(
          data['viewerIsReviewer'],
          ParamType.bool,
          false,
        ),
        conversationStatus: deserializeParam<ConversationStatus>(
          data['conversationStatus'],
          ParamType.Enum,
          false,
        ),
        reason: deserializeParam(
          data['reason'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ChatEntryContextStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChatEntryContextStruct &&
        status == other.status &&
        roomId == other.roomId &&
        requestId == other.requestId &&
        isPublic == other.isPublic &&
        otherProfileId == other.otherProfileId &&
        otherFullName == other.otherFullName &&
        otherAvatarUrl == other.otherAvatarUrl &&
        otherRole == other.otherRole &&
        isRoomEmpty == other.isRoomEmpty &&
        firstMessageTextOnly == other.firstMessageTextOnly &&
        limitToSingleInitialMessage == other.limitToSingleInitialMessage &&
        viewerIsReviewer == other.viewerIsReviewer &&
        conversationStatus == other.conversationStatus &&
        reason == other.reason;
  }

  @override
  int get hashCode => const ListEquality().hash([
        status,
        roomId,
        requestId,
        isPublic,
        otherProfileId,
        otherFullName,
        otherAvatarUrl,
        otherRole,
        isRoomEmpty,
        firstMessageTextOnly,
        limitToSingleInitialMessage,
        viewerIsReviewer,
        conversationStatus,
        reason
      ]);
}

ChatEntryContextStruct createChatEntryContextStruct({
  ChatEntryStatus? status,
  String? roomId,
  String? requestId,
  bool? isPublic,
  String? otherProfileId,
  String? otherFullName,
  String? otherAvatarUrl,
  UserRole? otherRole,
  bool? isRoomEmpty,
  bool? firstMessageTextOnly,
  bool? limitToSingleInitialMessage,
  bool? viewerIsReviewer,
  ConversationStatus? conversationStatus,
  String? reason,
}) =>
    ChatEntryContextStruct(
      status: status,
      roomId: roomId,
      requestId: requestId,
      isPublic: isPublic,
      otherProfileId: otherProfileId,
      otherFullName: otherFullName,
      otherAvatarUrl: otherAvatarUrl,
      otherRole: otherRole,
      isRoomEmpty: isRoomEmpty,
      firstMessageTextOnly: firstMessageTextOnly,
      limitToSingleInitialMessage: limitToSingleInitialMessage,
      viewerIsReviewer: viewerIsReviewer,
      conversationStatus: conversationStatus,
      reason: reason,
    );
