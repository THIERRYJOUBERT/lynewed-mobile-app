// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PublicRoomsResultStruct extends BaseStruct {
  PublicRoomsResultStruct({
    List<PublicChatRoomItemStruct>? items,
  }) : _items = items;

  // "items" field.
  List<PublicChatRoomItemStruct>? _items;
  List<PublicChatRoomItemStruct> get items => _items ?? const [];
  set items(List<PublicChatRoomItemStruct>? val) => _items = val;

  void updateItems(Function(List<PublicChatRoomItemStruct>) updateFn) {
    updateFn(_items ??= []);
  }

  bool hasItems() => _items != null;

  static PublicRoomsResultStruct fromMap(Map<String, dynamic> data) =>
      PublicRoomsResultStruct(
        items: getStructList(
          data['items'],
          PublicChatRoomItemStruct.fromMap,
        ),
      );

  static PublicRoomsResultStruct? maybeFromMap(dynamic data) => data is Map
      ? PublicRoomsResultStruct.fromMap(data.cast<String, dynamic>())
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

  static PublicRoomsResultStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      PublicRoomsResultStruct(
        items: deserializeStructParam<PublicChatRoomItemStruct>(
          data['items'],
          ParamType.DataStruct,
          true,
          structBuilder: PublicChatRoomItemStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'PublicRoomsResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is PublicRoomsResultStruct &&
        listEquality.equals(items, other.items);
  }

  @override
  int get hashCode => const ListEquality().hash([items]);
}

PublicRoomsResultStruct createPublicRoomsResultStruct() =>
    PublicRoomsResultStruct();
