import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class FFAppConstants {
  static String get googlePlacesApiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  static const String tosVersion = 'v1.0.0';
  static const String privacyVersion = 'v1.0.0';
  static String get agoraAppId => dotenv.env['AGORA_APP_ID'] ?? '';
}
