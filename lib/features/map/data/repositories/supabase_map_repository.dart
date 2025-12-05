/// Supabase implementation of MapRepository
/// 
/// Uses SupabaseMapDatasource for all data operations.
library;

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../domain/entities/entities.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/supabase_map_datasource.dart';

/// Implémentation Supabase du MapRepository
class SupabaseMapRepository implements MapRepository {
  SupabaseMapRepository({SupabaseMapDatasource? datasource})
      : _datasource = datasource ?? SupabaseMapDatasource();

  final SupabaseMapDatasource _datasource;

  @override
  Future<MapSearchResult> searchMarkers({
    required gmaps.LatLngBounds bounds,
    required MapFilter filter,
    required String userRole,
    double zoomLevel = 12.0,
  }) async {
    try {
      final data = await _datasource.searchMapBundle(
        bounds: bounds,
        filter: filter,
        userRole: userRole,
        zoomLevel: zoomLevel,
      );

      // Parse all markers from RPC response
      // Note: professionals and fixedLocations are now merged (RPC returns only fixedLocation type)
      // We put all pro markers in fixedLocations, professionals stays empty to avoid double counting
      final allMarkers = _datasource.parseAllMarkers(data);
      
      final fixedLocations = allMarkers
          .where((m) => m.type == MapMarkerType.proFixedLocation)
          .toList();
      final alerts = allMarkers
          .where((m) => m.type == MapMarkerType.professionalAlert)
          .toList();
      final weddings = allMarkers
          .where((m) => m.type == MapMarkerType.wedding)
          .toList();

      return MapSearchResult(
        professionals: const [], // Empty - all pros are in fixedLocations now
        fixedLocations: fixedLocations,
        alerts: alerts,
        weddings: weddings,
        totalCount: fixedLocations.length + alerts.length + weddings.length,
      );
    } catch (_) {
      // Return empty result on error - no logging in production
      return MapSearchResult.empty;
    }
  }

  @override
  Future<Map<String, dynamic>?> getProfessionalDetails(String professionalId) {
    return _datasource.getProfessionalDetails(professionalId);
  }

  @override
  Future<ProfessionalAlert?> getAlertDetails(String alertId) async {
    final data = await _datasource.getAlertDetails(alertId);
    if (data == null) return null;

    return _parseAlert(data);
  }

  @override
  Future<Wedding?> getWeddingDetails(String weddingId) async {
    final data = await _datasource.getWeddingDetails(weddingId);
    if (data == null) return null;

    return _parseWedding(data);
  }

  @override
  Future<ProfessionalAlert> saveAlert(ProfessionalAlert alert) async {
    // TODO: Implement when needed
    throw UnimplementedError('saveAlert not implemented yet');
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    // TODO: Implement when needed
    throw UnimplementedError('deleteAlert not implemented yet');
  }

  @override
  Future<Wedding> saveWedding(Wedding wedding) async {
    // TODO: Implement when needed
    throw UnimplementedError('saveWedding not implemented yet');
  }

  @override
  Future<Wedding?> getCurrentUserWedding() async {
    // TODO: Implement when needed
    return null;
  }

  @override
  Stream<List<ProfessionalAlert>> watchAlerts(gmaps.LatLngBounds bounds) {
    // TODO: Implement Supabase Realtime
    return const Stream.empty();
  }

  @override
  void dispose() {
    // Cleanup if needed
  }

  // --- Helpers privés ---

  ProfessionalAlert _parseAlert(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>? ?? {};
    final coords = _parseCoords(data['location_coords']);

    return ProfessionalAlert(
      id: data['id'] as String,
      professionalId: data['professional_id'] as String,
      type: AlertType.fromString(data['alert_type'] ?? data['motif_code']) ??
          AlertType.emergencyHelp,
      position: coords ?? const gmaps.LatLng(0, 0),
      eventDate: DateTime.tryParse(data['event_date'] ?? '') ?? DateTime.now(),
      title: data['title'] as String?,
      description: data['description'] as String?,
      createdAt: DateTime.tryParse(data['created_at'] ?? ''),
      expiresAt: DateTime.tryParse(data['expires_at'] ?? ''),
      professionalName: profile['full_name'] as String?,
      professionalAvatarUrl: profile['avatar_url'] as String?,
      profession: profile['profession'] as String?,
    );
  }

  Wedding _parseWedding(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>? ?? {};
    final coords = _parseCoords(data['location_coords']);

    return Wedding(
      id: data['id'] as String,
      brideId: data['user_id'] as String,
      position: coords ?? const gmaps.LatLng(0, 0),
      eventDate: DateTime.tryParse(data['event_date'] ?? ''),
      venueName: data['venue_name'] ?? data['title'] as String?,
      venueAddress: data['venue_address'] ?? data['label'] as String?,
      visibility: WeddingVisibility.fromString(data['visibility']),
      guestCount: data['guest_count'] as int?,
      budgetMin: (data['budget_min'] as num?)?.toDouble(),
      budgetMax: (data['budget_max'] as num?)?.toDouble(),
      currency: data['currency'] as String? ?? 'EUR',
      professionsNeeded: (data['professions_needed'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      searchRadiusKm: data['radius_km'] as int? ?? 50,
      notes: data['notes'] as String?,
      createdAt: DateTime.tryParse(data['created_at'] ?? ''),
      brideName: profile['full_name'] as String?,
      brideAvatarUrl: profile['avatar_url'] as String?,
    );
  }

  gmaps.LatLng? _parseCoords(dynamic coords) {
    if (coords == null) return null;

    if (coords is Map && coords['coordinates'] != null) {
      final c = coords['coordinates'] as List;
      if (c.length >= 2) {
        return gmaps.LatLng(
          (c[1] as num).toDouble(),
          (c[0] as num).toDouble(),
        );
      }
    }

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
}
