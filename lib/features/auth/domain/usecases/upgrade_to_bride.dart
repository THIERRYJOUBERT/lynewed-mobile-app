/// Use case for upgrading a guest account to a bride account.
///
/// This action is irreversible. The user will gain access to:
/// - Wedding creation
/// - Professional search
/// - Full planning features
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/core.dart';

/// Failure type for upgrade errors.
class UpgradeFailure extends AppFailure {
  const UpgradeFailure({
    required String message,
  }) : super(message);
}

/// Result type for upgrade operation.
sealed class UpgradeToBrideResult {
  const UpgradeToBrideResult();
}

/// Upgrade was successful.
class UpgradeSuccessful extends UpgradeToBrideResult {
  const UpgradeSuccessful();
}

/// User is not a guest (cannot upgrade).
class NotAGuest extends UpgradeToBrideResult {
  const NotAGuest();
}

/// Upgrade failed with error.
class UpgradeError extends UpgradeToBrideResult {
  const UpgradeError(this.message);
  final String message;
}

/// Use case for upgrading a guest to a bride.
///
/// Calls the `upgrade_guest_to_bride` RPC function which:
/// - Verifies the user is currently a guest
/// - Updates the role to 'bride'
class UpgradeToBride {
  UpgradeToBride({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Upgrades the specified user from guest to bride.
  ///
  /// Returns [UpgradeSuccessful] if the upgrade was successful,
  /// [NotAGuest] if the user is not a guest,
  /// or [UpgradeError] if an error occurred.
  Future<UpgradeToBrideResult> call(String userId) async {
    try {
      final response = await _supabase.rpc(
        'upgrade_guest_to_bride',
        params: {'p_user_id': userId},
      );

      if (response == true) {
        return const UpgradeSuccessful();
      }

      return const UpgradeError('Une erreur est survenue');
    } on PostgrestException catch (e) {
      if (e.message.contains('not a guest')) {
        return const NotAGuest();
      }
      return UpgradeError(e.message);
    } catch (e) {
      return const UpgradeError('Une erreur est survenue. Réessayez.');
    }
  }
}
