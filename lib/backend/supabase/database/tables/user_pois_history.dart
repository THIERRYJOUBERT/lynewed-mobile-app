import '../database.dart';

class UserPoisHistoryTable extends SupabaseTable<UserPoisHistoryRow> {
  @override
  String get tableName => 'user_pois_history';

  @override
  UserPoisHistoryRow createRow(Map<String, dynamic> data) =>
      UserPoisHistoryRow(data);
}

class UserPoisHistoryRow extends SupabaseDataRow {
  UserPoisHistoryRow(super.data);

  @override
  SupabaseTable get table => UserPoisHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get poiId => getField<String>('poi_id');
  set poiId(String? value) => setField<String>('poi_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  dynamic get oldValues => getField<dynamic>('old_values');
  set oldValues(dynamic value) => setField<dynamic>('old_values', value);

  dynamic get newValues => getField<dynamic>('new_values');
  set newValues(dynamic value) => setField<dynamic>('new_values', value);

  String? get changedBy => getField<String>('changed_by');
  set changedBy(String? value) => setField<String>('changed_by', value);

  DateTime get changedAt => getField<DateTime>('changed_at')!;
  set changedAt(DateTime value) => setField<DateTime>('changed_at', value);
}
