import '../database.dart';

class AlertMotifsTable extends SupabaseTable<AlertMotifsRow> {
  @override
  String get tableName => 'alert_motifs';

  @override
  AlertMotifsRow createRow(Map<String, dynamic> data) => AlertMotifsRow(data);
}

class AlertMotifsRow extends SupabaseDataRow {
  AlertMotifsRow(super.data);

  @override
  SupabaseTable get table => AlertMotifsTable();

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get nameFr => getField<String>('name_fr')!;
  set nameFr(String value) => setField<String>('name_fr', value);

  String get nameEn => getField<String>('name_en')!;
  set nameEn(String value) => setField<String>('name_en', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  int get sortOrder => getField<int>('sort_order')!;
  set sortOrder(int value) => setField<int>('sort_order', value);
}
