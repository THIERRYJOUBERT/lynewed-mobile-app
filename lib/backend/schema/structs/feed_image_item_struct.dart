// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FeedImageItemStruct extends BaseStruct {
  FeedImageItemStruct({
    String? imageUrl,
    String? fullscreenUrl,
    String? imageId,
    int? imageIndex,
    String? proProfileId,
    String? proFullName,
    String? proAvatarUrl,
    Profession? proProfession,
    String? proLocationLabel,
    bool? isFavorited,
  })  : _imageUrl = imageUrl,
        _fullscreenUrl = fullscreenUrl,
        _imageId = imageId,
        _imageIndex = imageIndex,
        _proProfileId = proProfileId,
        _proFullName = proFullName,
        _proAvatarUrl = proAvatarUrl,
        _proProfession = proProfession,
        _proLocationLabel = proLocationLabel,
        _isFavorited = isFavorited;

  // "imageUrl" field - crop_3x4 for grid display
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  // "fullscreenUrl" field - crop_9x16 for fullscreen display
  String? _fullscreenUrl;
  String get fullscreenUrl => _fullscreenUrl ?? _imageUrl ?? '';
  set fullscreenUrl(String? val) => _fullscreenUrl = val;

  bool hasFullscreenUrl() => _fullscreenUrl != null;

  // "imageId" field - unique ID for matching across formats
  String? _imageId;
  String get imageId => _imageId ?? '';
  set imageId(String? val) => _imageId = val;

  bool hasImageId() => _imageId != null;

  // "imageIndex" field.
  int? _imageIndex;
  int get imageIndex => _imageIndex ?? 0;
  set imageIndex(int? val) => _imageIndex = val;

  void incrementImageIndex(int amount) => imageIndex = imageIndex + amount;

  bool hasImageIndex() => _imageIndex != null;

  // "proProfileId" field.
  String? _proProfileId;
  String get proProfileId => _proProfileId ?? '';
  set proProfileId(String? val) => _proProfileId = val;

  bool hasProProfileId() => _proProfileId != null;

  // "proFullName" field.
  String? _proFullName;
  String get proFullName => _proFullName ?? '';
  set proFullName(String? val) => _proFullName = val;

  bool hasProFullName() => _proFullName != null;

  // "proAvatarUrl" field.
  String? _proAvatarUrl;
  String get proAvatarUrl => _proAvatarUrl ?? '';
  set proAvatarUrl(String? val) => _proAvatarUrl = val;

  bool hasProAvatarUrl() => _proAvatarUrl != null;

  // "proProfession" field.
  Profession? _proProfession;
  Profession? get proProfession => _proProfession;
  set proProfession(Profession? val) => _proProfession = val;

  bool hasProProfession() => _proProfession != null;

  // "proLocationLabel" field.
  String? _proLocationLabel;
  String get proLocationLabel => _proLocationLabel ?? '';
  set proLocationLabel(String? val) => _proLocationLabel = val;

  bool hasProLocationLabel() => _proLocationLabel != null;

  // "isFavorited" field.
  bool? _isFavorited;
  bool get isFavorited => _isFavorited ?? false;
  set isFavorited(bool? val) => _isFavorited = val;

  bool hasIsFavorited() => _isFavorited != null;

  static FeedImageItemStruct fromMap(Map<String, dynamic> data) =>
      FeedImageItemStruct(
        imageUrl: data['imageUrl'] as String?,
        fullscreenUrl: data['fullscreenUrl'] as String?,
        imageId: data['imageId'] as String?,
        imageIndex: castToType<int>(data['imageIndex']),
        proProfileId: data['proProfileId'] as String?,
        proFullName: data['proFullName'] as String?,
        proAvatarUrl: data['proAvatarUrl'] as String?,
        proProfession: data['proProfession'] is Profession
            ? data['proProfession']
            : deserializeEnum<Profession>(data['proProfession']),
        proLocationLabel: data['proLocationLabel'] as String?,
        isFavorited: data['isFavorited'] as bool?,
      );

  static FeedImageItemStruct? maybeFromMap(dynamic data) => data is Map
      ? FeedImageItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'imageUrl': _imageUrl,
        'fullscreenUrl': _fullscreenUrl,
        'imageId': _imageId,
        'imageIndex': _imageIndex,
        'proProfileId': _proProfileId,
        'proFullName': _proFullName,
        'proAvatarUrl': _proAvatarUrl,
        'proProfession': _proProfession?.serialize(),
        'proLocationLabel': _proLocationLabel,
        'isFavorited': _isFavorited,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
        'fullscreenUrl': serializeParam(
          _fullscreenUrl,
          ParamType.String,
        ),
        'imageId': serializeParam(
          _imageId,
          ParamType.String,
        ),
        'imageIndex': serializeParam(
          _imageIndex,
          ParamType.int,
        ),
        'proProfileId': serializeParam(
          _proProfileId,
          ParamType.String,
        ),
        'proFullName': serializeParam(
          _proFullName,
          ParamType.String,
        ),
        'proAvatarUrl': serializeParam(
          _proAvatarUrl,
          ParamType.String,
        ),
        'proProfession': serializeParam(
          _proProfession,
          ParamType.Enum,
        ),
        'proLocationLabel': serializeParam(
          _proLocationLabel,
          ParamType.String,
        ),
        'isFavorited': serializeParam(
          _isFavorited,
          ParamType.bool,
        ),
      }.withoutNulls;

  static FeedImageItemStruct fromSerializableMap(Map<String, dynamic> data) =>
      FeedImageItemStruct(
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        fullscreenUrl: deserializeParam(
          data['fullscreenUrl'],
          ParamType.String,
          false,
        ),
        imageId: deserializeParam(
          data['imageId'],
          ParamType.String,
          false,
        ),
        imageIndex: deserializeParam(
          data['imageIndex'],
          ParamType.int,
          false,
        ),
        proProfileId: deserializeParam(
          data['proProfileId'],
          ParamType.String,
          false,
        ),
        proFullName: deserializeParam(
          data['proFullName'],
          ParamType.String,
          false,
        ),
        proAvatarUrl: deserializeParam(
          data['proAvatarUrl'],
          ParamType.String,
          false,
        ),
        proProfession: deserializeParam<Profession>(
          data['proProfession'],
          ParamType.Enum,
          false,
        ),
        proLocationLabel: deserializeParam(
          data['proLocationLabel'],
          ParamType.String,
          false,
        ),
        isFavorited: deserializeParam(
          data['isFavorited'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'FeedImageItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is FeedImageItemStruct &&
        imageUrl == other.imageUrl &&
        fullscreenUrl == other.fullscreenUrl &&
        imageId == other.imageId &&
        imageIndex == other.imageIndex &&
        proProfileId == other.proProfileId &&
        proFullName == other.proFullName &&
        proAvatarUrl == other.proAvatarUrl &&
        proProfession == other.proProfession &&
        proLocationLabel == other.proLocationLabel &&
        isFavorited == other.isFavorited;
  }

  @override
  int get hashCode => const ListEquality().hash([
        imageUrl,
        fullscreenUrl,
        imageId,
        imageIndex,
        proProfileId,
        proFullName,
        proAvatarUrl,
        proProfession,
        proLocationLabel,
        isFavorited
      ]);
}

FeedImageItemStruct createFeedImageItemStruct({
  String? imageUrl,
  String? fullscreenUrl,
  String? imageId,
  int? imageIndex,
  String? proProfileId,
  String? proFullName,
  String? proAvatarUrl,
  Profession? proProfession,
  String? proLocationLabel,
  bool? isFavorited,
}) =>
    FeedImageItemStruct(
      imageUrl: imageUrl,
      fullscreenUrl: fullscreenUrl,
      imageId: imageId,
      imageIndex: imageIndex,
      proProfileId: proProfileId,
      proFullName: proFullName,
      proAvatarUrl: proAvatarUrl,
      proProfession: proProfession,
      proLocationLabel: proLocationLabel,
      isFavorited: isFavorited,
    );
