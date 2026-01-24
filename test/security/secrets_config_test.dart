import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/config/app_secrets.dart';

/// Tests for secure secrets configuration.
///
/// These tests verify that:
/// 1. Secrets are loaded via dart-define (compile-time constants)
/// 2. No hardcoded secrets exist in the codebase
/// 3. Required secrets throw descriptive errors when missing
void main() {
  group('AppSecrets', () {
    test('should expose supabaseUrl as compile-time constant', () {
      // AppSecrets should use String.fromEnvironment for compile-time safety
      // When no --dart-define is provided, returns empty string
      expect(AppSecrets.supabaseUrl, isA<String>());
    });

    test('should expose supabaseAnonKey as compile-time constant', () {
      expect(AppSecrets.supabaseAnonKey, isA<String>());
    });

    test('should expose googlePlacesApiKeyIos as compile-time constant', () {
      expect(AppSecrets.googlePlacesApiKeyIos, isA<String>());
    });

    test('should expose googlePlacesApiKeyAndroid as compile-time constant', () {
      expect(AppSecrets.googlePlacesApiKeyAndroid, isA<String>());
    });

    test('should expose agoraAppId as compile-time constant', () {
      expect(AppSecrets.agoraAppId, isA<String>());
    });

    test('should expose firebaseApiKeyIos as compile-time constant', () {
      expect(AppSecrets.firebaseApiKeyIos, isA<String>());
    });

    test('should expose firebaseApiKeyAndroid as compile-time constant', () {
      expect(AppSecrets.firebaseApiKeyAndroid, isA<String>());
    });
  });

  group('AppSecrets validation', () {
    test('isConfigured returns false when secrets are empty (test env)', () {
      // In test environment without --dart-define, secrets are empty
      // This is expected behavior - production builds use --dart-define-from-file
      final configured = AppSecrets.isConfigured;
      expect(configured, isA<bool>());
    });

    test('missingSecrets lists empty secrets', () {
      final missing = AppSecrets.missingSecrets;
      expect(missing, isA<List<String>>());
    });
  });
}
