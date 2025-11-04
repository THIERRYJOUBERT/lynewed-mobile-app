// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FeedResultStruct extends BaseStruct {
  FeedResultStruct({
    List<ProSummaryStruct>? items,
    String? nextCursor,
  })  : _items = items,
        _nextCursor = nextCursor;

  // "items" field.
  List<ProSummaryStruct>? _items;
  List<ProSummaryStruct> get items => _items ?? const [];
  set items(List<ProSummaryStruct>? val) => _items = val;

  void updateItems(Function(List<ProSummaryStruct>) updateFn) {
    updateFn(_items ??= []);
  }

  bool hasItems() => _items != null;

  // "nextCursor" field.
  String? _nextCursor;
  String get nextCursor => _nextCursor ?? '';
  set nextCursor(String? val) => _nextCursor = val;

  bool hasNextCursor() => _nextCursor != null;

  static FeedResultStruct fromMap(Map<String, dynamic> data) =>
      FeedResultStruct(
        items: getStructList(
          data['items'],
          ProSummaryStruct.fromMap,
        ),
        nextCursor: data['nextCursor'] as String?,
      );

  static FeedResultStruct? maybeFromMap(dynamic data) => data is Map
      ? FeedResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'items': _items?.map((e) => e.toMap()).toList(),
        'nextCursor': _nextCursor,
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
      }.withoutNulls;

  static FeedResultStruct fromSerializableMap(Map<String, dynamic> data) =>
      FeedResultStruct(
        items: deserializeStructParam<ProSummaryStruct>(
          data['items'],
          ParamType.DataStruct,
          true,
          structBuilder: ProSummaryStruct.fromSerializableMap,
        ),
        nextCursor: deserializeParam(
          data['nextCursor'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'FeedResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is FeedResultStruct &&
        listEquality.equals(items, other.items) &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode => const ListEquality().hash([items, nextCursor]);
}

FeedResultStruct createFeedResultStruct({
  String? nextCursor,
}) =>
    FeedResultStruct(
      nextCursor: nextCursor,
    );
