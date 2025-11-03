// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'dart:convert';

Future<ProDetailsStruct?> getProItemDetailsAction(String proProfileId) async {
  // --- Start of Helper Functions ---
  LatLng? _geoJsonToLatLng(dynamic geojson) {
    if (geojson is Map<String, dynamic>) {
      try {
        if (geojson['type'] == 'Point' &&
            (geojson['coordinates'] as List).length == 2) {
          return LatLng((geojson['coordinates'][1] as num).toDouble(),
              (geojson['coordinates'][0] as num).toDouble());
        }
      } catch (_) {}
    } else if (geojson is String) {
      try {
        final map = json.decode(geojson) as Map<String, dynamic>;
        if (map['type'] == 'Point' &&
            (map['coordinates'] as List).length == 2) {
          return LatLng((map['coordinates'][1] as num).toDouble(),
              (map['coordinates'][0] as num).toDouble());
        }
      } catch (_) {}
    }
    return null;
  }

  Profession _professionFromString(String? s) {
    try {
      if (s == null) return Profession.PHOTOGRAPHER;
      return Profession.values.firstWhere((e) => e.name == s);
    } catch (_) {
      return Profession.PHOTOGRAPHER;
    }
  }

  SubscriptionTierType _tierFromString(String? s) {
    switch (s) {
      case 'premiumVisibility':
        return SubscriptionTierType.premiumVisibility;
      case 'ultimateAccess':
        return SubscriptionTierType.ultimateAccess;
      case 'earlyAccess':
        return SubscriptionTierType.earlyAccess;
      case 'trial':
        return SubscriptionTierType.trial;
      default:
        return SubscriptionTierType.inactive;
    }
  }
  // --- End of Helper Functions ---

  try {
    final client = SupaFlow.client;
    final data = await client.rpc('get_pro_item_details', params: {
      'p_pro_profile_id': proProfileId,
    });
    if (data is! Map<String, dynamic>) return null;

    // Pas de ProSummaryStruct ici car il ne contient pas le nouveau champ

    final portfolio = (data['portfolioImages'] is List)
        ? (data['portfolioImages'] as List).map((e) => e.toString()).toList()
        : <String>[];

    // NOUVEAU : Parser la liste des images du slideshow
    final slideshow = (data['slideshowImages'] is List)
        ? (data['slideshowImages'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final fixedLocs = <LatLng>[];
    if (data['fixedLocations'] is List) {
      for (final g in (data['fixedLocations'] as List)) {
        final p = _geoJsonToLatLng(g);
        if (p != null) fixedLocs.add(p);
      }
    }

    return ProDetailsStruct(
      proProfileId: data['proProfileId']?.toString() ?? '',
      fullName: data['fullName']?.toString() ?? '',
      avatarUrl: data['avatarUrl']?.toString() ?? '',
      businessName: data['businessName']?.toString() ?? '',
      profession: _professionFromString(data['profession']?.toString()),
      budgetMin: (data['budgetMin'] as num?)?.toInt() ?? 0,
      budgetMax: (data['budgetMax'] as num?)?.toInt() ?? 0,
      currency: data['currency']?.toString() ?? 'EUR',
      subscriptionTier: _tierFromString(data['subscriptionTier']?.toString()),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
      locationLabel: data['locationLabel']?.toString() ?? '',
      coverImageUrl: data['coverImageUrl']?.toString() ?? '',
      isFavorited: data['isFavorited'] == true,
      isLive: data['isLive'] == true,
      description: data['description']?.toString() ?? '',
      portfolioImages: portfolio,
      slideshowImages: slideshow, // NOUVEAU CHAMP LIÉ
      fixedLocations: fixedLocs,
      instagramUrl: (data['socials'] is Map
              ? data['socials']['instagramUrl']?.toString()
              : null) ??
          data['instagramUrl']?.toString(),
      websiteUrl: (data['socials'] is Map
              ? data['socials']['websiteUrl']?.toString()
              : null) ??
          data['websiteUrl']?.toString(),
      profileVideoUrl: data['profileVideoUrl']?.toString(),
      canBeContactedByBride: data['canBeContactedByBride'] == true,
      canContactBride: data['canContactBride'] == true,
    );
  } catch (e) {
    print('getProItemDetailsAction error: $e');
    return null;
  }
}
