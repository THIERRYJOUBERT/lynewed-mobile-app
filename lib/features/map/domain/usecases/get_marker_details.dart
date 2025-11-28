/// Use cases for fetching marker details
/// 
/// Clean use case implementations replacing FlutterFlow actions.
/// Each use case is a single-responsibility class with clear interface.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/entities.dart';

/// Base class for use cases
abstract class UseCase<T, P> {
  Future<T> call(P params);
}

/// Get professional details use case
class GetProfessionalDetails implements UseCase<ProfessionalDetails?, String> {
  GetProfessionalDetails({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<ProfessionalDetails?> call(String proProfileId) async {
    if (proProfileId.isEmpty) {
      debugPrint('GetProfessionalDetails: proProfileId is empty');
      return null;
    }

    try {
      final data = await _client.rpc(
        'get_pro_item_details',
        params: {'p_pro_profile_id': proProfileId},
      );

      if (data is! Map<String, dynamic>) {
        debugPrint('GetProfessionalDetails: Invalid response type');
        return null;
      }

      return ProfessionalDetails.fromJson(data);
    } catch (e) {
      debugPrint('GetProfessionalDetails error: $e');
      return null;
    }
  }
}

/// Get alert details use case
class GetAlertDetails implements UseCase<AlertDetails?, String> {
  GetAlertDetails({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<AlertDetails?> call(String alertId) async {
    if (alertId.isEmpty) {
      debugPrint('GetAlertDetails: alertId is empty');
      return null;
    }

    try {
      final data = await _client.rpc(
        'get_alert_item_details',
        params: {'p_alert_id': alertId},
      );

      if (data is! Map<String, dynamic>) {
        debugPrint('GetAlertDetails: Invalid response type');
        return null;
      }

      return AlertDetails.fromJson(data);
    } catch (e) {
      debugPrint('GetAlertDetails error: $e');
      return null;
    }
  }
}

/// Get wedding details use case
class GetWeddingDetails implements UseCase<WeddingDetails?, String> {
  GetWeddingDetails({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<WeddingDetails?> call(String weddingId) async {
    if (weddingId.isEmpty) {
      debugPrint('GetWeddingDetails: weddingId is empty');
      return null;
    }

    try {
      final data = await _client.rpc(
        'get_wedding_pin_item_details',
        params: {'p_pin_id': weddingId},
      );

      if (data is! Map<String, dynamic>) {
        debugPrint('GetWeddingDetails: Invalid response type');
        return null;
      }

      return WeddingDetails.fromJson(data);
    } catch (e) {
      debugPrint('GetWeddingDetails error: $e');
      return null;
    }
  }
}

/// Service class that combines all use cases
/// 
/// Provides a single entry point for fetching marker details.
/// Includes in-memory caching to improve performance.
class MarkerDetailsService {
  MarkerDetailsService({SupabaseClient? client})
      : _getProfessionalDetails = GetProfessionalDetails(client: client),
        _getAlertDetails = GetAlertDetails(client: client),
        _getWeddingDetails = GetWeddingDetails(client: client);

  final GetProfessionalDetails _getProfessionalDetails;
  final GetAlertDetails _getAlertDetails;
  final GetWeddingDetails _getWeddingDetails;
  
  // Cache for marker details - keyed by marker ID
  final Map<String, _CachedDetails> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get professional details by ID (with cache)
  Future<ProfessionalDetails?> getProfessionalDetails(String id) async {
    final cached = _getFromCache<ProfessionalDetails>(id);
    if (cached != null) return cached;
    
    final result = await _getProfessionalDetails(id);
    if (result != null) _addToCache(id, result);
    return result;
  }

  /// Get alert details by ID (with cache)
  Future<AlertDetails?> getAlertDetails(String id) async {
    final cached = _getFromCache<AlertDetails>(id);
    if (cached != null) return cached;
    
    final result = await _getAlertDetails(id);
    if (result != null) _addToCache(id, result);
    return result;
  }

  /// Get wedding details by ID (with cache)
  Future<WeddingDetails?> getWeddingDetails(String id) async {
    final cached = _getFromCache<WeddingDetails>(id);
    if (cached != null) return cached;
    
    final result = await _getWeddingDetails(id);
    if (result != null) _addToCache(id, result);
    return result;
  }

  /// Get details for any marker type
  Future<dynamic> getDetailsForMarker(MapMarker marker) async {
    switch (marker.type) {
      case MapMarkerType.proFixedLocation:
        // Use profileId if available (when marker ID is fixed location ID), else fallback to marker ID
        return getProfessionalDetails(marker.style.profileId ?? marker.id);
      case MapMarkerType.professionalAlert:
        return getAlertDetails(marker.id);
      case MapMarkerType.wedding:
        return getWeddingDetails(marker.id);
      case MapMarkerType.poiPrivate:
        // POI is deprecated, return null
        return null;
    }
  }
  
  // Cache helpers
  T? _getFromCache<T>(String id) {
    final cached = _cache[id];
    if (cached == null) return null;
    if (DateTime.now().isAfter(cached.expiresAt)) {
      _cache.remove(id);
      return null;
    }
    return cached.data is T ? cached.data as T : null;
  }
  
  void _addToCache(String id, dynamic data) {
    _cache[id] = _CachedDetails(
      data: data,
      expiresAt: DateTime.now().add(_cacheDuration),
    );
  }
  
  /// Clear cache (useful when data changes)
  void clearCache() => _cache.clear();
  
  /// Invalidate specific cache entry
  void invalidateCache(String id) => _cache.remove(id);
}

/// Cache entry with expiration
class _CachedDetails {
  _CachedDetails({required this.data, required this.expiresAt});
  final dynamic data;
  final DateTime expiresAt;
}

/// Singleton instance for global use
class MarkerDetailsServiceProvider {
  static MarkerDetailsService? _instance;

  static MarkerDetailsService get instance {
    _instance ??= MarkerDetailsService();
    return _instance!;
  }

  static void reset() {
    _instance = null;
  }
}
