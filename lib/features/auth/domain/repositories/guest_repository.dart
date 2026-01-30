/// Guest repository interface for Clean Architecture.
///
/// Defines the contract for guest-specific operations.
/// Implementation will be in the data layer.
library;

import '../../../../core/core.dart';
import '../entities/entities.dart';

/// Result of joining a wedding as guest.
class JoinWeddingResult {
  /// Wedding ID the guest joined.
  final String weddingId;

  /// Name of the bride.
  final String brideName;

  /// Chat room ID for wedding team (may be null if not created).
  final String? chatRoomId;

  /// Guest entry ID in wedding_guests table.
  final String guestId;

  /// Creates a join wedding result.
  const JoinWeddingResult({
    required this.weddingId,
    required this.brideName,
    this.chatRoomId,
    required this.guestId,
  });
}

/// Repository interface for guest operations.
///
/// This is the contract that the data layer must implement.
/// All methods use [Result] for explicit error handling.
abstract class GuestRepository {
  /// Creates a new guest account and joins the wedding.
  ///
  /// This is a two-step process:
  /// 1. Create Supabase auth account with role='guest'
  /// 2. Call join_wedding_as_guest RPC to link to wedding
  ///
  /// Returns [AuthUser] on success, [Failure] on error.
  Future<Result<AuthUser>> signUpGuest({
    required String email,
    required String password,
    required String firstName,
    required String inviteCode,
  });

  /// Signs in with OAuth (Apple/Google) and joins wedding.
  ///
  /// For users who prefer social login.
  /// Returns [AuthUser] on success, [Failure] on error.
  Future<Result<AuthUser>> signInWithOAuthAndJoinWedding({
    required String inviteCode,
  });

  /// Joins an existing user to a wedding as guest.
  ///
  /// Called after user is authenticated.
  /// Returns [JoinWeddingResult] on success.
  Future<Result<JoinWeddingResult>> joinWedding({
    required String userId,
    required String inviteCode,
  });

  /// Gets the wedding info for a guest user.
  ///
  /// Returns null if user is not a guest or not linked to a wedding.
  Future<Result<JoinWeddingResult?>> getGuestWeddingInfo(String userId);
}
