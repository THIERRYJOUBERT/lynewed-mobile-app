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

  @override
  Future<RepositoryResult<void>> savePostToAlbum({
    required String albumId,
    required String postId,
  }) async {
    try {
      await _datasource.savePostToAlbum(
        albumId: albumId,
        postId: postId,
      );
      return const RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure('Failed to save post: $e');
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
}
