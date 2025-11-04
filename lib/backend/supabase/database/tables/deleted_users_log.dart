import '../database.dart';

class DeletedUsersLogTable extends SupabaseTable<DeletedUsersLogRow> {
  @override
  String get tableName => 'deleted_users_log';

  @override
  DeletedUsersLogRow createRow(Map<String, dynamic> data) =>
      DeletedUsersLogRow(data);
}

class DeletedUsersLogRow extends SupabaseDataRow {
  DeletedUsersLogRow(super.data);

  @override
  SupabaseTable get table => DeletedUsersLogTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime get deletedAt => getField<DateTime>('deleted_at')!;
  set deletedAt(DateTime value) => setField<DateTime>('deleted_at', value);

  String? get emailHash => getField<String>('email_hash');
  set emailHash(String? value) => setField<String>('email_hash', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);
}
