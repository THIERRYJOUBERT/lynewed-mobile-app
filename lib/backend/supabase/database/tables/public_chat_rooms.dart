import '../database.dart';

class PublicChatRoomsTable extends SupabaseTable<PublicChatRoomsRow> {
  @override
  String get tableName => 'public_chat_rooms';

  @override
  PublicChatRoomsRow createRow(Map<String, dynamic> data) =>
      PublicChatRoomsRow(data);
}

class PublicChatRoomsRow extends SupabaseDataRow {
  PublicChatRoomsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PublicChatRoomsTable();

  String get chatRoomId => getField<String>('chat_room_id')!;
  set chatRoomId(String value) => setField<String>('chat_room_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get coverImageUrl => getField<String>('cover_image_url');
  set coverImageUrl(String? value) =>
      setField<String>('cover_image_url', value);

  String get audienceRole => getField<String>('audience_role')!;
  set audienceRole(String value) => setField<String>('audience_role', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
