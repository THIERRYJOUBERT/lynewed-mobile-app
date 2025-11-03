import '../database.dart';

class UserLegalAcceptancesTable extends SupabaseTable<UserLegalAcceptancesRow> {
  @override
  String get tableName => 'user_legal_acceptances';

  @override
  UserLegalAcceptancesRow createRow(Map<String, dynamic> data) =>
      UserLegalAcceptancesRow(data);
}

class UserLegalAcceptancesRow extends SupabaseDataRow {
  UserLegalAcceptancesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserLegalAcceptancesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String? get tosVersion => getField<String>('tos_version');
  set tosVersion(String? value) => setField<String>('tos_version', value);

  String? get privacyVersion => getField<String>('privacy_version');
  set privacyVersion(String? value) =>
      setField<String>('privacy_version', value);

  DateTime get acceptedAt => getField<DateTime>('accepted_at')!;
  set acceptedAt(DateTime value) => setField<DateTime>('accepted_at', value);
}
