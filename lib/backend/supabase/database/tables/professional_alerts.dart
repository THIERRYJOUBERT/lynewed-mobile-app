import '../database.dart';

class ProfessionalAlertsTable extends SupabaseTable<ProfessionalAlertsRow> {
  @override
  String get tableName => 'professional_alerts';

  @override
  ProfessionalAlertsRow createRow(Map<String, dynamic> data) =>
      ProfessionalAlertsRow(data);
}

class ProfessionalAlertsRow extends SupabaseDataRow {
  ProfessionalAlertsRow(super.data);

  @override
  SupabaseTable get table => ProfessionalAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get authorProfileId => getField<String>('author_profile_id')!;
  set authorProfileId(String value) =>
      setField<String>('author_profile_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get message => getField<String>('message')!;
  set message(String value) => setField<String>('message', value);

  String get locationCoords => getField<String>('location_coords')!;
  set locationCoords(String value) =>
      setField<String>('location_coords', value);

  int get radiusKm => getField<int>('radius_km')!;
  set radiusKm(int value) => setField<int>('radius_km', value);

  int get durationHours => getField<int>('duration_hours')!;
  set durationHours(int value) => setField<int>('duration_hours', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get expiresAt => getField<DateTime>('expires_at')!;
  set expiresAt(DateTime value) => setField<DateTime>('expires_at', value);

  bool get reminderSent => getField<bool>('reminder_sent')!;
  set reminderSent(bool value) => setField<bool>('reminder_sent', value);

  bool get isDeleted => getField<bool>('is_deleted')!;
  set isDeleted(bool value) => setField<bool>('is_deleted', value);

  String get locationLabel => getField<String>('location_label')!;
  set locationLabel(String value) => setField<String>('location_label', value);

  String? get motifCode => getField<String>('motif_code');
  set motifCode(String? value) => setField<String>('motif_code', value);

  String? get alertType => getField<String>('alert_type');
  set alertType(String? value) => setField<String>('alert_type', value);
}
