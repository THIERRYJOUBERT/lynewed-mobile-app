import '../database.dart';

class NotificationSettingsTable extends SupabaseTable<NotificationSettingsRow> {
  @override
  String get tableName => 'notification_settings';

  @override
  NotificationSettingsRow createRow(Map<String, dynamic> data) =>
      NotificationSettingsRow(data);
}

class NotificationSettingsRow extends SupabaseDataRow {
  NotificationSettingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => NotificationSettingsTable();

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get notificationType => getField<String>('notification_type')!;
  set notificationType(String value) =>
      setField<String>('notification_type', value);

  bool get inAppEnabled => getField<bool>('in_app_enabled')!;
  set inAppEnabled(bool value) => setField<bool>('in_app_enabled', value);

  bool get pushEnabled => getField<bool>('push_enabled')!;
  set pushEnabled(bool value) => setField<bool>('push_enabled', value);
}
