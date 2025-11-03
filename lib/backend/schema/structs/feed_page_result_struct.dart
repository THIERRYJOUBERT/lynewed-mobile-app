// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FeedPageResultStruct extends BaseStruct {
  FeedPageResultStruct({
    List<FeedImageItemStruct>? items,
    String? nextCursor,
    String? newSeed,
  })  : _items = items,
        _nextCursor = nextCursor,
        _newSeed = newSeed;

  // "items" field.
  List<FeedImageItemStruct>? _items;
  List<FeedImageItemStruct> get items => _items ?? const [];
  set items(List<FeedImageItemStruct>? val) => _items = val;

  void updateItems(Function(List<FeedImageItemStruct>) updateFn) {
    updateFn(_items ??= []);
  }

  bool hasItems() => _items != null;

  // "nextCursor" field.
  String? _nextCursor;
  String get nextCursor => _nextCursor ?? '';
  set nextCursor(String? val) => _nextCursor = val;

  bool hasNextCursor() => _nextCursor != null;

  // "newSeed" field.
  String? _newSeed;
  String get newSeed => _newSeed ?? '';
  set newSeed(String? val) => _newSeed = val;

  bool hasNewSeed() => _newSeed != null;

  static FeedPageResultStruct fromMap(Map<String, dynamic> data) =>
      FeedPageResultStruct(
        items: getStructList(
          data['items'],
          FeedImageItemStruct.fromMap,
        ),
        nextCursor: data['nextCursor'] as String?,
        newSeed: data['newSeed'] as String?,
      );

  static FeedPageResultStruct? maybeFromMap(dynamic data) => data is Map
      ? FeedPageResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'items': _items?.map((e) => e.toMap()).toList(),
        'nextCursor': _nextCursor,
        'newSeed': _newSeed,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'items': serializeParam(
          _items,
          ParamType.DataStruct,
          isList: true,
        ),
        'nextCursor': serializeParam(
          _nextCursor,
          ParamType.String,
        ),
        'newSeed': serializeParam(
          _newSeed,
          ParamType.String,
        ),
      }.withoutNulls;

  static FeedPageResultStruct fromSerializableMap(Map<String, dynamic> data) =>
      FeedPageResultStruct(
        items: deserializeStructParam<FeedImageItemStruct>(
          data['items'],
          ParamType.DataStruct,
          true,
          structBuilder: FeedImageItemStruct.fromSerializableMap,
        ),
        nextCursor: deserializeParam(
          data['nextCursor'],
          ParamType.String,
          false,
        ),
        newSeed: deserializeParam(
          data['newSeed'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'FeedPageResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is FeedPageResultStruct &&
        listEquality.equals(items, other.items) &&
        nextCursor == other.nextCursor &&
        newSeed == other.newSeed;
  }

  @override
  int get hashCode => const ListEquality().hash([items, nextCursor, newSeed]);
}

FeedPageResultStruct createFeedPageResultStruct({
  String? nextCursor,
  String? newSeed,
}) =>
    FeedPageResultStruct(
      nextCursor: nextCursor,
      newSeed: newSeed,
    );
