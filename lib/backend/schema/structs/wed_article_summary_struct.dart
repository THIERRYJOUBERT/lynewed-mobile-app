// ignore_for_file: unnecessary_getters_setters

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Simplified struct for WOTW history list (no content blocks, no professional)
class WedArticleSummaryStruct extends BaseStruct {
  WedArticleSummaryStruct({
    String? id,
    String? title,
    List<String>? coverImages,
    DateTime? publishedAt,
  })  : _id = id,
        _title = title,
        _coverImages = coverImages,
        _publishedAt = publishedAt;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;
  bool hasId() => _id != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;
  bool hasTitle() => _title != null;

  // "coverImages" field.
  List<String>? _coverImages;
  List<String> get coverImages => _coverImages ?? const [];
  set coverImages(List<String>? val) => _coverImages = val;
  bool hasCoverImages() => _coverImages != null;

  // "publishedAt" field.
  DateTime? _publishedAt;
  DateTime? get publishedAt => _publishedAt;
  set publishedAt(DateTime? val) => _publishedAt = val;
  bool hasPublishedAt() => _publishedAt != null;

  /// First cover image URL (for thumbnail)
  String? get thumbnailUrl => coverImages.isNotEmpty ? coverImages.first : null;

  /// Formatted published date
  String get publishedDateFormatted {
    if (_publishedAt == null) return '';
    return '${_publishedAt!.day}/${_publishedAt!.month}/${_publishedAt!.year}';
  }

  static WedArticleSummaryStruct fromMap(Map<String, dynamic> data) =>
      WedArticleSummaryStruct(
        id: data['id'] as String?,
        title: data['title'] as String?,
        coverImages: getDataList(data['coverImages']),
        publishedAt: data['publishedAt'] is DateTime
            ? data['publishedAt']
            : (data['publishedAt'] is String
                ? DateTime.tryParse(data['publishedAt'])
                : null),
      );

  static WedArticleSummaryStruct? maybeFromMap(dynamic data) => data is Map
      ? WedArticleSummaryStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'title': _title,
        'coverImages': _coverImages,
        'publishedAt': _publishedAt?.toIso8601String(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(_id, ParamType.String),
        'title': serializeParam(_title, ParamType.String),
        'coverImages': serializeParam(_coverImages, ParamType.String, isList: true),
        'publishedAt': serializeParam(_publishedAt, ParamType.DateTime),
      }.withoutNulls;

  static WedArticleSummaryStruct fromSerializableMap(Map<String, dynamic> data) =>
      WedArticleSummaryStruct(
        id: deserializeParam(data['id'], ParamType.String, false),
        title: deserializeParam(data['title'], ParamType.String, false),
        coverImages: deserializeParam<String>(data['coverImages'], ParamType.String, true),
        publishedAt: deserializeParam(data['publishedAt'], ParamType.DateTime, false),
      );

  @override
  String toString() => 'WedArticleSummaryStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is WedArticleSummaryStruct &&
        id == other.id &&
        title == other.title &&
        listEquality.equals(coverImages, other.coverImages) &&
        publishedAt == other.publishedAt;
  }

  @override
  int get hashCode => const ListEquality().hash([id, title, coverImages, publishedAt]);
}
