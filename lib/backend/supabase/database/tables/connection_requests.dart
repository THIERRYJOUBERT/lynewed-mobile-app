import '../database.dart';

class ConnectionRequestsTable extends SupabaseTable<ConnectionRequestsRow> {
  @override
  String get tableName => 'connection_requests';

  @override
  ConnectionRequestsRow createRow(Map<String, dynamic> data) =>
      ConnectionRequestsRow(data);
}

class ConnectionRequestsRow extends SupabaseDataRow {
  ConnectionRequestsRow(super.data);

  @override
  SupabaseTable get table => ConnectionRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get proProfileId => getField<String>('pro_profile_id')!;
  set proProfileId(String value) => setField<String>('pro_profile_id', value);

  String get brideProfileId => getField<String>('bride_profile_id')!;
  set brideProfileId(String value) =>
      setField<String>('bride_profile_id', value);

  String get source => getField<String>('source')!;
  set source(String value) => setField<String>('source', value);

  String? get sourceId => getField<String>('source_id');
  set sourceId(String? value) => setField<String>('source_id', value);

  String? get initialMessage => getField<String>('initial_message');
  set initialMessage(String? value) =>
      setField<String>('initial_message', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get respondedAt => getField<DateTime>('responded_at');
  set respondedAt(DateTime? value) => setField<DateTime>('responded_at', value);

  String get initiatorId => getField<String>('initiator_id')!;
  set initiatorId(String value) => setField<String>('initiator_id', value);
}
