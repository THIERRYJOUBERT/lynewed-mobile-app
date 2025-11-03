// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WedContentBlockStruct extends BaseStruct {
  WedContentBlockStruct({
    String? type,
    String? text,
    List<String>? imageUrls,
    String? layout,
    int? columns,
  })  : _type = type,
        _text = text,
        _imageUrls = imageUrls,
        _layout = layout,
        _columns = columns;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  // "imageUrls" field.
  List<String>? _imageUrls;
  List<String> get imageUrls => _imageUrls ?? const [];
  set imageUrls(List<String>? val) => _imageUrls = val;

  void updateImageUrls(Function(List<String>) updateFn) {
    updateFn(_imageUrls ??= []);
  }

  bool hasImageUrls() => _imageUrls != null;

  // "layout" field.
  String? _layout;
  String get layout => _layout ?? '';
  set layout(String? val) => _layout = val;

  bool hasLayout() => _layout != null;

  // "columns" field.
  int? _columns;
  int get columns => _columns ?? 0;
  set columns(int? val) => _columns = val;

  void incrementColumns(int amount) => columns = columns + amount;

  bool hasColumns() => _columns != null;

  static WedContentBlockStruct fromMap(Map<String, dynamic> data) =>
      WedContentBlockStruct(
        type: data['type'] as String?,
        text: data['text'] as String?,
        imageUrls: getDataList(data['imageUrls']),
        layout: data['layout'] as String?,
        columns: castToType<int>(data['columns']),
      );

  static WedContentBlockStruct? maybeFromMap(dynamic data) => data is Map
      ? WedContentBlockStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'type': _type,
        'text': _text,
        'imageUrls': _imageUrls,
        'layout': _layout,
        'columns': _columns,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
        'imageUrls': serializeParam(
          _imageUrls,
          ParamType.String,
          isList: true,
        ),
        'layout': serializeParam(
          _layout,
          ParamType.String,
        ),
        'columns': serializeParam(
          _columns,
          ParamType.int,
        ),
      }.withoutNulls;

  static WedContentBlockStruct fromSerializableMap(Map<String, dynamic> data) =>
      WedContentBlockStruct(
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
        imageUrls: deserializeParam<String>(
          data['imageUrls'],
          ParamType.String,
          true,
        ),
        layout: deserializeParam(
          data['layout'],
          ParamType.String,
          false,
        ),
        columns: deserializeParam(
          data['columns'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'WedContentBlockStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is WedContentBlockStruct &&
        type == other.type &&
        text == other.text &&
        listEquality.equals(imageUrls, other.imageUrls) &&
        layout == other.layout &&
        columns == other.columns;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([type, text, imageUrls, layout, columns]);
}

WedContentBlockStruct createWedContentBlockStruct({
  String? type,
  String? text,
  String? layout,
  int? columns,
}) =>
    WedContentBlockStruct(
      type: type,
      text: text,
      layout: layout,
      columns: columns,
    );
