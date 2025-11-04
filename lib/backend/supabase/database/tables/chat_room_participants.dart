import '../database.dart';

class ChatRoomParticipantsTable extends SupabaseTable<ChatRoomParticipantsRow> {
  @override
  String get tableName => 'chat_room_participants';

  @override
  ChatRoomParticipantsRow createRow(Map<String, dynamic> data) =>
      ChatRoomParticipantsRow(data);
}

class ChatRoomParticipantsRow extends SupabaseDataRow {
  ChatRoomParticipantsRow(super.data);

  @override
  SupabaseTable get table => ChatRoomParticipantsTable();

  String get roomId => getField<String>('room_id')!;
  set roomId(String value) => setField<String>('room_id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get conversationStatus => getField<String>('conversation_status')!;
  set conversationStatus(String value) =>
      setField<String>('conversation_status', value);

  DateTime get joinedAt => getField<DateTime>('joined_at')!;
  set joinedAt(DateTime value) => setField<DateTime>('joined_at', value);

  DateTime? get lastReadAt => getField<DateTime>('last_read_at');
  set lastReadAt(DateTime? value) => setField<DateTime>('last_read_at', value);
}
