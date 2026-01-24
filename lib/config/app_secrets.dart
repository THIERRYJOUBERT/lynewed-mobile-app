/// Secure secrets configuration using compile-time constants.
///
/// All secrets are loaded via --dart-define-from-file at build time.
/// This approach ensures:
/// - Secrets are not in source code or git history
/// - Secrets are compile-time constants (tree-shaken if unused)
/// - No runtime file loading (.env as asset is removed)
///
/// Usage:
/// ```bash
/// flutter build ios --dart-define-from-file=secrets.json
/// flutter build apk --dart-define-from-file=secrets.json
/// flutter run --dart-define-from-file=secrets.json
/// ```
abstract class AppSecrets {
  AppSecrets._();

  // Supabase
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // Google Places API (platform-specific for bundle ID restrictions)
  static const String googlePlacesApiKeyIos =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY_IOS');
  static const String googlePlacesApiKeyAndroid =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY_ANDROID');

  // Agora Video
  static const String agoraAppId =
      String.fromEnvironment('AGORA_APP_ID');

  // Firebase (platform-specific)
  static const String firebaseApiKeyIos =
      String.fromEnvironment('FIREBASE_API_KEY_IOS');
  static const String firebaseApiKeyAndroid =
      String.fromEnvironment('FIREBASE_API_KEY_ANDROID');

  /// Returns true if all required secrets are configured.
  /// In production builds with --dart-define-from-file, this should be true.
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        agoraAppId.isNotEmpty;
  }

  /// Returns list of missing secret names for debugging.
  /// Useful for showing setup errors to developers.
  static List<String> get missingSecrets {
    final missing = <String>[];
    if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
    if (googlePlacesApiKeyIos.isEmpty) missing.add('GOOGLE_PLACES_API_KEY_IOS');
    if (googlePlacesApiKeyAndroid.isEmpty) {
      missing.add('GOOGLE_PLACES_API_KEY_ANDROID');
    }
    if (agoraAppId.isEmpty) missing.add('AGORA_APP_ID');
    if (firebaseApiKeyIos.isEmpty) missing.add('FIREBASE_API_KEY_IOS');
    if (firebaseApiKeyAndroid.isEmpty) missing.add('FIREBASE_API_KEY_ANDROID');
    return missing;
  }
}
