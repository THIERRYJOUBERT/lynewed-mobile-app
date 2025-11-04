// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// ACTION: callSearchMapBundleV2 (Version finale, sécurisée et robuste)


// Helpers
LatLng? _latLngFromPosition(dynamic pos) {
  try {
    if (pos is Map<String, dynamic>) {
      if ((pos['type']?.toString().toUpperCase() ?? '') == 'POINT' &&
          pos['coordinates'] is List &&
          (pos['coordinates'] as List).length >= 2) {
        final coords = pos['coordinates'] as List;
        final lng = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();
        return LatLng(lat, lng);
      }
    }
  } catch (_) {}
  return null;
}

MapMarkerType _markerTypeFromString(String s) {
  try {
    return MapMarkerType.values.firstWhere((e) => e.name == s);
  } catch (_) {
    return MapMarkerType.professional;
  }
}

Future<MapdatabundleStruct> callSearchMapBundleV2(
  ViewportinfoStruct viewport,
  QueryFiltersStruct filters,
  UserRole viewerRole,
) async {
  final client = SupaFlow.client;

  // Profession tokens (mapping FF -> Supabase)
  final List<String> professionsTokens =
      mapProfessionsToSupabaseTokens(filters.professions);

  final Map<String, dynamic> filterParams = {
    'showPros': filters.showPros,
    'showProRecent': filters.showProRecent,
    'showFixedLocations': filters.showFixedLocations,
    'showBridePrivatePoi': filters.showBridePrivatePoi,
    'showWeddingPins': filters.showWeddingPins,
    'showProAlerts': filters.showProAlerts,
    'showOnlyMyProfessionPins': filters.showOnlyMyProfessionPins,
    'currency': filters.currency,
  };

  // Budget only (viewport-only => pas de radius)
  if (filters.budgetMin > 0.0) {
    filterParams['budgetMin'] = filters.budgetMin;
  }
  if (filters.budgetMax > 0.0) {
    filterParams['budgetMax'] =
        (filters.budgetMax >= 100000.0) ? null : filters.budgetMax;
  }
  if (professionsTokens.isNotEmpty) {
    filterParams['professions'] = professionsTokens;
  }
  // center facultatif (non utilisé côté SQL désormais)
  if (filters.center != null) {
    filterParams['center'] = {
      'longitude': filters.center!.longitude,
      'latitude': filters.center!.latitude,
    };
  }

  final params = {
    'p_bbox_coords': {
      'min_lng': viewport.swLng,
      'min_lat': viewport.swLat,
      'max_lng': viewport.neLng,
      'max_lat': viewport.neLat,
    },
    'p_viewer_role': viewerRole.name,
    'p_filters': filterParams,
    'p_zoom': (viewport.zoom ?? 12.0).round(),
  };

  final res = await client.rpc('search_map_bundle', params: params);
  if (res == null || res is! Map<String, dynamic>) {
    return MapdatabundleStruct(markers: [], weddingPins: []);
  }

  final markersJson = (res['markers'] as List?) ?? const [];
  final overlaysJson = (res['overlays'] as List?) ?? const [];
  final debugStats = (res['debugStats']?.toString() ?? '');

  final markers = <MapMarkerStruct>[];
  for (final m in markersJson) {
    if (m is! Map) continue;
    final id = m['id']?.toString();
    final typeStr = m['type']?.toString() ?? 'professional';
    final pos = _latLngFromPosition(m['position']);
    if (id == null || pos == null) continue;
    final style = m['styleInfo'] is Map
        ? Map<String, dynamic>.from(m['styleInfo'])
        : <String, dynamic>{};

    markers.add(MapMarkerStruct(
      id: id,
      type: _markerTypeFromString(typeStr),
      position: pos,
      styleInfo: MarkerStyleInfoStruct(
        avatarUrl: style['avatarUrl']?.toString() ?? '',
        borderColorHex: style['borderColorHex']?.toString(),
        isOwn: (style['isOwn'] == true),
      ),
    ));
  }

  final overlays = <WeddingPinOverlayStruct>[];
  for (final o in overlaysJson) {
    // plus d’overlays renvoyés (liste vide), mais on garde le parsing défensif
    if (o is! Map) continue;
  }

  return MapdatabundleStruct(
    markers: markers,
    weddingPins: overlays,
    debugStats: debugStats,
  );
}
