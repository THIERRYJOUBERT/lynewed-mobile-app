// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MessageLongPressDataStruct extends BaseStruct {
  MessageLongPressDataStruct({
    int? messageId,
    bool? isMine,
    MessageType? messageType,
    String? attachmentUrl,
    String? content,
    DateTime? createdAt,
    String? authorProfileId,
  })  : _messageId = messageId,
        _isMine = isMine,
        _messageType = messageType,
        _attachmentUrl = attachmentUrl,
        _content = content,
        _createdAt = createdAt,
        _authorProfileId = authorProfileId;

  // "messageId" field.
  int? _messageId;
  int get messageId => _messageId ?? 0;
  set messageId(int? val) => _messageId = val;

  void incrementMessageId(int amount) => messageId = messageId + amount;

  bool hasMessageId() => _messageId != null;

  // "isMine" field.
  bool? _isMine;
  bool get isMine => _isMine ?? false;
  set isMine(bool? val) => _isMine = val;

  bool hasIsMine() => _isMine != null;

  // "messageType" field.
  MessageType? _messageType;
  MessageType? get messageType => _messageType;
  set messageType(MessageType? val) => _messageType = val;

  bool hasMessageType() => _messageType != null;

  // "attachmentUrl" field.
  String? _attachmentUrl;
  String get attachmentUrl => _attachmentUrl ?? '';
  set attachmentUrl(String? val) => _attachmentUrl = val;

  bool hasAttachmentUrl() => _attachmentUrl != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  set content(String? val) => _content = val;

  bool hasContent() => _content != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "authorProfileId" field.
  String? _authorProfileId;
  String get authorProfileId => _authorProfileId ?? '';
  set authorProfileId(String? val) => _authorProfileId = val;

  bool hasAuthorProfileId() => _authorProfileId != null;

  static MessageLongPressDataStruct fromMap(Map<String, dynamic> data) =>
      MessageLongPressDataStruct(
        messageId: castToType<int>(data['messageId']),
        isMine: data['isMine'] as bool?,
        messageType: data['messageType'] is MessageType
            ? data['messageType']
            : deserializeEnum<MessageType>(data['messageType']),
        attachmentUrl: data['attachmentUrl'] as String?,
        content: data['content'] as String?,
        createdAt: data['createdAt'] as DateTime?,
        authorProfileId: data['authorProfileId'] as String?,
      );

  static MessageLongPressDataStruct? maybeFromMap(dynamic data) => data is Map
      ? MessageLongPressDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'messageId': _messageId,
        'isMine': _isMine,
        'messageType': _messageType?.serialize(),
        'attachmentUrl': _attachmentUrl,
        'content': _content,
        'createdAt': _createdAt,
        'authorProfileId': _authorProfileId,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'messageId': serializeParam(
          _messageId,
          ParamType.int,
        ),
        'isMine': serializeParam(
          _isMine,
          ParamType.bool,
        ),
        'messageType': serializeParam(
          _messageType,
          ParamType.Enum,
        ),
        'attachmentUrl': serializeParam(
          _attachmentUrl,
          ParamType.String,
        ),
        'content': serializeParam(
          _content,
          ParamType.String,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
        'authorProfileId': serializeParam(
          _authorProfileId,
          ParamType.String,
        ),
      }.withoutNulls;

  static MessageLongPressDataStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      MessageLongPressDataStruct(
        messageId: deserializeParam(
          data['messageId'],
          ParamType.int,
          false,
        ),
        isMine: deserializeParam(
          data['isMine'],
          ParamType.bool,
          false,
        ),
        messageType: deserializeParam<MessageType>(
          data['messageType'],
          ParamType.Enum,
          false,
        ),
        attachmentUrl: deserializeParam(
          data['attachmentUrl'],
          ParamType.String,
          false,
        ),
        content: deserializeParam(
          data['content'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
        authorProfileId: deserializeParam(
          data['authorProfileId'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'MessageLongPressDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MessageLongPressDataStruct &&
        messageId == other.messageId &&
        isMine == other.isMine &&
        messageType == other.messageType &&
        attachmentUrl == other.attachmentUrl &&
        content == other.content &&
        createdAt == other.createdAt &&
        authorProfileId == other.authorProfileId;
  }

  @override
  int get hashCode => const ListEquality().hash([
        messageId,
        isMine,
        messageType,
        attachmentUrl,
        content,
        createdAt,
        authorProfileId
      ]);
}

MessageLongPressDataStruct createMessageLongPressDataStruct({
  int? messageId,
  bool? isMine,
  MessageType? messageType,
  String? attachmentUrl,
  String? content,
  DateTime? createdAt,
  String? authorProfileId,
}) =>
    MessageLongPressDataStruct(
      messageId: messageId,
      isMine: isMine,
      messageType: messageType,
      attachmentUrl: attachmentUrl,
      content: content,
      createdAt: createdAt,
      authorProfileId: authorProfileId,
    );
