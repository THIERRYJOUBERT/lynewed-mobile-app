// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PublicChatRoomItemStruct extends BaseStruct {
  PublicChatRoomItemStruct({
    String? roomId,
    String? title,
    String? coverImageUrl,
    int? activeUsersCount,
  })  : _roomId = roomId,
        _title = title,
        _coverImageUrl = coverImageUrl,
        _activeUsersCount = activeUsersCount;

  // "roomId" field.
  String? _roomId;
  String get roomId => _roomId ?? '';
  set roomId(String? val) => _roomId = val;

  bool hasRoomId() => _roomId != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "coverImageUrl" field.
  String? _coverImageUrl;
  String get coverImageUrl => _coverImageUrl ?? '';
  set coverImageUrl(String? val) => _coverImageUrl = val;

  bool hasCoverImageUrl() => _coverImageUrl != null;

  // "activeUsersCount" field.
  int? _activeUsersCount;
  int get activeUsersCount => _activeUsersCount ?? 0;
  set activeUsersCount(int? val) => _activeUsersCount = val;

  void incrementActiveUsersCount(int amount) =>
      activeUsersCount = activeUsersCount + amount;

  bool hasActiveUsersCount() => _activeUsersCount != null;

  static PublicChatRoomItemStruct fromMap(Map<String, dynamic> data) =>
      PublicChatRoomItemStruct(
        roomId: data['roomId'] as String?,
        title: data['title'] as String?,
        coverImageUrl: data['coverImageUrl'] as String?,
        activeUsersCount: castToType<int>(data['activeUsersCount']),
      );

  static PublicChatRoomItemStruct? maybeFromMap(dynamic data) => data is Map
      ? PublicChatRoomItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'roomId': _roomId,
        'title': _title,
        'coverImageUrl': _coverImageUrl,
        'activeUsersCount': _activeUsersCount,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'roomId': serializeParam(
          _roomId,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'coverImageUrl': serializeParam(
          _coverImageUrl,
          ParamType.String,
        ),
        'activeUsersCount': serializeParam(
          _activeUsersCount,
          ParamType.int,
        ),
      }.withoutNulls;

  static PublicChatRoomItemStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      PublicChatRoomItemStruct(
        roomId: deserializeParam(
          data['roomId'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        coverImageUrl: deserializeParam(
          data['coverImageUrl'],
          ParamType.String,
          false,
        ),
        activeUsersCount: deserializeParam(
          data['activeUsersCount'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'PublicChatRoomItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PublicChatRoomItemStruct &&
        roomId == other.roomId &&
        title == other.title &&
        coverImageUrl == other.coverImageUrl &&
        activeUsersCount == other.activeUsersCount;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([roomId, title, coverImageUrl, activeUsersCount]);
}

PublicChatRoomItemStruct createPublicChatRoomItemStruct({
  String? roomId,
  String? title,
  String? coverImageUrl,
  int? activeUsersCount,
}) =>
    PublicChatRoomItemStruct(
      roomId: roomId,
      title: title,
      coverImageUrl: coverImageUrl,
      activeUsersCount: activeUsersCount,
    );
