import '../database.dart';

class SupportTicketsTable extends SupabaseTable<SupportTicketsRow> {
  @override
  String get tableName => 'support_tickets';

  @override
  SupportTicketsRow createRow(Map<String, dynamic> data) =>
      SupportTicketsRow(data);
}

class SupportTicketsRow extends SupabaseDataRow {
  SupportTicketsRow(super.data);

  @override
  SupabaseTable get table => SupportTicketsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get subject => getField<String>('subject')!;
  set subject(String value) => setField<String>('subject', value);

  String get message => getField<String>('message')!;
  set message(String value) => setField<String>('message', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get adminNotes => getField<String>('admin_notes');
  set adminNotes(String? value) => setField<String>('admin_notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);
}
