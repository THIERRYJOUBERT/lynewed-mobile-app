import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'config/app_secrets.dart';

abstract class FFAppConstants {
  /// Platform-specific Google Places API key.
  /// Uses separate keys for iOS/Android with bundle ID restrictions.
  static String get googlePlacesApiKey {
    String key;
    if (Platform.isIOS) {
      key = AppSecrets.googlePlacesApiKeyIos;
      if (key.isEmpty && kDebugMode) {
        debugPrint('[FFAppConstants] WARNING: GOOGLE_PLACES_API_KEY_IOS is empty');
      }
    } else if (Platform.isAndroid) {
      key = AppSecrets.googlePlacesApiKeyAndroid;
      if (key.isEmpty && kDebugMode) {
        debugPrint('[FFAppConstants] WARNING: GOOGLE_PLACES_API_KEY_ANDROID is empty');
      }
    } else {
      // Fallback for web or other platforms - use iOS key
      key = AppSecrets.googlePlacesApiKeyIos;
      if (key.isEmpty && kDebugMode) {
        debugPrint('[FFAppConstants] WARNING: GOOGLE_PLACES_API_KEY is empty');
      }
    }
    return key;
  }

  static const String tosVersion = 'v1.0.0';
  static const String privacyVersion = 'v1.0.0';

  /// Agora App ID for video calls.
  static String get agoraAppId {
    const appId = AppSecrets.agoraAppId;
    if (appId.isEmpty && kDebugMode) {
      debugPrint('[FFAppConstants] WARNING: AGORA_APP_ID is empty');
    }
    return appId;
  }
}
