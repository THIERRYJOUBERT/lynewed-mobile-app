// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import '/auth/supabase_auth/auth_util.dart';
import '/core/di/injection_container.dart';
import '/features/auth/auth.dart';

/// Uploads an avatar image from a local file path.
///
/// @Deprecated: Use AuthRepository.uploadAvatar() from the Clean Architecture
/// auth module instead. This function is kept for legacy FlutterFlow pages.
///
/// Note: The Clean Architecture version takes Uint8List bytes directly,
/// while this legacy version takes a file path.
///
/// Migration path:
/// ```dart
/// // Old (deprecated):
/// final url = await uploadAvatar(localPath);
///
/// // New (recommended):
/// final file = File(localPath);
/// final bytes = await file.readAsBytes();
/// final fileName = localPath.split('/').last;
/// final authRepository = sl<AuthRepository>();
/// final result = await authRepository.uploadAvatar(bytes, fileName);
/// final url = result.getOrNull();
/// ```
@Deprecated('Use AuthRepository.uploadAvatar() instead. See auth module.')
Future<String?> uploadAvatar(String localPath) async {
  if (currentUserUid.isEmpty || localPath.isEmpty) {
    return null;
  }

  try {
    final file = File(localPath);
    final fileBytes = await file.readAsBytes();
    final fileName = localPath.split('/').last;

    final authRepository = sl<AuthRepository>();
    final result = await authRepository.uploadAvatar(fileBytes, fileName);

    return result.getOrNull();
  } catch (e) {
    return null;
  }
}
