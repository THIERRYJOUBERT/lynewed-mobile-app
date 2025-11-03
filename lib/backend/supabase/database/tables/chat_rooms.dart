import '../database.dart';

class ChatRoomsTable extends SupabaseTable<ChatRoomsRow> {
  @override
  String get tableName => 'chat_rooms';

  @override
  ChatRoomsRow createRow(Map<String, dynamic> data) => ChatRoomsRow(data);
}

class ChatRoomsRow extends SupabaseDataRow {
  ChatRoomsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ChatRoomsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
