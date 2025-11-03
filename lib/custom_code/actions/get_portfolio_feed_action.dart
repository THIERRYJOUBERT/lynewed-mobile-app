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
import 'dart:math';

Future<FeedPageResultStruct?> getPortfolioFeedAction(
  QueryFiltersStruct? filters,
  String? cursor,
  int? pageSize,
  String? seed,
) async {
  List<String> _normalizeProfessions(dynamic list) {
    final out = <String>[];
    if (list is List) {
      for (final e in list) {
        if (e is String) {
          out.add(e.trim().toUpperCase());
        } else if (e is Profession) {
          out.add(e.name.toUpperCase());
        } else {
          out.add(e.toString().toUpperCase());
        }
      }
    }
    return out;
  }

  Profession _professionFromString(String? s) {
    if (s == null) return Profession.PHOTOGRAPHER;
    try {
      return Profession.values
          .firstWhere((e) => e.name.toUpperCase() == s.toUpperCase());
    } catch (_) {
      return Profession.PHOTOGRAPHER;
    }
  }

  try {
    final client = SupaFlow.client;

    final Map<String, dynamic> filterParams = {};
    if (filters != null) {
      if (filters.center != null) {
        filterParams['center'] = {
          'latitude': filters.center!.latitude,
          'longitude': filters.center!.longitude,
        };
        final double radius = (filters.radiusKm ?? 100.0);
        filterParams['radiusKm'] = radius.clamp(5.0, 1000.0);
      }
      if ((filters.professions ?? []).isNotEmpty) {
        filterParams['professions'] =
            _normalizeProfessions(filters.professions);
      }

      // MODIFIÉ : Ajout des filtres de budget s'ils sont pertinents
      // On n'envoie pas budgetMin s'il est à zéro (pas de limite inférieure)
      if (filters.budgetMin != null && filters.budgetMin! > 0) {
        filterParams['budgetMin'] = filters.budgetMin;
      }
      // On n'envoie pas budgetMax s'il est à la valeur maximale (pas de limite supérieure)
      if (filters.budgetMax != null && filters.budgetMax! < 40000.0) {
        filterParams['budgetMax'] = filters.budgetMax;
      }
    }

    final String filtersJson = jsonEncode(filterParams);

    final params = {
      'p_filters': jsonDecode(
          filtersJson), // Utilise jsonDecode pour envoyer un vrai JSON
      'p_cursor': cursor,
      'p_page_size': pageSize ?? 30,
      'p_seed': seed,
    };

    final response = await client.rpc('get_portfolio_feed', params: params);

    if (response == null) {
      return null;
    }

    Map<String, dynamic> responseMap = response;

    final itemsJson = (responseMap['items'] as List?) ?? const [];

    final List<FeedImageItemStruct> feedItems = [];
    for (final item in itemsJson) {
      if (item is! Map<String, dynamic>) continue;
      feedItems.add(
        FeedImageItemStruct(
          imageUrl: item['imageUrl'] as String?,
          imageIndex: (item['imageIndex'] as num?)?.toInt(),
          proProfileId: item['proProfileId']?.toString(),
          proFullName: item['proFullName'] as String?,
          proAvatarUrl: item['proAvatarUrl'] as String?,
          proProfession:
              _professionFromString(item['proProfession'] as String?),
          proLocationLabel: item['proLocationLabel'] as String?,
          isFavorited: item['isFavorited'] as bool? ?? false,
        ),
      );
    }

    return FeedPageResultStruct(
      items: feedItems,
      nextCursor: responseMap['nextCursor'] as String?,
      newSeed: responseMap['newSeed'] as String?,
    );
  } catch (e, st) {
    print('CRITICAL ERROR in getPortfolioFeedAction: $e');
    print(st);
    return null;
  }
}
