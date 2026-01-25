import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

abstract class FFAppConstants {
  /// Platform-specific Google Places API key.
  /// Uses separate keys for iOS/Android with bundle ID restrictions.
  static String get googlePlacesApiKey {
    String key;
    if (Platform.isIOS) {
      key = dotenv.env['GOOGLE_PLACES_API_KEY_IOS'] ?? '';
      if (key.isEmpty && kDebugMode) {
        debugPrint('[FFAppConstants] WARNING: GOOGLE_PLACES_API_KEY_IOS is empty');
      }
    } else if (Platform.isAndroid) {
      key = dotenv.env['GOOGLE_PLACES_API_KEY_ANDROID'] ?? '';
      if (key.isEmpty && kDebugMode) {
        debugPrint('[FFAppConstants] WARNING: GOOGLE_PLACES_API_KEY_ANDROID is empty');
      }
    } else {
      // Fallback for web or other platforms
      key = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
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
    final appId = dotenv.env['AGORA_APP_ID'] ?? '';
    if (appId.isEmpty && kDebugMode) {
      debugPrint('[FFAppConstants] WARNING: AGORA_APP_ID is empty');
    }
    return appId;
  }
}
