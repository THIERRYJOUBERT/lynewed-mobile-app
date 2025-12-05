import '../database.dart';

class ProfessionalDetailsTable extends SupabaseTable<ProfessionalDetailsRow> {
  @override
  String get tableName => 'professional_details';

  @override
  ProfessionalDetailsRow createRow(Map<String, dynamic> data) =>
      ProfessionalDetailsRow(data);
}

class ProfessionalDetailsRow extends SupabaseDataRow {
  ProfessionalDetailsRow(super.data);

  @override
  SupabaseTable get table => ProfessionalDetailsTable();

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get businessName => getField<String>('business_name')!;
  set businessName(String value) => setField<String>('business_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  List<String> get portfolioImages => getListField<String>('portfolio_images');
  set portfolioImages(List<String> value) =>
      setListField<String>('portfolio_images', value);

  String get locationCoords => getField<String>('location_coords')!;
  set locationCoords(String value) =>
      setField<String>('location_coords', value);

  String get profession => getField<String>('profession')!;
  set profession(String value) => setField<String>('profession', value);

  bool get isLive => getField<bool>('is_live')!;
  set isLive(bool value) => setField<bool>('is_live', value);

  int get wishlistCount => getField<int>('wishlist_count')!;
  set wishlistCount(int value) => setField<int>('wishlist_count', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get locationCity => getField<String>('location_city');
  set locationCity(String? value) => setField<String>('location_city', value);

  String? get locationCountryCode => getField<String>('location_country_code');
  set locationCountryCode(String? value) =>
      setField<String>('location_country_code', value);

  String? get locationLabel => getField<String>('location_label');
  set locationLabel(String? value) => setField<String>('location_label', value);

  int? get budgetMin => getField<int>('budget_min');
  set budgetMin(int? value) => setField<int>('budget_min', value);

  int? get budgetMax => getField<int>('budget_max');
  set budgetMax(int? value) => setField<int>('budget_max', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get instagramUrl => getField<String>('instagram_url');
  set instagramUrl(String? value) => setField<String>('instagram_url', value);

  String? get websiteUrl => getField<String>('website_url');
  set websiteUrl(String? value) => setField<String>('website_url', value);

  double? get budgetMinEur => getField<double>('budget_min_eur');
  set budgetMinEur(double? value) => setField<double>('budget_min_eur', value);

  double? get budgetMaxEur => getField<double>('budget_max_eur');
  set budgetMaxEur(double? value) => setField<double>('budget_max_eur', value);

  List<String> get slideshowImages => getListField<String>('slideshow_images');
  set slideshowImages(List<String> value) =>
      setListField<String>('slideshow_images', value);

  /// Upcoming travels - JSONB array
  dynamic get upcomingTravels => getField<dynamic>('upcoming_travels');
  set upcomingTravels(dynamic value) => setField<dynamic>('upcoming_travels', value);
}
