/// My Wedding Repository Implementation
///
/// Implements MyWeddingRepository using SupabaseMyWeddingDatasource.
library;

import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../datasources/supabase_my_wedding_datasource.dart';

/// Implementation of MyWeddingRepository
class MyWeddingRepositoryImpl implements MyWeddingRepository {
  MyWeddingRepositoryImpl({
    SupabaseMyWeddingDatasource? datasource,
  }) : _datasource = datasource ?? SupabaseMyWeddingDatasource();

  final SupabaseMyWeddingDatasource _datasource;

  @override
  Future<RepositoryResult<WeddingOverview?>> getMyWedding() async {
    try {
      final wedding = await _datasource.getMyWedding();
      return RepositoryResult.success(wedding);
    } catch (e) {
      return RepositoryResult.failure('Failed to get wedding: $e');
    }
  }

  @override
  Future<RepositoryResult<String>> createWedding({
    required DateTime eventDate,
    required double lat,
    required double lng,
    String? venueName,
    String? venueAddress,
    String? countryCode,
  }) async {
    try {
      final weddingId = await _datasource.createWedding(
        eventDate: eventDate,
        lat: lat,
        lng: lng,
        venueName: venueName,
        venueAddress: venueAddress,
        countryCode: countryCode,
      );
      return RepositoryResult.success(weddingId);
    } catch (e) {
      return RepositoryResult.failure('Failed to create wedding: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> updateOnboardingData({
    required String weddingId,
    required OnboardingData data,
  }) async {
    try {
      await _datasource.updateOnboardingData(
        weddingId: weddingId,
        data: data,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update onboarding data: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> completeOnboarding({
    required String weddingId,
  }) async {
    try {
      await _datasource.completeOnboarding(weddingId: weddingId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to complete onboarding: $e');
    }
  }

  @override
  Future<RepositoryResult<List<ContactedPro>>> getContactedPros() async {
    try {
      final pros = await _datasource.getContactedPros();
      return RepositoryResult.success(pros);
    } catch (e) {
      return RepositoryResult.failure('Failed to get contacted pros: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> inviteProToWedding({
    required String weddingId,
    required String proProfileId,
  }) async {
    try {
      await _datasource.inviteProToWedding(
        weddingId: weddingId,
        proProfileId: proProfileId,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to invite pro: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> excludeProFromWedding({
    required String weddingId,
    required String proProfileId,
    String? reason,
  }) async {
    try {
      await _datasource.excludeProFromWedding(
        weddingId: weddingId,
        proProfileId: proProfileId,
        reason: reason,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to exclude pro: $e');
    }
  }

  @override
  Future<RepositoryResult<List<WeddingTeamMember>>> getWeddingTeam({
    required String weddingId,
  }) async {
    try {
      final team = await _datasource.getWeddingTeam(weddingId: weddingId);
      return RepositoryResult.success(team);
    } catch (e) {
      return RepositoryResult.failure('Failed to get wedding team: $e');
    }
  }

  // ========== INSPIRATION ALBUMS ==========

  @override
  Future<RepositoryResult<List<InspirationAlbum>>> getInspirationAlbums({
    required String weddingId,
  }) async {
    try {
      final albums = await _datasource.getInspirationAlbums(weddingId: weddingId);
      return RepositoryResult.success(albums);
    } catch (e) {
      return RepositoryResult.failure('Failed to get albums: $e');
    }
  }

  @override
  Future<RepositoryResult<InspirationAlbum>> createInspirationAlbum({
    required String weddingId,
    required String name,
    String? category,
    bool isPrivate = false,
  }) async {
    try {
      final album = await _datasource.createInspirationAlbum(
        weddingId: weddingId,
        name: name,
        category: category,
        isPrivate: isPrivate,
      );
      return RepositoryResult.success(album);
    } catch (e) {
      return RepositoryResult.failure('Failed to create album: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> updateInspirationAlbum({
    required String albumId,
    String? name,
    String? category,
    bool? isPrivate,
    String? coverImageUrl,
    int? sortOrder,
  }) async {
    try {
      await _datasource.updateInspirationAlbum(
        albumId: albumId,
        name: name,
        category: category,
        isPrivate: isPrivate,
        coverImageUrl: coverImageUrl,
        sortOrder: sortOrder,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update album: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> deleteInspirationAlbum({required String albumId}) async {
    try {
      await _datasource.deleteInspirationAlbum(albumId: albumId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to delete album: $e');
    }
  }

  // ========== ALBUM IMAGES ==========

  @override
  Future<RepositoryResult<List<AlbumImage>>> getAlbumImages({
    required String albumId,
  }) async {
    try {
      final images = await _datasource.getAlbumImages(albumId: albumId);
      return RepositoryResult.success(images);
    } catch (e) {
      return RepositoryResult.failure('Failed to get album images: $e');
    }
  }

  @override
  Future<RepositoryResult<AlbumImage>> uploadAlbumImage({
    required String albumId,
    required String imageUrl,
    String? thumbnailUrl,
  }) async {
    try {
      final image = await _datasource.uploadAlbumImage(
        albumId: albumId,
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
      );
      return RepositoryResult.success(image);
    } catch (e) {
      return RepositoryResult.failure('Failed to upload image: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> deleteAlbumImage({required String imageId}) async {
    try {
      await _datasource.deleteAlbumImage(imageId: imageId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to delete image: $e');
    }
  }

  // ========== SAVED POSTS ==========

  @override
  Future<RepositoryResult<List<SavedPost>>> getSavedPosts({
    required String albumId,
  }) async {
    try {
      final posts = await _datasource.getSavedPosts(albumId: albumId);
      return RepositoryResult.success(posts);
    } catch (e) {
      return RepositoryResult.failure('Failed to get saved posts: $e');
    }
  }

  @override
  Future<RepositoryResult<SavedPost>> saveImageToAlbum({
    required String albumId,
    required String imageUrl,
    String? sourceProfileId,
  }) async {
    try {
      final savedPost = await _datasource.saveImageToAlbum(
        albumId: albumId,
        imageUrl: imageUrl,
        sourceProfileId: sourceProfileId,
      );
      return RepositoryResult.success(savedPost);
    } catch (e) {
      return RepositoryResult.failure('Failed to save image: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> removeSavedPost({required String savedPostId}) async {
    try {
      await _datasource.removeSavedPost(savedPostId: savedPostId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to remove saved post: $e');
    }
  }

  @override
  Future<RepositoryResult<bool>> removeSavedPostByImageUrl({
    required String weddingId,
    required String imageUrl,
  }) async {
    try {
      final deleted = await _datasource.removeSavedPostByImageUrl(
        weddingId: weddingId,
        imageUrl: imageUrl,
      );
      return RepositoryResult.success(deleted);
    } catch (e) {
      return RepositoryResult.failure('Failed to remove saved post: $e');
    }
  }

  @override
  Future<RepositoryResult<bool>> isImageSavedInWedding({
    required String weddingId,
    required String imageUrl,
  }) async {
    try {
      final isSaved = await _datasource.isImageSavedInWedding(
        weddingId: weddingId,
        imageUrl: imageUrl,
      );
      return RepositoryResult.success(isSaved);
    } catch (e) {
      return RepositoryResult.failure('Failed to check if image is saved: $e');
    }
  }

  @override
  Future<RepositoryResult<WeddingTeamChatInfo?>> getWeddingTeamChat({
    required String weddingId,
  }) async {
    try {
      final chatInfo = await _datasource.getWeddingTeamChat(weddingId: weddingId);
      return RepositoryResult.success(chatInfo);
    } catch (e) {
      return RepositoryResult.failure('Failed to get wedding team chat: $e');
    }
  }

  @override
  Future<RepositoryResult<List<WeddingTeamMember>>> getActiveWeddingTeam({
    required String weddingId,
  }) async {
    try {
      final team = await _datasource.getActiveWeddingTeam(weddingId: weddingId);
      return RepositoryResult.success(team);
    } catch (e) {
      return RepositoryResult.failure('Failed to get active wedding team: $e');
    }
  }

  @override
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
  }) async {
    try {
      await _datasource.updateWedding(
        weddingId: weddingId,
        name: name,
        eventDate: eventDate,
        lat: lat,
        lng: lng,
        venueAddress: venueAddress,
        countryCode: countryCode,
        guestCount: guestCount,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        currency: currency,
        visibility: visibility,
        searchRadiusKm: searchRadiusKm,
        coverImageUrl: coverImageUrl,
        noteForPros: noteForPros,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update wedding: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> updateWeddingStatus({
    required String weddingId,
    required String status,
  }) async {
    try {
      await _datasource.updateWeddingStatus(
        weddingId: weddingId,
        status: status,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update wedding status: $e');
    }
  }

  // ========== WEDDING EVENTS (AGENDA) ==========

  @override
  Future<RepositoryResult<List<WeddingEvent>>> getWeddingEvents({
    required String weddingId,
  }) async {
    try {
      final events = await _datasource.getWeddingEvents(weddingId: weddingId);
      return RepositoryResult.success(events);
    } catch (e) {
      return RepositoryResult.failure('Failed to get events: $e');
    }
  }

  @override
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
  }) async {
    try {
      final event = await _datasource.createWeddingEvent(
        weddingId: weddingId,
        title: title,
        eventDate: eventDate,
        description: description,
        eventEndDate: eventEndDate,
        location: location,
        linkedProId: linkedProId,
        isPublic: isPublic,
        reminder1Week: reminder1Week,
        reminder1Day: reminder1Day,
        reminder1Hour: reminder1Hour,
      );
      return RepositoryResult.success(event);
    } catch (e) {
      return RepositoryResult.failure('Failed to create event: $e');
    }
  }

  @override
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
  }) async {
    try {
      await _datasource.updateWeddingEvent(
        eventId: eventId,
        title: title,
        description: description,
        eventDate: eventDate,
        eventEndDate: eventEndDate,
        location: location,
        linkedProId: linkedProId,
        isPublic: isPublic,
        status: status,
        reminder1Week: reminder1Week,
        reminder1Day: reminder1Day,
        reminder1Hour: reminder1Hour,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update event: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> deleteWeddingEvent({required String eventId}) async {
    try {
      await _datasource.deleteWeddingEvent(eventId: eventId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to delete event: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> toggleEventStatus({
    required String eventId,
    required String currentStatus,
  }) async {
    try {
      await _datasource.toggleEventStatus(
        eventId: eventId,
        currentStatus: currentStatus,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to toggle event status: $e');
    }
  }

  // ========== WEDDING EXPENSES (BUDGET) ==========

  @override
  Future<RepositoryResult<List<WeddingExpense>>> getWeddingExpenses({
    required String weddingId,
  }) async {
    try {
      final expenses = await _datasource.getWeddingExpenses(weddingId: weddingId);
      return RepositoryResult.success(expenses);
    } catch (e) {
      return RepositoryResult.failure('Failed to get expenses: $e');
    }
  }

  @override
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
  }) async {
    try {
      final expense = await _datasource.createWeddingExpense(
        weddingId: weddingId,
        category: category,
        amount: amount,
        currencyCode: currencyCode,
        description: description,
        status: status,
        paidAmount: paidAmount,
        dueDate: dueDate,
        linkedProId: linkedProId,
      );
      return RepositoryResult.success(expense);
    } catch (e) {
      return RepositoryResult.failure('Failed to create expense: $e');
    }
  }

  @override
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
  }) async {
    try {
      await _datasource.updateWeddingExpense(
        expenseId: expenseId,
        category: category,
        description: description,
        amount: amount,
        currencyCode: currencyCode,
        status: status,
        paidAmount: paidAmount,
        dueDate: dueDate,
        linkedProId: linkedProId,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update expense: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> deleteWeddingExpense({required String expenseId}) async {
    try {
      await _datasource.deleteWeddingExpense(expenseId: expenseId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to delete expense: $e');
    }
  }

  // ========== WEDDING GUESTS ==========

  @override
  Future<RepositoryResult<List<WeddingGuest>>> getWeddingGuests({
    required String weddingId,
  }) async {
    try {
      final guests = await _datasource.getWeddingGuests(weddingId: weddingId);
      return RepositoryResult.success(guests);
    } catch (e) {
      return RepositoryResult.failure('Failed to get guests: $e');
    }
  }

  @override
  Future<RepositoryResult<WeddingGuest>> createWeddingGuest({
    required String weddingId,
    required String name,
    String? email,
    String? phone,
    String? role,
    String? notes,
  }) async {
    try {
      final guest = await _datasource.createWeddingGuest(
        weddingId: weddingId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        notes: notes,
      );
      return RepositoryResult.success(guest);
    } catch (e) {
      return RepositoryResult.failure('Failed to create guest: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> updateWeddingGuest({
    required String guestId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? notes,
  }) async {
    try {
      await _datasource.updateWeddingGuest(
        guestId: guestId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        notes: notes,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update guest: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> deleteWeddingGuest({required String guestId}) async {
    try {
      await _datasource.deleteWeddingGuest(guestId: guestId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to delete guest: $e');
    }
  }

  // ========== WEDDING GROUPS ==========

  @override
  Future<RepositoryResult<List<WeddingGroup>>> getWeddingGroups({
    required String weddingId,
  }) async {
    try {
      final groups = await _datasource.getWeddingGroups(weddingId: weddingId);
      return RepositoryResult.success(groups);
    } catch (e) {
      return RepositoryResult.failure('Failed to get wedding groups: $e');
    }
  }

  @override
  Future<RepositoryResult<String>> createWeddingGroup({
    required String weddingId,
    required String name,
    required bool isPublic,
    List<String>? memberProfileIds,
  }) async {
    try {
      final roomId = await _datasource.createWeddingGroup(
        weddingId: weddingId,
        name: name,
        isPublic: isPublic,
        memberProfileIds: memberProfileIds,
      );
      return RepositoryResult.success(roomId);
    } catch (e) {
      return RepositoryResult.failure('Failed to create wedding group: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> updateWeddingGroup({
    required String roomId,
    String? name,
    bool? isPublic,
  }) async {
    try {
      await _datasource.updateWeddingGroup(
        roomId: roomId,
        name: name,
        isPublic: isPublic,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to update wedding group: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> deleteWeddingGroup({required String roomId}) async {
    try {
      await _datasource.deleteWeddingGroup(roomId: roomId);
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to delete wedding group: $e');
    }
  }

  @override
  Future<RepositoryResult<List<GroupMember>>> getWeddingGroupMembers({
    required String roomId,
  }) async {
    try {
      final members = await _datasource.getWeddingGroupMembers(roomId: roomId);
      return RepositoryResult.success(members);
    } catch (e) {
      return RepositoryResult.failure('Failed to get group members: $e');
    }
  }

  @override
  Future<RepositoryResult<List<EligibleGroupMember>>> getEligibleGroupMembers({
    required String weddingId,
  }) async {
    try {
      final members = await _datasource.getEligibleGroupMembers(weddingId: weddingId);
      return RepositoryResult.success(members);
    } catch (e) {
      return RepositoryResult.failure('Failed to get eligible members: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> addGroupMembers({
    required String roomId,
    required List<String> profileIds,
  }) async {
    try {
      await _datasource.manageWeddingGroupMembers(
        roomId: roomId,
        addProfileIds: profileIds,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to add group members: $e');
    }
  }

  @override
  Future<RepositoryResult<void>> removeGroupMembers({
    required String roomId,
    required List<String> profileIds,
  }) async {
    try {
      await _datasource.manageWeddingGroupMembers(
        roomId: roomId,
        removeProfileIds: profileIds,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to remove group members: $e');
    }
  }

  @override
  Future<RepositoryResult<int>> sendBulkInvitations({
    required String weddingId,
  }) async {
    try {
      final count = await _datasource.sendBulkInvitations(weddingId: weddingId);
      return RepositoryResult.success(count);
    } catch (e) {
      return RepositoryResult.failure('Failed to send bulk invitations: $e');
    }
  }
}
