import '../database.dart';

class UserPoisTable extends SupabaseTable<UserPoisRow> {
  @override
  String get tableName => 'user_pois';

  @override
  UserPoisRow createRow(Map<String, dynamic> data) => UserPoisRow(data);
}

class UserPoisRow extends SupabaseDataRow {
  UserPoisRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserPoisTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get brideProfileId => getField<String>('bride_profile_id')!;
  set brideProfileId(String value) =>
      setField<String>('bride_profile_id', value);

  String? get label => getField<String>('label');
  set label(String? value) => setField<String>('label', value);

  String get coords => getField<String>('coords')!;
  set coords(String value) => setField<String>('coords', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int? get radiusKm => getField<int>('radius_km');
  set radiusKm(int? value) => setField<int>('radius_km', value);

  List<String> get professions => getListField<String>('professions');
  set professions(List<String>? value) =>
      setListField<String>('professions', value);

  int? get budgetMin => getField<int>('budget_min');
  set budgetMin(int? value) => setField<int>('budget_min', value);

  int? get budgetMax => getField<int>('budget_max');
  set budgetMax(int? value) => setField<int>('budget_max', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  DateTime? get eventStartDate => getField<DateTime>('event_start_date');
  set eventStartDate(DateTime? value) =>
      setField<DateTime>('event_start_date', value);

  DateTime? get eventEndDate => getField<DateTime>('event_end_date');
  set eventEndDate(DateTime? value) =>
      setField<DateTime>('event_end_date', value);

  String get locationLabel => getField<String>('location_label')!;
  set locationLabel(String value) => setField<String>('location_label', value);
}
