/// Supabase My Wedding Datasource
///
/// Handles all Supabase operations for the My Wedding module.
/// Includes onboarding, wedding team management, and inspiration albums.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '/utils/secure_logger.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';

/// Supabase datasource for My Wedding operations
class SupabaseMyWeddingDatasource {
  SupabaseMyWeddingDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Get current user ID
  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Get the current user's wedding
  /// Returns null if no wedding exists
  Future<WeddingOverview?> getMyWedding() async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('getMyWedding: No authenticated user');
      return null;
    }

    try {
      final response = await _client
          .from('weddings')
          .select('''
            id,
            bride_profile_id,
            wedding_name,
            venue_coords,
            venue_label,
            event_date,
            event_end_date,
            location_country_code,
            visibility,
            guest_count,
            budget_min,
            budget_max,
            currency,
            professions_needed,
            search_radius_km,
            cover_image_url,
            note_for_pros,
            status,
            onboarding_step,
            cancelled_at,
            created_at
          ''')
          .eq('bride_profile_id', userId)
          .maybeSingle();

      if (response == null) {
        SecureLogger.info('getMyWedding: No wedding found for user');
        return null;
      }

      return WeddingOverview.fromJson(response);
    } catch (e) {
      SecureLogger.error('getMyWedding error: $e');
      rethrow;
    }
  }

  /// Create a new wedding during onboarding
  /// Called at step 2 with date and location
  Future<String> createWedding({
    required DateTime eventDate,
    required double lat,
    required double lng,
    String? venueName,
    String? venueAddress,
    String? countryCode,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    try {
      final response = await _client
          .from('weddings')
          .insert({
            'bride_profile_id': userId,
            'event_date': eventDate.toIso8601String().split('T')[0],
            'venue_coords': 'POINT($lng $lat)',
            'search_area_coords': 'POINT($lng $lat)',
            'venue_label': venueAddress,
            'location_country_code': countryCode,
            'onboarding_step': 2,
            'status': 'planning',
            'visibility': 'private',
          })
          .select('id')
          .single();

      final weddingId = response['id'] as String;
      SecureLogger.info('createWedding: Created wedding $weddingId');
      return weddingId;
    } catch (e) {
      SecureLogger.error('createWedding error: $e');
      rethrow;
    }
  }

  /// Update wedding data during onboarding
  /// Called at steps 3-8
  Future<void> updateOnboardingData({
    required String weddingId,
    required OnboardingData data,
  }) async {
    try {
      final updateData = data.toJson();
      if (updateData.isEmpty) {
        SecureLogger.warning('updateOnboardingData: No data to update');
        return;
      }

      SecureLogger.info('updateOnboardingData: Sending data: $updateData');

      await _client
          .from('weddings')
          .update(updateData)
          .eq('id', weddingId);

      SecureLogger.info('updateOnboardingData: Updated wedding $weddingId with step ${data.onboardingStep}');
    } catch (e) {
      SecureLogger.error('updateOnboardingData error: $e');
      rethrow;
    }
  }

  /// Complete onboarding
  /// Sets onboarding_step to null, which triggers wedding_team chat creation via trigger
  Future<void> completeOnboarding({
    required String weddingId,
  }) async {
    try {
      await _client
          .from('weddings')
          .update({
            'onboarding_step': null,
          })
          .eq('id', weddingId);

      SecureLogger.info('completeOnboarding: Completed onboarding for wedding $weddingId');
    } catch (e) {
      SecureLogger.error('completeOnboarding error: $e');
      rethrow;
    }
  }

  /// Get list of professionals the bride has contacted
  /// Based on chat rooms where bride has sent messages
  Future<List<ContactedPro>> getContactedPros() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    try {
      // Get pros from private chat rooms where user is a participant
      final response = await _client
          .from('chat_room_participants')
          .select('''
            chat_rooms!inner(
              id,
              is_private,
              chat_room_participants!inner(
                profile_id,
                profiles!inner(
                  id,
                  display_name,
                  avatar_url,
                  profession
                )
              )
            )
          ''')
          .eq('profile_id', userId)
          .eq('chat_rooms.is_private', true);

      final pros = <ContactedPro>[];
      final seenIds = <String>{};

      for (final item in response) {
        final chatRoom = item['chat_rooms'] as Map<String, dynamic>?;
        if (chatRoom == null) continue;

        final participants = chatRoom['chat_room_participants'] as List<dynamic>?;
        if (participants == null) continue;

        for (final participant in participants) {
          final profileId = participant['profile_id'] as String?;
          if (profileId == null || profileId == userId || seenIds.contains(profileId)) {
            continue;
          }

          final profile = participant['profiles'] as Map<String, dynamic>?;
          if (profile == null) continue;

          seenIds.add(profileId);
          pros.add(ContactedPro(
            profileId: profileId,
            displayName: profile['display_name'] as String? ?? 'Unknown',
            avatarUrl: profile['avatar_url'] as String?,
            profession: profile['profession'] as String?,
          ));
        }
      }

      SecureLogger.info('getContactedPros: Found ${pros.length} contacted pros');
      return pros;
    } catch (e) {
      SecureLogger.error('getContactedPros error: $e');
      rethrow;
    }
  }

  /// Invite a professional to the wedding team
  Future<void> inviteProToWedding({
    required String weddingId,
    required String proProfileId,
  }) async {
    try {
      await _client
          .from('wedding_participants')
          .upsert({
            'wedding_id': weddingId,
            'professional_profile_id': proProfileId,
            'status': 'active',
            'joined_at': DateTime.now().toIso8601String(),
          }, onConflict: 'wedding_id,professional_profile_id');

      SecureLogger.info('inviteProToWedding: Invited pro $proProfileId to wedding $weddingId');
    } catch (e) {
      SecureLogger.error('inviteProToWedding error: $e');
      rethrow;
    }
  }

  /// Exclude a professional from the wedding team
  Future<void> excludeProFromWedding({
    required String weddingId,
    required String proProfileId,
    String? reason,
  }) async {
    try {
      await _client
          .from('wedding_participants')
          .update({
            'status': 'excluded',
            'excluded_at': DateTime.now().toIso8601String(),
            'excluded_reason': reason,
          })
          .eq('wedding_id', weddingId)
          .eq('professional_profile_id', proProfileId);

      SecureLogger.info('excludeProFromWedding: Excluded pro $proProfileId from wedding $weddingId');
    } catch (e) {
      SecureLogger.error('excludeProFromWedding error: $e');
      rethrow;
    }
  }

  /// Get wedding team members
  Future<List<WeddingTeamMember>> getWeddingTeam({
    required String weddingId,
  }) async {
    try {
      final response = await _client
          .from('wedding_participants')
          .select('''
            professional_profile_id,
            status,
            joined_at,
            left_at,
            left_reason,
            excluded_at,
            excluded_reason,
            is_muted,
            profiles!wedding_participants_professional_profile_id_fkey(
              display_name,
              avatar_url,
              profession
            )
          ''')
          .eq('wedding_id', weddingId);

      return response.map<WeddingTeamMember>((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;
        return WeddingTeamMember(
          profileId: json['professional_profile_id'] as String,
          displayName: profile?['display_name'] as String? ?? 'Unknown',
          avatarUrl: profile?['avatar_url'] as String?,
          profession: profile?['profession'] as String?,
          status: json['status'] as String? ?? 'active',
          joinedAt: json['joined_at'] != null
              ? DateTime.parse(json['joined_at'] as String)
              : null,
          leftAt: json['left_at'] != null
              ? DateTime.parse(json['left_at'] as String)
              : null,
          leftReason: json['left_reason'] as String?,
          excludedAt: json['excluded_at'] != null
              ? DateTime.parse(json['excluded_at'] as String)
              : null,
          excludedReason: json['excluded_reason'] as String?,
          isMuted: json['is_muted'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      SecureLogger.error('getWeddingTeam error: $e');
      rethrow;
    }
  }

  /// Save a post to an inspiration album
  Future<void> savePostToAlbum({
    required String albumId,
    required String postId,
  }) async {
    try {
      await _client
          .from('saved_posts')
          .insert({
            'album_id': albumId,
            'post_id': postId,
            'saved_at': DateTime.now().toIso8601String(),
          });

      SecureLogger.info('savePostToAlbum: Saved post $postId to album $albumId');
    } catch (e) {
      SecureLogger.error('savePostToAlbum error: $e');
      rethrow;
    }
  }
}
