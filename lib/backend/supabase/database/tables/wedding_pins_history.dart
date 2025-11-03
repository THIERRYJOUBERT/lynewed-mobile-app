import '../database.dart';

class WeddingPinsHistoryTable extends SupabaseTable<WeddingPinsHistoryRow> {
  @override
  String get tableName => 'wedding_pins_history';

  @override
  WeddingPinsHistoryRow createRow(Map<String, dynamic> data) =>
      WeddingPinsHistoryRow(data);
}

class WeddingPinsHistoryRow extends SupabaseDataRow {
  WeddingPinsHistoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => WeddingPinsHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get weddingPinId => getField<String>('wedding_pin_id');
  set weddingPinId(String? value) => setField<String>('wedding_pin_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  dynamic? get oldValues => getField<dynamic>('old_values');
  set oldValues(dynamic? value) => setField<dynamic>('old_values', value);

  dynamic? get newValues => getField<dynamic>('new_values');
  set newValues(dynamic? value) => setField<dynamic>('new_values', value);

  String? get changedBy => getField<String>('changed_by');
  set changedBy(String? value) => setField<String>('changed_by', value);

  DateTime get changedAt => getField<DateTime>('changed_at')!;
  set changedAt(DateTime value) => setField<DateTime>('changed_at', value);
}
