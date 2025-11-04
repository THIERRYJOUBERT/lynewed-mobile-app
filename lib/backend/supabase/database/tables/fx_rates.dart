import '../database.dart';

class FxRatesTable extends SupabaseTable<FxRatesRow> {
  @override
  String get tableName => 'fx_rates';

  @override
  FxRatesRow createRow(Map<String, dynamic> data) => FxRatesRow(data);
}

class FxRatesRow extends SupabaseDataRow {
  FxRatesRow(super.data);

  @override
  SupabaseTable get table => FxRatesTable();

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get base => getField<String>('base')!;
  set base(String value) => setField<String>('base', value);

  double get rate => getField<double>('rate')!;
  set rate(double value) => setField<double>('rate', value);

  DateTime get validOn => getField<DateTime>('valid_on')!;
  set validOn(DateTime value) => setField<DateTime>('valid_on', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
