// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class InboxResultStruct extends BaseStruct {
  InboxResultStruct({
    List<ConversationListItemStruct>? items,
  }) : _items = items;

  // "items" field.
  List<ConversationListItemStruct>? _items;
  List<ConversationListItemStruct> get items => _items ?? const [];
  set items(List<ConversationListItemStruct>? val) => _items = val;

  void updateItems(Function(List<ConversationListItemStruct>) updateFn) {
    updateFn(_items ??= []);
  }

  bool hasItems() => _items != null;

  static InboxResultStruct fromMap(Map<String, dynamic> data) =>
      InboxResultStruct(
        items: getStructList(
          data['items'],
          ConversationListItemStruct.fromMap,
        ),
      );

  static InboxResultStruct? maybeFromMap(dynamic data) => data is Map
      ? InboxResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'items': _items?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'items': serializeParam(
          _items,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static InboxResultStruct fromSerializableMap(Map<String, dynamic> data) =>
      InboxResultStruct(
        items: deserializeStructParam<ConversationListItemStruct>(
          data['items'],
          ParamType.DataStruct,
          true,
          structBuilder: ConversationListItemStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'InboxResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is InboxResultStruct &&
        listEquality.equals(items, other.items);
  }

  @override
  int get hashCode => const ListEquality().hash([items]);
}

InboxResultStruct createInboxResultStruct() => InboxResultStruct();
