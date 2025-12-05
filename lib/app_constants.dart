import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

abstract class FFAppConstants {
  // ✅ PLATFORM-SPECIFIC: Use separate keys for iOS/Android with bundle ID restrictions
  static String get googlePlacesApiKey {
    String key;
    if (Platform.isIOS) {
      key = dotenv.env['GOOGLE_PLACES_API_KEY_IOS'] ?? '';
      if (key.isEmpty && kDebugMode) {
      }
    } else if (Platform.isAndroid) {
      key = dotenv.env['GOOGLE_PLACES_API_KEY_ANDROID'] ?? '';
      if (key.isEmpty && kDebugMode) {
      }
    } else {
      // Fallback for web or other platforms
      key = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
      if (key.isEmpty && kDebugMode) {
      }
    }
    return key;
  }
  
  static const String tosVersion = 'v1.0.0';
  static const String privacyVersion = 'v1.0.0';
  
  static String get agoraAppId {
    final appId = dotenv.env['AGORA_APP_ID'] ?? '';
    if (appId.isEmpty && kDebugMode) {
    }
    return appId;
  }
}
