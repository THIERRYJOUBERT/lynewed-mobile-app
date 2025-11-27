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
  Future<Map<String, dynamic>> searchMapBundle({
    required gmaps.LatLngBounds bounds,
    required MapFilter filter,
    required String userRole,
    required double zoomLevel,
  }) async {
    final params = {
      'p_sw_lat': bounds.southwest.latitude,
      'p_sw_lng': bounds.southwest.longitude,
      'p_ne_lat': bounds.northeast.latitude,
      'p_ne_lng': bounds.northeast.longitude,
      'p_viewer_role': userRole,
      'p_limit': ZoomLimits.getLimit(zoomLevel),
      // Filtres
      'p_professions': filter.professions.map((p) => p.name.toUpperCase()).toList(),
      'p_budget_min': filter.budgetMin,
      'p_budget_max': filter.budgetMax,
      'p_currency': filter.currency,
      'p_country_code': filter.countryCode,
      // Toggles
      'p_show_pros': filter.toggles.showPros,
      'p_show_fixed_locations': filter.toggles.showFixedLocations,
      'p_show_alerts': filter.toggles.showAlerts,
      'p_show_weddings': filter.toggles.showWeddings,
      'p_show_only_my_profession': filter.toggles.showOnlyMyProfession,
    };

    final response = await _client.rpc('search_map_bundle', params: params);
    return response as Map<String, dynamic>? ?? {};
  }

  /// Parse les professionnels depuis la réponse RPC
  List<MapMarker> parseProfessionals(Map<String, dynamic> data) {
    final professionals = data['professionals'] as List? ?? [];
    return professionals.map((p) {
      final coords = _parseCoords(p['location_coords']);
      if (coords == null) return null;
      
      return MapMarker(
        id: p['id'] as String,
        type: MapMarkerType.professional,
        position: coords,
        style: MarkerStyle(
          avatarUrl: p['avatar_url'] as String?,
          label: p['full_name'] as String?,
          borderColorHex: _professionColor(p['profession'] as String?),
        ),
        metadata: {
          'profession': p['profession'],
          'full_name': p['full_name'],
          'subscription_tier': p['subscription_tier'],
        },
      );
    }).whereType<MapMarker>().toList();
  }

  /// Parse les fixed locations depuis la réponse RPC
  List<MapMarker> parseFixedLocations(Map<String, dynamic> data) {
    final locations = data['fixed_locations'] as List? ?? [];
    return locations.map((l) {
      final coords = _parseCoords(l['location_coords']);
      if (coords == null) return null;
      
      return MapMarker(
        id: '${l['professional_id']}_${l['id']}',
        type: MapMarkerType.proFixedLocation,
        position: coords,
        style: MarkerStyle(
          avatarUrl: l['avatar_url'] as String?,
          label: l['location_label'] as String?,
          borderColorHex: _professionColor(l['profession'] as String?),
        ),
        metadata: {
          'professional_id': l['professional_id'],
          'location_label': l['location_label'],
          'profession': l['profession'],
        },
      );
    }).whereType<MapMarker>().toList();
  }

  /// Parse les alertes depuis la réponse RPC
  List<MapMarker> parseAlerts(Map<String, dynamic> data) {
    final alerts = data['alerts'] as List? ?? [];
    return alerts.map((a) {
      final coords = _parseCoords(a['location_coords']);
      if (coords == null) return null;
      
      final alertType = AlertType.fromString(a['alert_type'] ?? a['motif_code']);
      
      return MapMarker(
        id: a['id'] as String,
        type: MapMarkerType.professionalAlert,
        position: coords,
        style: MarkerStyle(
          avatarUrl: a['professional_avatar'] as String?,
          label: a['title'] as String?,
          borderColorHex: '#FF5722', // Orange pour alertes
          iconAsset: alertType?.iconAsset,
        ),
        metadata: {
          'alert_type': alertType?.name,
          'event_date': a['event_date'],
          'professional_id': a['professional_id'],
          'professional_name': a['professional_name'],
        },
      );
    }).whereType<MapMarker>().toList();
  }

  /// Parse les mariages depuis la réponse RPC
  List<MapMarker> parseWeddings(Map<String, dynamic> data) {
    final weddings = data['weddings'] as List? ?? 
                     data['wedding_pins'] as List? ?? []; // Compatibilité ancien nom
    return weddings.map((w) {
      final coords = _parseCoords(w['location_coords']);
      if (coords == null) return null;
      
      return MapMarker(
        id: w['id'] as String,
        type: MapMarkerType.wedding,
        position: coords,
        style: MarkerStyle(
          avatarUrl: w['bride_avatar'] as String?,
          label: w['venue_name'] as String?,
          borderColorHex: '#E91E63', // Rose pour mariages
        ),
        metadata: {
          'bride_id': w['bride_id'],
          'bride_name': w['bride_name'],
          'event_date': w['event_date'],
          'venue_name': w['venue_name'],
        },
      );
    }).whereType<MapMarker>().toList();
  }

  /// Récupère les détails d'un professionnel
  Future<Map<String, dynamic>?> getProfessionalDetails(String id) async {
    final response = await _client.rpc(
      'get_pro_item_details',
      params: {'p_professional_id': id},
    );
    return response as Map<String, dynamic>?;
  }

  /// Récupère les détails d'une alerte
  Future<Map<String, dynamic>?> getAlertDetails(String id) async {
    final response = await _client
        .from('professional_alerts')
        .select('''
          *,
          profiles!professional_alerts_professional_id_fkey(
            full_name,
            avatar_url,
            profession
          )
        ''')
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Récupère les détails d'un mariage
  Future<Map<String, dynamic>?> getWeddingDetails(String id) async {
    // TODO: Adapter quand table weddings créée
    final response = await _client
        .from('wedding_pins')
        .select('''
          *,
          profiles!wedding_pins_user_id_fkey(
            full_name,
            avatar_url
          )
        ''')
        .eq('id', id)
        .maybeSingle();
    return response;
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
      case 'VIDEOGRAPHER':
        return '#9C27B0'; // Violet
      case 'WEDDINGPLANNER':
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
