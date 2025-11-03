import '../database.dart';

class GeometryColumnsTable extends SupabaseTable<GeometryColumnsRow> {
  @override
  String get tableName => 'geometry_columns';

  @override
  GeometryColumnsRow createRow(Map<String, dynamic> data) =>
      GeometryColumnsRow(data);
}

class GeometryColumnsRow extends SupabaseDataRow {
  GeometryColumnsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GeometryColumnsTable();

  String? get fTableCatalog => getField<String>('f_table_catalog');
  set fTableCatalog(String? value) =>
      setField<String>('f_table_catalog', value);

  String? get fTableSchema => getField<String>('f_table_schema');
  set fTableSchema(String? value) => setField<String>('f_table_schema', value);

  String? get fTableName => getField<String>('f_table_name');
  set fTableName(String? value) => setField<String>('f_table_name', value);

  String? get fGeometryColumn => getField<String>('f_geometry_column');
  set fGeometryColumn(String? value) =>
      setField<String>('f_geometry_column', value);

  int? get coordDimension => getField<int>('coord_dimension');
  set coordDimension(int? value) => setField<int>('coord_dimension', value);

  int? get srid => getField<int>('srid');
  set srid(int? value) => setField<int>('srid', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);
}
