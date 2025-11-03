// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AppNotificationStruct extends BaseStruct {
  AppNotificationStruct({
    String? notificationId,
    NotificationType? notificationType,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? referenceId,
    String? senderAvatarUrl,
  })  : _notificationId = notificationId,
        _notificationType = notificationType,
        _title = title,
        _message = message,
        _createdAt = createdAt,
        _isRead = isRead,
        _referenceId = referenceId,
        _senderAvatarUrl = senderAvatarUrl;

  // "notificationId" field.
  String? _notificationId;
  String get notificationId => _notificationId ?? '';
  set notificationId(String? val) => _notificationId = val;

  bool hasNotificationId() => _notificationId != null;

  // "notificationType" field.
  NotificationType? _notificationType;
  NotificationType? get notificationType => _notificationType;
  set notificationType(NotificationType? val) => _notificationType = val;

  bool hasNotificationType() => _notificationType != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  set message(String? val) => _message = val;

  bool hasMessage() => _message != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "isRead" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  set isRead(bool? val) => _isRead = val;

  bool hasIsRead() => _isRead != null;

  // "referenceId" field.
  String? _referenceId;
  String get referenceId => _referenceId ?? '';
  set referenceId(String? val) => _referenceId = val;

  bool hasReferenceId() => _referenceId != null;

  // "senderAvatarUrl" field.
  String? _senderAvatarUrl;
  String get senderAvatarUrl => _senderAvatarUrl ?? '';
  set senderAvatarUrl(String? val) => _senderAvatarUrl = val;

  bool hasSenderAvatarUrl() => _senderAvatarUrl != null;

  static AppNotificationStruct fromMap(Map<String, dynamic> data) =>
      AppNotificationStruct(
        notificationId: data['notificationId'] as String?,
        notificationType: data['notificationType'] is NotificationType
            ? data['notificationType']
            : deserializeEnum<NotificationType>(data['notificationType']),
        title: data['title'] as String?,
        message: data['message'] as String?,
        createdAt: data['createdAt'] as DateTime?,
        isRead: data['isRead'] as bool?,
        referenceId: data['referenceId'] as String?,
        senderAvatarUrl: data['senderAvatarUrl'] as String?,
      );

  static AppNotificationStruct? maybeFromMap(dynamic data) => data is Map
      ? AppNotificationStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'notificationId': _notificationId,
        'notificationType': _notificationType?.serialize(),
        'title': _title,
        'message': _message,
        'createdAt': _createdAt,
        'isRead': _isRead,
        'referenceId': _referenceId,
        'senderAvatarUrl': _senderAvatarUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'notificationId': serializeParam(
          _notificationId,
          ParamType.String,
        ),
        'notificationType': serializeParam(
          _notificationType,
          ParamType.Enum,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'message': serializeParam(
          _message,
          ParamType.String,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
        'isRead': serializeParam(
          _isRead,
          ParamType.bool,
        ),
        'referenceId': serializeParam(
          _referenceId,
          ParamType.String,
        ),
        'senderAvatarUrl': serializeParam(
          _senderAvatarUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static AppNotificationStruct fromSerializableMap(Map<String, dynamic> data) =>
      AppNotificationStruct(
        notificationId: deserializeParam(
          data['notificationId'],
          ParamType.String,
          false,
        ),
        notificationType: deserializeParam<NotificationType>(
          data['notificationType'],
          ParamType.Enum,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        message: deserializeParam(
          data['message'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
        isRead: deserializeParam(
          data['isRead'],
          ParamType.bool,
          false,
        ),
        referenceId: deserializeParam(
          data['referenceId'],
          ParamType.String,
          false,
        ),
        senderAvatarUrl: deserializeParam(
          data['senderAvatarUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'AppNotificationStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AppNotificationStruct &&
        notificationId == other.notificationId &&
        notificationType == other.notificationType &&
        title == other.title &&
        message == other.message &&
        createdAt == other.createdAt &&
        isRead == other.isRead &&
        referenceId == other.referenceId &&
        senderAvatarUrl == other.senderAvatarUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([
        notificationId,
        notificationType,
        title,
        message,
        createdAt,
        isRead,
        referenceId,
        senderAvatarUrl
      ]);
}

AppNotificationStruct createAppNotificationStruct({
  String? notificationId,
  NotificationType? notificationType,
  String? title,
  String? message,
  DateTime? createdAt,
  bool? isRead,
  String? referenceId,
  String? senderAvatarUrl,
}) =>
    AppNotificationStruct(
      notificationId: notificationId,
      notificationType: notificationType,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead,
      referenceId: referenceId,
      senderAvatarUrl: senderAvatarUrl,
    );
