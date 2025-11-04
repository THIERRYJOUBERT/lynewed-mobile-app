import '../database.dart';

class WishlistItemsTable extends SupabaseTable<WishlistItemsRow> {
  @override
  String get tableName => 'wishlist_items';

  @override
  WishlistItemsRow createRow(Map<String, dynamic> data) =>
      WishlistItemsRow(data);
}

class WishlistItemsRow extends SupabaseDataRow {
  WishlistItemsRow(super.data);

  @override
  SupabaseTable get table => WishlistItemsTable();

  String get brideProfileId => getField<String>('bride_profile_id')!;
  set brideProfileId(String value) =>
      setField<String>('bride_profile_id', value);

  String get professionalProfileId =>
      getField<String>('professional_profile_id')!;
  set professionalProfileId(String value) =>
      setField<String>('professional_profile_id', value);

  DateTime get addedAt => getField<DateTime>('added_at')!;
  set addedAt(DateTime value) => setField<DateTime>('added_at', value);
}
