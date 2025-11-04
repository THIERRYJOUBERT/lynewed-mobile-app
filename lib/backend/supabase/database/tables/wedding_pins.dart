import '../database.dart';

class WeddingPinsTable extends SupabaseTable<WeddingPinsRow> {
  @override
  String get tableName => 'wedding_pins';

  @override
  WeddingPinsRow createRow(Map<String, dynamic> data) => WeddingPinsRow(data);
}

class WeddingPinsRow extends SupabaseDataRow {
  WeddingPinsRow(super.data);

  @override
  SupabaseTable get table => WeddingPinsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get brideProfileId => getField<String>('bride_profile_id')!;
  set brideProfileId(String value) =>
      setField<String>('bride_profile_id', value);

  String get locationCoords => getField<String>('location_coords')!;
  set locationCoords(String value) =>
      setField<String>('location_coords', value);

  int get radiusKm => getField<int>('radius_km')!;
  set radiusKm(int value) => setField<int>('radius_km', value);

  List<String> get professionsNeeded =>
      getListField<String>('professions_needed');
  set professionsNeeded(List<String>? value) =>
      setListField<String>('professions_needed', value);

  List<int> get budgetBrackets => getListField<int>('budget_brackets');
  set budgetBrackets(List<int>? value) =>
      setListField<int>('budget_brackets', value);

  DateTime? get eventStartDate => getField<DateTime>('event_start_date');
  set eventStartDate(DateTime? value) =>
      setField<DateTime>('event_start_date', value);

  DateTime? get eventEndDate => getField<DateTime>('event_end_date');
  set eventEndDate(DateTime? value) =>
      setField<DateTime>('event_end_date', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String get locationLabel => getField<String>('location_label')!;
  set locationLabel(String value) => setField<String>('location_label', value);

  int? get budgetMin => getField<int>('budget_min');
  set budgetMin(int? value) => setField<int>('budget_min', value);

  int? get budgetMax => getField<int>('budget_max');
  set budgetMax(int? value) => setField<int>('budget_max', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  double? get budgetMinEur => getField<double>('budget_min_eur');
  set budgetMinEur(double? value) => setField<double>('budget_min_eur', value);

  double? get budgetMaxEur => getField<double>('budget_max_eur');
  set budgetMaxEur(double? value) => setField<double>('budget_max_eur', value);

  bool get isDeleted => getField<bool>('is_deleted')!;
  set isDeleted(bool value) => setField<bool>('is_deleted', value);
}
