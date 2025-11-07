// ✅ ROBUSTNESS: Network retry logic for critical operations
import 'dart:async';
import 'package:flutter/foundation.dart';

class NetworkHelper {
  /// Retry a network operation with exponential backoff
  /// 
  /// Example usage:
  /// ```dart
  /// final result = await NetworkHelper.retryOperation(
  ///   () => supabase.from('profiles').select(),
  ///   maxAttempts: 3,
  ///   context: 'fetch_profiles',
  /// );
  /// ```
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    required String context,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration currentDelay = initialDelay;

    while (true) {
      attempt++;
      
      try {
        debugPrint('🔄 [$context] Attempt $attempt/$maxAttempts');
        final result = await operation();
        
        if (attempt > 1) {
          debugPrint('✅ [$context] Succeeded on attempt $attempt');
        }
        
        return result;
      } catch (error) {
        final isLastAttempt = attempt >= maxAttempts;
        final shouldRetryError = shouldRetry?.call(error) ?? _defaultShouldRetry(error);
        
        if (isLastAttempt || !shouldRetryError) {
          debugPrint('❌ [$context] Failed after $attempt attempts: $error');
          rethrow;
        }
        
        debugPrint('⚠️ [$context] Attempt $attempt failed, retrying in ${currentDelay.inSeconds}s: $error');
        
        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }
  }

  /// Default retry logic: retry on network errors, not on validation errors
  static bool _defaultShouldRetry(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Don't retry on client errors (4xx)
    if (errorString.contains('400') ||
        errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('404') ||
        errorString.contains('validation')) {
      return false;
    }
    
    // Retry on network errors and server errors (5xx)
    if (errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return true;
    }
    
    // Default: retry
    return true;
  }

  /// Retry with timeout
  static Future<T> retryWithTimeout<T>(
    Future<T> Function() operation, {
    required Duration timeout,
    int maxAttempts = 3,
    required String context,
  }) async {
    return retryOperation(
      () => operation().timeout(
        timeout,
        onTimeout: () => throw TimeoutException(
          '[$context] Operation timed out after ${timeout.inSeconds}s',
        ),
      ),
      maxAttempts: maxAttempts,
      context: context,
    );
  }
}
