import '../database.dart';

class PublicWeddingPinsTable extends SupabaseTable<PublicWeddingPinsRow> {
  @override
  String get tableName => 'public_wedding_pins';

  @override
  PublicWeddingPinsRow createRow(Map<String, dynamic> data) =>
      PublicWeddingPinsRow(data);
}

class PublicWeddingPinsRow extends SupabaseDataRow {
  PublicWeddingPinsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PublicWeddingPinsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get locationCoords => getField<String>('locationCoords');
  set locationCoords(String? value) =>
      setField<String>('locationCoords', value);

  int? get radiusKm => getField<int>('radiusKm');
  set radiusKm(int? value) => setField<int>('radiusKm', value);

  List<String> get professionsNeeded =>
      getListField<String>('professionsNeeded');
  set professionsNeeded(List<String>? value) =>
      setListField<String>('professionsNeeded', value);

  DateTime? get eventStartDate => getField<DateTime>('eventStartDate');
  set eventStartDate(DateTime? value) =>
      setField<DateTime>('eventStartDate', value);

  DateTime? get eventEndDate => getField<DateTime>('eventEndDate');
  set eventEndDate(DateTime? value) =>
      setField<DateTime>('eventEndDate', value);

  bool? get isActive => getField<bool>('isActive');
  set isActive(bool? value) => setField<bool>('isActive', value);

  int? get budgetMin => getField<int>('budgetMin');
  set budgetMin(int? value) => setField<int>('budgetMin', value);

  int? get budgetMax => getField<int>('budgetMax');
  set budgetMax(int? value) => setField<int>('budgetMax', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  double? get budgetMinEur => getField<double>('budgetMinEur');
  set budgetMinEur(double? value) => setField<double>('budgetMinEur', value);

  double? get budgetMaxEur => getField<double>('budgetMaxEur');
  set budgetMaxEur(double? value) => setField<double>('budgetMaxEur', value);
}
