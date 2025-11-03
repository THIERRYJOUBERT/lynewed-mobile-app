import '../database.dart';

class SyncControlTable extends SupabaseTable<SyncControlRow> {
  @override
  String get tableName => 'sync_control';

  @override
  SyncControlRow createRow(Map<String, dynamic> data) => SyncControlRow(data);
}

class SyncControlRow extends SupabaseDataRow {
  SyncControlRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SyncControlTable();

  String get syncType => getField<String>('sync_type')!;
  set syncType(String value) => setField<String>('sync_type', value);

  DateTime get lastSyncTimestamp => getField<DateTime>('last_sync_timestamp')!;
  set lastSyncTimestamp(DateTime value) =>
      setField<DateTime>('last_sync_timestamp', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
