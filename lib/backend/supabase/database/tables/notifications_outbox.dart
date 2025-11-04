import '../database.dart';

class NotificationsOutboxTable extends SupabaseTable<NotificationsOutboxRow> {
  @override
  String get tableName => 'notifications_outbox';

  @override
  NotificationsOutboxRow createRow(Map<String, dynamic> data) =>
      NotificationsOutboxRow(data);
}

class NotificationsOutboxRow extends SupabaseDataRow {
  NotificationsOutboxRow(super.data);

  @override
  SupabaseTable get table => NotificationsOutboxTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  dynamic get payload => getField<dynamic>('payload')!;
  set payload(dynamic value) => setField<dynamic>('payload', value);

  int get attempts => getField<int>('attempts')!;
  set attempts(int value) => setField<int>('attempts', value);

  String? get lastError => getField<String>('last_error');
  set lastError(String? value) => setField<String>('last_error', value);

  DateTime? get processedAt => getField<DateTime>('processed_at');
  set processedAt(DateTime? value) => setField<DateTime>('processed_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get eventKey => getField<String>('event_key')!;
  set eventKey(String value) => setField<String>('event_key', value);

  DateTime? get claimedAt => getField<DateTime>('claimed_at');
  set claimedAt(DateTime? value) => setField<DateTime>('claimed_at', value);

  String? get claimedBy => getField<String>('claimed_by');
  set claimedBy(String? value) => setField<String>('claimed_by', value);
}
