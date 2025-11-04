// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReplayItemStruct extends BaseStruct {
  ReplayItemStruct({
    String? replayId,
    String? title,
    String? description,
    String? youtubeUrl,
    String? thumbnailUrl,
    DateTime? publishedAt,
    bool? isFeatured,
    List<ReplayGuestItemStruct>? guests,
  })  : _replayId = replayId,
        _title = title,
        _description = description,
        _youtubeUrl = youtubeUrl,
        _thumbnailUrl = thumbnailUrl,
        _publishedAt = publishedAt,
        _isFeatured = isFeatured,
        _guests = guests;

  // "replayId" field.
  String? _replayId;
  String get replayId => _replayId ?? '';
  set replayId(String? val) => _replayId = val;

  bool hasReplayId() => _replayId != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  set description(String? val) => _description = val;

  bool hasDescription() => _description != null;

  // "youtubeUrl" field.
  String? _youtubeUrl;
  String get youtubeUrl => _youtubeUrl ?? '';
  set youtubeUrl(String? val) => _youtubeUrl = val;

  bool hasYoutubeUrl() => _youtubeUrl != null;

  // "thumbnailUrl" field.
  String? _thumbnailUrl;
  String get thumbnailUrl => _thumbnailUrl ?? '';
  set thumbnailUrl(String? val) => _thumbnailUrl = val;

  bool hasThumbnailUrl() => _thumbnailUrl != null;

  // "publishedAt" field.
  DateTime? _publishedAt;
  DateTime? get publishedAt => _publishedAt;
  set publishedAt(DateTime? val) => _publishedAt = val;

  bool hasPublishedAt() => _publishedAt != null;

  // "isFeatured" field.
  bool? _isFeatured;
  bool get isFeatured => _isFeatured ?? false;
  set isFeatured(bool? val) => _isFeatured = val;

  bool hasIsFeatured() => _isFeatured != null;

  // "guests" field.
  List<ReplayGuestItemStruct>? _guests;
  List<ReplayGuestItemStruct> get guests => _guests ?? const [];
  set guests(List<ReplayGuestItemStruct>? val) => _guests = val;

  void updateGuests(Function(List<ReplayGuestItemStruct>) updateFn) {
    updateFn(_guests ??= []);
  }

  bool hasGuests() => _guests != null;

  static ReplayItemStruct fromMap(Map<String, dynamic> data) =>
      ReplayItemStruct(
        replayId: data['replayId'] as String?,
        title: data['title'] as String?,
        description: data['description'] as String?,
        youtubeUrl: data['youtubeUrl'] as String?,
        thumbnailUrl: data['thumbnailUrl'] as String?,
        publishedAt: data['publishedAt'] as DateTime?,
        isFeatured: data['isFeatured'] as bool?,
        guests: getStructList(
          data['guests'],
          ReplayGuestItemStruct.fromMap,
        ),
      );

  static ReplayItemStruct? maybeFromMap(dynamic data) => data is Map
      ? ReplayItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'replayId': _replayId,
        'title': _title,
        'description': _description,
        'youtubeUrl': _youtubeUrl,
        'thumbnailUrl': _thumbnailUrl,
        'publishedAt': _publishedAt,
        'isFeatured': _isFeatured,
        'guests': _guests?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'replayId': serializeParam(
          _replayId,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'description': serializeParam(
          _description,
          ParamType.String,
        ),
        'youtubeUrl': serializeParam(
          _youtubeUrl,
          ParamType.String,
        ),
        'thumbnailUrl': serializeParam(
          _thumbnailUrl,
          ParamType.String,
        ),
        'publishedAt': serializeParam(
          _publishedAt,
          ParamType.DateTime,
        ),
        'isFeatured': serializeParam(
          _isFeatured,
          ParamType.bool,
        ),
        'guests': serializeParam(
          _guests,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static ReplayItemStruct fromSerializableMap(Map<String, dynamic> data) =>
      ReplayItemStruct(
        replayId: deserializeParam(
          data['replayId'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        description: deserializeParam(
          data['description'],
          ParamType.String,
          false,
        ),
        youtubeUrl: deserializeParam(
          data['youtubeUrl'],
          ParamType.String,
          false,
        ),
        thumbnailUrl: deserializeParam(
          data['thumbnailUrl'],
          ParamType.String,
          false,
        ),
        publishedAt: deserializeParam(
          data['publishedAt'],
          ParamType.DateTime,
          false,
        ),
        isFeatured: deserializeParam(
          data['isFeatured'],
          ParamType.bool,
          false,
        ),
        guests: deserializeStructParam<ReplayGuestItemStruct>(
          data['guests'],
          ParamType.DataStruct,
          true,
          structBuilder: ReplayGuestItemStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'ReplayItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ReplayItemStruct &&
        replayId == other.replayId &&
        title == other.title &&
        description == other.description &&
        youtubeUrl == other.youtubeUrl &&
        thumbnailUrl == other.thumbnailUrl &&
        publishedAt == other.publishedAt &&
        isFeatured == other.isFeatured &&
        listEquality.equals(guests, other.guests);
  }

  @override
  int get hashCode => const ListEquality().hash([
        replayId,
        title,
        description,
        youtubeUrl,
        thumbnailUrl,
        publishedAt,
        isFeatured,
        guests
      ]);
}

ReplayItemStruct createReplayItemStruct({
  String? replayId,
  String? title,
  String? description,
  String? youtubeUrl,
  String? thumbnailUrl,
  DateTime? publishedAt,
  bool? isFeatured,
}) =>
    ReplayItemStruct(
      replayId: replayId,
      title: title,
      description: description,
      youtubeUrl: youtubeUrl,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
      isFeatured: isFeatured,
    );
