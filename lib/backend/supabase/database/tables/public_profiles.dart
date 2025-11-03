import '../database.dart';

class PublicProfilesTable extends SupabaseTable<PublicProfilesRow> {
  @override
  String get tableName => 'public_profiles';

  @override
  PublicProfilesRow createRow(Map<String, dynamic> data) =>
      PublicProfilesRow(data);
}

class PublicProfilesRow extends SupabaseDataRow {
  PublicProfilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PublicProfilesTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  String? get country => getField<String>('country');
  set country(String? value) => setField<String>('country', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
