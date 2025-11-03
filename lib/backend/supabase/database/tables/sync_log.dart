import '../database.dart';

class SyncLogTable extends SupabaseTable<SyncLogRow> {
  @override
  String get tableName => 'sync_log';

  @override
  SyncLogRow createRow(Map<String, dynamic> data) => SyncLogRow(data);
}

class SyncLogRow extends SupabaseDataRow {
  SyncLogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SyncLogTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get proId => getField<String>('pro_id');
  set proId(String? value) => setField<String>('pro_id', value);

  String? get operation => getField<String>('operation');
  set operation(String? value) => setField<String>('operation', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get error => getField<String>('error');
  set error(String? value) => setField<String>('error', value);

  DateTime? get syncedAt => getField<DateTime>('synced_at');
  set syncedAt(DateTime? value) => setField<DateTime>('synced_at', value);
}
