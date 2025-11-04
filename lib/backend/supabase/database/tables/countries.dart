import '../database.dart';

class CountriesTable extends SupabaseTable<CountriesRow> {
  @override
  String get tableName => 'countries';

  @override
  CountriesRow createRow(Map<String, dynamic> data) => CountriesRow(data);
}

class CountriesRow extends SupabaseDataRow {
  CountriesRow(super.data);

  @override
  SupabaseTable get table => CountriesTable();

  String get iso2 => getField<String>('iso2')!;
  set iso2(String value) => setField<String>('iso2', value);

  String get nameFr => getField<String>('name_fr')!;
  set nameFr(String value) => setField<String>('name_fr', value);

  String get nameEn => getField<String>('name_en')!;
  set nameEn(String value) => setField<String>('name_en', value);

  String? get phoneCode => getField<String>('phone_code');
  set phoneCode(String? value) => setField<String>('phone_code', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
