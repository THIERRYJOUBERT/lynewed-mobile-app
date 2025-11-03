// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WedArticleStruct extends BaseStruct {
  WedArticleStruct({
    String? id,
    String? title,
    List<String>? coverImages,
    List<WedContentBlockStruct>? contentBlocks,
    ProDetailsStruct? professional,
  })  : _id = id,
        _title = title,
        _coverImages = coverImages,
        _contentBlocks = contentBlocks,
        _professional = professional;

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

  void updateCoverImages(Function(List<String>) updateFn) {
    updateFn(_coverImages ??= []);
  }

  bool hasCoverImages() => _coverImages != null;

  // "contentBlocks" field.
  List<WedContentBlockStruct>? _contentBlocks;
  List<WedContentBlockStruct> get contentBlocks => _contentBlocks ?? const [];
  set contentBlocks(List<WedContentBlockStruct>? val) => _contentBlocks = val;

  void updateContentBlocks(Function(List<WedContentBlockStruct>) updateFn) {
    updateFn(_contentBlocks ??= []);
  }

  bool hasContentBlocks() => _contentBlocks != null;

  // "professional" field.
  ProDetailsStruct? _professional;
  ProDetailsStruct get professional => _professional ?? ProDetailsStruct();
  set professional(ProDetailsStruct? val) => _professional = val;

  void updateProfessional(Function(ProDetailsStruct) updateFn) {
    updateFn(_professional ??= ProDetailsStruct());
  }

  bool hasProfessional() => _professional != null;

  static WedArticleStruct fromMap(Map<String, dynamic> data) =>
      WedArticleStruct(
        id: data['id'] as String?,
        title: data['title'] as String?,
        coverImages: getDataList(data['coverImages']),
        contentBlocks: getStructList(
          data['contentBlocks'],
          WedContentBlockStruct.fromMap,
        ),
        professional: data['professional'] is ProDetailsStruct
            ? data['professional']
            : ProDetailsStruct.maybeFromMap(data['professional']),
      );

  static WedArticleStruct? maybeFromMap(dynamic data) => data is Map
      ? WedArticleStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'title': _title,
        'coverImages': _coverImages,
        'contentBlocks': _contentBlocks?.map((e) => e.toMap()).toList(),
        'professional': _professional?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'coverImages': serializeParam(
          _coverImages,
          ParamType.String,
          isList: true,
        ),
        'contentBlocks': serializeParam(
          _contentBlocks,
          ParamType.DataStruct,
          isList: true,
        ),
        'professional': serializeParam(
          _professional,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static WedArticleStruct fromSerializableMap(Map<String, dynamic> data) =>
      WedArticleStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        coverImages: deserializeParam<String>(
          data['coverImages'],
          ParamType.String,
          true,
        ),
        contentBlocks: deserializeStructParam<WedContentBlockStruct>(
          data['contentBlocks'],
          ParamType.DataStruct,
          true,
          structBuilder: WedContentBlockStruct.fromSerializableMap,
        ),
        professional: deserializeStructParam(
          data['professional'],
          ParamType.DataStruct,
          false,
          structBuilder: ProDetailsStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'WedArticleStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is WedArticleStruct &&
        id == other.id &&
        title == other.title &&
        listEquality.equals(coverImages, other.coverImages) &&
        listEquality.equals(contentBlocks, other.contentBlocks) &&
        professional == other.professional;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([id, title, coverImages, contentBlocks, professional]);
}

WedArticleStruct createWedArticleStruct({
  String? id,
  String? title,
  ProDetailsStruct? professional,
}) =>
    WedArticleStruct(
      id: id,
      title: title,
      professional: professional ?? ProDetailsStruct(),
    );
