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
import '/actions/actions.dart' as action_blocks;

// Import with alias to avoid naming conflicts with FlutterFlow enums
import '../../domain/entities/entities.dart' as entities;
import '../../domain/entities/professional_details.dart' show SubscriptionTier;
import '../../domain/entities/alert_details.dart' show AlertDetails;
import '../../domain/entities/wedding_details.dart' show WeddingDetails;
import '../../domain/usecases/get_marker_details.dart' show MarkerDetailsServiceProvider;

// Chat module imports for moderation and navigation
import '/features/chat/presentation/sheets/sheets.dart';
import '/features/chat/domain/repositories/contact_repository.dart';
import '/features/chat/data/repositories/contact_repository_impl.dart';

/// Service singleton for map-related actions
class MapActionsService {
  MapActionsService._();
  
  static final MapActionsService _instance = MapActionsService._();
  static MapActionsService get instance => _instance;
  
  final SupabaseClient _supabase = Supabase.instance.client;
  final ContactRepository _contactRepository = ContactRepositoryImpl();
  
  // Simple cache for profile data to improve performance
  final Map<String, Map<String, dynamic>> _profileCache = {};

  /// Invalidate cache for a specific profile
  /// Call this when favorite status changes to ensure fresh data
  void invalidateProfileCache(String proProfileId) {
    _profileCache.remove(proProfileId);
  }
  
  /// Clear all profile cache
  void clearProfileCache() {
    _profileCache.clear();
  }

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
        // Fallback to direct query
        final data = await _supabase
            .from('profiles')
            .select('''
              id, full_name, avatar_url,
              professional_details (
                business_name, profession, description, portfolio_images,
                slideshow_images, instagram_url, website_url, profile_video_url,
                has_cover_video, location_label
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
            'slideshowImages': details?['slideshow_images'],
            'instagramUrl': details?['instagram_url'],
            'websiteUrl': details?['website_url'],
            'profileVideoUrl': details?['profile_video_url'],
            'hasCoverVideo': details?['has_cover_video'] == true,
            'locationLabel': details?['location_label'],
            'isFavorited': false,
            'isLive': true,
            'canBeContactedByBride': true,
            'canContactBride': true,
          };
          _profileCache[proProfileId] = responseData;
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

  /// Navigate to chat with a profile
  /// Uses action_blocks.contactChatRoom which properly loads contact info
  Future<void> navigateToChat(
    BuildContext context,
    String otherProfileId,
  ) async {
    await action_blocks.contactChatRoom(
      context,
      targetProfileID: otherProfileId,
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
      
      bool newValue;
      if (currentValue) {
        // Remove from wishlist
        await _supabase
            .from('wishlist_items')
            .delete()
            .eq('bride_profile_id', userId)
            .eq('professional_profile_id', proProfileId);
        newValue = false;
      } else {
        // Add to wishlist
        await _supabase.from('wishlist_items').insert({
          'bride_profile_id': userId,
          'professional_profile_id': proProfileId,
        });
        newValue = true;
      }
      
      // Invalidate all caches to ensure fresh data everywhere
      invalidateProfileCache(proProfileId);
      MarkerDetailsServiceProvider.instance.invalidateCache(proProfileId);
      
      return newValue;
    } catch (e) {
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
      return false;
    }
  }

  // ============================================================
  // MODERATION ACTIONS
  // ============================================================

  /// Show report user sheet and handle submission
  void showReportUserSheet(
    BuildContext context, {
    required String profileId,
    required String userName,
    String? userAvatarUrl,
  }) {
    ReportUserSheet.show(
      context: context,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      onReport: (reason, details) async {
        final result = await _contactRepository.reportUser(
          reportedProfileId: profileId,
          reason: reason,
          details: details,
        );
        
        if (context.mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signalement envoyé'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.error ?? 'Erreur lors du signalement'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
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
      hasCoverVideo: details.hasCoverVideo,
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
}

