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

  /// Update wedding status (active, cancelled)
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
      } else if (status == 'active') {
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
          })
          .select()
          .single();

      SecureLogger.info('createWeddingEvent: Created event for wedding $weddingId');
      return WeddingEvent.fromJson(response);
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
    } catch (e) {
      SecureLogger.error('updateWeddingEvent error: $e');
      rethrow;
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
}
