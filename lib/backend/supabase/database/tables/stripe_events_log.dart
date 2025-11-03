import '../database.dart';

class StripeEventsLogTable extends SupabaseTable<StripeEventsLogRow> {
  @override
  String get tableName => 'stripe_events_log';

  @override
  StripeEventsLogRow createRow(Map<String, dynamic> data) =>
      StripeEventsLogRow(data);
}

class StripeEventsLogRow extends SupabaseDataRow {
  StripeEventsLogRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StripeEventsLogTable();

  String get eventId => getField<String>('event_id')!;
  set eventId(String value) => setField<String>('event_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  DateTime get receivedAt => getField<DateTime>('received_at')!;
  set receivedAt(DateTime value) => setField<DateTime>('received_at', value);

  DateTime? get processedAt => getField<DateTime>('processed_at');
  set processedAt(DateTime? value) => setField<DateTime>('processed_at', value);

  String? get resultStatus => getField<String>('result_status');
  set resultStatus(String? value) => setField<String>('result_status', value);
}
