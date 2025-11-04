import '../database.dart';

class PublicProfessionalsTable extends SupabaseTable<PublicProfessionalsRow> {
  @override
  String get tableName => 'public_professionals';

  @override
  PublicProfessionalsRow createRow(Map<String, dynamic> data) =>
      PublicProfessionalsRow(data);
}

class PublicProfessionalsRow extends SupabaseDataRow {
  PublicProfessionalsRow(super.data);

  @override
  SupabaseTable get table => PublicProfessionalsTable();

  String? get profileId => getField<String>('profileId');
  set profileId(String? value) => setField<String>('profileId', value);

  String? get fullName => getField<String>('fullName');
  set fullName(String? value) => setField<String>('fullName', value);

  String? get avatarUrl => getField<String>('avatarUrl');
  set avatarUrl(String? value) => setField<String>('avatarUrl', value);

  String? get businessName => getField<String>('businessName');
  set businessName(String? value) => setField<String>('businessName', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get locationLabel => getField<String>('locationLabel');
  set locationLabel(String? value) => setField<String>('locationLabel', value);

  String? get profession => getField<String>('profession');
  set profession(String? value) => setField<String>('profession', value);

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

  bool? get isLive => getField<bool>('isLive');
  set isLive(bool? value) => setField<bool>('isLive', value);

  String? get subscriptionTier => getField<String>('subscriptionTier');
  set subscriptionTier(String? value) =>
      setField<String>('subscriptionTier', value);

  String? get coverImageUrl => getField<String>('coverImageUrl');
  set coverImageUrl(String? value) => setField<String>('coverImageUrl', value);

  int? get wishlistCount => getField<int>('wishlistCount');
  set wishlistCount(int? value) => setField<int>('wishlistCount', value);
}
