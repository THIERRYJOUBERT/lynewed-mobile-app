import '../database.dart';

class ProfessionalSubscriptionsTable
    extends SupabaseTable<ProfessionalSubscriptionsRow> {
  @override
  String get tableName => 'professional_subscriptions';

  @override
  ProfessionalSubscriptionsRow createRow(Map<String, dynamic> data) =>
      ProfessionalSubscriptionsRow(data);
}

class ProfessionalSubscriptionsRow extends SupabaseDataRow {
  ProfessionalSubscriptionsRow(super.data);

  @override
  SupabaseTable get table => ProfessionalSubscriptionsTable();

  String get profileId => getField<String>('profile_id')!;
  set profileId(String value) => setField<String>('profile_id', value);

  String get subscriptionTier => getField<String>('subscription_tier')!;
  set subscriptionTier(String value) =>
      setField<String>('subscription_tier', value);

  DateTime? get trialEndsAt => getField<DateTime>('trial_ends_at');
  set trialEndsAt(DateTime? value) =>
      setField<DateTime>('trial_ends_at', value);

  String? get stripeCustomerId => getField<String>('stripe_customer_id');
  set stripeCustomerId(String? value) =>
      setField<String>('stripe_customer_id', value);

  String? get stripeSubscriptionId =>
      getField<String>('stripe_subscription_id');
  set stripeSubscriptionId(String? value) =>
      setField<String>('stripe_subscription_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
