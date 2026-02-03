/// Accept CGVU Use Case.
///
/// Handles logging CGVU acceptance to the database for audit purposes.
/// Used for magazine purchases and other features requiring explicit consent.
library;

import '/backend/supabase/supabase.dart';

/// Use case for recording CGVU acceptance.
///
/// Logs the acceptance to `cgvu_acceptances` table for legal audit trail.
class AcceptCgvuUseCase {
  /// Creates the use case.
  const AcceptCgvuUseCase();

  /// Records CGVU acceptance for the current user.
  ///
  /// Parameters:
  /// - [cgvuType]: Type of CGVU (e.g., 'magazine_purchase').
  /// - [cgvuVersion]: Version of the CGVU text accepted.
  /// - [deviceInfo]: Optional device information for audit.
  ///
  /// Returns [AcceptCgvuResult.success] if logged successfully,
  /// or [AcceptCgvuResult.failure] with an error message.
  Future<AcceptCgvuResult> call({
    required String cgvuType,
    required String cgvuVersion,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId == null) {
        return const AcceptCgvuResult.failure('User not authenticated');
      }

      await SupaFlow.client.from('cgvu_acceptances').insert({
        'user_id': userId,
        'cgvu_type': cgvuType,
        'cgvu_version': cgvuVersion,
        if (deviceInfo != null) 'device_info': deviceInfo,
      });

      return const AcceptCgvuResult.success();
    } catch (e) {
      return AcceptCgvuResult.failure('Failed to log acceptance: $e');
    }
  }

  /// Checks if user has already accepted a specific CGVU type and version.
  ///
  /// Useful for skipping the dialog if user has already accepted.
  Future<bool> hasAccepted({
    required String cgvuType,
    required String cgvuVersion,
  }) async {
    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId == null) return false;

      final result = await SupaFlow.client
          .from('cgvu_acceptances')
          .select('id')
          .eq('user_id', userId)
          .eq('cgvu_type', cgvuType)
          .eq('cgvu_version', cgvuVersion)
          .limit(1);

      return (result as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

/// Result of CGVU acceptance operation.
class AcceptCgvuResult {
  const AcceptCgvuResult.success() : error = null;
  const AcceptCgvuResult.failure(this.error);

  /// Error message if failed.
  final String? error;

  /// Returns true if the operation was successful.
  bool get isSuccess => error == null;

  /// Returns true if the operation failed.
  bool get isFailure => error != null;
}
