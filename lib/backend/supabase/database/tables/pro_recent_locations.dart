import '../database.dart';

class ProRecentLocationsTable extends SupabaseTable<ProRecentLocationsRow> {
  @override
  String get tableName => 'pro_recent_locations';

  @override
  ProRecentLocationsRow createRow(Map<String, dynamic> data) =>
      ProRecentLocationsRow(data);
}

class ProRecentLocationsRow extends SupabaseDataRow {
  ProRecentLocationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProRecentLocationsTable();

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get coordsApprox => getField<String>('coords_approx')!;
  set coordsApprox(String value) => setField<String>('coords_approx', value);

  DateTime get lastSeenAt => getField<DateTime>('last_seen_at')!;
  set lastSeenAt(DateTime value) => setField<DateTime>('last_seen_at', value);

  bool get isOptIn => getField<bool>('is_opt_in')!;
  set isOptIn(bool value) => setField<bool>('is_opt_in', value);
}
