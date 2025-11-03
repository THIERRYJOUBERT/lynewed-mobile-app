import '../database.dart';

class VideoSessionsTable extends SupabaseTable<VideoSessionsRow> {
  @override
  String get tableName => 'video_sessions';

  @override
  VideoSessionsRow createRow(Map<String, dynamic> data) =>
      VideoSessionsRow(data);
}

class VideoSessionsRow extends SupabaseDataRow {
  VideoSessionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VideoSessionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get initiatorId => getField<String>('initiator_id')!;
  set initiatorId(String value) => setField<String>('initiator_id', value);

  String get receiverId => getField<String>('receiver_id')!;
  set receiverId(String value) => setField<String>('receiver_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get agoraChannelName => getField<String>('agora_channel_name')!;
  set agoraChannelName(String value) =>
      setField<String>('agora_channel_name', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get acceptedAt => getField<DateTime>('accepted_at');
  set acceptedAt(DateTime? value) => setField<DateTime>('accepted_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);
}
