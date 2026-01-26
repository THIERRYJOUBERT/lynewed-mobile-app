// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/core/di/injection_container.dart';
import '/features/auth/auth.dart';

/// Calls the account deletion edge function.
///
/// @Deprecated: Use AuthRepository.deleteAccount() from the Clean Architecture
/// auth module instead. This function is kept for legacy FlutterFlow pages.
///
/// Migration path:
/// ```dart
/// // Old (deprecated):
/// final success = await callDeleteAccountEdgeFunction();
///
/// // New (recommended):
/// final authRepository = sl<AuthRepository>();
/// final result = await authRepository.deleteAccount();
/// final success = result.isSuccess;
/// ```
@Deprecated('Use AuthRepository.deleteAccount() instead. See auth module.')
Future<bool> callDeleteAccountEdgeFunction() async {
  try {
    final authRepository = sl<AuthRepository>();
    final result = await authRepository.deleteAccount();
    return result.isSuccess;
  } catch (e) {
    return false;
  }
}
