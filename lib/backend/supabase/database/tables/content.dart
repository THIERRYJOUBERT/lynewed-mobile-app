import '../database.dart';

class ContentTable extends SupabaseTable<ContentRow> {
  @override
  String get tableName => 'content';

  @override
  ContentRow createRow(Map<String, dynamic> data) => ContentRow(data);
}

class ContentRow extends SupabaseDataRow {
  ContentRow(super.data);

  @override
  SupabaseTable get table => ContentTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get linkedProProfileId => getField<String>('linked_pro_profile_id');
  set linkedProProfileId(String? value) =>
      setField<String>('linked_pro_profile_id', value);

  dynamic get translations => getField<dynamic>('translations')!;
  set translations(dynamic value) => setField<dynamic>('translations', value);

  bool get isPublished => getField<bool>('is_published')!;
  set isPublished(bool value) => setField<bool>('is_published', value);

  DateTime? get publishedAt => getField<DateTime>('published_at');
  set publishedAt(DateTime? value) => setField<DateTime>('published_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
