/// StripeAccount entity representing a Stripe Connect account.
///
/// Maps to the `stripe_accounts` table in Supabase.
/// Used for seller onboarding and payout management.
library;

import 'package:flutter/foundation.dart';

/// Represents a Stripe Connect account for a seller.
///
/// Contains all the information needed to track a seller's Stripe
/// onboarding status and payment capabilities.
@immutable
class StripeAccount {
  /// User ID (references profiles.id).
  final String userId;

  /// Stripe Connect account ID (acct_xxx).
  final String stripeAccountId;

  /// Account type (express, standard, custom).
  final String accountType;

  /// Whether onboarding is complete.
  final bool onboardingComplete;

  /// Whether the account can accept charges.
  final bool chargesEnabled;

  /// Whether the account can receive payouts.
  final bool payoutsEnabled;

  /// Whether all required details have been submitted.
  final bool detailsSubmitted;

  /// List of currently due requirements.
  final List<String> currentlyDue;

  /// List of past due requirements.
  final List<String> pastDue;

  /// Reason the account is disabled, if applicable.
  final String? disabledReason;

  /// Account country code (US, FR, etc.).
  final String? country;

  /// Default currency for the account.
  final String? defaultCurrency;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  const StripeAccount({
    required this.userId,
    required this.stripeAccountId,
    this.accountType = 'express',
    this.onboardingComplete = false,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
    this.detailsSubmitted = false,
    this.currentlyDue = const [],
    this.pastDue = const [],
    this.disabledReason,
    this.country,
    this.defaultCurrency,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a StripeAccount from a JSON map (Supabase row).
  factory StripeAccount.fromJson(Map<String, dynamic> json) {
    return StripeAccount(
      userId: json['user_id'] as String,
      stripeAccountId: json['stripe_account_id'] as String,
      accountType: json['account_type'] as String? ?? 'express',
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      chargesEnabled: json['charges_enabled'] as bool? ?? false,
      payoutsEnabled: json['payouts_enabled'] as bool? ?? false,
      detailsSubmitted: json['details_submitted'] as bool? ?? false,
      currentlyDue: (json['currently_due'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      pastDue: (json['past_due'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      disabledReason: json['disabled_reason'] as String?,
      country: json['country'] as String?,
      defaultCurrency: json['default_currency'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Creates a copy with optional field overrides.
  StripeAccount copyWith({
    String? userId,
    String? stripeAccountId,
    String? accountType,
    bool? onboardingComplete,
    bool? chargesEnabled,
    bool? payoutsEnabled,
    bool? detailsSubmitted,
    List<String>? currentlyDue,
    List<String>? pastDue,
    String? disabledReason,
    String? country,
    String? defaultCurrency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StripeAccount(
      userId: userId ?? this.userId,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      accountType: accountType ?? this.accountType,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      chargesEnabled: chargesEnabled ?? this.chargesEnabled,
      payoutsEnabled: payoutsEnabled ?? this.payoutsEnabled,
      detailsSubmitted: detailsSubmitted ?? this.detailsSubmitted,
      currentlyDue: currentlyDue ?? this.currentlyDue,
      pastDue: pastDue ?? this.pastDue,
      disabledReason: disabledReason ?? this.disabledReason,
      country: country ?? this.country,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the account is fully active (can charge and receive payouts).
  bool get isActive => chargesEnabled && payoutsEnabled;

  /// Whether there are pending requirements.
  bool get hasActionRequired => currentlyDue.isNotEmpty || pastDue.isNotEmpty;

  /// Whether the account is in restricted state.
  bool get isRestricted => disabledReason != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StripeAccount &&
        other.userId == userId &&
        other.stripeAccountId == stripeAccountId &&
        other.accountType == accountType &&
        other.onboardingComplete == onboardingComplete &&
        other.chargesEnabled == chargesEnabled &&
        other.payoutsEnabled == payoutsEnabled &&
        other.detailsSubmitted == detailsSubmitted &&
        listEquals(other.currentlyDue, currentlyDue) &&
        listEquals(other.pastDue, pastDue) &&
        other.disabledReason == disabledReason &&
        other.country == country &&
        other.defaultCurrency == defaultCurrency &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      stripeAccountId,
      accountType,
      onboardingComplete,
      chargesEnabled,
      payoutsEnabled,
      detailsSubmitted,
      Object.hashAll(currentlyDue),
      Object.hashAll(pastDue),
      disabledReason,
      country,
      defaultCurrency,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'StripeAccount(userId: $userId, stripeAccountId: $stripeAccountId, '
        'isActive: $isActive)';
  }
}
