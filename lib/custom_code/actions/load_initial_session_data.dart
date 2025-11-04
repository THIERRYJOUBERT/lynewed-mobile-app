// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

Future<SessionDataBundleStruct?> loadInitialSessionData() async {
  // --- Fonctions Helper internes pour le parsing ---
  UserRole roleFromString(String? s) {
    switch (s) {
      case 'professional':
        return UserRole.professional;
      case 'bride':
      default:
        return UserRole.bride;
    }
  }

  DistanceUnit distanceUnitFromString(String? s) {
    return (s?.toString() ?? 'km') == 'miles'
        ? DistanceUnit.miles
        : DistanceUnit.km;
  }

  SubscriptionTierType tierFromString(String? s) {
    switch (s) {
      case 'trial':
        return SubscriptionTierType.trial;
      case 'earlyAccess':
        return SubscriptionTierType.earlyAccess;
      case 'premiumVisibility':
        return SubscriptionTierType.premiumVisibility;
      case 'ultimateAccess':
        return SubscriptionTierType.ultimateAccess;
      case 'inactive':
      default:
        return SubscriptionTierType.inactive;
    }
  }

  Profession? professionFromString(String? s) {
    if (s == null) return null;
    try {
      return Profession.values
          .firstWhere((e) => e.name.toUpperCase() == s.toUpperCase());
    } catch (e) {
      return null;
    }
  }
  // --- Fin des Helpers ---

  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('loadInitialSessionData: No authenticated user found.');
      return null;
    }

    // --- Étape 1 : Chargement du profil ---
    final profResponse = await client
        .from('profiles')
        .select('id, role, full_name, avatar_url')
        .eq('id', userId)
        .single();

    final PublicProfileStruct profile = PublicProfileStruct(
      id: profResponse['id']?.toString() ?? '',
      role: roleFromString(profResponse['role']?.toString()),
      fullName: profResponse['full_name']?.toString() ?? '',
      avatarUrl: profResponse['avatar_url']?.toString() ?? '',
    );

    // --- Étape 2 : Chargement des préférences utilisateur ---
    final prefsResponse = await client
        .from('user_preferences')
        .select(
            'distance_unit, currency, default_radius_km, default_city, default_country_code, default_locale, default_timezone, map_toggles, last_filters')
        .eq('profile_id', userId)
        .single();

    final dynamic rawMapToggles = prefsResponse['map_toggles'];
    Map<String, dynamic> toggles = {};
    if (rawMapToggles is String && rawMapToggles.isNotEmpty) {
      toggles = json.decode(rawMapToggles) as Map<String, dynamic>;
    } else if (rawMapToggles is Map<String, dynamic>) {
      toggles = rawMapToggles;
    }

    final String? lastFiltersJson = prefsResponse['last_filters'] is String
        ? prefsResponse['last_filters']
        : null;

    final userPrefs = UserPreferencesStruct(
      distanceUnit: distanceUnitFromString(prefsResponse['distance_unit']),
      currency: prefsResponse['currency']?.toString() ?? 'EUR',
      defaultRadiusKm:
          (prefsResponse['default_radius_km'] as num?)?.toInt() ?? 20,
      defaultCity: prefsResponse['default_city']?.toString(),
      defaultCountry: prefsResponse['default_country_code']?.toString(),
      defaultLocale: prefsResponse['default_locale']?.toString(),
      defaultTimezone: prefsResponse['default_timezone']?.toString(),
      mapToggles: LayerTogglesStruct(
        showPros: toggles['showPros'] == true,
        showProRecent: toggles['showProRecent'] == true,
        showFixedLocations: toggles['showFixedLocations'] == true,
        showBridePrivatePoi: toggles['showBridePrivatePoi'] == true,
        showWeddingPins: toggles['showWeddingPins'] == true,
        showProAlerts: toggles['showProAlerts'] == true,
        showSearchTarget: true,
        showOnlyMyProfessionPins: toggles['showOnlyMyProfessionPins'] == true,
      ),
      lastFiltersJson: lastFiltersJson,
    );

    // --- ÉTAPE 3 : Logique conditionnelle pour le rôle 'professional' ---
    ProSubscriptionSummaryStruct? proSubscription;

    if (profile.role == UserRole.professional) {
      try {
        // Version corrigée avec deux requêtes distinctes
        final subResponse = await client
            .from('professional_subscriptions')
            .select('subscription_tier, trial_ends_at')
            .eq('profile_id', userId)
            .maybeSingle();

        final detailsResponse = await client
            .from('professional_details')
            .select('profession')
            .eq('profile_id', userId)
            .maybeSingle();

        final quotaResponse = await client
            .rpc('get_fixed_locations_quota', params: {'p_profile_id': userId});

        final String? professionString =
            detailsResponse?['profession'] as String?;
        final String subscriptionTierString =
            (subResponse?['subscription_tier'] as String?) ?? 'inactive';
        final String? trialEndsAtStr = subResponse?['trial_ends_at'] as String?;
        final int fixedLocationsQuota = (quotaResponse as num?)?.toInt() ?? 0;

        proSubscription = ProSubscriptionSummaryStruct(
          profileId: userId,
          subscriptionTier: tierFromString(subscriptionTierString),
          trialEndsAt:
              trialEndsAtStr != null ? DateTime.tryParse(trialEndsAtStr) : null,
          fixedLocationsQuota: fixedLocationsQuota,
          profession: professionFromString(professionString),
        );
      } catch (e) {
        debugPrint(
            'Error fetching professional subscription/quota, defaulting. Error: $e');
        proSubscription = ProSubscriptionSummaryStruct(
          profileId: userId,
          subscriptionTier: SubscriptionTierType.inactive,
          fixedLocationsQuota: 0,
          profession: null,
        );
      }
    }

    // --- Étape 4 : Assemblage et retour du bundle final ---
    return SessionDataBundleStruct(
      profile: profile,
      preferences: userPrefs,
      proSubscription: proSubscription,
    );
  } catch (e) {
    debugPrint('loadInitialSessionData critical error: $e');
    return null;
  }
}
