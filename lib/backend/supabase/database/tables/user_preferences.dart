import '../database.dart';

class UserPreferencesTable extends SupabaseTable<UserPreferencesRow> {
  @override
  String get tableName => 'user_preferences';

  @override
  UserPreferencesRow createRow(Map<String, dynamic> data) =>
      UserPreferencesRow(data);
}

class UserPreferencesRow extends SupabaseDataRow {
  UserPreferencesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserPreferencesTable();

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get distanceUnit => getField<String>('distance_unit')!;
  set distanceUnit(String value) => setField<String>('distance_unit', value);

  int get defaultRadiusKm => getField<int>('default_radius_km')!;
  set defaultRadiusKm(int value) => setField<int>('default_radius_km', value);

  String? get defaultCountryCode => getField<String>('default_country_code');
  set defaultCountryCode(String? value) =>
      setField<String>('default_country_code', value);

  String? get defaultCity => getField<String>('default_city');
  set defaultCity(String? value) => setField<String>('default_city', value);

  String? get defaultLocale => getField<String>('default_locale');
  set defaultLocale(String? value) => setField<String>('default_locale', value);

  dynamic get mapToggles => getField<dynamic>('map_toggles')!;
  set mapToggles(dynamic value) => setField<dynamic>('map_toggles', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String? get defaultTimezone => getField<String>('default_timezone');
  set defaultTimezone(String? value) =>
      setField<String>('default_timezone', value);

  dynamic? get lastFilters => getField<dynamic>('last_filters');
  set lastFilters(dynamic? value) => setField<dynamic>('last_filters', value);

  dynamic? get lastFeedFilters => getField<dynamic>('last_feed_filters');
  set lastFeedFilters(dynamic? value) =>
      setField<dynamic>('last_feed_filters', value);
}
