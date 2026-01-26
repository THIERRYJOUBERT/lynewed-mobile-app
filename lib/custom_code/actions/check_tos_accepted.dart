// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/core/di/injection_container.dart';
import '/features/auth/auth.dart';

/// Checks if the current user has accepted the terms of service.
///
/// @Deprecated: Use AuthRepository.hasAcceptedTerms() from the Clean Architecture
/// auth module instead. This function is kept for legacy FlutterFlow pages.
///
/// Migration path:
/// ```dart
/// // Old (deprecated):
/// final accepted = await checkTosAccepted();
///
/// // New (recommended):
/// final authRepository = sl<AuthRepository>();
/// final result = await authRepository.hasAcceptedTerms();
/// final accepted = result.getOrNull() ?? false;
/// ```
@Deprecated('Use AuthRepository.hasAcceptedTerms() instead. See auth module.')
Future<bool> checkTosAccepted() async {
  try {
    final authRepository = sl<AuthRepository>();
    final result = await authRepository.hasAcceptedTerms();
    return result.getOrNull() ?? false;
  } catch (e) {
    return false;
  }
}
