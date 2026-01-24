import 'dart:convert';
import 'package:crypto/crypto.dart';

import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

String? professionToStyle(Profession? p) {
  /// Retourne le code couleur HEX associé à une profession.
  /// Utile pour l'UI (badges, bordures, etc.)
  if (p == null) {
    return '#000000'; // Retourne noir par défaut
  }

  // Palette "accents" par profession, identique à la logique backend.
  final Map<Profession, String> ringColors = {
    Profession.PHOTOGRAPHER: '#9C27B0', // Violet
    Profession.FILMMAKER: '#3F51B5', // Indigo
    Profession.PLANNER: '#009688', // Teal
    Profession.MAKEUP: '#E91E63', // Rose
    Profession.HAIRDRESSER: '#FF9800', // Orange
    Profession.DESIGNER: '#607D8B', // Bleu-gris
    Profession.BRIDALDESIGNER: '#795548', // Marron
    Profession.VENUE: '#4CAF50', // Vert
    Profession.BRIDALSHOP: '#00BCD4', // Cyan
    Profession.FLORIST: '#8BC34A', // Vert clair
  };

  return ringColors[p] ?? '#000000'; // Fallback sur noir
}

String stringToImagePath(String imageUrl) {
  // Vérifie si l'URL est valide et non vide
  if (imageUrl.isEmpty) {
    return '';
  }

  // Retourne directement l'URL - FlutterFlow gère automatiquement
  // la conversion String vers ImagePath dans les widgets Image
  return imageUrl;
}

QueryFiltersStruct deepCopyQueryFilters(QueryFiltersStruct? filtersToCopy) {
  // Si l'objet source est nul, on retourne un objet vide.
  if (filtersToCopy == null) {
    return QueryFiltersStruct();
  }

  // Crée une NOUVELLE instance de QueryFiltersStruct.
  return QueryFiltersStruct(
    // La ligne la plus importante : crée une nouvelle liste modifiable.
    professions: List.from(filtersToCopy.professions),

    // Copie les autres champs.
    budgetMin: filtersToCopy.budgetMin,
    budgetMax: filtersToCopy.budgetMax,
    currency: filtersToCopy.currency,
    center: filtersToCopy.center,
    radiusKm: filtersToCopy.radiusKm,
    countryCode: filtersToCopy.countryCode,
    nearby: filtersToCopy.nearby,
    showPros: filtersToCopy.showPros,
    showProRecent: filtersToCopy.showProRecent,
    showFixedLocations: filtersToCopy.showFixedLocations,
    showBridePrivatePoi: filtersToCopy.showBridePrivatePoi,
    showWeddingPins: filtersToCopy.showWeddingPins,
    showProAlerts: filtersToCopy.showProAlerts,
    showOnlyMyProfessionPins: filtersToCopy.showOnlyMyProfessionPins,
  );
}

bool isRecoveryLink(String? url) {
  if (url == null || url.isEmpty) {
    return false;
  }

  // On parse l'URL pour analyser ses composants de manière fiable
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return false;
  }

  // Un lien de récupération Supabase contient 'type=recovery' dans le fragment (#) ou dans les query params
  // Le lien peut être sous plusieurs formes :
  // - lynewed://#access_token=...&type=recovery
  // - lynewed://resetpassword.com#access_token=...&type=recovery
  // - lynewed://?type=recovery&access_token=...
  
  // Vérifier d'abord si c'est un lien lynewed://
  if (uri.scheme != 'lynewed') {
    return false;
  }
  
  // Vérifier dans le fragment (après #)
  if (uri.fragment.contains('type=recovery')) {
    return true;
  }
  
  // Vérifier dans les query parameters
  if (uri.queryParameters.containsKey('type') && 
      uri.queryParameters['type'] == 'recovery') {
    return true;
  }
  
  // Vérifier si le fragment contient des paramètres parsables
  if (uri.fragment.isNotEmpty) {
    try {
      final fragmentParams = Uri.splitQueryString(uri.fragment);
      if (fragmentParams['type'] == 'recovery') {
        return true;
      }
    } catch (e) {
      // Ignorer les erreurs de parsing
    }
  }
  
  return false;
}

List<String> mapProfessionsToSupabaseTokens(List<Profession>? items) {
  final out = <String>{};
  for (final p in (items ?? <Profession>[])) {
    switch (p) {
      case Profession.PHOTOGRAPHER:
        out.addAll({'PHOTOGRAPHER', 'PHOTO/MOVIE'});
        break;
      case Profession.FILMMAKER:
        out.addAll({'FILMMAKER', 'PHOTO/MOVIE'});
        break;
      case Profession.MAKEUP:
        out.addAll({'MAKEUP', 'MAKEUPARTIST'});
        break;
      case Profession.DESIGNER:
        out.addAll({'DESIGNER', 'EVENTDESIGNER'});
        break;
      // Nouveaux/renommés (veiller à créer ces enums côté FlutterFlow)
      case Profession.PHOTOMOVIE:
        out.add('PHOTO/MOVIE');
        break;
      case Profession.MAKEUPARTIST:
        out.add('MAKEUPARTIST');
        break;
      case Profession.EVENTDESIGNER:
        out.add('EVENTDESIGNER');
        break;
      case Profession.OTHER:
        out.add('OTHER');
        break;
      case Profession.BRIDALDESIGNER:
        out.add('BRIDALDESIGNER');
        break;
      case Profession.BRIDALSHOP:
        out.add('BRIDALSHOP');
        break;
      case Profession.VENUE:
        out.add('VENUE');
        break;
      case Profession.HAIRDRESSER:
        out.add('HAIRDRESSER');
        break;
      case Profession.PLANNER:
        out.add('PLANNER');
        break;
      default:
        out.add(p.name); // fallback
        break;
    }
  }
  return out.toList();
}

Profession? professionFromSupabaseToken(String s) {
  final t = s.toUpperCase();
  switch (t) {
    case 'PHOTO/MOVIE':
    case 'PHOTOMOVIE':
    case 'PHOTO_MOVIE':
      return Profession.PHOTOMOVIE;
    case 'MAKEUPARTIST':
      return Profession.MAKEUPARTIST;
    case 'EVENTDESIGNER':
      return Profession.EVENTDESIGNER;
    case 'BRIDALDESIGNER':
      return Profession.BRIDALDESIGNER;
    case 'PHOTOGRAPHER':
      return Profession.PHOTOGRAPHER;
    case 'FILMMAKER':
      return Profession.FILMMAKER;
    case 'MAKEUP':
      return Profession.MAKEUP;
    case 'HAIRDRESSER':
      return Profession.HAIRDRESSER;
    case 'DESIGNER':
      return Profession.DESIGNER;
    case 'VENUE':
      return Profession.VENUE;
    case 'BRIDALSHOP':
      return Profession.BRIDALSHOP;
    case 'FLORIST':
      return Profession.FLORIST;
    case 'PLANNER':
      return Profession.PLANNER;
    case 'OTHER':
      return Profession.OTHER;
    default:
      return null;
  }
}

String generateDefaultFiltersJson() {
  // 1. Crée un objet QueryFiltersStruct avec les valeurs par défaut souhaitées.
  final defaultFilters = QueryFiltersStruct(
    showPros: true,
    showProRecent: true,
    showFixedLocations: true,
    showBridePrivatePoi: true,
    showWeddingPins: true,
    showProAlerts: true,
    showOnlyMyProfessionPins: false,
    professions:
        Profession.values.toList(), // Prend toutes les professions de l'enum
    budgetMin: null,
    budgetMax: null,
    center: null,
    radiusKm: null,
    currency: 'USD', // Assurez-vous que c'est votre devise par défaut
    nearby: false,
  );

  // 2. Duplication de la logique de `filtersToJsonString` ici :
  // ==========================================================
  final double? budgetMaxClean = (defaultFilters.budgetMax >= 100000.0)
      ? null
      : defaultFilters.budgetMax;

  Map<String, dynamic>? centerJson;
  if (defaultFilters.center != null) {
    centerJson = {
      'longitude': defaultFilters.center!.longitude,
      'latitude': defaultFilters.center!.latitude,
    };
  }

  // Utilise la fonction de mapping (qui est aussi une Custom Function, donc accessible)
  final List<String> professionsTokens =
      mapProfessionsToSupabaseTokens(defaultFilters.professions);

  final Map<String, dynamic> jsonMap = {
    if (professionsTokens.isNotEmpty) 'professions': professionsTokens,
    'budgetMin': defaultFilters.budgetMin,
    if (budgetMaxClean != null) 'budgetMax': budgetMaxClean,
    if (defaultFilters.currency.isNotEmpty)
      'currency': defaultFilters.currency,
    if (centerJson != null) 'center': centerJson,
    'radiusKm': defaultFilters.radiusKm,
    'showPros': defaultFilters.showPros,
    'showProRecent': defaultFilters.showProRecent,
    'showFixedLocations': defaultFilters.showFixedLocations,
    'showBridePrivatePoi': defaultFilters.showBridePrivatePoi,
    'showWeddingPins': defaultFilters.showWeddingPins,
    'showProAlerts': defaultFilters.showProAlerts,
    'showOnlyMyProfessionPins': defaultFilters.showOnlyMyProfessionPins,
  };
  // ==========================================================

  return jsonEncode(jsonMap);
}

int generateAgoraUid(String uid) {
  if (uid.isEmpty) return 0;
  
  // Utiliser MD5 pour garantir la cohérence avec l'Edge Function TypeScript
  // MD5 du userId pour obtenir un hash déterministe
  final bytes = utf8.encode(uid);
  final digest = md5.convert(bytes);
  
  // Prendre les 4 premiers octets du hash MD5
  final hashBytes = digest.bytes;
  
  // Convertir en int 32-bit non signé
  int agoraUid = (hashBytes[0] << 24) |
                 (hashBytes[1] << 16) |
                 (hashBytes[2] << 8) |
                 hashBytes[3];
  
  // S'assurer que c'est un nombre positif (masque 0x7FFFFFFF)
  return agoraUid & 0x7FFFFFFF;
}
