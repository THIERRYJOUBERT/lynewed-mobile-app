// ✅ ROBUSTNESS: Centralized error handling utility
import 'package:flutter/foundation.dart';

class ErrorHandler {
  /// Log error with context for debugging
  /// Only logs in debug mode to prevent production data exposure
  static void logError(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    if (!kDebugMode) return;
    
    debugPrint('❌ [$context] Error: $error');
    
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    
    if (additionalData != null && additionalData.isNotEmpty) {
      debugPrint('Additional data: $additionalData');
    }
    
    // TODO: Send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// Handle async operations with error catching
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    required String context,
    T? fallbackValue,
    Function(dynamic error)? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(context, error, stackTrace: stackTrace);
      onError?.call(error);
      return fallbackValue;
    }
  }

  /// Validate required environment variables
  static String requireEnv(String key, {String? defaultValue}) {
    final value = defaultValue;
    if (value == null || value.isEmpty) {
      throw StateError(
        '❌ CONFIGURATION ERROR: Required environment variable "$key" is missing or empty. '
        'Please check your .env file.',
      );
    }
    return value;
  }

  /// Validate API response
  static bool isValidResponse(dynamic response) {
    if (response == null) return false;
    if (response is Map && response.containsKey('error')) return false;
    return true;
  }
}
