/// Map Actions Service
/// 
/// Handles all user actions from map sheets:
/// - View Profile navigation
/// - Contact/Chat navigation
/// - Favorite toggle
/// - Alert deletion
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/index.dart';

// Import with alias to avoid naming conflicts with FlutterFlow enums
import '../../domain/entities/entities.dart' as entities;
import '../../domain/entities/professional_details.dart' show SubscriptionTier;
import '../../domain/entities/alert_details.dart' show AlertDetails;
import '../../domain/entities/wedding_details.dart' show WeddingDetails;

/// Service singleton for map-related actions
class MapActionsService {
  MapActionsService._();
  
  static final MapActionsService _instance = MapActionsService._();
  static MapActionsService get instance => _instance;
  
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Simple cache for profile data to improve performance
  final Map<String, Map<String, dynamic>> _profileCache = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // ============================================================
  // NAVIGATION ACTIONS
  // ============================================================

  /// Navigate to professional public profile
  void navigateToProProfile(
    BuildContext context,
    entities.ProfessionalDetails details,
  ) {
    final proDetailsStruct = _convertToProDetailsStruct(details);
    
    // Use ProDetailsWidget (pages/shared/) - NOT PublicProProfileViewWidget (pages/pro/)
    // ProDetailsWidget is the shared page for viewing any pro profile
    context.pushNamed(
      ProDetailsWidget.routeName,
      queryParameters: {
        'proDetails': serializeParam(
          proDetailsStruct,
          ParamType.DataStruct,
        ),
      }.withoutNulls,
    );
  }

  /// Navigate to bride profile (from wedding)
  void navigateToBrideProfile(
    BuildContext context,
    WeddingDetails details,
  ) {
    // Bride profile page doesn't exist yet - planned for Part B
    // Show informative message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil bride disponible dans une prochaine version'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigate to author profile (from alert)
  /// Works for both active and expired alerts
  /// 
  /// IMPORTANT: This method is async because it needs to fetch pro details.
  /// It handles: 1) Pop sheet 2) Fetch data 3) Navigate to profile
  Future<void> navigateToAuthorProfile(
    BuildContext context,
    AlertDetails details,
  ) async {
    // Safety check: authorId must be valid
    if (details.authorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load author profile')),
      );
      return;
    }
    
    // CRITICAL: Capture GoRouter BEFORE popping the sheet
    // After pop, the context becomes invalid and we can't use context.pushNamed
    final goRouter = GoRouter.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Pop the sheet first
    Navigator.of(context).pop();
    
    // Now fetch the profile data
    final proProfileId = details.authorId;
    
    // Check cache first
    if (_profileCache.containsKey(proProfileId)) {
      _navigateWithGoRouter(goRouter, _profileCache[proProfileId]!);
      return;
    }
    
    try {
      Map<String, dynamic>? responseData;
      
      try {
        // Try RPC first
        final response = await _supabase.rpc(
          'get_pro_item_details',
          params: {'p_pro_profile_id': proProfileId},
        );
        if (response != null && response is Map<String, dynamic>) {
          // Flatten socials object for ProDetailsStruct compatibility
          final socials = response['socials'] as Map<String, dynamic>?;
          responseData = {
            ...response,
            'instagramUrl': socials?['instagramUrl'] ?? response['instagramUrl'],
            'websiteUrl': socials?['websiteUrl'] ?? response['websiteUrl'],
          };
          _profileCache[proProfileId] = responseData;
        }
      } catch (rpcError) {
        debugPrint('RPC failed, using fallback: $rpcError');
        // Fallback to direct query
        final data = await _supabase
            .from('profiles')
            .select('''
              id, full_name, avatar_url,
              professional_details (
                business_name, profession, description, portfolio_images,
                instagram_url, website_url, profile_video_url,
                location_label
              )
            ''')
            .eq('id', proProfileId)
            .maybeSingle();
            
        if (data != null) {
          final details = data['professional_details'] as Map<String, dynamic>?;
          responseData = {
            'proProfileId': data['id'],
            'fullName': data['full_name'],
            'avatarUrl': data['avatar_url'],
            'businessName': details?['business_name'],
            'profession': details?['profession'],
            'description': details?['description'],
            'portfolioImages': details?['portfolio_images'],
            'instagramUrl': details?['instagram_url'],
            'websiteUrl': details?['website_url'],
            'profileVideoUrl': details?['profile_video_url'],
            'locationLabel': details?['location_label'],
            'isFavorited': false,
            'isLive': true,
            'canBeContactedByBride': true,
            'canContactBride': true,
          };
          _profileCache[proProfileId] = responseData!;
        }
      }
      
      if (responseData != null) {
        _navigateWithGoRouter(goRouter, responseData);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Profile not found')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching professional details: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error loading profile')),
      );
    }
  }
  
  /// Navigate using captured GoRouter (for async operations after context invalidation)
  void _navigateWithGoRouter(GoRouter router, Map<String, dynamic> responseData) {
    final proDetails = ProDetailsStruct.fromMap(responseData);
    router.pushNamed(
      ProDetailsWidget.routeName,
      queryParameters: {
        'proDetails': serializeParam(proDetails, ParamType.DataStruct),
      }.withoutNulls,
    );
  }

  /// Navigate to chat with professional
  Future<void> navigateToChat(
    BuildContext context,
    String otherProfileId, {
    String? existingRoomId,
  }) async {
    // Check for existing chat room or create new one
    final roomId = existingRoomId ?? await _getOrCreateChatRoom(otherProfileId);
    
    if (!context.mounted) return;
    
    context.pushNamed(
      ChatDetailsWidget.routeName,
      queryParameters: {
        'otherProfileId': otherProfileId,
        if (roomId != null) 'roomId': roomId,
        'isRoomEmpty': serializeParam(roomId == null, ParamType.bool),
      }.withoutNulls,
    );
  }

  /// Navigate to contact bride (initiate chat request)
  Future<void> navigateToContactBride(
    BuildContext context,
    WeddingDetails details,
  ) async {
    if (details.brideId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to contact bride')),
      );
      return;
    }
    
    await navigateToChat(context, details.brideId);
  }

  /// Navigate to help alert author (initiate chat)
  Future<void> navigateToHelpAlert(
    BuildContext context,
    AlertDetails details,
  ) async {
    await navigateToChat(context, details.authorId);
  }

  // ============================================================
  // DATA ACTIONS
  // ============================================================

  /// Toggle favorite status for a professional
  Future<bool> toggleFavorite(
    String proProfileId, {
    required bool currentValue,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return currentValue;
      
      if (currentValue) {
        // Remove from wishlist
        await _supabase
            .from('wishlist_items')
            .delete()
            .eq('bride_profile_id', userId)
            .eq('professional_profile_id', proProfileId);
        return false;
      } else {
        // Add to wishlist
        await _supabase.from('wishlist_items').insert({
          'bride_profile_id': userId,
          'professional_profile_id': proProfileId,
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return currentValue; // Return unchanged on error
    }
  }

  /// Delete an alert (uses delete_alert RPC)
  Future<bool> deleteAlert(String alertId) async {
    try {
      final result = await _supabase.rpc(
        'delete_alert',
        params: {'p_alert_id': alertId},
      );
      // Result is jsonb: {success: true/false, ...}
      if (result is Map) {
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting alert: $e');
      return false;
    }
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  /// Convert ProfessionalDetails to ProDetailsStruct for navigation
  ProDetailsStruct _convertToProDetailsStruct(entities.ProfessionalDetails details) {
    return ProDetailsStruct(
      proProfileId: details.id,
      fullName: details.fullName,
      avatarUrl: details.avatarUrl,
      businessName: details.businessName,
      profession: _convertProfession(details.profession),
      budgetMin: details.budgetMin,
      budgetMax: details.budgetMax,
      currency: details.currency,
      subscriptionTier: _convertSubscriptionTier(details.subscriptionTier),
      distanceKm: details.distanceKm,
      locationLabel: details.locationLabel,
      coverImageUrl: details.coverImageUrl,
      isFavorited: details.isFavorited,
      isLive: details.isLive,
      description: details.description,
      portfolioImages: details.portfolioImages,
      slideshowImages: details.slideshowImages,
      instagramUrl: details.instagramUrl,
      websiteUrl: details.websiteUrl,
      profileVideoUrl: details.profileVideoUrl,
      canBeContactedByBride: details.canBeContactedByBride,
      canContactBride: details.canContactBride,
      // Note: fixedLocations requires conversion gmaps.LatLng → FlutterFlow LatLng
      fixedLocations: details.fixedLocations
          .map((l) => LatLng(l.latitude, l.longitude))
          .toList(),
    );
  }

  /// Convert our Profession enum to FlutterFlow's Profession enum
  Profession? _convertProfession(entities.Profession? profession) {
    if (profession == null) return null;
    final name = profession.toRpcValue;
    return Profession.values.firstWhere(
      (e) => e.name.toUpperCase() == name,
      orElse: () => Profession.OTHER,
    );
  }

  /// Convert our SubscriptionTier to FlutterFlow's SubscriptionTierType
  SubscriptionTierType? _convertSubscriptionTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.inactive:
        return SubscriptionTierType.inactive;
      case SubscriptionTier.trial:
        return SubscriptionTierType.trial;
      case SubscriptionTier.earlyAccess:
        return SubscriptionTierType.earlyAccess;
      case SubscriptionTier.premiumVisibility:
        return SubscriptionTierType.premiumVisibility;
      case SubscriptionTier.ultimateAccess:
        return SubscriptionTierType.ultimateAccess;
    }
  }

  /// Navigate to pro profile by ID (fetch details first)
  Future<void> _navigateToProProfileById(
    BuildContext context,
    String proProfileId,
  ) async {
    // Check cache first
    if (_profileCache.containsKey(proProfileId)) {
      _navigateWithProDetailsStruct(context, _profileCache[proProfileId]!);
      return;
    }
    
    try {
      Map<String, dynamic>? responseData;
      
      try {
        // Try RPC first
        final response = await _supabase.rpc(
          'get_pro_item_details',
          params: {'p_pro_profile_id': proProfileId},
        );
        if (response != null && response is Map<String, dynamic>) {
          // Flatten socials object for ProDetailsStruct compatibility
          final socials = response['socials'] as Map<String, dynamic>?;
          responseData = {
            ...response,
            'instagramUrl': socials?['instagramUrl'] ?? response['instagramUrl'],
            'websiteUrl': socials?['websiteUrl'] ?? response['websiteUrl'],
          };
          _profileCache[proProfileId] = responseData;
        }
      } catch (rpcError) {
        debugPrint('RPC failed, using fallback: $rpcError');
        // Fallback to direct query - use LEFT JOIN to handle non-pro users
        final data = await _supabase
            .from('profiles')
            .select('''
              id, full_name, avatar_url,
              professional_details (
                business_name, profession, description, portfolio_images,
                instagram_url, website_url, profile_video_url,
                location_label
              )
            ''')
            .eq('id', proProfileId)
            .maybeSingle();
            
        if (data != null) {
          final details = data['professional_details'] as Map<String, dynamic>?;
          
          responseData = {
            'proProfileId': data['id'],
            'fullName': data['full_name'],
            'avatarUrl': data['avatar_url'],
            'businessName': details?['business_name'],
            'profession': details?['profession'],
            'description': details?['description'],
            'portfolioImages': details?['portfolio_images'],
            'instagramUrl': details?['instagram_url'],
            'websiteUrl': details?['website_url'],
            'profileVideoUrl': details?['profile_video_url'],
            'locationLabel': details?['location_label'],
            'isFavorited': false,
            'isLive': true,
            'canBeContactedByBride': true,
            'canContactBride': true,
          };
          _profileCache[proProfileId] = responseData!;
        }
      }
      
      if (responseData != null) {
        _navigateWithProDetailsStruct(context, responseData);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile not found')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching professional details: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading profile')),
        );
      }
    }
  }
  
  void _navigateWithProDetailsStruct(BuildContext context, Map<String, dynamic> responseData) {
    if (!context.mounted) return;
    final proDetails = ProDetailsStruct.fromMap(responseData);
    context.pushNamed(
      ProDetailsWidget.routeName,
      queryParameters: {
        'proDetails': serializeParam(proDetails, ParamType.DataStruct),
      }.withoutNulls,
    );
  }

  /// Get or create a chat room with another user
  Future<String?> _getOrCreateChatRoom(String otherProfileId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Check for existing room
      final existingRoom = await _supabase
          .from('chat_rooms')
          .select('id')
          .or('and(user1_id.eq.$userId,user2_id.eq.$otherProfileId),and(user1_id.eq.$otherProfileId,user2_id.eq.$userId)')
          .maybeSingle();

      if (existingRoom != null) {
        return existingRoom['id'] as String;
      }

      // No existing room, return null to create on first message
      return null;
    } catch (e) {
      debugPrint('Error getting chat room: $e');
      return null;
    }
  }
}

