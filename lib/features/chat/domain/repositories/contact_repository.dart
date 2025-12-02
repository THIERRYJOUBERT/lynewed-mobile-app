/// Contact repository interface - Clean Architecture
/// 
/// Defines the contract for contact/connection request operations.
library;

import '../entities/entities.dart';
import 'chat_repository.dart';

/// Contact repository interface
abstract class ContactRepository {
  // ============================================================
  // CONTACT CONTEXT
  // ============================================================

  /// Prepare contact context (check if can contact, get room, etc.)
  Future<ChatResult<ChatEntryContext>> prepareContactContext(String targetProfileId);

  // ============================================================
  // CONTACT REQUESTS (Pro → Bride)
  // ============================================================

  /// Create a contact request (Pro → Bride)
  /// Returns the request ID on success
  Future<ChatResult<String>> createContactRequest({
    required String targetId,
    required ContactRequestSource source,
    required String message,
  });

  /// Get pending contact requests for current user (as Bride)
  Future<ChatResult<List<ContactRequest>>> getPendingContactRequests();

  /// Accept a contact request (as Bride)
  /// Returns the room ID on success
  Future<ChatResult<String>> acceptContactRequest(String requestId);

  /// Decline a contact request (as Bride)
  Future<ChatResult<void>> declineContactRequest(String requestId);

  // ============================================================
  // BLOCKING
  // ============================================================

  /// Block a user
  Future<ChatResult<void>> blockUser(String profileId);

  /// Unblock a user
  Future<ChatResult<void>> unblockUser(String profileId);

  /// Get list of blocked users
  Future<ChatResult<List<BlockedUser>>> getBlockedUsers();

  /// Check if a user is blocked
  Future<ChatResult<bool>> isUserBlocked(String profileId);

  // ============================================================
  // REPORTING
  // ============================================================

  /// Report a message
  Future<ChatResult<void>> reportMessage({
    required int messageId,
    required ReportReason reason,
    String? details,
  });
}
