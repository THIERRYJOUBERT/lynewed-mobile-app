import '../database.dart';

class UserBlocksTable extends SupabaseTable<UserBlocksRow> {
  @override
  String get tableName => 'user_blocks';

  @override
  UserBlocksRow createRow(Map<String, dynamic> data) => UserBlocksRow(data);
}

class UserBlocksRow extends SupabaseDataRow {
  UserBlocksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserBlocksTable();

  String get blockerProfileId => getField<String>('blocker_profile_id')!;
  set blockerProfileId(String value) =>
      setField<String>('blocker_profile_id', value);

  String get blockedProfileId => getField<String>('blocked_profile_id')!;
  set blockedProfileId(String value) =>
      setField<String>('blocked_profile_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
