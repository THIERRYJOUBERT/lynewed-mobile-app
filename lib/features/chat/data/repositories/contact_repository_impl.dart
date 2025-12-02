/// Contact repository implementation - Clean Architecture
/// 
/// Implements ContactRepository using ChatRemoteDatasource.
library;

import '../../domain/entities/entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/chat_remote_datasource.dart';

/// Implementation of ContactRepository
class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl({ChatRemoteDatasource? datasource})
      : _datasource = datasource ?? ChatRemoteDatasource();

  final ChatRemoteDatasource _datasource;

  // ============================================================
  // CONTACT CONTEXT
  // ============================================================

  @override
  Future<ChatResult<ChatEntryContext>> prepareContactContext(String targetProfileId) async {
    try {
      final context = await _datasource.prepareContactContext(targetProfileId);
      return ChatResult.success(context);
    } catch (e) {
      return ChatResult.failure('Failed to prepare contact context: $e');
    }
  }

  // ============================================================
  // CONTACT REQUESTS
  // ============================================================

  @override
  Future<ChatResult<String>> createContactRequest({
    required String targetId,
    required ContactRequestSource source,
    required String message,
  }) async {
    try {
      final requestId = await _datasource.createContactRequest(
        targetId: targetId,
        source: source,
        message: message,
      );
      return ChatResult.success(requestId);
    } catch (e) {
      return ChatResult.failure('Failed to create contact request: $e');
    }
  }

  @override
  Future<ChatResult<List<ContactRequest>>> getPendingContactRequests() async {
    try {
      final requests = await _datasource.getPendingContactRequests();
      return ChatResult.success(requests);
    } catch (e) {
      return ChatResult.failure('Failed to load contact requests: $e');
    }
  }

  @override
  Future<ChatResult<String>> acceptContactRequest(String requestId) async {
    try {
      final roomId = await _datasource.acceptContactRequest(requestId);
      return ChatResult.success(roomId);
    } catch (e) {
      return ChatResult.failure('Failed to accept contact request: $e');
    }
  }

  @override
  Future<ChatResult<void>> declineContactRequest(String requestId) async {
    try {
      await _datasource.declineContactRequest(requestId);
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to decline contact request: $e');
    }
  }

  @override
  Stream<ContactRequest> subscribeToContactRequests() {
    return _datasource.subscribeToContactRequests();
  }

  // ============================================================
  // BLOCKING
  // ============================================================

  @override
  Future<ChatResult<void>> blockUser(String profileId) async {
    try {
      await _datasource.blockUser(profileId);
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to block user: $e');
    }
  }

  @override
  Future<ChatResult<void>> unblockUser(String profileId) async {
    try {
      await _datasource.unblockUser(profileId);
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to unblock user: $e');
    }
  }

  @override
  Future<ChatResult<List<BlockedUser>>> getBlockedUsers() async {
    try {
      final users = await _datasource.getBlockedUsers();
      return ChatResult.success(users);
    } catch (e) {
      return ChatResult.failure('Failed to load blocked users: $e');
    }
  }

  @override
  Future<ChatResult<bool>> isUserBlocked(String profileId) async {
    try {
      final isBlocked = await _datasource.isUserBlocked(profileId);
      return ChatResult.success(isBlocked);
    } catch (e) {
      return ChatResult.failure('Failed to check block status: $e');
    }
  }

  // ============================================================
  // REPORTING
  // ============================================================

  @override
  Future<ChatResult<void>> reportMessage({
    required int messageId,
    required ReportReason reason,
    String? details,
  }) async {
    try {
      await _datasource.reportMessage(
        messageId: messageId,
        reason: reason,
        details: details,
      );
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to report message: $e');
    }
  }

  @override
  Future<ChatResult<void>> reportUser({
    required String reportedProfileId,
    required ReportReason reason,
    String? details,
  }) async {
    try {
      await _datasource.reportUser(
        reportedProfileId: reportedProfileId,
        reason: reason,
        details: details,
      );
      return const ChatResult.success(null);
    } catch (e) {
      return ChatResult.failure('Failed to report user: $e');
    }
  }
}
