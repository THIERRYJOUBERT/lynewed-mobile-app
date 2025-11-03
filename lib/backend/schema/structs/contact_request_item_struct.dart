// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ContactRequestItemStruct extends BaseStruct {
  ContactRequestItemStruct({
    String? requestId,
    String? otherProfileId,
    UserRole? otherRole,
    String? otherFullName,
    String? otherAvatarUrl,
    ConnectionRequestSource? source,
    String? initialMessage,
    String? initiatorId,
    DateTime? createdAt,
    String? roomId,
  })  : _requestId = requestId,
        _otherProfileId = otherProfileId,
        _otherRole = otherRole,
        _otherFullName = otherFullName,
        _otherAvatarUrl = otherAvatarUrl,
        _source = source,
        _initialMessage = initialMessage,
        _initiatorId = initiatorId,
        _createdAt = createdAt,
        _roomId = roomId;

  // "requestId" field.
  String? _requestId;
  String get requestId => _requestId ?? '';
  set requestId(String? val) => _requestId = val;

  bool hasRequestId() => _requestId != null;

  // "otherProfileId" field.
  String? _otherProfileId;
  String get otherProfileId => _otherProfileId ?? '';
  set otherProfileId(String? val) => _otherProfileId = val;

  bool hasOtherProfileId() => _otherProfileId != null;

  // "otherRole" field.
  UserRole? _otherRole;
  UserRole? get otherRole => _otherRole;
  set otherRole(UserRole? val) => _otherRole = val;

  bool hasOtherRole() => _otherRole != null;

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

  // "source" field.
  ConnectionRequestSource? _source;
  ConnectionRequestSource? get source => _source;
  set source(ConnectionRequestSource? val) => _source = val;

  bool hasSource() => _source != null;

  // "initialMessage" field.
  String? _initialMessage;
  String get initialMessage => _initialMessage ?? '';
  set initialMessage(String? val) => _initialMessage = val;

  bool hasInitialMessage() => _initialMessage != null;

  // "initiatorId" field.
  String? _initiatorId;
  String get initiatorId => _initiatorId ?? '';
  set initiatorId(String? val) => _initiatorId = val;

  bool hasInitiatorId() => _initiatorId != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "roomId" field.
  String? _roomId;
  String get roomId => _roomId ?? '';
  set roomId(String? val) => _roomId = val;

  bool hasRoomId() => _roomId != null;

  static ContactRequestItemStruct fromMap(Map<String, dynamic> data) =>
      ContactRequestItemStruct(
        requestId: data['requestId'] as String?,
        otherProfileId: data['otherProfileId'] as String?,
        otherRole: data['otherRole'] is UserRole
            ? data['otherRole']
            : deserializeEnum<UserRole>(data['otherRole']),
        otherFullName: data['otherFullName'] as String?,
        otherAvatarUrl: data['otherAvatarUrl'] as String?,
        source: data['source'] is ConnectionRequestSource
            ? data['source']
            : deserializeEnum<ConnectionRequestSource>(data['source']),
        initialMessage: data['initialMessage'] as String?,
        initiatorId: data['initiatorId'] as String?,
        createdAt: data['createdAt'] as DateTime?,
        roomId: data['roomId'] as String?,
      );

  static ContactRequestItemStruct? maybeFromMap(dynamic data) => data is Map
      ? ContactRequestItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'requestId': _requestId,
        'otherProfileId': _otherProfileId,
        'otherRole': _otherRole?.serialize(),
        'otherFullName': _otherFullName,
        'otherAvatarUrl': _otherAvatarUrl,
        'source': _source?.serialize(),
        'initialMessage': _initialMessage,
        'initiatorId': _initiatorId,
        'createdAt': _createdAt,
        'roomId': _roomId,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'requestId': serializeParam(
          _requestId,
          ParamType.String,
        ),
        'otherProfileId': serializeParam(
          _otherProfileId,
          ParamType.String,
        ),
        'otherRole': serializeParam(
          _otherRole,
          ParamType.Enum,
        ),
        'otherFullName': serializeParam(
          _otherFullName,
          ParamType.String,
        ),
        'otherAvatarUrl': serializeParam(
          _otherAvatarUrl,
          ParamType.String,
        ),
        'source': serializeParam(
          _source,
          ParamType.Enum,
        ),
        'initialMessage': serializeParam(
          _initialMessage,
          ParamType.String,
        ),
        'initiatorId': serializeParam(
          _initiatorId,
          ParamType.String,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
        'roomId': serializeParam(
          _roomId,
          ParamType.String,
        ),
      }.withoutNulls;

  static ContactRequestItemStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ContactRequestItemStruct(
        requestId: deserializeParam(
          data['requestId'],
          ParamType.String,
          false,
        ),
        otherProfileId: deserializeParam(
          data['otherProfileId'],
          ParamType.String,
          false,
        ),
        otherRole: deserializeParam<UserRole>(
          data['otherRole'],
          ParamType.Enum,
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
        source: deserializeParam<ConnectionRequestSource>(
          data['source'],
          ParamType.Enum,
          false,
        ),
        initialMessage: deserializeParam(
          data['initialMessage'],
          ParamType.String,
          false,
        ),
        initiatorId: deserializeParam(
          data['initiatorId'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
        roomId: deserializeParam(
          data['roomId'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ContactRequestItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ContactRequestItemStruct &&
        requestId == other.requestId &&
        otherProfileId == other.otherProfileId &&
        otherRole == other.otherRole &&
        otherFullName == other.otherFullName &&
        otherAvatarUrl == other.otherAvatarUrl &&
        source == other.source &&
        initialMessage == other.initialMessage &&
        initiatorId == other.initiatorId &&
        createdAt == other.createdAt &&
        roomId == other.roomId;
  }

  @override
  int get hashCode => const ListEquality().hash([
        requestId,
        otherProfileId,
        otherRole,
        otherFullName,
        otherAvatarUrl,
        source,
        initialMessage,
        initiatorId,
        createdAt,
        roomId
      ]);
}

ContactRequestItemStruct createContactRequestItemStruct({
  String? requestId,
  String? otherProfileId,
  UserRole? otherRole,
  String? otherFullName,
  String? otherAvatarUrl,
  ConnectionRequestSource? source,
  String? initialMessage,
  String? initiatorId,
  DateTime? createdAt,
  String? roomId,
}) =>
    ContactRequestItemStruct(
      requestId: requestId,
      otherProfileId: otherProfileId,
      otherRole: otherRole,
      otherFullName: otherFullName,
      otherAvatarUrl: otherAvatarUrl,
      source: source,
      initialMessage: initialMessage,
      initiatorId: initiatorId,
      createdAt: createdAt,
      roomId: roomId,
    );
