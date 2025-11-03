import '../database.dart';

class SpatialRefSysTable extends SupabaseTable<SpatialRefSysRow> {
  @override
  String get tableName => 'spatial_ref_sys';

  @override
  SpatialRefSysRow createRow(Map<String, dynamic> data) =>
      SpatialRefSysRow(data);
}

class SpatialRefSysRow extends SupabaseDataRow {
  SpatialRefSysRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SpatialRefSysTable();

  int get srid => getField<int>('srid')!;
  set srid(int value) => setField<int>('srid', value);

  String? get authName => getField<String>('auth_name');
  set authName(String? value) => setField<String>('auth_name', value);

  int? get authSrid => getField<int>('auth_srid');
  set authSrid(int? value) => setField<int>('auth_srid', value);

  String? get srtext => getField<String>('srtext');
  set srtext(String? value) => setField<String>('srtext', value);

  String? get proj4text => getField<String>('proj4text');
  set proj4text(String? value) => setField<String>('proj4text', value);
}
