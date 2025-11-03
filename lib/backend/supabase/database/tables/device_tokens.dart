import '../database.dart';

class DeviceTokensTable extends SupabaseTable<DeviceTokensRow> {
  @override
  String get tableName => 'device_tokens';

  @override
  DeviceTokensRow createRow(Map<String, dynamic> data) => DeviceTokensRow(data);
}

class DeviceTokensRow extends SupabaseDataRow {
  DeviceTokensRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DeviceTokensTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get token => getField<String>('token')!;
  set token(String value) => setField<String>('token', value);

  String get platform => getField<String>('platform')!;
  set platform(String value) => setField<String>('platform', value);

  DateTime get lastSeenAt => getField<DateTime>('last_seen_at')!;
  set lastSeenAt(DateTime value) => setField<DateTime>('last_seen_at', value);
}
