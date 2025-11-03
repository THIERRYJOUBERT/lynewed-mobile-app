// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ContactRequestsResultStruct extends BaseStruct {
  ContactRequestsResultStruct({
    List<ContactRequestItemStruct>? items,
  }) : _items = items;

  // "items" field.
  List<ContactRequestItemStruct>? _items;
  List<ContactRequestItemStruct> get items => _items ?? const [];
  set items(List<ContactRequestItemStruct>? val) => _items = val;

  void updateItems(Function(List<ContactRequestItemStruct>) updateFn) {
    updateFn(_items ??= []);
  }

  bool hasItems() => _items != null;

  static ContactRequestsResultStruct fromMap(Map<String, dynamic> data) =>
      ContactRequestsResultStruct(
        items: getStructList(
          data['items'],
          ContactRequestItemStruct.fromMap,
        ),
      );

  static ContactRequestsResultStruct? maybeFromMap(dynamic data) => data is Map
      ? ContactRequestsResultStruct.fromMap(data.cast<String, dynamic>())
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

  static ContactRequestsResultStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ContactRequestsResultStruct(
        items: deserializeStructParam<ContactRequestItemStruct>(
          data['items'],
          ParamType.DataStruct,
          true,
          structBuilder: ContactRequestItemStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'ContactRequestsResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ContactRequestsResultStruct &&
        listEquality.equals(items, other.items);
  }

  @override
  int get hashCode => const ListEquality().hash([items]);
}

ContactRequestsResultStruct createContactRequestsResultStruct() =>
    ContactRequestsResultStruct();
