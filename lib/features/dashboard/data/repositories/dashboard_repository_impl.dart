/// Dashboard repository implementation
///
/// Supabase implementation of DashboardRepository.
/// Uses SupaFlow pattern for data access.
library;

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lynewed_beta/backend/supabase/supabase.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/dashboard/domain/entities/pro_stats.dart';
import 'package:lynewed_beta/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:lynewed_beta/features/map/domain/entities/alert_details.dart';
import 'package:lynewed_beta/features/map/domain/entities/professional_alert.dart';

/// Supabase implementation of DashboardRepository
class DashboardRepositoryImpl implements DashboardRepository {
  /// Creates repository with default Supabase client
  DashboardRepositoryImpl() : _mockDatasource = null;

  /// Creates repository with mock datasource for testing
  DashboardRepositoryImpl.withMockDatasource(this._mockDatasource);

  final dynamic _mockDatasource;

  SupabaseClient get _client => SupaFlow.client;
  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Result<ProStats>> getStats() async {
    // Use mock if available (for testing)
    if (_mockDatasource != null) {
      try {
        final stats = await _mockDatasource.getStats();
        return Success(stats as ProStats);
      } catch (e) {
        return Failure(ServerFailure(e.toString()));
      }
    }

    try {
      if (_userId == null) {
        return const Failure(AuthFailure('User not authenticated'));
      }

      // Fetch stats in parallel
      final results = await Future.wait([
        _getProfileViews(),
        _getSavedCount(),
        _getMessageCount(),
        _getAlertCount(),
      ]);

      final stats = ProStats(
        profileViews: results[0],
        savedCount: results[1],
        messageCount: results[2],
        alertCount: results[3],
        lastUpdated: DateTime.now(),
      );

      return Success(stats);
    } catch (e) {
      return Failure(ServerFailure('Failed to load stats: $e'));
    }
  }

  @override
  Future<Result<List<ProfessionalAlert>>> getActiveAlerts({int limit = 3}) async {
    // Use mock if available (for testing)
    if (_mockDatasource != null) {
      try {
        final alerts = await _mockDatasource.getActiveAlerts(limit: limit);
        return Success(alerts as List<ProfessionalAlert>);
      } catch (e) {
        return Failure(ServerFailure(e.toString()));
      }
    }

    try {
      if (_userId == null) {
        return const Failure(AuthFailure('User not authenticated'));
      }

      final now = DateTime.now().toIso8601String();

      // Fetch active alerts (not expired, not own)
      final response = await _client
          .from('professional_alerts')
          .select('''
            *,
            profiles:professional_id (
              full_name,
              avatar_url,
              profession
            )
          ''')
          .neq('professional_id', _userId!)
          .gt('expires_at', now)
          .order('created_at', ascending: false)
          .limit(limit);

      final alerts = (response as List<dynamic>)
          .map((data) => _parseAlert(data as Map<String, dynamic>))
          .toList();

      return Success(alerts);
    } catch (e) {
      return Failure(ServerFailure('Failed to load alerts: $e'));
    }
  }

  // --- Private helpers ---

  Future<int> _getProfileViews() async {
    try {
      // Get profile view count from analytics or profile_views table
      // For now, return from profile stats if available
      final response = await _client
          .from('professional_details')
          .select('profile_views_count')
          .eq('user_id', _userId!)
          .maybeSingle();

      return (response?['profile_views_count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _getSavedCount() async {
    try {
      // Count brides who wishlisted this professional
      final response = await _client
          .from('bride_wishlists')
          .select()
          .eq('professional_id', _userId!)
          .count(CountOption.exact);

      return response.count;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _getMessageCount() async {
    try {
      // Count unread messages
      final response = await _client
          .from('chat_messages')
          .select()
          .eq('receiver_id', _userId!)
          .isFilter('read_at', null)
          .count(CountOption.exact);

      return response.count;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _getAlertCount() async {
    try {
      // Count user's active alerts
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('professional_alerts')
          .select()
          .eq('professional_id', _userId!)
          .gt('expires_at', now)
          .count(CountOption.exact);

      return response.count;
    } catch (_) {
      return 0;
    }
  }

  ProfessionalAlert _parseAlert(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>? ?? {};
    final coords = _parseCoords(data['location_coords']);

    return ProfessionalAlert(
      id: data['id'] as String,
      professionalId: data['professional_id'] as String,
      type: AlertType.fromString(data['alert_type'] ?? data['motif_code']),
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
