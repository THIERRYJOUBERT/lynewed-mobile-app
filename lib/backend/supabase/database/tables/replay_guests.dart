import '../database.dart';

class ReplayGuestsTable extends SupabaseTable<ReplayGuestsRow> {
  @override
  String get tableName => 'replay_guests';

  @override
  ReplayGuestsRow createRow(Map<String, dynamic> data) => ReplayGuestsRow(data);
}

class ReplayGuestsRow extends SupabaseDataRow {
  ReplayGuestsRow(super.data);

  @override
  SupabaseTable get table => ReplayGuestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String? get profession => getField<String>('profession');
  set profession(String? value) => setField<String>('profession', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
