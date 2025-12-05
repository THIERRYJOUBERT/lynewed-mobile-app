// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Structure for V2 images with multiple crop formats
/// Used for slideshow and portfolio images
class ImageV2Struct extends BaseStruct {
  ImageV2Struct({
    String? id,
    String? crop1x1,
    String? crop3x4,
    String? crop9x16,
  })  : _id = id,
        _crop1x1 = crop1x1,
        _crop3x4 = crop3x4,
        _crop9x16 = crop9x16;

  // "id" field - unique identifier for matching across formats
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;
  bool hasId() => _id != null;

  // "crop1x1" field - square format (500x500) for header slider
  String? _crop1x1;
  String get crop1x1 => _crop1x1 ?? '';
  set crop1x1(String? val) => _crop1x1 = val;
  bool hasCrop1x1() => _crop1x1 != null;

  // "crop3x4" field - vertical format (600x800) for portfolio grid
  String? _crop3x4;
  String get crop3x4 => _crop3x4 ?? '';
  set crop3x4(String? val) => _crop3x4 = val;
  bool hasCrop3x4() => _crop3x4 != null;

  // "crop9x16" field - fullscreen format (450x800) for detail view
  String? _crop9x16;
  String get crop9x16 => _crop9x16 ?? '';
  set crop9x16(String? val) => _crop9x16 = val;
  bool hasCrop9x16() => _crop9x16 != null;

  static ImageV2Struct fromMap(Map<String, dynamic> data) => ImageV2Struct(
        id: data['id'] as String?,
        crop1x1: data['crop_1x1'] as String?,
        crop3x4: data['crop_3x4'] as String?,
        crop9x16: data['crop_9x16'] as String?,
      );

  static ImageV2Struct? maybeFromMap(dynamic data) => data is Map
      ? ImageV2Struct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'crop_1x1': _crop1x1,
        'crop_3x4': _crop3x4,
        'crop_9x16': _crop9x16,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(_id, ParamType.String),
        'crop_1x1': serializeParam(_crop1x1, ParamType.String),
        'crop_3x4': serializeParam(_crop3x4, ParamType.String),
        'crop_9x16': serializeParam(_crop9x16, ParamType.String),
      }.withoutNulls;

  static ImageV2Struct fromSerializableMap(Map<String, dynamic> data) =>
      ImageV2Struct(
        id: deserializeParam(data['id'], ParamType.String, false),
        crop1x1: deserializeParam(data['crop_1x1'], ParamType.String, false),
        crop3x4: deserializeParam(data['crop_3x4'], ParamType.String, false),
        crop9x16: deserializeParam(data['crop_9x16'], ParamType.String, false),
      );

  @override
  String toString() => 'ImageV2Struct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ImageV2Struct &&
        id == other.id &&
        crop1x1 == other.crop1x1 &&
        crop3x4 == other.crop3x4 &&
        crop9x16 == other.crop9x16;
  }

  @override
  int get hashCode => const ListEquality().hash([id, crop1x1, crop3x4, crop9x16]);
}

ImageV2Struct createImageV2Struct({
  String? id,
  String? crop1x1,
  String? crop3x4,
  String? crop9x16,
}) =>
    ImageV2Struct(
      id: id,
      crop1x1: crop1x1,
      crop3x4: crop3x4,
      crop9x16: crop9x16,
    );
