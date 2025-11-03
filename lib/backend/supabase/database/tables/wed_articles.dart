import '../database.dart';

class WedArticlesTable extends SupabaseTable<WedArticlesRow> {
  @override
  String get tableName => 'wed_articles';

  @override
  WedArticlesRow createRow(Map<String, dynamic> data) => WedArticlesRow(data);
}

class WedArticlesRow extends SupabaseDataRow {
  WedArticlesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => WedArticlesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  dynamic get title => getField<dynamic>('title')!;
  set title(dynamic value) => setField<dynamic>('title', value);

  String get linkedProProfileId => getField<String>('linked_pro_profile_id')!;
  set linkedProProfileId(String value) =>
      setField<String>('linked_pro_profile_id', value);

  List<String> get coverImages => getListField<String>('cover_images')!;
  set coverImages(List<String> value) =>
      setListField<String>('cover_images', value);

  dynamic? get contentBlocks => getField<dynamic>('content_blocks');
  set contentBlocks(dynamic? value) =>
      setField<dynamic>('content_blocks', value);

  bool get isPublished => getField<bool>('is_published')!;
  set isPublished(bool value) => setField<bool>('is_published', value);

  DateTime? get publishedAt => getField<DateTime>('published_at');
  set publishedAt(DateTime? value) => setField<DateTime>('published_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
