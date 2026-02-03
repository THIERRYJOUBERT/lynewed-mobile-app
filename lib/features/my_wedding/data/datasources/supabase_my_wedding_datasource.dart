/// Supabase My Wedding Datasource
///
/// Handles all Supabase operations for the My Wedding module.
/// Includes onboarding, wedding team management, and inspiration albums.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '/features/guest/domain/entities/guest_media.dart';
import '/utils/secure_logger.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../models/guest_album_model.dart';

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
            created_at,
            invite_code,
            invite_code_expires_at
          ''')
          .eq('bride_profile_id', userId)
          .eq('is_deleted', false)
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
  /// Based on private chat rooms where user has conversations with pros
  Future<List<ContactedPro>> getContactedPros() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    try {
      // Use raw SQL via RPC for reliability
      final response = await _client.rpc('get_contacted_pros_for_bride', params: {
        'p_bride_id': userId,
      });

      final pros = <ContactedPro>[];
      
      if (response == null || (response is List && response.isEmpty)) {
        SecureLogger.info('getContactedPros: No pros found via RPC');
        return pros;
      }

      for (final item in response as List) {
        final profileId = item['profile_id'] as String?;
        if (profileId == null) continue;

        pros.add(ContactedPro(
          profileId: profileId,
          displayName: item['business_name'] as String? ?? 
                      item['full_name'] as String? ?? 
                      'Unknown',
          avatarUrl: item['avatar_url'] as String?,
          profession: item['profession'] as String?,
        ));
      }

      SecureLogger.info('getContactedPros: Found ${pros.length} contacted pros');
      return pros;
    } catch (e, stack) {
      SecureLogger.error('getContactedPros RPC error: $e\n$stack');
      // Fallback to manual queries if RPC doesn't exist
      return _getContactedProsManual(userId);
    }
  }

  /// Fallback method using manual queries
  Future<List<ContactedPro>> _getContactedProsManual(String userId) async {
    try {
      // Step 1: Get all private chat room IDs where user is a participant
      final roomsResponse = await _client
          .from('chat_room_participants')
          .select('room_id')
          .eq('profile_id', userId);

      if (roomsResponse.isEmpty) return [];

      final allRoomIds = (roomsResponse as List)
          .map((r) => r['room_id'] as String)
          .toList();

      // Step 2: Filter to only private rooms
      final privateRoomsResponse = await _client
          .from('chat_rooms')
          .select('id')
          .inFilter('id', allRoomIds)
          .eq('type', 'private');

      if (privateRoomsResponse.isEmpty) return [];

      final roomIds = (privateRoomsResponse as List)
          .map((r) => r['id'] as String)
          .toList();

      // Step 3: Get other participants from these rooms
      final participantsResponse = await _client
          .from('chat_room_participants')
          .select('profile_id')
          .inFilter('room_id', roomIds)
          .neq('profile_id', userId);

      if (participantsResponse.isEmpty) return [];

      final otherProfileIds = (participantsResponse as List)
          .map((p) => p['profile_id'] as String)
          .toSet()
          .toList();

      // Step 4: Get profile details for professionals only
      final profilesResponse = await _client
          .from('profiles')
          .select('id, full_name, avatar_url, role')
          .inFilter('id', otherProfileIds)
          .eq('role', 'professional');

      final pros = <ContactedPro>[];

      for (final profile in profilesResponse) {
        final profileId = profile['id'] as String?;
        if (profileId == null) continue;

        // Get professional details
        final proDetailsResponse = await _client
            .from('professional_details')
            .select('profession, business_name')
            .eq('profile_id', profileId)
            .maybeSingle();

        pros.add(ContactedPro(
          profileId: profileId,
          displayName: proDetailsResponse?['business_name'] as String? ?? 
                      profile['full_name'] as String? ?? 
                      'Unknown',
          avatarUrl: profile['avatar_url'] as String?,
          profession: proDetailsResponse?['profession'] as String?,
        ));
      }

      return pros;
    } catch (e) {
      SecureLogger.error('getContactedPros manual error: $e');
      return [];
    }
  }

  /// Invite a professional to the wedding team
  Future<void> inviteProToWedding({
    required String weddingId,
    required String proProfileId,
  }) async {
    try {
      // Get the pro's profession from professional_details
      final proDetails = await _client
          .from('professional_details')
          .select('profession')
          .eq('profile_id', proProfileId)
          .maybeSingle();

      final profession = proDetails?['profession'] as String?;

      await _client
          .from('wedding_participants')
          .upsert({
            'wedding_id': weddingId,
            'professional_profile_id': proProfileId,
            'profession': profession,
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
            profession,
            status,
            joined_at,
            left_at,
            left_reason,
            excluded_at,
            excluded_reason,
            is_muted,
            profiles!wedding_participants_professional_profile_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .eq('wedding_id', weddingId);

      return response.map<WeddingTeamMember>((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;
        return WeddingTeamMember(
          profileId: json['professional_profile_id'] as String,
          displayName: profile?['full_name'] as String? ?? 'Unknown',
          avatarUrl: profile?['avatar_url'] as String?,
          profession: json['profession'] as String?,
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

  // ========== INSPIRATION ALBUMS ==========

  /// Get all inspiration albums for a wedding
  Future<List<InspirationAlbum>> getInspirationAlbums({
    required String weddingId,
  }) async {
    try {
      final response = await _client
          .from('inspiration_albums')
          .select('''
            *,
            album_images(count),
            saved_posts(count)
          ''')
          .eq('wedding_id', weddingId)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);

      return (response as List).map((raw) {
        final json = Map<String, dynamic>.from(raw as Map);

        final albumImagesAgg = (json['album_images'] as List?)?.cast<dynamic>();
        final savedPostsAgg = (json['saved_posts'] as List?)?.cast<dynamic>();

        final albumImagesCount = albumImagesAgg != null && albumImagesAgg.isNotEmpty
            ? (albumImagesAgg.first as Map)['count'] as int? ?? 0
            : 0;
        final savedPostsCount = savedPostsAgg != null && savedPostsAgg.isNotEmpty
            ? (savedPostsAgg.first as Map)['count'] as int? ?? 0
            : 0;

        json['images_count'] = albumImagesCount + savedPostsCount;

        return InspirationAlbum.fromJson(json);
      }).toList();
    } catch (e) {
      SecureLogger.error('getInspirationAlbums error: $e');
      rethrow;
    }
  }

  /// Create a new inspiration album
  Future<InspirationAlbum> createInspirationAlbum({
    required String weddingId,
    required String name,
    String? category,
    bool isPrivate = false,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    try {
      final response = await _client
          .from('inspiration_albums')
          .insert({
            'wedding_id': weddingId,
            'bride_profile_id': userId,
            'name': name,
            'category': category ?? 'general',
            'is_private': isPrivate,
          })
          .select()
          .single();

      SecureLogger.info('createInspirationAlbum: Created album for wedding $weddingId');
      return InspirationAlbum.fromJson(response);
    } catch (e) {
      SecureLogger.error('createInspirationAlbum error: $e');
      rethrow;
    }
  }

  /// Update an inspiration album
  Future<void> updateInspirationAlbum({
    required String albumId,
    String? name,
    String? category,
    bool? isPrivate,
    String? coverImageUrl,
    int? sortOrder,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;
      if (isPrivate != null) updateData['is_private'] = isPrivate;
      if (coverImageUrl != null) updateData['cover_image_url'] = coverImageUrl;
      if (sortOrder != null) updateData['sort_order'] = sortOrder;

      if (updateData.length == 1) {
        SecureLogger.warning('updateInspirationAlbum: No data to update');
        return;
      }

      await _client
          .from('inspiration_albums')
          .update(updateData)
          .eq('id', albumId);

      SecureLogger.info('updateInspirationAlbum: Updated album $albumId');
    } catch (e) {
      SecureLogger.error('updateInspirationAlbum error: $e');
      rethrow;
    }
  }

  /// Delete an inspiration album
  Future<void> deleteInspirationAlbum({required String albumId}) async {
    try {
      await _client
          .from('inspiration_albums')
          .delete()
          .eq('id', albumId);

      SecureLogger.info('deleteInspirationAlbum: Deleted album $albumId');
    } catch (e) {
      SecureLogger.error('deleteInspirationAlbum error: $e');
      rethrow;
    }
  }

  // ========== ALBUM IMAGES (uploaded from gallery) ==========

  /// Get all images in an album (both uploaded and saved)
  Future<List<AlbumImage>> getAlbumImages({
    required String albumId,
  }) async {
    try {
      final response = await _client
          .from('album_images')
          .select()
          .eq('album_id', albumId)
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((json) => AlbumImage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      SecureLogger.error('getAlbumImages error: $e');
      rethrow;
    }
  }

  /// Upload an image to an album (from gallery)
  Future<AlbumImage> uploadAlbumImage({
    required String albumId,
    required String imageUrl,
    String? thumbnailUrl,
  }) async {
    try {
      final response = await _client
          .from('album_images')
          .insert({
            'album_id': albumId,
            'image_url': imageUrl,
            'thumbnail_url': thumbnailUrl,
          })
          .select()
          .single();

      SecureLogger.info('uploadAlbumImage: Added image to album $albumId');
      return AlbumImage.fromJson(response);
    } catch (e) {
      SecureLogger.error('uploadAlbumImage error: $e');
      rethrow;
    }
  }

  /// Upload media (photo or video) to an album
  ///
  /// For videos, include thumbnailUrl, durationSeconds, and fileSizeBytes.
  Future<AlbumImage> uploadAlbumMedia({
    required String albumId,
    required String mediaUrl,
    required String mediaType,
    String? thumbnailUrl,
    String? caption,
    int? durationSeconds,
    int? fileSizeBytes,
  }) async {
    try {
      final response = await _client
          .from('album_images')
          .insert({
            'album_id': albumId,
            'image_url': mediaUrl,
            'thumbnail_url': thumbnailUrl,
            'media_type': mediaType,
            'caption': caption,
            'duration_seconds': durationSeconds,
            'file_size_bytes': fileSizeBytes,
          })
          .select()
          .single();

      SecureLogger.info('uploadAlbumMedia: Added $mediaType to album $albumId');
      return AlbumImage.fromJson(response);
    } catch (e) {
      SecureLogger.error('uploadAlbumMedia error: $e');
      rethrow;
    }
  }

  /// Delete an image from an album
  Future<void> deleteAlbumImage({required String imageId}) async {
    try {
      await _client
          .from('album_images')
          .delete()
          .eq('id', imageId);

      SecureLogger.info('deleteAlbumImage: Deleted image $imageId');
    } catch (e) {
      SecureLogger.error('deleteAlbumImage error: $e');
      rethrow;
    }
  }

  // ========== SAVED POSTS (saved from feed) ==========

  /// Get all saved posts in an album
  Future<List<SavedPost>> getSavedPosts({
    required String albumId,
  }) async {
    try {
      final response = await _client
          .from('saved_posts')
          .select('''
            *,
            profiles:source_profile_id(full_name)
          ''')
          .eq('album_id', albumId)
          .order('saved_at', ascending: false);

      return (response as List)
          .map((json) => SavedPost.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      SecureLogger.error('getSavedPosts error: $e');
      rethrow;
    }
  }

  /// Save an image from feed to an album
  Future<SavedPost> saveImageToAlbum({
    required String albumId,
    required String imageUrl,
    String? sourceProfileId,
  }) async {
    try {
      final response = await _client
          .from('saved_posts')
          .insert({
            'album_id': albumId,
            'image_url': imageUrl,
            if (sourceProfileId != null) 'source_profile_id': sourceProfileId,
          })
          .select()
          .single();

      // Auto-set cover if missing
      try {
        final album = await _client
            .from('inspiration_albums')
            .select('cover_image_url')
            .eq('id', albumId)
            .maybeSingle();
        final currentCover = album?['cover_image_url'] as String?;
        if (currentCover == null || currentCover.isEmpty) {
          await updateInspirationAlbum(
            albumId: albumId,
            coverImageUrl: imageUrl,
          );
        }
      } catch (_) {
        // Ignore cover update failure (non-blocking)
      }

      SecureLogger.info('saveImageToAlbum: Saved image to album $albumId');
      return SavedPost.fromJson(response);
    } catch (e) {
      SecureLogger.error('saveImageToAlbum error: $e');
      rethrow;
    }
  }

  /// Remove a saved post from an album
  Future<void> removeSavedPost({required String savedPostId}) async {
    try {
      await _client
          .from('saved_posts')
          .delete()
          .eq('id', savedPostId);

      SecureLogger.info('removeSavedPost: Removed saved post $savedPostId');
    } catch (e) {
      SecureLogger.error('removeSavedPost error: $e');
      rethrow;
    }
  }

  /// Check if an image is already saved in any album for this wedding
  Future<bool> isImageSavedInWedding({
    required String weddingId,
    required String imageUrl,
  }) async {
    try {
      final response = await _client
          .from('saved_posts')
          .select('id, inspiration_albums!inner(wedding_id)')
          .eq('image_url', imageUrl)
          .eq('inspiration_albums.wedding_id', weddingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      SecureLogger.error('isImageSavedInWedding error: $e');
      return false;
    }
  }

  /// Remove a saved post by image URL for a specific wedding
  /// Returns true if deleted, false if not found
  Future<bool> removeSavedPostByImageUrl({
    required String weddingId,
    required String imageUrl,
  }) async {
    try {
      // First find the saved post
      final response = await _client
          .from('saved_posts')
          .select('id, inspiration_albums!inner(wedding_id)')
          .eq('image_url', imageUrl)
          .eq('inspiration_albums.wedding_id', weddingId)
          .maybeSingle();

      if (response == null) {
        SecureLogger.info('removeSavedPostByImageUrl: No saved post found for image');
        return false;
      }

      final savedPostId = response['id'] as String;
      await _client.from('saved_posts').delete().eq('id', savedPostId);

      SecureLogger.info('removeSavedPostByImageUrl: Removed saved post $savedPostId');
      return true;
    } catch (e) {
      SecureLogger.error('removeSavedPostByImageUrl error: $e');
      rethrow;
    }
  }

  /// Get wedding team chat room info
  /// Returns the wedding_team chat room with participants and unread count
  Future<WeddingTeamChatInfo?> getWeddingTeamChat({
    required String weddingId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('getWeddingTeamChat: No authenticated user');
      return null;
    }

    try {
      // Get the wedding_team chat room for this wedding
      final response = await _client
          .from('chat_rooms')
          .select('''
            id,
            wedding_id,
            chat_room_participants(
              profile_id,
              profiles(
                avatar_url
              )
            )
          ''')
          .eq('wedding_id', weddingId)
          .eq('type', 'wedding_team')
          .maybeSingle();

      if (response == null) {
        SecureLogger.info('getWeddingTeamChat: No wedding team chat found for wedding $weddingId');
        return null;
      }

      // Get unread count for current user
      final roomId = response['id'] as String;
      final unreadCount = await _getUnreadCountForRoom(roomId, userId);

      // Parse participants
      final participants = response['chat_room_participants'] as List<dynamic>? ?? [];
      final avatars = <String>[];
      
      for (final p in participants) {
        final profile = p['profiles'] as Map<String, dynamic>?;
        final avatarUrl = profile?['avatar_url'] as String?;
        if (avatarUrl != null && avatarUrl.isNotEmpty && avatars.length < 4) {
          avatars.add(avatarUrl);
        }
      }

      return WeddingTeamChatInfo(
        roomId: roomId,
        weddingId: weddingId,
        participantsCount: participants.length,
        unreadCount: unreadCount,
        participantAvatars: avatars,
      );
    } catch (e) {
      SecureLogger.error('getWeddingTeamChat error: $e');
      rethrow;
    }
  }

  /// Get unread message count for a specific room
  Future<int> _getUnreadCountForRoom(String roomId, String userId) async {
    try {
      // Get last_read_at for the user in this room
      final participantResponse = await _client
          .from('chat_room_participants')
          .select('last_read_at')
          .eq('room_id', roomId)
          .eq('profile_id', userId)
          .maybeSingle();

      if (participantResponse == null) {
        return 0;
      }

      final lastReadAt = participantResponse['last_read_at'] as String?;
      
      // Count messages after last_read_at
      if (lastReadAt == null) {
        // Never read - count all messages not from this user
        final countResponse = await _client
            .from('chat_messages')
            .select('id')
            .eq('room_id', roomId)
            .neq('profile_id', userId)
            .eq('is_deleted', false);
        return (countResponse as List).length;
      } else {
        // Count messages after last_read_at not from this user
        final countResponse = await _client
            .from('chat_messages')
            .select('id')
            .eq('room_id', roomId)
            .neq('profile_id', userId)
            .eq('is_deleted', false)
            .gt('created_at', lastReadAt);
        return (countResponse as List).length;
      }
    } catch (e) {
      SecureLogger.error('_getUnreadCountForRoom error: $e');
      return 0;
    }
  }

  /// Get active wedding team members (pros with status = 'active')
  Future<List<WeddingTeamMember>> getActiveWeddingTeam({
    required String weddingId,
  }) async {
    try {
      final response = await _client
          .from('wedding_participants')
          .select('''
            professional_profile_id,
            profession,
            status,
            joined_at,
            is_muted,
            profiles!wedding_participants_professional_profile_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .eq('wedding_id', weddingId)
          .eq('status', 'active');

      return response.map<WeddingTeamMember>((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;
        return WeddingTeamMember(
          profileId: json['professional_profile_id'] as String,
          displayName: profile?['full_name'] as String? ?? 'Unknown',
          avatarUrl: profile?['avatar_url'] as String?,
          profession: json['profession'] as String?,
          status: json['status'] as String? ?? 'active',
          joinedAt: json['joined_at'] != null
              ? DateTime.parse(json['joined_at'] as String)
              : null,
          isMuted: json['is_muted'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      SecureLogger.error('getActiveWeddingTeam error: $e');
      rethrow;
    }
  }

  /// Update wedding details
  Future<void> updateWedding({
    required String weddingId,
    String? name,
    DateTime? eventDate,
    double? lat,
    double? lng,
    String? venueAddress,
    String? countryCode,
    int? guestCount,
    int? budgetMin,
    int? budgetMax,
    String? currency,
    String? visibility,
    int? searchRadiusKm,
    String? coverImageUrl,
    String? noteForPros,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['wedding_name'] = name;
      if (eventDate != null) updateData['event_date'] = eventDate.toIso8601String().split('T')[0];
      if (lat != null && lng != null) {
        updateData['venue_coords'] = 'POINT($lng $lat)';
        updateData['search_area_coords'] = 'POINT($lng $lat)';
      }
      if (venueAddress != null) updateData['venue_label'] = venueAddress;
      if (countryCode != null) updateData['location_country_code'] = countryCode;
      if (guestCount != null) updateData['guest_count'] = guestCount;
      if (budgetMin != null) updateData['budget_min'] = budgetMin;
      if (budgetMax != null) updateData['budget_max'] = budgetMax;
      if (currency != null) updateData['currency'] = currency;
      if (visibility != null) updateData['visibility'] = visibility;
      if (searchRadiusKm != null) updateData['search_radius_km'] = searchRadiusKm;
      if (coverImageUrl != null) updateData['cover_image_url'] = coverImageUrl;
      if (noteForPros != null) updateData['note_for_pros'] = noteForPros;

      if (updateData.isEmpty) {
        SecureLogger.warning('updateWedding: No data to update');
        return;
      }

      await _client
          .from('weddings')
          .update(updateData)
          .eq('id', weddingId);

      SecureLogger.info('updateWedding: Updated wedding $weddingId');
    } catch (e) {
      SecureLogger.error('updateWedding error: $e');
      rethrow;
    }
  }

  /// Update wedding status (planning, confirmed, completed, cancelled)
  Future<void> updateWeddingStatus({
    required String weddingId,
    required String status,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
      };

      // Set cancelled_at when cancelling, clear it when resuming
      if (status == 'cancelled') {
        updateData['cancelled_at'] = DateTime.now().toIso8601String();
      } else if (status == 'planning') {
        updateData['cancelled_at'] = null;
      }

      await _client
          .from('weddings')
          .update(updateData)
          .eq('id', weddingId);

      SecureLogger.info('updateWeddingStatus: Updated wedding $weddingId to status $status');
    } catch (e) {
      SecureLogger.error('updateWeddingStatus error: $e');
      rethrow;
    }
  }

  // ========== WEDDING EVENTS (AGENDA) ==========

  /// Get all events for a wedding
  Future<List<WeddingEvent>> getWeddingEvents({
    required String weddingId,
  }) async {
    try {
      final response = await _client
          .from('wedding_events')
          .select()
          .eq('wedding_id', weddingId)
          .order('event_date', ascending: true);

      return (response as List)
          .map((json) => WeddingEvent.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      SecureLogger.error('getWeddingEvents error: $e');
      rethrow;
    }
  }

  /// Create a new wedding event
  Future<WeddingEvent> createWeddingEvent({
    required String weddingId,
    required String title,
    required DateTime eventDate,
    String? description,
    DateTime? eventEndDate,
    String? location,
    String? linkedProId,
    bool isPublic = false,
    bool reminder1Week = false,
    bool reminder1Day = false,
    bool reminder1Hour = false,
  }) async {
    try {
      final response = await _client
          .from('wedding_events')
          .insert({
            'wedding_id': weddingId,
            'title': title,
            'description': description,
            'event_date': eventDate.toIso8601String(),
            'event_end_date': eventEndDate?.toIso8601String(),
            'location': location,
            'linked_pro_id': linkedProId,
            'is_public': isPublic,
            'status': 'pending',
            'reminder_1_week': reminder1Week,
            'reminder_1_day': reminder1Day,
            'reminder_1_hour': reminder1Hour,
          })
          .select()
          .single();

      final event = WeddingEvent.fromJson(response);
      SecureLogger.info('createWeddingEvent: Created event for wedding $weddingId');

      // Schedule reminders if any are enabled (EPIC-08)
      if (reminder1Week || reminder1Day || reminder1Hour) {
        await _scheduleReminders(
          eventId: event.id,
          eventDate: eventDate,
          reminder1Week: reminder1Week,
          reminder1Day: reminder1Day,
          reminder1Hour: reminder1Hour,
        );
      }

      return event;
    } catch (e) {
      SecureLogger.error('createWeddingEvent error: $e');
      rethrow;
    }
  }

  /// Update a wedding event
  Future<void> updateWeddingEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? eventEndDate,
    String? location,
    String? linkedProId,
    bool? isPublic,
    String? status,
    bool? reminder1Week,
    bool? reminder1Day,
    bool? reminder1Hour,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (eventDate != null) updateData['event_date'] = eventDate.toIso8601String();
      if (eventEndDate != null) updateData['event_end_date'] = eventEndDate.toIso8601String();
      if (location != null) updateData['location'] = location;
      if (linkedProId != null) updateData['linked_pro_id'] = linkedProId;
      if (isPublic != null) updateData['is_public'] = isPublic;
      if (status != null) updateData['status'] = status;
      if (reminder1Week != null) updateData['reminder_1_week'] = reminder1Week;
      if (reminder1Day != null) updateData['reminder_1_day'] = reminder1Day;
      if (reminder1Hour != null) updateData['reminder_1_hour'] = reminder1Hour;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      if (updateData.length == 1) {
        SecureLogger.warning('updateWeddingEvent: No data to update');
        return;
      }

      await _client
          .from('wedding_events')
          .update(updateData)
          .eq('id', eventId);

      SecureLogger.info('updateWeddingEvent: Updated event $eventId');

      // Re-schedule reminders if any reminder field changed (EPIC-08)
      if (reminder1Week != null || reminder1Day != null || reminder1Hour != null) {
        // Get the current event to get the eventDate
        final eventResponse = await _client
            .from('wedding_events')
            .select('event_date, reminder_1_week, reminder_1_day, reminder_1_hour')
            .eq('id', eventId)
            .single();

        final currentEventDate = DateTime.parse(eventResponse['event_date'] as String);
        final r1Week = eventResponse['reminder_1_week'] as bool? ?? false;
        final r1Day = eventResponse['reminder_1_day'] as bool? ?? false;
        final r1Hour = eventResponse['reminder_1_hour'] as bool? ?? false;

        await _scheduleReminders(
          eventId: eventId,
          eventDate: eventDate ?? currentEventDate,
          reminder1Week: r1Week,
          reminder1Day: r1Day,
          reminder1Hour: r1Hour,
        );
      }
    } catch (e) {
      SecureLogger.error('updateWeddingEvent error: $e');
      rethrow;
    }
  }

  /// Schedule reminders for a wedding event (EPIC-08)
  ///
  /// Deletes existing scheduled notifications and creates new ones
  /// based on the reminder settings. Skips reminders that are in the past.
  Future<void> _scheduleReminders({
    required String eventId,
    required DateTime eventDate,
    required bool reminder1Week,
    required bool reminder1Day,
    required bool reminder1Hour,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('_scheduleReminders: No authenticated user');
      return;
    }

    try {
      // Delete existing scheduled notifications for this event
      await _client
          .from('scheduled_notifications')
          .delete()
          .eq('event_id', eventId);

      final now = DateTime.now();
      final notifications = <Map<String, dynamic>>[];

      // Schedule 1 week reminder
      if (reminder1Week) {
        final scheduledAt = eventDate.subtract(const Duration(days: 7));
        if (scheduledAt.isAfter(now)) {
          notifications.add({
            'event_id': eventId,
            'user_id': userId,
            'scheduled_at': scheduledAt.toUtc().toIso8601String(),
            'notification_type': '1_week',
          });
        }
      }

      // Schedule 1 day reminder
      if (reminder1Day) {
        final scheduledAt = eventDate.subtract(const Duration(days: 1));
        if (scheduledAt.isAfter(now)) {
          notifications.add({
            'event_id': eventId,
            'user_id': userId,
            'scheduled_at': scheduledAt.toUtc().toIso8601String(),
            'notification_type': '1_day',
          });
        }
      }

      // Schedule 1 hour reminder
      if (reminder1Hour) {
        final scheduledAt = eventDate.subtract(const Duration(hours: 1));
        if (scheduledAt.isAfter(now)) {
          notifications.add({
            'event_id': eventId,
            'user_id': userId,
            'scheduled_at': scheduledAt.toUtc().toIso8601String(),
            'notification_type': '1_hour',
          });
        }
      }

      // Insert new notifications if any
      if (notifications.isNotEmpty) {
        await _client.from('scheduled_notifications').insert(notifications);
        SecureLogger.info('_scheduleReminders: Scheduled ${notifications.length} reminders for event $eventId');
      } else {
        SecureLogger.info('_scheduleReminders: No reminders to schedule for event $eventId (all in past or disabled)');
      }
    } catch (e) {
      SecureLogger.error('_scheduleReminders error: $e');
      // Don't rethrow - reminder scheduling failure shouldn't block event creation/update
    }
  }

  /// Delete a wedding event
  Future<void> deleteWeddingEvent({required String eventId}) async {
    try {
      await _client
          .from('wedding_events')
          .delete()
          .eq('id', eventId);

      SecureLogger.info('deleteWeddingEvent: Deleted event $eventId');
    } catch (e) {
      SecureLogger.error('deleteWeddingEvent error: $e');
      rethrow;
    }
  }

  /// Toggle event status (pending <-> done)
  Future<void> toggleEventStatus({
    required String eventId,
    required String currentStatus,
  }) async {
    final newStatus = currentStatus == 'done' ? 'pending' : 'done';
    await updateWeddingEvent(eventId: eventId, status: newStatus);
  }

  // ========== WEDDING EXPENSES (BUDGET) ==========

  /// Get all expenses for a wedding
  Future<List<WeddingExpense>> getWeddingExpenses({
    required String weddingId,
  }) async {
    try {
      final response = await _client
          .from('wedding_expenses')
          .select()
          .eq('wedding_id', weddingId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => WeddingExpense.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      SecureLogger.error('getWeddingExpenses error: $e');
      rethrow;
    }
  }

  /// Create a new wedding expense
  Future<WeddingExpense> createWeddingExpense({
    required String weddingId,
    required String category,
    required double amount,
    required String currencyCode,
    String? description,
    String? status,
    double? paidAmount,
    DateTime? dueDate,
    String? linkedProId,
  }) async {
    try {
      final response = await _client
          .from('wedding_expenses')
          .insert({
            'wedding_id': weddingId,
            'category': category,
            'description': description,
            'amount': amount,
            'currency_code': currencyCode,
            'status': status ?? 'pending',
            'paid_amount': paidAmount ?? 0,
            'due_date': dueDate?.toIso8601String().split('T')[0],
            'linked_pro_id': linkedProId,
          })
          .select()
          .single();

      SecureLogger.info('createWeddingExpense: Created expense for wedding $weddingId');
      return WeddingExpense.fromJson(response);
    } catch (e) {
      SecureLogger.error('createWeddingExpense error: $e');
      rethrow;
    }
  }

  /// Update a wedding expense
  Future<void> updateWeddingExpense({
    required String expenseId,
    String? category,
    String? description,
    double? amount,
    String? currencyCode,
    String? status,
    double? paidAmount,
    DateTime? dueDate,
    String? linkedProId,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (category != null) updateData['category'] = category;
      if (description != null) updateData['description'] = description;
      if (amount != null) updateData['amount'] = amount;
      if (currencyCode != null) updateData['currency_code'] = currencyCode;
      if (status != null) updateData['status'] = status;
      if (paidAmount != null) updateData['paid_amount'] = paidAmount;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String().split('T')[0];
      if (linkedProId != null) updateData['linked_pro_id'] = linkedProId;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      if (updateData.length == 1) {
        SecureLogger.warning('updateWeddingExpense: No data to update');
        return;
      }

      await _client
          .from('wedding_expenses')
          .update(updateData)
          .eq('id', expenseId);

      SecureLogger.info('updateWeddingExpense: Updated expense $expenseId');
    } catch (e) {
      SecureLogger.error('updateWeddingExpense error: $e');
      rethrow;
    }
  }

  /// Delete a wedding expense
  Future<void> deleteWeddingExpense({required String expenseId}) async {
    try {
      await _client
          .from('wedding_expenses')
          .delete()
          .eq('id', expenseId);

      SecureLogger.info('deleteWeddingExpense: Deleted expense $expenseId');
    } catch (e) {
      SecureLogger.error('deleteWeddingExpense error: $e');
      rethrow;
    }
  }

  // ========== WEDDING GUESTS ==========

  /// Get all guests for a wedding
  Future<List<WeddingGuest>> getWeddingGuests({
    required String weddingId,
  }) async {
    try {
      final response = await _client
          .from('wedding_guests')
          .select()
          .eq('wedding_id', weddingId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => WeddingGuest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      SecureLogger.error('getWeddingGuests error: $e');
      rethrow;
    }
  }

  /// Create a new wedding guest
  Future<WeddingGuest> createWeddingGuest({
    required String weddingId,
    required String name,
    String? email,
    String? phone,
    String? role,
    String? notes,
  }) async {
    try {
      final response = await _client
          .from('wedding_guests')
          .insert({
            'wedding_id': weddingId,
            'name': name,
            'email': email,
            'phone': phone,
            'role': role ?? 'guest',
            'notes': notes,
          })
          .select()
          .single();

      SecureLogger.info('createWeddingGuest: Created guest for wedding $weddingId');
      return WeddingGuest.fromJson(response);
    } catch (e) {
      SecureLogger.error('createWeddingGuest error: $e');
      rethrow;
    }
  }

  /// Update a wedding guest
  Future<void> updateWeddingGuest({
    required String guestId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (role != null) updateData['role'] = role;
      if (notes != null) updateData['notes'] = notes;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      if (updateData.length == 1) {
        SecureLogger.warning('updateWeddingGuest: No data to update');
        return;
      }

      await _client
          .from('wedding_guests')
          .update(updateData)
          .eq('id', guestId);

      SecureLogger.info('updateWeddingGuest: Updated guest $guestId');
    } catch (e) {
      SecureLogger.error('updateWeddingGuest error: $e');
      rethrow;
    }
  }

  /// Delete a wedding guest
  Future<void> deleteWeddingGuest({required String guestId}) async {
    try {
      await _client
          .from('wedding_guests')
          .delete()
          .eq('id', guestId);

      SecureLogger.info('deleteWeddingGuest: Deleted guest $guestId');
    } catch (e) {
      SecureLogger.error('deleteWeddingGuest error: $e');
      rethrow;
    }
  }

  // ========== WEDDING GROUPS ==========

  /// Get all wedding groups for a wedding
  Future<List<WeddingGroup>> getWeddingGroups({required String weddingId}) async {
    try {
      final response = await _client.rpc(
        'get_wedding_groups',
        params: {'p_wedding_id': weddingId},
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => WeddingGroup.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      SecureLogger.error('getWeddingGroups error: $e');
      rethrow;
    }
  }

  /// Create a new wedding group
  Future<String> createWeddingGroup({
    required String weddingId,
    required String name,
    required bool isPublic,
    List<String>? memberProfileIds,
  }) async {
    try {
      final response = await _client.rpc(
        'create_wedding_group',
        params: {
          'p_wedding_id': weddingId,
          'p_name': name,
          'p_is_public': isPublic,
          if (memberProfileIds != null) 'p_member_profile_ids': memberProfileIds,
        },
      );

      SecureLogger.info('createWeddingGroup: Created group $name for wedding $weddingId');
      return response as String;
    } catch (e) {
      SecureLogger.error('createWeddingGroup error: $e');
      rethrow;
    }
  }

  /// Update a wedding group
  Future<void> updateWeddingGroup({
    required String roomId,
    String? name,
    bool? isPublic,
  }) async {
    try {
      await _client.rpc(
        'update_wedding_group',
        params: {
          'p_room_id': roomId,
          if (name != null) 'p_name': name,
          if (isPublic != null) 'p_is_public': isPublic,
        },
      );

      SecureLogger.info('updateWeddingGroup: Updated group $roomId');
    } catch (e) {
      SecureLogger.error('updateWeddingGroup error: $e');
      rethrow;
    }
  }

  /// Delete a wedding group (soft delete)
  Future<void> deleteWeddingGroup({required String roomId}) async {
    try {
      await _client.rpc(
        'delete_wedding_group',
        params: {'p_room_id': roomId},
      );

      SecureLogger.info('deleteWeddingGroup: Deleted group $roomId');
    } catch (e) {
      SecureLogger.error('deleteWeddingGroup error: $e');
      rethrow;
    }
  }

  /// Get members of a wedding group
  Future<List<GroupMember>> getWeddingGroupMembers({required String roomId}) async {
    try {
      final response = await _client.rpc(
        'get_wedding_group_members',
        params: {'p_room_id': roomId},
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => GroupMember.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      SecureLogger.error('getWeddingGroupMembers error: $e');
      rethrow;
    }
  }

  /// Get eligible members for group (joined guests + active pros)
  Future<List<EligibleGroupMember>> getEligibleGroupMembers({required String weddingId}) async {
    try {
      final response = await _client.rpc(
        'get_eligible_group_members',
        params: {'p_wedding_id': weddingId},
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => EligibleGroupMember.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      SecureLogger.error('getEligibleGroupMembers error: $e');
      rethrow;
    }
  }

  /// Manage wedding group members (add/remove)
  Future<void> manageWeddingGroupMembers({
    required String roomId,
    List<String>? addProfileIds,
    List<String>? removeProfileIds,
  }) async {
    try {
      await _client.rpc(
        'manage_wedding_group_members',
        params: {
          'p_room_id': roomId,
          if (addProfileIds != null) 'p_add_profile_ids': addProfileIds,
          if (removeProfileIds != null) 'p_remove_profile_ids': removeProfileIds,
        },
      );

      SecureLogger.info('manageWeddingGroupMembers: Updated members for group $roomId');
    } catch (e) {
      SecureLogger.error('manageWeddingGroupMembers error: $e');
      rethrow;
    }
  }

  /// Send bulk invitations to all pending guests with email
  Future<int> sendBulkInvitations({required String weddingId}) async {
    try {
      final response = await _client.rpc(
        'send_bulk_invitations',
        params: {'p_wedding_id': weddingId},
      );

      final Map<String, dynamic> result = response as Map<String, dynamic>;
      final int count = result['queued'] as int? ?? 0;

      SecureLogger.info('sendBulkInvitations: Queued $count invitations for wedding $weddingId');
      return count;
    } catch (e) {
      SecureLogger.error('sendBulkInvitations error: $e');
      rethrow;
    }
  }

  // ========== GUEST ALBUMS (BRIDE VIEW) ==========

  /// Get all guest albums for a wedding.
  ///
  /// Returns albums with photo/video counts and first thumbnail.
  /// Albums are ordered by creation date (newest first).
  Future<List<GuestAlbum>> getGuestAlbums({required String weddingId}) async {
    try {
      // Query guest_albums with joined profile and media counts
      final response = await _client
          .from('guest_albums')
          .select('''
            id,
            wedding_id,
            guest_user_id,
            created_at,
            profiles!guest_albums_guest_user_id_fkey (
              full_name,
              avatar_url
            ),
            guest_media (
              id,
              media_type,
              thumbnail_path,
              storage_path
            )
          ''')
          .eq('wedding_id', weddingId)
          .order('created_at', ascending: false);

      final albums = (response as List).map((json) {
        final mediaList = json['guest_media'] as List? ?? [];
        final photoCount = mediaList.where((m) => m['media_type'] == 'photo').length;
        final videoCount = mediaList.where((m) => m['media_type'] == 'video').length;

        // Get thumbnail from first media (prefer photos)
        String? thumbnailUrl;
        if (mediaList.isNotEmpty) {
          final firstMedia = mediaList.first;
          final thumbnailPath = firstMedia['thumbnail_path'] as String?;
          final storagePath = firstMedia['storage_path'] as String?;

          // Build full URL for thumbnail
          if (thumbnailPath != null || storagePath != null) {
            final path = thumbnailPath ?? storagePath;
            thumbnailUrl = _client.storage.from('wedding-albums').getPublicUrl(path!);
          }
        }

        return GuestAlbumModel.fromJson({
          ...json,
          'photo_count': photoCount,
          'video_count': videoCount,
          'thumbnail_url': thumbnailUrl,
        });
      }).toList();

      SecureLogger.info('getGuestAlbums: Found ${albums.length} albums for wedding $weddingId');
      return albums;
    } catch (e) {
      SecureLogger.error('getGuestAlbums error: $e');
      rethrow;
    }
  }

  /// Get all media for a specific guest album.
  ///
  /// Returns media ordered by creation date (newest first).
  Future<List<GuestMedia>> getGuestAlbumMedia({required String albumId}) async {
    try {
      final response = await _client
          .from('guest_media')
          .select()
          .eq('album_id', albumId)
          .order('created_at', ascending: false);

      final media = (response as List)
          .map((json) => GuestMedia.fromJson(json as Map<String, dynamic>))
          .toList();

      SecureLogger.info('getGuestAlbumMedia: Found ${media.length} media for album $albumId');
      return media;
    } catch (e) {
      SecureLogger.error('getGuestAlbumMedia error: $e');
      rethrow;
    }
  }

  // ========== PHOTO SHARES ==========

  /// Share photos/videos with wedding guests.
  ///
  /// Creates share records for the given media items.
  /// Uses upsert to handle duplicates gracefully.
  Future<int> sharePhotosWithGuests({
    required String weddingId,
    required List<ShareMediaItem> mediaItems,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    if (mediaItems.isEmpty) return 0;

    try {
      // Build insert data for all media items
      final insertData = mediaItems
          .map((item) => {
                'wedding_id': weddingId,
                'media_type': item.mediaType,
                'media_id': item.mediaId,
                'shared_by': userId,
              })
          .toList();

      // Use upsert with ON CONFLICT DO NOTHING equivalent
      await _client.from('photo_shares').upsert(
            insertData,
            onConflict: 'wedding_id,media_type,media_id',
            ignoreDuplicates: true,
          );

      SecureLogger.info(
          'sharePhotosWithGuests: Shared ${mediaItems.length} items for wedding $weddingId');
      return mediaItems.length;
    } catch (e) {
      SecureLogger.error('sharePhotosWithGuests error: $e');
      rethrow;
    }
  }

  /// Remove share records for photos/videos.
  ///
  /// Returns the number of shares removed.
  Future<int> unsharePhotos({
    required String weddingId,
    required List<ShareMediaItem> mediaItems,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    if (mediaItems.isEmpty) return 0;

    try {
      int deletedCount = 0;

      // Delete each share record individually (Supabase doesn't support
      // batch delete with complex conditions)
      for (final item in mediaItems) {
        final result = await _client
            .from('photo_shares')
            .delete()
            .eq('wedding_id', weddingId)
            .eq('media_type', item.mediaType)
            .eq('media_id', item.mediaId)
            .eq('shared_by', userId)
            .select('id');

        deletedCount += (result as List).length;
      }

      SecureLogger.info(
          'unsharePhotos: Removed $deletedCount shares for wedding $weddingId');
      return deletedCount;
    } catch (e) {
      SecureLogger.error('unsharePhotos error: $e');
      rethrow;
    }
  }

  /// Get all shared media IDs for a wedding.
  ///
  /// Returns a set of media IDs that have been shared.
  Future<Set<String>> getSharedMediaIds({required String weddingId}) async {
    try {
      final response = await _client
          .from('photo_shares')
          .select('media_id')
          .eq('wedding_id', weddingId);

      final ids = (response as List)
          .map((row) => row['media_id'] as String)
          .toSet();

      SecureLogger.info(
          'getSharedMediaIds: Found ${ids.length} shared media for wedding $weddingId');
      return ids;
    } catch (e) {
      SecureLogger.error('getSharedMediaIds error: $e');
      rethrow;
    }
  }

  /// Check if a specific media item is shared.
  Future<bool> isMediaShared({
    required String weddingId,
    required String mediaId,
    required String mediaType,
  }) async {
    try {
      final response = await _client
          .from('photo_shares')
          .select('id')
          .eq('wedding_id', weddingId)
          .eq('media_id', mediaId)
          .eq('media_type', mediaType)
          .maybeSingle();

      return response != null;
    } catch (e) {
      SecureLogger.error('isMediaShared error: $e');
      rethrow;
    }
  }

  // ========== MAGAZINE SELECTIONS ==========

  /// Get all magazine selections for a wedding.
  ///
  /// Returns selections ordered by position with thumbnail URLs from joined tables.
  Future<List<MagazineSelection>> getMagazineSelections({
    required String weddingId,
  }) async {
    try {
      // Query magazine_selections and get the thumbnail URL from the source table
      final response = await _client.from('magazine_selections').select('''
            id,
            wedding_id,
            user_id,
            media_type,
            media_id,
            position,
            created_at
          ''').eq('wedding_id', weddingId).order('position', ascending: true);

      final selections = <MagazineSelection>[];

      for (final row in response as List) {
        // For now, create without thumbnail - UI will load thumbnails separately
        selections.add(MagazineSelection.fromJson(row));
      }

      SecureLogger.info(
          'getMagazineSelections: Found ${selections.length} selections');
      return selections;
    } catch (e) {
      SecureLogger.error('getMagazineSelections error: $e');
      rethrow;
    }
  }

  /// Add photos to the magazine selection.
  ///
  /// Assigns positions starting from the current max position + 1.
  /// Returns the number of photos successfully added.
  Future<int> addToMagazine({
    required String weddingId,
    required String userId,
    required List<MagazineMediaItem> mediaItems,
    int maxPhotos = 60,
  }) async {
    if (mediaItems.isEmpty) return 0;

    try {
      // Get current max position
      final countResponse = await _client
          .from('magazine_selections')
          .select('position')
          .eq('wedding_id', weddingId)
          .order('position', ascending: false)
          .limit(1)
          .maybeSingle();

      int startPosition = 1;
      if (countResponse != null) {
        startPosition = (countResponse['position'] as int) + 1;
      }

      // Check if adding would exceed limit
      final currentCount = startPosition - 1;
      if (currentCount + mediaItems.length > maxPhotos) {
        throw Exception('Would exceed maximum $maxPhotos photos');
      }

      // Build insert data with positions
      final insertData = <Map<String, dynamic>>[];
      for (var i = 0; i < mediaItems.length; i++) {
        final item = mediaItems[i];
        insertData.add({
          'wedding_id': weddingId,
          'user_id': userId,
          'media_type': item.mediaType,
          'media_id': item.mediaId,
          'position': startPosition + i,
        });
      }

      // Insert all at once
      await _client.from('magazine_selections').insert(insertData);

      SecureLogger.info(
          'addToMagazine: Added ${mediaItems.length} photos starting at position $startPosition');
      return mediaItems.length;
    } catch (e) {
      SecureLogger.error('addToMagazine error: $e');
      rethrow;
    }
  }

  /// Remove a photo from the magazine selection.
  ///
  /// Also recompacts positions so there are no gaps.
  Future<void> removeFromMagazine({
    required String selectionId,
    required String weddingId,
  }) async {
    try {
      // Get the position of the item being removed
      final itemResponse = await _client
          .from('magazine_selections')
          .select('position')
          .eq('id', selectionId)
          .single();

      final removedPosition = itemResponse['position'] as int;

      // Delete the item
      await _client.from('magazine_selections').delete().eq('id', selectionId);

      // Recompact positions: decrement all positions greater than removed
      await _client.rpc('recompact_magazine_positions', params: {
        'p_wedding_id': weddingId,
        'p_removed_position': removedPosition,
      });

      SecureLogger.info(
          'removeFromMagazine: Removed selection $selectionId from position $removedPosition');
    } catch (e) {
      // If RPC doesn't exist, do manual recompact
      if (e.toString().contains('function') ||
          e.toString().contains('does not exist')) {
        await _recompactPositionsManually(weddingId);
        SecureLogger.info(
            'removeFromMagazine: Used manual recompact for $selectionId');
      } else {
        SecureLogger.error('removeFromMagazine error: $e');
        rethrow;
      }
    }
  }

  /// Manual recompact positions when RPC is not available.
  Future<void> _recompactPositionsManually(String weddingId) async {
    try {
      // Get all selections ordered by position
      final response = await _client
          .from('magazine_selections')
          .select('id, position')
          .eq('wedding_id', weddingId)
          .order('position', ascending: true);

      // Update each position sequentially
      var newPosition = 1;
      for (final row in response as List) {
        if (row['position'] != newPosition) {
          await _client
              .from('magazine_selections')
              .update({'position': newPosition}).eq('id', row['id'] as String);
        }
        newPosition++;
      }
    } catch (e) {
      SecureLogger.error('_recompactPositionsManually error: $e');
      rethrow;
    }
  }

  /// Reorder photos in the magazine.
  ///
  /// Moves the photo at oldIndex to newIndex and shifts others.
  Future<void> reorderMagazine({
    required String weddingId,
    required int oldIndex,
    required int newIndex,
  }) async {
    if (oldIndex == newIndex) return;

    try {
      // Get all selections ordered by position
      final response = await _client
          .from('magazine_selections')
          .select('id, position')
          .eq('wedding_id', weddingId)
          .order('position', ascending: true);

      final items = (response as List).toList();
      if (oldIndex >= items.length || newIndex >= items.length) {
        throw Exception('Invalid index');
      }

      // Reorder in memory
      final movedItem = items.removeAt(oldIndex);
      items.insert(newIndex, movedItem);

      // Update all positions
      for (var i = 0; i < items.length; i++) {
        final expectedPosition = i + 1;
        if (items[i]['position'] != expectedPosition) {
          await _client
              .from('magazine_selections')
              .update({'position': expectedPosition}).eq(
                  'id', items[i]['id'] as String);
        }
      }

      SecureLogger.info(
          'reorderMagazine: Moved from index $oldIndex to $newIndex');
    } catch (e) {
      SecureLogger.error('reorderMagazine error: $e');
      rethrow;
    }
  }

  /// Clear all magazine selections for a wedding.
  Future<void> clearMagazineSelections({required String weddingId}) async {
    try {
      await _client
          .from('magazine_selections')
          .delete()
          .eq('wedding_id', weddingId);

      SecureLogger.info(
          'clearMagazineSelections: Cleared all selections for wedding $weddingId');
    } catch (e) {
      SecureLogger.error('clearMagazineSelections error: $e');
      rethrow;
    }
  }
}
