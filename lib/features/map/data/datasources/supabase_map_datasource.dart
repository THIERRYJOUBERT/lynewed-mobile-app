/// Supabase datasource for map data
/// 
/// Handles all Supabase RPC calls and queries for map feature.
/// Uses existing search_map_bundle RPC with proper parsing.
library;

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/entities.dart';

/// Configuration des limites par niveau de zoom
/// Style Uber/Relay: PLUS de markers au zoom faible (vue d'ensemble)
/// MOINS de markers au zoom élevé (détail, performance)
class ZoomLimits {
  static int getLimit(double zoom) {
    if (zoom <= 5) return 2000;   // Continent - vue d'ensemble max
    if (zoom <= 8) return 800;    // Pays - vue régionale élargie
    if (zoom <= 11) return 300;   // Région - affichage standard
    if (zoom <= 14) return 100;   // Ville - limité pour performance
    return 50;                     // Rue/Quartier - très limité (vue détaillée)
  }
}

/// Datasource Supabase pour les données map
class SupabaseMapDatasource {
  SupabaseMapDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Appelle search_map_bundle RPC
  /// 
  /// Signature RPC Supabase:
  /// search_map_bundle(p_bbox_coords jsonb, p_viewer_role text, p_filters jsonb, p_zoom integer)
  Future<Map<String, dynamic>> searchMapBundle({
    required gmaps.LatLngBounds bounds,
    required MapFilter filter,
    required String userRole,
    required double zoomLevel,
  }) async {
    // Format bbox pour la RPC
    final bboxCoords = {
      'min_lat': bounds.southwest.latitude,
      'min_lng': bounds.southwest.longitude,
      'max_lat': bounds.northeast.latitude,
      'max_lng': bounds.northeast.longitude,
    };

    // Format filtres pour la RPC
    // Use toRpcValue for correct backend enum mapping
    final filters = {
      'professions': filter.professions.map((p) => p.toRpcValue).toList(),
      'budgetMin': filter.budgetMin?.toString(),
      'budgetMax': filter.budgetMax?.toString(),
      'currency': filter.currency,
      // Toggles
      'showPros': filter.toggles.showPros,
      'showFixedLocations': filter.toggles.showFixedLocations,
      'showProRecent': false, // Désactivé dans la refonte
      'showBridePrivatePoi': false, // POI deprecated
      'showProAlerts': filter.toggles.showAlerts,
      'showWeddings': filter.toggles.showWeddings,  // Updated for new RPC
      'showOnlyMyProfessionPins': filter.toggles.showOnlyMyProfession,
    };

    final response = await _client.rpc('search_map_bundle', params: {
      'p_bbox_coords': bboxCoords,
      'p_viewer_role': userRole,
      'p_filters': filters,
      'p_zoom': zoomLevel.round(),
    });
    return response as Map<String, dynamic>? ?? {};
  }

  /// Parse tous les markers depuis la réponse RPC search_map_bundle
  /// 
  /// La RPC retourne: { markers: [...], overlays: [...], debugStats: "..." }
  /// Chaque marker a: { id, type, position: {type: "Point", coordinates: [lng, lat]}, styleInfo: {...} }
  List<MapMarker> parseAllMarkers(Map<String, dynamic> data) {
    final markers = data['markers'] as List? ?? [];
    return markers.map((m) {
      final position = _parseGeoJsonPosition(m['position']);
      if (position == null) return null;
      
      final type = _parseMarkerType(m['type'] as String?);
      final styleInfo = m['styleInfo'] as Map<String, dynamic>? ?? {};
      
      return MapMarker(
        id: m['id']?.toString() ?? '',
        type: type,
        position: position,
        style: MarkerStyle(
          avatarUrl: styleInfo['avatarUrl'] as String?,
          borderColorHex: styleInfo['borderColorHex'] as String?,
          // Label for initials display (fallback to name from metadata)
          label: styleInfo['label'] as String? ?? 
                 styleInfo['name'] as String? ?? 
                 styleInfo['displayName'] as String?,
          profileId: styleInfo['profileId'] as String?,
        ),
        metadata: {
          'isOwn': styleInfo['isOwn'] == true,
        },
      );
    }).whereType<MapMarker>().toList();
  }

  /// Parse le type de marker depuis la string RPC
  MapMarkerType _parseMarkerType(String? type) {
    switch (type?.toLowerCase()) {
      case 'professional':
        return MapMarkerType.proFixedLocation;
      case 'fixedlocation':
        return MapMarkerType.proFixedLocation;
      case 'prorecent':
        return MapMarkerType.proFixedLocation;
      case 'professionalalert':
        return MapMarkerType.professionalAlert;
      case 'wedding':  // New type from updated RPC
        return MapMarkerType.wedding;
      case 'weddingpin':  // Legacy compatibility
        return MapMarkerType.wedding;
      case 'poiprivate':  // Deprecated, fallback to pro
        return MapMarkerType.proFixedLocation;
      default:
        return MapMarkerType.proFixedLocation;
    }
  }

  /// Parse position GeoJSON depuis la RPC
  gmaps.LatLng? _parseGeoJsonPosition(dynamic position) {
    if (position == null) return null;
    if (position is! Map) return null;
    
    final coords = position['coordinates'];
    if (coords is! List || coords.length < 2) return null;
    
    return gmaps.LatLng(
      (coords[1] as num).toDouble(), // lat
      (coords[0] as num).toDouble(), // lng
    );
  }

  /// Parse les professionnels depuis la réponse RPC (legacy)
  @Deprecated('Utiliser parseAllMarkers à la place')
  List<MapMarker> parseProfessionals(Map<String, dynamic> data) {
    return parseAllMarkers(data)
        .where((m) => m.type == MapMarkerType.proFixedLocation)
        .toList();
  }

  /// Parse les fixed locations depuis la réponse RPC (legacy)
  @Deprecated('Utiliser parseAllMarkers à la place')
  List<MapMarker> parseFixedLocations(Map<String, dynamic> data) {
    return parseProfessionals(data);
  }

  /// Parse les alertes depuis la réponse RPC (legacy)
  @Deprecated('Utiliser parseAllMarkers à la place')
  List<MapMarker> parseAlerts(Map<String, dynamic> data) {
    return parseAllMarkers(data)
        .where((m) => m.type == MapMarkerType.professionalAlert)
        .toList();
  }

  /// Parse les mariages depuis la réponse RPC (legacy)
  @Deprecated('Utiliser parseAllMarkers à la place')
  List<MapMarker> parseWeddings(Map<String, dynamic> data) {
    return parseAllMarkers(data)
        .where((m) => m.type == MapMarkerType.wedding)
        .toList();
  }

  /// Récupère les détails d'un professionnel via RPC
  /// 
  /// Utilise get_pro_item_details(p_pro_profile_id uuid)
  Future<Map<String, dynamic>?> getProfessionalDetails(String id) async {
    try {
      final response = await _client.rpc(
        'get_pro_item_details',
        params: {'p_pro_profile_id': id},
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      // Log error but don't crash
      return null;
    }
  }

  /// Récupère les détails d'une alerte via RPC
  /// 
  /// Utilise get_alert_item_details(p_alert_id uuid)
  Future<Map<String, dynamic>?> getAlertDetails(String id) async {
    try {
      final response = await _client.rpc(
        'get_alert_item_details',
        params: {'p_alert_id': id},
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      // Log error but don't crash
      return null;
    }
  }

  /// Récupère les détails d'un mariage via RPC
  /// 
  /// Utilise get_wedding_details(p_wedding_id uuid) - NEW Phase 5
  Future<Map<String, dynamic>?> getWeddingDetails(String id) async {
    try {
      final response = await _client.rpc(
        'get_wedding_details',
        params: {'p_wedding_id': id},
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      // Log error but don't crash
      return null;
    }
  }

  /// Récupère le mariage de l'utilisateur courant (bride)
  Future<Map<String, dynamic>?> getMyWedding() async {
    try {
      final response = await _client.rpc('get_my_wedding');
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Crée ou met à jour le mariage de la bride
  Future<Map<String, dynamic>?> upsertWedding({
    String? weddingName,
    required DateTime eventDate,
    DateTime? eventEndDate,
    double? venueLat,
    double? venueLng,
    String? venueLabel,
    int searchRadiusKm = 50,
    int? budgetMin,
    int? budgetMax,
    String currency = 'EUR',
    List<String>? professionsNeeded,
    String visibility = 'private',
  }) async {
    try {
      final response = await _client.rpc('upsert_wedding', params: {
        'p_wedding_name': weddingName,
        'p_event_date': eventDate.toIso8601String().split('T').first,
        'p_event_end_date': eventEndDate?.toIso8601String().split('T').first,
        'p_venue_lat': venueLat,
        'p_venue_lng': venueLng,
        'p_venue_label': venueLabel,
        'p_search_radius_km': searchRadiusKm,
        'p_budget_min': budgetMin,
        'p_budget_max': budgetMax,
        'p_currency': currency,
        'p_professions_needed': professionsNeeded,
        'p_visibility': visibility,
      });
      return response as Map<String, dynamic>?;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Supprime le mariage de la bride (soft delete)
  Future<bool> deleteMyWedding() async {
    try {
      await _client.rpc('delete_my_wedding');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============== ALERT MANAGEMENT ==============

  /// Crée une nouvelle alerte professionnelle
  /// 
  /// Utilise create_alert RPC avec validation:
  /// - Max 3 alertes actives par pro
  /// - event_date obligatoire et futur
  /// - title max 100 caractères
  Future<Map<String, dynamic>?> createAlert({
    required String alertType,
    required String title,
    required String message,
    required DateTime eventDate,
    required double locationLat,
    required double locationLng,
    required String locationLabel,
    int radiusKm = 50,
    String? professionNeeded,
  }) async {
    try {
      final response = await _client.rpc('create_alert', params: {
        'p_alert_type': alertType,
        'p_title': title,
        'p_message': message,
        'p_event_date': eventDate.toIso8601String().split('T').first,
        'p_location_lat': locationLat,
        'p_location_lng': locationLng,
        'p_location_label': locationLabel,
        'p_radius_km': radiusKm,
        'p_profession_needed': professionNeeded,
      });
      return response as Map<String, dynamic>?;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Met à jour une alerte existante
  Future<Map<String, dynamic>?> updateAlert({
    required String alertId,
    String? title,
    String? message,
    DateTime? eventDate,
    double? locationLat,
    double? locationLng,
    String? locationLabel,
    String? status,
  }) async {
    try {
      final response = await _client.rpc('update_alert', params: {
        'p_alert_id': alertId,
        'p_title': title,
        'p_message': message,
        'p_event_date': eventDate?.toIso8601String().split('T').first,
        'p_location_lat': locationLat,
        'p_location_lng': locationLng,
        'p_location_label': locationLabel,
        'p_status': status,
      });
      return response as Map<String, dynamic>?;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Supprime une alerte (soft delete)
  Future<Map<String, dynamic>?> deleteAlert(String alertId) async {
    try {
      final response = await _client.rpc('delete_alert', params: {
        'p_alert_id': alertId,
      });
      return response as Map<String, dynamic>?;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les alertes de l'utilisateur courant
  Future<List<Map<String, dynamic>>> getMyAlerts() async {
    try {
      final response = await _client.rpc('get_my_alerts');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- Helpers privés ---

  /// Parse les coordonnées depuis différents formats
  gmaps.LatLng? _parseCoords(dynamic coords) {
    if (coords == null) return null;
    
    // Format GeoJSON: {"type": "Point", "coordinates": [lng, lat]}
    if (coords is Map && coords['coordinates'] != null) {
      final c = coords['coordinates'] as List;
      if (c.length >= 2) {
        return gmaps.LatLng(
          (c[1] as num).toDouble(),
          (c[0] as num).toDouble(),
        );
      }
    }
    
    // Format string "lat,lng"
    if (coords is String && coords.contains(',')) {
      final parts = coords.split(',');
      if (parts.length >= 2) {
        return gmaps.LatLng(
          double.tryParse(parts[0].trim()) ?? 0,
          double.tryParse(parts[1].trim()) ?? 0,
        );
      }
    }
    
    // Format objet {lat, lng}
    if (coords is Map) {
      final lat = coords['lat'] ?? coords['latitude'];
      final lng = coords['lng'] ?? coords['longitude'];
      if (lat != null && lng != null) {
        return gmaps.LatLng(
          (lat as num).toDouble(),
          (lng as num).toDouble(),
        );
      }
    }
    
    return null;
  }

  /// Couleur de bordure par profession
  String _professionColor(String? profession) {
    switch (profession?.toUpperCase()) {
      case 'PHOTOGRAPHER':
        return '#2196F3'; // Bleu
      case 'FILMMAKER':
        return '#9C27B0'; // Violet
      case 'PLANNER':
        return '#4CAF50'; // Vert
      case 'VENUE':
        return '#FF9800'; // Orange
      case 'CATERER':
        return '#795548'; // Marron
      case 'DJ':
        return '#E91E63'; // Rose
      case 'FLORIST':
        return '#8BC34A'; // Vert clair
      default:
        return '#607D8B'; // Gris bleu
    }
  }
}
