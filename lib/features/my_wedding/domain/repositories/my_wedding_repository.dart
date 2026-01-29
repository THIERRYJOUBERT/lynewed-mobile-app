/// My Wedding Repository Interface
///
/// Defines the contract for wedding data operations.
/// Implemented by MyWeddingRepositoryImpl in the data layer.
library;

import '../entities/entities.dart';
export '../entities/wedding_team_chat_info.dart';

/// Onboarding data for creating/updating a wedding
class OnboardingData {
  const OnboardingData({
    this.eventDate,
    this.venueName,
    this.venueAddress,
    this.lat,
    this.lng,
    this.countryCode,
    this.professionsNeeded,
    this.guestCount,
    this.budgetMin,
    this.budgetMax,
    this.visibility,
    this.searchRadius,
    this.coverImageUrl,
    this.onboardingStep,
  });

  final DateTime? eventDate;
  final String? venueName;
  final String? venueAddress;
  final double? lat;
  final double? lng;
  final String? countryCode;
  final List<String>? professionsNeeded;
  final int? guestCount;
  final double? budgetMin;
  final double? budgetMax;
  final String? visibility;
  final int? searchRadius;
  final String? coverImageUrl;
  final int? onboardingStep;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (eventDate != null) map['event_date'] = eventDate!.toIso8601String().split('T')[0];
    if (venueAddress != null) map['venue_label'] = venueAddress;
    if (lat != null && lng != null) {
      map['venue_coords'] = 'POINT($lng $lat)';
      map['search_area_coords'] = 'POINT($lng $lat)';
    }
    if (countryCode != null) map['location_country_code'] = countryCode;
    if (professionsNeeded != null) map['professions_needed'] = professionsNeeded;
    if (guestCount != null) map['guest_count'] = guestCount;
    if (budgetMin != null) map['budget_min'] = budgetMin!.toInt();
    if (budgetMax != null) map['budget_max'] = budgetMax!.toInt();
    if (visibility != null) map['visibility'] = visibility;
    if (searchRadius != null) map['search_radius_km'] = searchRadius;
    if (coverImageUrl != null) map['cover_image_url'] = coverImageUrl;
    if (onboardingStep != null) map['onboarding_step'] = onboardingStep;
    return map;
  }
}

/// Result wrapper for repository operations
class RepositoryResult<T> {
  const RepositoryResult.success(this.data) : error = null;
  const RepositoryResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// My Wedding Repository Interface
abstract class MyWeddingRepository {
  /// Get the current user's wedding overview
  /// Returns null if no wedding exists
  Future<RepositoryResult<WeddingOverview?>> getMyWedding();

  /// Create a new wedding during onboarding (step 2)
  /// Returns the created wedding ID
  Future<RepositoryResult<String>> createWedding({
    required DateTime eventDate,
    required double lat,
    required double lng,
    String? venueName,
    String? venueAddress,
    String? countryCode,
  });

  /// Update wedding data during onboarding (steps 3-8)
  Future<RepositoryResult<void>> updateOnboardingData({
    required String weddingId,
    required OnboardingData data,
  });

  /// Complete onboarding (step 9)
  /// Sets onboarding_step to null and triggers wedding_team chat creation
  Future<RepositoryResult<void>> completeOnboarding({
    required String weddingId,
  });

  /// Get list of professionals the bride has contacted
  /// Used for pro invitation step
  Future<RepositoryResult<List<ContactedPro>>> getContactedPros();

  /// Invite a professional to the wedding team
  Future<RepositoryResult<void>> inviteProToWedding({
    required String weddingId,
    required String proProfileId,
  });

  /// Exclude a professional from the wedding team
  Future<RepositoryResult<void>> excludeProFromWedding({
    required String weddingId,
    required String proProfileId,
    String? reason,
  });

  /// Get wedding team members
  Future<RepositoryResult<List<WeddingTeamMember>>> getWeddingTeam({
    required String weddingId,
  });

  // ========== INSPIRATION ALBUMS ==========

  /// Get all inspiration albums for a wedding
  Future<RepositoryResult<List<InspirationAlbum>>> getInspirationAlbums({
    required String weddingId,
  });

  /// Create a new inspiration album
  Future<RepositoryResult<InspirationAlbum>> createInspirationAlbum({
    required String weddingId,
    required String name,
    String? category,
    bool isPrivate = false,
  });

  /// Update an inspiration album
  Future<RepositoryResult<void>> updateInspirationAlbum({
    required String albumId,
    String? name,
    String? category,
    bool? isPrivate,
    String? coverImageUrl,
    int? sortOrder,
  });

  /// Delete an inspiration album
  Future<RepositoryResult<void>> deleteInspirationAlbum({required String albumId});

  // ========== ALBUM IMAGES ==========

  /// Get all images in an album
  Future<RepositoryResult<List<AlbumImage>>> getAlbumImages({
    required String albumId,
  });

  /// Upload an image to an album
  Future<RepositoryResult<AlbumImage>> uploadAlbumImage({
    required String albumId,
    required String imageUrl,
    String? thumbnailUrl,
  });

  /// Delete an image from an album
  Future<RepositoryResult<void>> deleteAlbumImage({required String imageId});

  // ========== SAVED POSTS ==========

  /// Get all saved posts in an album
  Future<RepositoryResult<List<SavedPost>>> getSavedPosts({
    required String albumId,
  });

  /// Save an image from feed to an album
  Future<RepositoryResult<SavedPost>> saveImageToAlbum({
    required String albumId,
    required String imageUrl,
    String? sourceProfileId,
  });

  /// Remove a saved post from an album
  Future<RepositoryResult<void>> removeSavedPost({required String savedPostId});

  /// Remove a saved post by image URL for a specific wedding
  Future<RepositoryResult<bool>> removeSavedPostByImageUrl({
    required String weddingId,
    required String imageUrl,
  });

  /// Check if an image is already saved in any album for this wedding
  Future<RepositoryResult<bool>> isImageSavedInWedding({
    required String weddingId,
    required String imageUrl,
  });

  /// Get wedding team chat room info
  Future<RepositoryResult<WeddingTeamChatInfo?>> getWeddingTeamChat({
    required String weddingId,
  });

  /// Get active wedding team members (pros with status = 'active')
  Future<RepositoryResult<List<WeddingTeamMember>>> getActiveWeddingTeam({
    required String weddingId,
  });

  /// Update wedding details
  Future<RepositoryResult<void>> updateWedding({
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
  });

  /// Update wedding status (active, cancelled)
  Future<RepositoryResult<void>> updateWeddingStatus({
    required String weddingId,
    required String status,
  });

  // ========== WEDDING EVENTS (AGENDA) ==========

  /// Get all events for a wedding
  Future<RepositoryResult<List<WeddingEvent>>> getWeddingEvents({
    required String weddingId,
  });

  /// Create a new wedding event
  Future<RepositoryResult<WeddingEvent>> createWeddingEvent({
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
  });

  /// Update a wedding event
  Future<RepositoryResult<void>> updateWeddingEvent({
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
  });

  /// Delete a wedding event
  Future<RepositoryResult<void>> deleteWeddingEvent({required String eventId});

  /// Toggle event status (pending <-> done)
  Future<RepositoryResult<void>> toggleEventStatus({
    required String eventId,
    required String currentStatus,
  });

  // ========== WEDDING EXPENSES (BUDGET) ==========

  /// Get all expenses for a wedding
  Future<RepositoryResult<List<WeddingExpense>>> getWeddingExpenses({
    required String weddingId,
  });

  /// Create a new wedding expense
  Future<RepositoryResult<WeddingExpense>> createWeddingExpense({
    required String weddingId,
    required String category,
    required double amount,
    required String currencyCode,
    String? description,
    String? status,
    double? paidAmount,
    DateTime? dueDate,
    String? linkedProId,
  });

  /// Update a wedding expense
  Future<RepositoryResult<void>> updateWeddingExpense({
    required String expenseId,
    String? category,
    String? description,
    double? amount,
    String? currencyCode,
    String? status,
    double? paidAmount,
    DateTime? dueDate,
    String? linkedProId,
  });

  /// Delete a wedding expense
  Future<RepositoryResult<void>> deleteWeddingExpense({required String expenseId});

  // ========== WEDDING GUESTS ==========

  /// Get all guests for a wedding
  Future<RepositoryResult<List<WeddingGuest>>> getWeddingGuests({
    required String weddingId,
  });

  /// Create a new wedding guest
  Future<RepositoryResult<WeddingGuest>> createWeddingGuest({
    required String weddingId,
    required String name,
    String? email,
    String? phone,
    String? role,
    String? notes,
  });

  /// Update a wedding guest
  Future<RepositoryResult<void>> updateWeddingGuest({
    required String guestId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? notes,
  });

  /// Delete a wedding guest
  Future<RepositoryResult<void>> deleteWeddingGuest({required String guestId});
}

/// Contacted professional for invitation
class ContactedPro {
  const ContactedPro({
    required this.profileId,
    required this.displayName,
    this.avatarUrl,
    this.profession,
    this.lastContactDate,
  });

  final String profileId;
  final String displayName;
  final String? avatarUrl;
  final String? profession;
  final DateTime? lastContactDate;

  factory ContactedPro.fromJson(Map<String, dynamic> json) {
    return ContactedPro(
      profileId: json['profile_id'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      profession: json['profession'] as String?,
      lastContactDate: json['last_contact_date'] != null
          ? DateTime.parse(json['last_contact_date'] as String)
          : null,
    );
  }
}

/// Wedding team member
class WeddingTeamMember {
  const WeddingTeamMember({
    required this.profileId,
    required this.displayName,
    this.avatarUrl,
    this.profession,
    required this.status,
    this.joinedAt,
    this.leftAt,
    this.leftReason,
    this.excludedAt,
    this.excludedReason,
    this.isMuted = false,
  });

  final String profileId;
  final String displayName;
  final String? avatarUrl;
  final String? profession;
  final String status; // 'active', 'left', 'excluded'
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final String? leftReason;
  final DateTime? excludedAt;
  final String? excludedReason;
  final bool isMuted;

  bool get isActive => status == 'active';
  bool get hasLeft => status == 'left';
  bool get isExcluded => status == 'excluded';

  factory WeddingTeamMember.fromJson(Map<String, dynamic> json) {
    return WeddingTeamMember(
      profileId: json['professional_profile_id'] as String,
      displayName: json['display_name'] as String? ?? 'Unknown',
      avatarUrl: json['avatar_url'] as String?,
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
  }
}
