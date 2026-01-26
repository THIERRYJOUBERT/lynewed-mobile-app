// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/core/di/injection_container.dart';
import '/features/auth/auth.dart';

/// Inserts a legal acceptance record for the current user.
///
/// @Deprecated: Use AuthRepository.acceptTerms() from the Clean Architecture
/// auth module instead. This function is kept for legacy FlutterFlow pages.
///
/// Migration path:
/// ```dart
/// // Old (deprecated):
/// final success = await insertLegalAcceptance();
///
/// // New (recommended):
/// final authRepository = sl<AuthRepository>();
/// final result = await authRepository.acceptTerms();
/// final success = result.isSuccess;
/// ```
@Deprecated('Use AuthRepository.acceptTerms() instead. See auth module.')
Future<bool> insertLegalAcceptance() async {
  try {
    final authRepository = sl<AuthRepository>();
    final result = await authRepository.acceptTerms();
    return result.isSuccess;
  } catch (e) {
    return false;
  }
}
