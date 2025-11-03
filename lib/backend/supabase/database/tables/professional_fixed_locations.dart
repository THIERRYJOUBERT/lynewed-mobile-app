import '../database.dart';

class ProfessionalFixedLocationsTable
    extends SupabaseTable<ProfessionalFixedLocationsRow> {
  @override
  String get tableName => 'professional_fixed_locations';

  @override
  ProfessionalFixedLocationsRow createRow(Map<String, dynamic> data) =>
      ProfessionalFixedLocationsRow(data);
}

class ProfessionalFixedLocationsRow extends SupabaseDataRow {
  ProfessionalFixedLocationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfessionalFixedLocationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get professionalProfileId =>
      getField<String>('professional_profile_id')!;
  set professionalProfileId(String value) =>
      setField<String>('professional_profile_id', value);

  String get locationCoords => getField<String>('location_coords')!;
  set locationCoords(String value) =>
      setField<String>('location_coords', value);

  String? get label => getField<String>('label');
  set label(String? value) => setField<String>('label', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
