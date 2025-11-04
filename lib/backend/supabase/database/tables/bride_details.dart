import '../database.dart';

class BrideDetailsTable extends SupabaseTable<BrideDetailsRow> {
  @override
  String get tableName => 'bride_details';

  @override
  BrideDetailsRow createRow(Map<String, dynamic> data) => BrideDetailsRow(data);
}

class BrideDetailsRow extends SupabaseDataRow {
  BrideDetailsRow(super.data);

  @override
  SupabaseTable get table => BrideDetailsTable();

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
