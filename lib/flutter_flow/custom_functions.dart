import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'lat_lng.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

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

List<MapMarkerStruct> filterMapMarkers(
  List<MapMarkerStruct> allMarkers,
  LayerTogglesStruct toggles,
) {
  return allMarkers.where((m) {
    switch (m.type) {
      case MapMarkerType.professional:
        return toggles.showPros ?? true;
      case MapMarkerType.fixedLocation:
        return toggles.showFixedLocations ?? true;
      case MapMarkerType.proRecent:
        return toggles.showProRecent ?? true;
      case MapMarkerType.poiPrivate:
        return toggles.showBridePrivatePoi ?? true;
      case MapMarkerType.professionalAlert:
        return toggles.showProAlerts ?? true;
      case MapMarkerType.weddingPin: // <-- NOUVEAU
        return toggles.showWeddingPins ?? true;
      case MapMarkerType.searchTarget:
      case MapMarkerType.user:
      default:
        return true;
    }
  }).toList();
}

String imagePathToString(String? imagePath) {
// Vérifiez si imagePath n'est pas null et n'est pas vide
  if (imagePath != null && imagePath.isNotEmpty) {
    return imagePath;
  }

// Retourne une chaîne vide si null ou vide
  return '';
}

String getCountryNameFromIso2(
  String iso2Code,
  String? lang,
) {
  // This map contains the country data directly in the code.
  // It's a direct implementation of the user's request.
  // Architect's note: The best practice is to fetch this data from a single
  // source of truth (like the 'countries' table in Supabase) and cache it
  // in the app state to avoid data duplication and maintenance issues.
  const Map<String, Map<String, String>> countries = {
    'AF': {'fr': 'Afghanistan', 'en': 'Afghanistan'},
    'AL': {'fr': 'Albanie', 'en': 'Albania'},
    'DZ': {'fr': 'Algérie', 'en': 'Algeria'},
    'AS': {'fr': 'Samoa américaines', 'en': 'American Samoa'},
    'AD': {'fr': 'Andorre', 'en': 'Andorra'},
    'AO': {'fr': 'Angola', 'en': 'Angola'},
    'AI': {'fr': 'Anguilla', 'en': 'Anguilla'},
    'AQ': {'fr': 'Antarctique', 'en': 'Antarctica'},
    'AG': {'fr': 'Antigua-et-Barbuda', 'en': 'Antigua and Barbuda'},
    'AR': {'fr': 'Argentine', 'en': 'Argentina'},
    'AM': {'fr': 'Arménie', 'en': 'Armenia'},
    'AW': {'fr': 'Aruba', 'en': 'Aruba'},
    'AU': {'fr': 'Australie', 'en': 'Australia'},
    'AT': {'fr': 'Autriche', 'en': 'Austria'},
    'AZ': {'fr': 'Azerbaïdjan', 'en': 'Azerbaijan'},
    'BS': {'fr': 'Bahamas', 'en': 'Bahamas'},
    'BH': {'fr': 'Bahreïn', 'en': 'Bahrain'},
    'BD': {'fr': 'Bangladesh', 'en': 'Bangladesh'},
    'BB': {'fr': 'Barbade', 'en': 'Barbados'},
    'BY': {'fr': 'Biélorussie', 'en': 'Belarus'},
    'BE': {'fr': 'Belgique', 'en': 'Belgium'},
    'BZ': {'fr': 'Belize', 'en': 'Belize'},
    'BJ': {'fr': 'Bénin', 'en': 'Benin'},
    'BM': {'fr': 'Bermudes', 'en': 'Bermuda'},
    'BT': {'fr': 'Bhoutan', 'en': 'Bhutan'},
    'BO': {'fr': 'Bolivie', 'en': 'Bolivia'},
    'BA': {'fr': 'Bosnie-Herzégovine', 'en': 'Bosnia and Herzegovina'},
    'BW': {'fr': 'Botswana', 'en': 'Botswana'},
    'BR': {'fr': 'Brésil', 'en': 'Brazil'},
    'IO': {
      'fr': 'Territoire britannique de l\'océan Indien',
      'en': 'British Indian Ocean Territory'
    },
    'VG': {'fr': 'Îles Vierges britanniques', 'en': 'British Virgin Islands'},
    'BN': {'fr': 'Brunéi Darussalam', 'en': 'Brunei Darussalam'},
    'BG': {'fr': 'Bulgarie', 'en': 'Bulgaria'},
    'BF': {'fr': 'Burkina Faso', 'en': 'Burkina Faso'},
    'BI': {'fr': 'Burundi', 'en': 'Burundi'},
    'KH': {'fr': 'Cambodge', 'en': 'Cambodia'},
    'CM': {'fr': 'Cameroun', 'en': 'Cameroon'},
    'CA': {'fr': 'Canada', 'en': 'Canada'},
    'CV': {'fr': 'Cap-Vert', 'en': 'Cape Verde'},
    'KY': {'fr': 'Îles Caïmans', 'en': 'Cayman Islands'},
    'CF': {'fr': 'République centrafricaine', 'en': 'Central African Republic'},
    'TD': {'fr': 'Tchad', 'en': 'Chad'},
    'CL': {'fr': 'Chili', 'en': 'Chile'},
    'CN': {'fr': 'Chine', 'en': 'China'},
    'CX': {'fr': 'Île Christmas', 'en': 'Christmas Island'},
    'CC': {'fr': 'Îles Cocos (Keeling)', 'en': 'Cocos (Keeling) Islands'},
    'CO': {'fr': 'Colombie', 'en': 'Colombia'},
    'KM': {'fr': 'Comores', 'en': 'Comoros'},
    'CG': {'fr': 'Congo (Brazzaville)', 'en': 'Congo (Brazzaville)'},
    'CD': {'fr': 'Congo (Kinshasa)', 'en': 'Congo (Kinshasa)'},
    'CK': {'fr': 'Îles Cook', 'en': 'Cook Islands'},
    'CR': {'fr': 'Costa Rica', 'en': 'Costa Rica'},
    'CI': {'fr': 'Côte d\'Ivoire', 'en': 'Côte d\'Ivoire'},
    'HR': {'fr': 'Croatie', 'en': 'Croatia'},
    'CU': {'fr': 'Cuba', 'en': 'Cuba'},
    'CW': {'fr': 'Curaçao', 'en': 'Curaçao'},
    'CY': {'fr': 'Chypre', 'en': 'Cyprus'},
    'CZ': {'fr': 'République tchèque', 'en': 'Czech Republic'},
    'DK': {'fr': 'Danemark', 'en': 'Denmark'},
    'DJ': {'fr': 'Djibouti', 'en': 'Djibouti'},
    'DM': {'fr': 'Dominique', 'en': 'Dominica'},
    'DO': {'fr': 'République dominicaine', 'en': 'Dominican Republic'},
    'EC': {'fr': 'Équateur', 'en': 'Ecuador'},
    'EG': {'fr': 'Égypte', 'en': 'Egypt'},
    'SV': {'fr': 'El Salvador', 'en': 'El Salvador'},
    'GQ': {'fr': 'Guinée équatoriale', 'en': 'Equatorial Guinea'},
    'ER': {'fr': 'Érythrée', 'en': 'Eritrea'},
    'EE': {'fr': 'Estonie', 'en': 'Estonia'},
    'ET': {'fr': 'Éthiopie', 'en': 'Ethiopia'},
    'FK': {'fr': 'Îles Malouines', 'en': 'Falkland Islands'},
    'FO': {'fr': 'Îles Féroé', 'en': 'Faroe Islands'},
    'FJ': {'fr': 'Fidji', 'en': 'Fiji'},
    'FI': {'fr': 'Finlande', 'en': 'Finland'},
    'FR': {'fr': 'France', 'en': 'France'},
    'GF': {'fr': 'Guyane française', 'en': 'French Guiana'},
    'PF': {'fr': 'Polynésie française', 'en': 'French Polynesia'},
    'TF': {
      'fr': 'Terres australes françaises',
      'en': 'French Southern Territories'
    },
    'GA': {'fr': 'Gabon', 'en': 'Gabon'},
    'GM': {'fr': 'Gambie', 'en': 'Gambia'},
    'GE': {'fr': 'Géorgie', 'en': 'Georgia'},
    'DE': {'fr': 'Allemagne', 'en': 'Germany'},
    'GH': {'fr': 'Ghana', 'en': 'Ghana'},
    'GI': {'fr': 'Gibraltar', 'en': 'Gibraltar'},
    'GR': {'fr': 'Grèce', 'en': 'Greece'},
    'GL': {'fr': 'Groenland', 'en': 'Greenland'},
    'GD': {'fr': 'Grenade', 'en': 'Grenada'},
    'GP': {'fr': 'Guadeloupe', 'en': 'Guadeloupe'},
    'GU': {'fr': 'Guam', 'en': 'Guam'},
    'GT': {'fr': 'Guatemala', 'en': 'Guatemala'},
    'GG': {'fr': 'Guernesey', 'en': 'Guernsey'},
    'GN': {'fr': 'Guinée', 'en': 'Guinea'},
    'GW': {'fr': 'Guinée-Bissau', 'en': 'Guinea-Bissau'},
    'GY': {'fr': 'Guyana', 'en': 'Guyana'},
    'HT': {'fr': 'Haïti', 'en': 'Haiti'},
    'HN': {'fr': 'Honduras', 'en': 'Honduras'},
    'HK': {'fr': 'Hong Kong', 'en': 'Hong Kong'},
    'HU': {'fr': 'Hongrie', 'en': 'Hungary'},
    'IS': {'fr': 'Islande', 'en': 'Iceland'},
    'IN': {'fr': 'Inde', 'en': 'India'},
    'ID': {'fr': 'Indonésie', 'en': 'Indonesia'},
    'IR': {'fr': 'Iran', 'en': 'Iran'},
    'IQ': {'fr': 'Irak', 'en': 'Iraq'},
    'IE': {'fr': 'Irlande', 'en': 'Ireland'},
    'IM': {'fr': 'Île de Man', 'en': 'Isle of Man'},
    'IL': {'fr': 'Israël', 'en': 'Israel'},
    'IT': {'fr': 'Italie', 'en': 'Italy'},
    'JM': {'fr': 'Jamaïque', 'en': 'Jamaica'},
    'JP': {'fr': 'Japon', 'en': 'Japan'},
    'JE': {'fr': 'Jersey', 'en': 'Jersey'},
    'JO': {'fr': 'Jordanie', 'en': 'Jordan'},
    'KZ': {'fr': 'Kazakhstan', 'en': 'Kazakhstan'},
    'KE': {'fr': 'Kenya', 'en': 'Kenya'},
    'KI': {'fr': 'Kiribati', 'en': 'Kiribati'},
    'KW': {'fr': 'Koweït', 'en': 'Kuwait'},
    'KG': {'fr': 'Kirghizistan', 'en': 'Kyrgyzstan'},
    'LA': {'fr': 'Laos', 'en': 'Laos'},
    'LV': {'fr': 'Lettonie', 'en': 'Latvia'},
    'LB': {'fr': 'Liban', 'en': 'Lebanon'},
    'LS': {'fr': 'Lesotho', 'en': 'Lesotho'},
    'LR': {'fr': 'Libéria', 'en': 'Liberia'},
    'LY': {'fr': 'Libye', 'en': 'Libya'},
    'LI': {'fr': 'Liechtenstein', 'en': 'Liechtenstein'},
    'LT': {'fr': 'Lituanie', 'en': 'Lithuania'},
    'LU': {'fr': 'Luxembourg', 'en': 'Luxembourg'},
    'MO': {'fr': 'Macao', 'en': 'Macao'},
    'MK': {'fr': 'Macédoine du Nord', 'en': 'North Macedonia'},
    'MG': {'fr': 'Madagascar', 'en': 'Madagascar'},
    'MW': {'fr': 'Malawi', 'en': 'Malawi'},
    'MY': {'fr': 'Malaisie', 'en': 'Malaysia'},
    'MV': {'fr': 'Maldives', 'en': 'Maldives'},
    'ML': {'fr': 'Mali', 'en': 'Mali'},
    'MT': {'fr': 'Malte', 'en': 'Malta'},
    'MH': {'fr': 'Îles Marshall', 'en': 'Marshall Islands'},
    'MQ': {'fr': 'Martinique', 'en': 'Martinique'},
    'MR': {'fr': 'Mauritanie', 'en': 'Mauritania'},
    'MU': {'fr': 'Maurice', 'en': 'Mauritius'},
    'YT': {'fr': 'Mayotte', 'en': 'Mayotte'},
    'MX': {'fr': 'Mexique', 'en': 'Mexico'},
    'FM': {'fr': 'Micronésie', 'en': 'Micronesia'},
    'MD': {'fr': 'Moldavie', 'en': 'Moldova'},
    'MC': {'fr': 'Monaco', 'en': 'Monaco'},
    'MN': {'fr': 'Mongolie', 'en': 'Mongolia'},
    'ME': {'fr': 'Monténégro', 'en': 'Montenegro'},
    'MS': {'fr': 'Montserrat', 'en': 'Montserrat'},
    'MA': {'fr': 'Maroc', 'en': 'Morocco'},
    'MZ': {'fr': 'Mozambique', 'en': 'Mozambique'},
    'MM': {'fr': 'Myanmar', 'en': 'Myanmar'},
    'NA': {'fr': 'Namibie', 'en': 'Namibia'},
    'NR': {'fr': 'Nauru', 'en': 'Nauru'},
    'NP': {'fr': 'Népal', 'en': 'Nepal'},
    'NL': {'fr': 'Pays-Bas', 'en': 'Netherlands'},
    'NC': {'fr': 'Nouvelle-Calédonie', 'en': 'New Caledonia'},
    'NZ': {'fr': 'Nouvelle-Zélande', 'en': 'New Zealand'},
    'NI': {'fr': 'Nicaragua', 'en': 'Nicaragua'},
    'NE': {'fr': 'Niger', 'en': 'Niger'},
    'NG': {'fr': 'Nigéria', 'en': 'Nigeria'},
    'NU': {'fr': 'Niué', 'en': 'Niue'},
    'NF': {'fr': 'Île Norfolk', 'en': 'Norfolk Island'},
    'KP': {'fr': 'Corée du Nord', 'en': 'North Korea'},
    'MP': {'fr': 'Îles Mariannes du Nord', 'en': 'Northern Mariana Islands'},
    'NO': {'fr': 'Norvège', 'en': 'Norway'},
    'OM': {'fr': 'Oman', 'en': 'Oman'},
    'PK': {'fr': 'Pakistan', 'en': 'Pakistan'},
    'PW': {'fr': 'Palaos', 'en': 'Palau'},
    'PS': {'fr': 'Palestine', 'en': 'Palestine'},
    'PA': {'fr': 'Panama', 'en': 'Panama'},
    'PG': {'fr': 'Papouasie-Nouvelle-Guinée', 'en': 'Papua New Guinea'},
    'PY': {'fr': 'Paraguay', 'en': 'Paraguay'},
    'PE': {'fr': 'Pérou', 'en': 'Peru'},
    'PH': {'fr': 'Philippines', 'en': 'Philippines'},
    'PN': {'fr': 'Îles Pitcairn', 'en': 'Pitcairn Islands'},
    'PL': {'fr': 'Pologne', 'en': 'Poland'},
    'PT': {'fr': 'Portugal', 'en': 'Portugal'},
    'PR': {'fr': 'Porto Rico', 'en': 'Puerto Rico'},
    'QA': {'fr': 'Qatar', 'en': 'Qatar'},
    'RE': {'fr': 'La Réunion', 'en': 'Réunion'},
    'RO': {'fr': 'Roumanie', 'en': 'Romania'},
    'RU': {'fr': 'Russie', 'en': 'Russia'},
    'RW': {'fr': 'Rwanda', 'en': 'Rwanda'},
    'BL': {'fr': 'Saint-Barthélemy', 'en': 'Saint Barthélemy'},
    'SH': {'fr': 'Sainte-Hélène', 'en': 'Saint Helena'},
    'KN': {'fr': 'Saint-Christophe-et-Niévès', 'en': 'Saint Kitts and Nevis'},
    'LC': {'fr': 'Sainte-Lucie', 'en': 'Saint Lucia'},
    'MF': {
      'fr': 'Saint-Martin (partie française)',
      'en': 'Saint Martin (French part)'
    },
    'PM': {'fr': 'Saint-Pierre-et-Miquelon', 'en': 'Saint Pierre and Miquelon'},
    'VC': {
      'fr': 'Saint-Vincent-et-les-Grenadines',
      'en': 'Saint Vincent and the Grenadines'
    },
    'WS': {'fr': 'Samoa', 'en': 'Samoa'},
    'SM': {'fr': 'Saint-Marin', 'en': 'San Marino'},
    'ST': {'fr': 'Sao Tomé-et-Principe', 'en': 'Sao Tome and Principe'},
    'SA': {'fr': 'Arabie saoudite', 'en': 'Saudi Arabia'},
    'SN': {'fr': 'Sénégal', 'en': 'Senegal'},
    'RS': {'fr': 'Serbie', 'en': 'Serbia'},
    'SC': {'fr': 'Seychelles', 'en': 'Seychelles'},
    'SL': {'fr': 'Sierra Leone', 'en': 'Sierra Leone'},
    'SG': {'fr': 'Singapour', 'en': 'Singapore'},
    'SX': {
      'fr': 'Saint-Martin (partie néerlandaise)',
      'en': 'Sint Maarten (Dutch part)'
    },
    'SK': {'fr': 'Slovaquie', 'en': 'Slovakia'},
    'SI': {'fr': 'Slovénie', 'en': 'Slovenia'},
    'SB': {'fr': 'Îles Salomon', 'en': 'Solomon Islands'},
    'SO': {'fr': 'Somalie', 'en': 'Somalia'},
    'ZA': {'fr': 'Afrique du Sud', 'en': 'South Africa'},
    'KR': {'fr': 'Corée du Sud', 'en': 'South Korea'},
    'SS': {'fr': 'Soudan du Sud', 'en': 'South Sudan'},
    'ES': {'fr': 'Espagne', 'en': 'Spain'},
    'LK': {'fr': 'Sri Lanka', 'en': 'Sri Lanka'},
    'SD': {'fr': 'Soudan', 'en': 'Sudan'},
    'SR': {'fr': 'Suriname', 'en': 'Suriname'},
    'SJ': {'fr': 'Svalbard et Jan Mayen', 'en': 'Svalbard and Jan Mayen'},
    'SZ': {'fr': 'Eswatini', 'en': 'Eswatini'},
    'SE': {'fr': 'Suède', 'en': 'Sweden'},
    'CH': {'fr': 'Suisse', 'en': 'Switzerland'},
    'SY': {'fr': 'Syrie', 'en': 'Syria'},
    'TW': {'fr': 'Taïwan', 'en': 'Taiwan'},
    'TJ': {'fr': 'Tadjikistan', 'en': 'Tajikistan'},
    'TZ': {'fr': 'Tanzanie', 'en': 'Tanzania'},
    'TH': {'fr': 'Thaïlande', 'en': 'Thailand'},
    'TL': {'fr': 'Timor oriental', 'en': 'Timor-Leste'},
    'TG': {'fr': 'Togo', 'en': 'Togo'},
    'TK': {'fr': 'Tokelau', 'en': 'Tokelau'},
    'TO': {'fr': 'Tonga', 'en': 'Tonga'},
    'TT': {'fr': 'Trinité-et-Tobago', 'en': 'Trinidad and Tobago'},
    'TN': {'fr': 'Tunisie', 'en': 'Tunisia'},
    'TR': {'fr': 'Turquie', 'en': 'Turkey'},
    'TM': {'fr': 'Turkménistan', 'en': 'Turkmenistan'},
    'TC': {'fr': 'Îles Turques-et-Caïques', 'en': 'Turks and Caicos Islands'},
    'TV': {'fr': 'Tuvalu', 'en': 'Tuvalu'},
    'VI': {'fr': 'Îles Vierges américaines', 'en': 'U.S. Virgin Islands'},
    'UG': {'fr': 'Ouganda', 'en': 'Uganda'},
    'UA': {'fr': 'Ukraine', 'en': 'Ukraine'},
    'AE': {'fr': 'Émirats arabes unis', 'en': 'United Arab Emirates'},
    'GB': {'fr': 'Royaume-Uni', 'en': 'United Kingdom'},
    'US': {'fr': 'États-Unis', 'en': 'United States'},
    'UY': {'fr': 'Uruguay', 'en': 'Uruguay'},
    'UZ': {'fr': 'Ouzbékistan', 'en': 'Uzbekistan'},
    'VU': {'fr': 'Vanuatu', 'en': 'Vanuatu'},
    'VA': {'fr': 'Cité du Vatican', 'en': 'Vatican City'},
    'VE': {'fr': 'Venezuela', 'en': 'Venezuela'},
    'VN': {'fr': 'Viêt Nam', 'en': 'Vietnam'},
    'WF': {'fr': 'Wallis-et-Futuna', 'en': 'Wallis and Futuna'},
    'EH': {'fr': 'Sahara occidental', 'en': 'Western Sahara'},
    'YE': {'fr': 'Yémen', 'en': 'Yemen'},
    'ZM': {'fr': 'Zambie', 'en': 'Zambia'},
    'ZW': {'fr': 'Zimbabwe', 'en': 'Zimbabwe'},
    'AX': {'fr': 'Îles Åland', 'en': 'Åland Islands'}
  };

  // Normalize language to 'fr' or 'en', defaulting to 'en'
  final String normalizedLang = (lang?.toLowerCase() == 'fr') ? 'fr' : 'en';

  // Find the country data for the given iso2Code
  final countryData = countries[iso2Code.toUpperCase()];

  // If the country code is not found, return the code itself for debugging
  if (countryData == null) {
    return iso2Code;
  }

  // Return the name in the requested language, with a fallback to English,
  // then to the original code if something is wrong.
  return countryData[normalizedLang] ?? countryData['en'] ?? iso2Code;
}

QueryFiltersStruct jsonToQueryFilters(String? jsonString) {
  // Defaults robustes
  final defaultFilters = QueryFiltersStruct(
    showPros: true,
    showProRecent: true,
    showFixedLocations: true,
    showBridePrivatePoi: true,
    showWeddingPins: true,
    showProAlerts: true,
    showOnlyMyProfessionPins: false,
    professions: [],
  );

  if (jsonString == null || jsonString.isEmpty) {
    return defaultFilters;
  }

  try {
    final data = json.decode(jsonString) as Map<String, dynamic>;

    // Professions (tokens supabase -> enums FF)
    final rawProfessions = data['professions'] as List?;
    final tokens = rawProfessions?.map((p) => p.toString()).toList() ?? [];
    final professionsEnumList = tokens
        .map((s) => professionFromSupabaseToken(s))
        .whereType<Profession>()
        .toList();

    // Center
    LatLng? center;
    if (data['center'] is Map<String, dynamic>) {
      final m = data['center'] as Map<String, dynamic>;
      final lat = (m['latitude'] as num?)?.toDouble();
      final lng = (m['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        center = LatLng(lat, lng);
      }
    }

    return QueryFiltersStruct(
      showPros: data['showPros'] as bool? ?? defaultFilters.showPros,
      showProRecent:
          data['showProRecent'] as bool? ?? defaultFilters.showProRecent,
      showFixedLocations: data['showFixedLocations'] as bool? ??
          defaultFilters.showFixedLocations,
      showBridePrivatePoi: data['showBridePrivatePoi'] as bool? ??
          defaultFilters.showBridePrivatePoi,
      showWeddingPins:
          data['showWeddingPins'] as bool? ?? defaultFilters.showWeddingPins,
      showProAlerts:
          data['showProAlerts'] as bool? ?? defaultFilters.showProAlerts,
      showOnlyMyProfessionPins: data['showOnlyMyProfessionPins'] as bool? ??
          defaultFilters.showOnlyMyProfessionPins,
      professions: professionsEnumList,
      budgetMin: (data['budgetMin'] as num?)?.toDouble(),
      budgetMax: (data['budgetMax'] as num?)?.toDouble(),
      currency: data['currency'] as String?,
      center: center,
      radiusKm: (data['radiusKm'] as num?)?.toDouble(),
    );
  } catch (e) {
    return defaultFilters;
  }
}

DateTime? stringToDateTime(String? dateString) {
  // Vérifier si la chaîne est null ou vide
  if (dateString == null || dateString.isEmpty) {
    return null;
  }

  try {
    // Supprimer les espaces
    dateString = dateString.trim();

    // Vérifier le format DD/MM/YYYY avec regex
    final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    final match = regex.firstMatch(dateString);

    if (match == null) {
      return null;
    }

    // Extraire jour, mois et année
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);

    // Vérifier la validité des valeurs
    if (month < 1 || month > 12) {
      return null;
    }

    if (day < 1 || day > 31) {
      return null;
    }

    // Créer le DateTime
    final date = DateTime(year, month, day);

    // Vérifier que la date créée correspond bien aux valeurs entrées
    // (protège contre des dates comme 31/02/2028)
    if (date.day != day || date.month != month || date.year != year) {
      return null;
    }

    return date;
  } catch (e) {
    // En cas d'erreur de parsing
    return null;
  }
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
  final t = (s ?? '').toUpperCase();
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
