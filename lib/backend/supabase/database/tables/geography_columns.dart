import '../database.dart';

class GeographyColumnsTable extends SupabaseTable<GeographyColumnsRow> {
  @override
  String get tableName => 'geography_columns';

  @override
  GeographyColumnsRow createRow(Map<String, dynamic> data) =>
      GeographyColumnsRow(data);
}

class GeographyColumnsRow extends SupabaseDataRow {
  GeographyColumnsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GeographyColumnsTable();

  String? get fTableCatalog => getField<String>('f_table_catalog');
  set fTableCatalog(String? value) =>
      setField<String>('f_table_catalog', value);

  String? get fTableSchema => getField<String>('f_table_schema');
  set fTableSchema(String? value) => setField<String>('f_table_schema', value);

  String? get fTableName => getField<String>('f_table_name');
  set fTableName(String? value) => setField<String>('f_table_name', value);

  String? get fGeographyColumn => getField<String>('f_geography_column');
  set fGeographyColumn(String? value) =>
      setField<String>('f_geography_column', value);

  int? get coordDimension => getField<int>('coord_dimension');
  set coordDimension(int? value) => setField<int>('coord_dimension', value);

  int? get srid => getField<int>('srid');
  set srid(int? value) => setField<int>('srid', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);
}
