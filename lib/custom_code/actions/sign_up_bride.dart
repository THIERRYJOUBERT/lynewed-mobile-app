// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/core/di/injection_container.dart';
import '/features/auth/auth.dart';

/// Signs up a new bride user with email and password.
///
/// @Deprecated: Use AuthRepository.signUpBride() from the Clean Architecture
/// auth module instead. This function is kept for legacy FlutterFlow pages.
///
/// The Clean Architecture version automatically handles terms acceptance.
///
/// Migration path:
/// ```dart
/// // Old (deprecated):
/// final success = await signUpBride(email, password);
///
/// // New (recommended):
/// final authRepository = sl<AuthRepository>();
/// final result = await authRepository.signUpBride(
///   email: email,
///   password: password,
/// );
/// final success = result.isSuccess;
/// ```
@Deprecated('Use AuthRepository.signUpBride() instead. See auth module.')
Future<bool> signUpBride(
  String email,
  String password,
) async {
  if (email.isEmpty || password.isEmpty) {
    return false;
  }

  try {
    final authRepository = sl<AuthRepository>();
    final result = await authRepository.signUpBride(
      email: email,
      password: password,
    );
    return result.isSuccess;
  } catch (e) {
    return false;
  }
}
