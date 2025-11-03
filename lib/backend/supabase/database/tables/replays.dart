import '../database.dart';

class ReplaysTable extends SupabaseTable<ReplaysRow> {
  @override
  String get tableName => 'replays';

  @override
  ReplaysRow createRow(Map<String, dynamic> data) => ReplaysRow(data);
}

class ReplaysRow extends SupabaseDataRow {
  ReplaysRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReplaysTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get youtubeUrl => getField<String>('youtube_url')!;
  set youtubeUrl(String value) => setField<String>('youtube_url', value);

  String get thumbnailUrl => getField<String>('thumbnail_url')!;
  set thumbnailUrl(String value) => setField<String>('thumbnail_url', value);

  DateTime get publishedAt => getField<DateTime>('published_at')!;
  set publishedAt(DateTime value) => setField<DateTime>('published_at', value);

  bool get isFeatured => getField<bool>('is_featured')!;
  set isFeatured(bool value) => setField<bool>('is_featured', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
